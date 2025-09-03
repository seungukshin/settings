local AeroSpace = {
  name = 'AeroSpace',
  version = '1.0',
  author = 'Seunguk Shin <seunguk.shin@gmail.com>',
  license = 'MIT - https://opensource.org/licenses/MIT',

  -- configuration
  aerospace = '/opt/homebrew/bin/aerospace',
  size_icon = 24,
  pad_app = 0,
  pad_space = 4,
  notch_display = 1, -- index in aerospace, 0 to ignore
  places = {}, -- place table - places[app bundle id] = workspace id
  monitors = {}, -- monitor table - monitors[monitor id] = workspace id
  hide_windows = {},

  -- internal data
  log = hs.logger.new('AeroSpace', 'info'),
}

function AeroSpace:dump()
  self.log.i('focused workspace:', self.focused_workspace)
  self.log.i('windows:')
  for k, v in pairs(self.workspaces_windows) do
    self.log.i(' ', k, ':')
    for k, v in pairs(v) do
      self.log.i('   ', k, ':', v)
    end
  end
  self.log.i('monitors:')
  for k, v in pairs(self.workspaces_monitor) do
    self.log.i(' ', k, ':', v)
  end
end

function AeroSpace:workspaceChanged(focused, previous)
  self.log.d('workspaceChanged', focused, previous)
  if self:updateFocus(focused, previous) then
    --self:updateWorkspaces({focused, previous})
    self:sync()
  end
end

-- add place table item
-- bid: app bundle id
-- sid: workspace id
-- return: none
function AeroSpace:addPlaceForApp(bid, sid)
  if bid == nil then return end
  self.places[bid] = sid
end

-- add monitor table item
-- mid: monitor bundle id
-- sid: workspace id
-- return: none
function AeroSpace:addWorkspaceForMonitor(mid, sid)
  if mid == nil then return end
  self.monitors[mid] = sid
end

-- replace apps
-- return: none
function AeroSpace:replaceApps()
  self.log.i('replaceApps')

  for k, v in pairs(self.workspaces_windows) do
    local sid = k
    for k, v in pairs(v) do
      local wid = k
      local bid = v
      self.log.i(sid, wid, bid)
      if self.places[bid] ~= nil and self.places[bid] ~= sid then
	self.log.i(sid, wid, bid, '->', self.places[bid])
	self:run({'move-node-to-workspace', '--window-id', tostring(wid), tostring(self.places[bid])}, nil)
      end
    end
  end

  for k, v in pairs(self.monitors) do
    self.log.d(v, '->', k)
    self:run({'focus-monitor', tostring(k)}, function()
	self:run({'summon-workspace', tostring(v)}, nil)
    end)
  end

  self:sync()
end

-- sid: workspace id
-- return: none
function AeroSpace:moveFocusedWindowToWorkspace(sid)
  local csid = self.focused_workspace
  self:run({'move-node-to-workspace', sid}, function()
      --self:updateWorkspaces({tonumber(sid), tonumber(csid)})
      self:sync()
  end)
end

-- summon next workspace
-- return: none
function AeroSpace:nextWorkspace()
  local fsid = self.focused_workspace
  local tsid = {}
  for sid, _ in pairs(self.workspaces_windows) do table.insert(tsid, sid) end
  table.sort(tsid)
  for _, sid in pairs(tsid) do
    if sid > fsid then
      self:run({'summon-workspace', tostring(sid)}, nil)
      return
    end
  end
  self:run({'summon-workspace', tostring(tsid[1])}, nil)
  return
end

-- summon previous workspace
-- return: none
function AeroSpace:prevWorkspace()
  local fsid = self.focused_workspace
  local tsid = {}
  for sid, _ in pairs(self.workspaces_windows) do table.insert(tsid, sid) end
  table.sort(tsid, function(a, b) return a > b end)
  for _, sid in pairs(tsid) do
    if sid < fsid then
      self:run({'summon-workspace', tostring(sid)}, nil)
      return
    end
  end
  self:run({'summon-workspace', tostring(tsid[1])}, nil)
  return
end

-- clear prefix key status
-- return: none
function AeroSpace:clear()
  self.waitPrefix = true
  self.modal:exit()
end

-- run aerospace command
-- args: arguments table for yabai
-- cb: callback function
-- return: task object
function AeroSpace:run(args, cb)
  local st = hs.timer.absoluteTime()
  self.log.d('run')

  local task = hs.task.new(self.aerospace, function(exitCode, stdOut, stdErr)
		self.log.d('run:exitCode:', exitCode)
		self.log.d('run:stdOut:', stdOut)
		self.log.d('run:stdErr:', stdErr)
		if cb ~= nil then
		  cb(exitCode, stdOut, stdErr)
		end
		local ed = hs.timer.absoluteTime()
		self.log.d('run-real:', (ed - st) / 1000000, 'ms: ', table.unpack(args))
  end, args):start()

  local ed = hs.timer.absoluteTime()
  self.log.d('run:', (ed - st) / 1000000, 'ms: ', table.unpack(args))
  return task
end

-- run a command and return stdout
-- cmd: command string
-- return: output string
function AeroSpace:execute(cmd)
  local st = hs.timer.absoluteTime()
  self.log.d('execute')

  local handle = io.popen(cmd, 'r')
  local output = handle:read('*a')
  handle:close()
  self.log.d('execute:output:', output)

  local ed = hs.timer.absoluteTime()
  self.log.d('execute:', (ed - st) / 1000000, 'ms: ', cmd)
  return output
end

-- run aerospace query command and extract key value
-- cmd: command string for query
-- cb: callback function
-- return: task object
function AeroSpace:query(args, cb)
  local st = hs.timer.absoluteTime()
  self.log.d('query')

  table.insert(args, '--json')
  local task = hs.task.new(self.aerospace, function(exitCode, stdOut, stdErr)
		self.log.d('run:exitCode:', exitCode)
		self.log.d('run:stdOut:', stdOut)
		self.log.d('run:stdErr:', stdErr)
		if exitCode ~= 0 then return end
		if stdOut == '' then return end
		local output = hs.json.decode(stdOut)
		cb(output)

		local ed = hs.timer.absoluteTime()
		self.log.d('query-real:', (ed - st) / 1000000, 'ms: ', table.unpack(args))
  end, args):start()

  local ed = hs.timer.absoluteTime()
  self.log.d('query:', (ed - st) / 1000000, 'ms: ', table.unpack(args))
  return task
end

-- bind prefix + key to cb
-- mods: mods key for binding
-- key: normal key for binding
-- cb: callback function for binding
-- return: none
function AeroSpace:bind(mods, key, cb)
  self.modal:bind(mods, key, cb)
end

-- update indicator status
-- return: none
function AeroSpace:updateIndicator()
  for _, cs in pairs(self.canvases) do
    for _, c in pairs(cs) do
      local count = c:elementCount() -- the last element is the indicator
      if self.waitPrefix then
	c:elementAttribute(count, 'strokeColor', {red=0, green=0, blue=0, alpha=0.5})
	c:elementAttribute(count, 'fillColor', {red=0, green=0, blue=0, alpha=0.5})
      else
	c:elementAttribute(count, 'strokeColor', {red=1, green=0, blue=0, alpha=0.5})
	c:elementAttribute(count, 'fillColor', {red=1, green=0, blue=0, alpha=0.5})
      end
    end
  end
end

-- show canvases and set click event
-- index: index of double buffering canvases
-- return: none
function AeroSpace:showCanvases(index)
  self.log.d('show canvases:', index)
  for _, c in pairs(self.canvases[index]) do
    c:mouseCallback(function(canvas, event, id, x, y)
	--self.log.d('click workspace:', id)
	--for k, cc in pairs(self.canvases[index]) do
	  --self.log.i(c, ' ', k, ' ', cc)
	  --if c == cc then
	    --self.log.i('equal!!!')
	  --end
	--end
	if id > 0 then
	  self:run({'focus', '--window-id', tostring(id)}, nil)
	else
	  id = id * -1
	  if self.visible_workspaces[id] then
	    local focused_workspace = self.focused_workspace
	    local task = self:query({'list-monitors', '--focused', '--format', '%{monitor-id}'}, function(output)
		local smid = output[1]['monitor-id']
		local tmid = self.visible_workspaces[id]
		self:run({'summon-workspace', tostring(10)}, function()
		    self:run({'focus-monitor', tostring(tmid)}, function()
			self:run({'summon-workspace', tostring(focused_workspace)}, function()
			    self:run({'focus-monitor', tostring(smid)}, function()
				self:run({'summon-workspace', tostring(id)}, nil)
			    end)
			end)
		    end)
		end)
	    end)
	  else
	    self:run({'summon-workspace', tostring(id)}, nil)
	  end
	end
    end)
    c:clickActivating(false)
    c:canvasMouseEvents(false, true, false, false)
    c:show()
  end
  hindex = (index == 1) and 2 or 1
  for _, c in pairs(self.canvases[hindex]) do
    c:hide()
    c:canvasMouseEvents(false, false, false, false)
  end
end

-- append the elements to all canvases
-- elements: the elements to be added
-- cindex: index of double buffering canvases
-- return: none
function AeroSpace:appendElements(elements, cindex)
  for _, c in pairs(self.canvases[cindex]) do
    c:appendElements(elements)
  end
end

-- reset canvases
-- index: index of double buffering canvases
-- return: none
function AeroSpace:resetCanvases(index)
  self.log.i('resetCanvases:', index)
  for _, c in pairs(self.canvases[index]) do
    --for i = c:elementCount(), 1, -1 do
      --c:removeElement(i)
    --end
    self.log.i('delete canvas')
    --c:hide()
    c:delete()
  end
  self.canvases[index] = {}
  for k, v in pairs(hs.screen.allScreens()) do
    self.log.i('allScreens:', k, v)
    local p = v:fullFrame()
    local w = self.width
    local x = p.x + (p.w / 2) - (w / 2)
    local y = p.y
    if k == self.notch_display then y = v:frame().y end
    if self.canvases[index][k] == nil then
      local c = hs.canvas.new({x=x, y=y, w=w, h=self.size_icon})
      self.canvases[index][k] = c
    else
      self.canvases[index][k]:frame({x=x, y=y, w=w, h=self.size_icon})
    end
  end
  self.log.i('resetCanvases ----------')
end

-- add workspaces information on all displays
-- sid: workspace id
-- offset: start offset in the canvas
-- return: start offset for next workspace
function AeroSpace:addWorkspace(sid, offset)
  local v = self.workspaces_windows[sid]
  local alpha = 0.5
  local r, g, b = 0, 0, 0
  if self.workspaces_monitor[sid] == nil then self.workspaces_monitor[sid] = 0 end
  local monitor = self.workspaces_monitor[sid] % 3
  if self.workspaces_monitor[sid] > 0 then
    alpha = 1.0
    if monitor == 1 then r = 1 end
    if monitor == 2 then g = 1 end
    if monitor == 0 then b = 1 end
  end
  -- workspace id
  local labelText = hs.styledtext.new(tostring(sid), {
					font={size=20},
					color={red=0, green=0, blue=0, alpha=alpha},
					paragraphStyle={alignment='center'}
  })

  local space_offset = offset
  local space_count = 0
  local elements = {}
  offset = offset + self.pad_space + self.size_icon
  for wid, bid in pairs(v) do
    -- apps
    self.log.d('item:', wid, bid)
    --local app = hs.appfinder.appFromName(name)
    --local appBundle = app:bundleID()
    --local appImage = hs.image.imageFromAppBundle(appBundle)
    local appImage = hs.image.imageFromAppBundle(bid)
    offset = offset + self.pad_app
    table.insert(elements, {
		   id = wid,
		   type = 'image',
		   image = appImage,
		   frame = {x=offset, y=0, w=self.size_icon, h=self.size_icon},
		   imageAlpha = alpha,
		   trackMouseUp = true,
		   trackMouseDown = false,
		   trackMouseMove = false
    })
    offset = offset + self.size_icon
    space_count = space_count + 1
  end

  -- workspace background
  space_offset = space_offset + self.pad_space
  self:appendElements({
      type = 'rectangle',
      action = 'strokeAndFill',
      strokeColor = {red=r, green=g, blue=b, alpha=alpha-0.3},
      fillColor = {red=r, green=g, blue=b, alpha=alpha-0.5},
      roundedRectRadii = {xRadius=5, yRadius=5},
      frame = {x=space_offset, y=0, w=self.size_icon+(self.pad_app+self.size_icon)*space_count, h=self.size_icon},
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
		      }, self.cindex)
  self:appendElements({
      id = sid * -1,
      type = 'text',
      text = labelText,
      padding = 3.0,
      frame = {x=space_offset, y=0, w=self.size_icon, h=self.size_icon},
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
		      }, self.cindex)
  if space_count > 0 then self:appendElements(elements, self.cindex) end

  return offset
end

-- display workspaces/windows information on all displays
-- return: none
function AeroSpace:display()
  local st = hs.timer.absoluteTime()
  self.log.i('display')

  -- toggle double buffering
  self.cindex = (self.cindex == 1) and 2 or 1

  -- calculate total width
  self.width = -1 * self.pad_space
  for k, v in pairs(self.workspaces_windows) do
    local count = 0
    for k, v in pairs(v) do
      self.width = self.width + self.pad_app + self.size_icon
      count = count + 1
    end
    if count > 0 then
      self.width = self.width + self.pad_space + self.size_icon
    end
  end

  -- reset canvases
  self:resetCanvases(self.cindex)

  -- add workspaces/windows
  local offset = -1 * self.pad_space
  local tsid = {}
  for sid, _ in pairs(self.workspaces_windows) do table.insert(tsid, sid) end
  table.sort(tsid)
  for _, sid in pairs(tsid) do
    local count = 0
    for k, v in pairs(self.workspaces_windows[sid]) do
      count = count + 1
    end
    if count > 0 then
      offset = self:addWorkspace(sid, offset)
    end
  end

  -- add key indicator
  self:appendElements({
      id = 0,
      type = 'circle',
      strokeColor = {red=0, green=0, blue=0, alpha=0.5},
      fillColor = {red=0, green=0, blue=0, alpha=0.5},
      center = {x=offset-2, y=2},
      radius = 2,
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
  }, self.cindex)

  -- show
  self:showCanvases(self.cindex)

  local ed = hs.timer.absoluteTime()
  self.log.i('display:', (ed - st) / 1000000, 'ms')
end

-- update windows information from aerospace
-- curr: focused workspace id
-- prev: previous workspace id
-- return: whether the display update is required or not (true / false)
function AeroSpace:updateFocus(curr, prev)
  --self.log.d('update:', curr, prev)
  --self.log.d('monitor:', self.workspaces_monitor[curr], self.workspaces_monitor[prev])
  self.focused_workspace = curr
  if self.workspaces_monitor[curr] > 0 then
    return false
  end
  self.workspaces_monitor[curr] = self.workspaces_monitor[prev]
  self.workspaces_monitor[prev] = 0
  return true
end

-- update windows information in workspaces
-- tsid: workspace id table to update
-- return: none
function AeroSpace:updateWorkspaces(tsid)
  local st = hs.timer.absoluteTime()
  self.log.i('updateWorkspaces')

  local args = {'list-windows', '--workspace'}
  for _, sid in pairs(tsid) do
    table.insert(args, tostring(sid))
    self.workspaces_windows[sid] = {}
  end
  table.insert(args, '--format')
  table.insert(args, '%{window-id}%{app-bundle-id}%{workspace}')
  local task = self:query(args, function(output)
      for _, v in pairs(output) do
	local sid = tonumber(v['workspace'])
	local wid = tonumber(v['window-id'])
	self.log.d('updateWorkspace:', sid, v['window-id'], v['app-bundle-id'])
	self.workspaces_windows[sid][wid] = v['app-bundle-id']
	self.log.d('updateWorkspace:', sid, v['app-bundle-id'])
      end
      self:display()
  end)

  local ed = hs.timer.absoluteTime()
  self.log.i('updateWorkspaces:', (ed - st) / 1000000, 'ms')
end

-- sync windows information from aerospace
-- return: none
function AeroSpace:sync()
  local st = hs.timer.absoluteTime()
  self.log.i('sync')

  self.workspaces_windows = {}
  self.workspaces_monitor = {}

  local windows_done = false
  local monitors_done = false
  local workspace_done = false

  -- windows
  local windows_task = self:query({'list-windows', '--all', '--format', '%{window-id}%{app-bundle-id}%{workspace}%{window-title}'}, function(output)
      for _, v in pairs(output) do
	for _, w in pairs(self.hide_windows) do
	  self.log.i('windows:', v['window-id'], v['app-bundle-id'], v['window-title'])
	  if v['window-title'] == 'Orion Preview' then
	    goto continue
	  end
	end
	local sid = tonumber(v['workspace'])
	if self.workspaces_windows[sid] == nil then
	  self.workspaces_windows[sid] = {}
	end
	local wid = tonumber(v['window-id'])
	self.workspaces_windows[sid][wid] = v['app-bundle-id']
	::continue::
      end
      windows_done = true
      if windows_done and monitors_done and workspace_done then
	self:display()
      end
  end)

  -- monitors
  local monitors_task = self:query({'list-workspaces', '--monitor', 'all', '--visible', '--format', '%{workspace}%{monitor-id}'}, function(output)
      for k, _ in pairs(self.workspaces_monitor) do
	self.workspaces_monitor[k] = 0
      end
      for k, v in pairs(output) do
	local sid = tonumber(v['workspace'])
	local mid = v['monitor-id']
	self.workspaces_monitor[sid] = mid
      end
      monitors_done = true
      if windows_done and monitors_done and workspace_done then
	self:display()
      end
  end)

  -- focused workspace
  --local workspace_task = self:query({'list-workspaces', '--focused', '--format', '%{workspace}'}, function(output)
  local workspace_task = self:query({'list-workspaces', '--visible', '--monitor', 'all', '--format', '%{workspace}%{monitor-id}%{workspace-is-focused}'}, function(output)
      self.visible_workspaces = {}
      for k, v in pairs(output) do
	if v['workspace-is-focused'] then
	  self.focused_workspace = tonumber(v['workspace'])
	end
	self.visible_workspaces[tonumber(v['workspace'])] = tonumber(v['monitor-id'])
      end
      workspace_done = true
      if windows_done and monitors_done and workspace_done then
	self:display()
      end
  end)

  local ed = hs.timer.absoluteTime()
  self.log.i('sync:', (ed - st) / 1000000, 'ms')
end

-- init instance
-- mods: mods key for prefix
-- key: normal key for prefix
-- return: none
function AeroSpace:init(mods, key)
  self.log.d('init')

  -- set prefix key
  self.waitPrefix = true
  self.modal = hs.hotkey.modal.new()
  hs.hotkey.bind(mods, key, function()
		   self.waitPrefix = not self.waitPrefix
		   if self.waitPrefix then
		     self.modal:exit()
		   else
		     self.modal:enter()
		   end
		   self:updateIndicator()
  end)

  self:sync()

  -- set display watcher
  self.screenWatcher = hs.screen.watcher.new(function()
      self.log.i('screen watcher')
      self:sync()
  end)
  self.screenWatcher:start()

  --[[ set space watcher
  self.spaceWatcher = hs.spaces.watcher.new(function()
      self.log.d('space watcher')
      self:triggerUpdate()
  end)
  self.spaceWatcher:start() ]]--

  -- set window watcher
  self.appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
      if eventType ~= hs.application.watcher.launched and
	eventType ~= hs.application.watcher.terminated and
	eventType ~= hs.application.watcher.activated and
	eventType ~= hs.application.watcher.deactivated then
	return
      end
      self.log.i('app watcher', appName, eventType, appObject:bundleID())
      --self:updateWorkspaces({self.focused_workspace})
      self:sync()
  end)
  self.appWatcher:start()
end

-- create new instance
-- mods: mods key for prefix
-- key: normal key for prefix
-- return: new instance
function AeroSpace:new(mods, key)
  local _self = setmetatable({
      -- internal data
      cindex = 1, -- canvas double buffering index 1 or 2
      canvases = {{}, {}}, -- canvas table - canvases[1/2][display index] = canvas

      workspaces_windows = {}, -- workspaces_windows[workspace id][window id] = app bundle id
      workspaces_monitor = {}, -- workspaces_monitor[workspace id] = monitor id
      visible_workspaces = {}, -- visible_workspaces[workspace id] = monitor id
      focused_workspace = 0, -- focused workspace id
      width = 0, -- width of the bar -> | pad space | space | pad app | app | ...

      screenWatcher = nil,
      --spaceWatcher = nil,
      appWatcher = nil,
  }, self)
  self.__index = self

  _self:init(mods, key)

  return _self
end

return AeroSpace
