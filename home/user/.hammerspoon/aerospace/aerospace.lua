local AeroSpace = {
  name = 'AeroSpace',
  version = '1.0',
  author = 'Seunguk Shin <seunguk.shin@gmail.com>',
  license = 'MIT - https://opensource.org/licenses/MIT',

  -- configuration
  aerospace = '/opt/homebrew/bin/aerospace',
  size_icon = 24,
  bar_offset_y = 3,
  pad_app = 0,
  pad_space = 4,
  notch_display = 'Built-in Retina Display',
  places = {}, -- place table - places[app bundle id] = workspace id
  monitors = {}, -- monitor table - monitors[monitor id] = workspace id
  hide_windows = {},
}

--------------------------------------------------------------------------------
-- external functions
--------------------------------------------------------------------------------

-- aerospace:addPlaceForApp(bid: number, sid: number) -> nil
-- add place table item
-- bid: number = app bundle id
-- sid: number = workspace id
-- return: nil
function AeroSpace:addPlaceForApp(bid, sid)
  if bid == nil then return end
  self.places[bid] = sid
end

-- aerospace:addWorkspaceForMonitor(mid: number, sid: number) -> nil
-- add monitor table item
-- mid: number = monitor bundle id
-- sid: number = workspace id
-- return: nil
function AeroSpace:addWorkspaceForMonitor(mid, sid)
  if mid == nil then return end
  self.monitors[mid] = sid
end

-- aerospace:bind(mods: table, key: string, cb: func) -> nil
-- bind prefix + key to cb
-- mods: table = mods key for binding
-- key: string = normal key for binding
-- cb: func = callback function for binding
-- return: nil
function AeroSpace:bind(mods, key, cb)
  self.modal:bind(mods, key, cb)
end

-- aerospace:clear() -> nil
-- clear prefix key status
-- return: nil
function AeroSpace:clear()
  self.waitPrefix = true
  self.modal:exit()
end

-- aerospace:dump() -> nil
-- print internal data
-- return: nil
function AeroSpace:dump()
  self.log.i('focused workspace:', self.focused_workspace)
  self.log.i('windows:')
  for k, v in pairs(self.workspaces) do
    self.log.i(' ', k, ':')
    for k, v in pairs(v) do
      self.log.i('   ', k, ':', v)
    end
  end
end

-- aerospace:replaceApps() -> nil
-- replace apps
-- return: nil
function AeroSpace:replaceApps()
  self.log.d('replaceApps')

  for k, v in pairs(self.workspaces) do
    local sid = k
    for k, v in pairs(v) do
      if type(k) == 'number' then
	local wid = k
	local bid = v
	self.log.d(sid, wid, bid)
	if self.places[bid] ~= nil and self.places[bid] ~= sid then
	  self.log.d(sid, wid, bid, '->', self.places[bid])
	  self:run({'move-node-to-workspace', '--window-id', tostring(wid), tostring(self.places[bid])}, nil)
	end
      end
    end
  end

  for k, v in pairs(self.monitors) do
    self.log.d(v, '->', k)
    self:run({'focus-monitor', tostring(k)}, function()
	self:run({'summon-workspace', tostring(v)}, nil)
    end)
  end
end

-- aerospace:changeLayout(layout: string) -> nil
-- change layout
-- layout: string = layout
-- return: nil
function AeroSpace:changeLayout(layout)
  self:run({'layout', layout}, nil)
end

-- aerospace:moveFocusedWindowToWorkspace(sid: number) -> nil
-- sid: number = workspace id
-- return: nil
function AeroSpace:moveFocusedWindowToWorkspace(sid)
  local csid = self.focused_workspace
  self:run({'move-node-to-workspace', sid}, function()
      self:updateWorkspaces({tonumber(sid), tonumber(csid)})
  end)
end

-- aerospace:nextWorkspace() -> nil
-- summon next workspace
-- return: nil
function AeroSpace:nextWorkspace()
  local fsid = self.focused_workspace
  local tsid = {}
  for sid, _ in pairs(self.workspaces) do table.insert(tsid, sid) end
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

-- aerospace:prevWorkspace() -> nil
-- summon previous workspace
-- return: nil
function AeroSpace:prevWorkspace()
  local fsid = self.focused_workspace
  local tsid = {}
  for sid, _ in pairs(self.workspaces) do table.insert(tsid, sid) end
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

--------------------------------------------------------------------------------
-- internal functions
--------------------------------------------------------------------------------

-- aerospace:run(args: table, cb: func) -> hs.task
-- run aerospace command
-- args: table = arguments table for aerospace
-- cb: func = callback function
-- return: hs.task = task object
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

-- aerospace:execute(cmd: table) -> string
-- run a command and return stdout
-- cmd: table = command string
-- return: string = output string
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

-- aerospace:query(args: table, cb: func) -> hs.task
-- run aerospace query command and extract key value
-- args: table = command string for query
-- cb: func = callback function
-- return: hs.task = task object
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

-- aerospace:focus(m: string, s: string, w: string) -> nil
-- focus a window
-- m: string = monitor id
-- s: string = space id
-- w: string = window id
function AeroSpace:focus(m, s, w)
  local st = hs.timer.absoluteTime()
  self.log.d('focus:', m, s, w)
  if m == nil then return end

  local mid = tonumber(m)
  local sid = tonumber(s)
  if self.workspaces[sid]['visible'] and self.workspaces[sid]['monitor'] ~= mid then
    -- workspace is visible in other monitor
    local dst_mid = self.workspaces[sid]['monitor']
    local cur_sid = -1
    for k, v in pairs(self.workspaces) do
      if v['visible'] and v['monitor'] == mid then
	cur_sid = k
	break
      end
    end

    if cur_sid > 0 then
      -- current workspace exists
      self:run({'move-workspace-to-monitor', '--workspace', tostring(cur_sid), tostring(dst_mid)}, function()
	  self:run({'move-workspace-to-monitor', '--workspace', s, m}, function()
	      self:run({'focus-monitor', tostring(dst_mid)}, function()
		  self:run({'workspace', tostring(cur_sid)}, function()
		      self:run({'focus-monitor', m}, function()
			  self:run({'workspace', s}, function()
			      if w == nil then return end
			      self:run({'focus', '--window-id', w}, function()
				  local ed = hs.timer.absoluteTime()
				  self.log.d('focus real:', (ed - st) / 1000000, 'ms')
			      end)
			  end)
		      end)
		  end)
	      end)
	  end)
      end)
    else
      -- current workspace doesn't exist
      self:run({'focus-monitor', m}, function()
	  if s == nil then return end
	  self:run({'move-workspace-to-monitor', '--workspace', s, m}, function()
	      if w == nil then return end
	      self:run({'focus', '--window-id', w}, function()
		  local ed = hs.timer.absoluteTime()
		  self.log.d('focus real:', (ed - st) / 1000000, 'ms')
	      end)
	  end)
      end)
    end
  else
    -- workspace is invisible
    self:run({'focus-monitor', m}, function()
	if s == nil then return end
        self:run({'summon-workspace', s}, function()
	    if w == nil then return end
	    self:run({'focus', '--window-id', w}, function()
		local ed = hs.timer.absoluteTime()
		self.log.d('focus real:', (ed - st) / 1000000, 'ms')
	    end)
	end)
    end)
  end

  local ed = hs.timer.absoluteTime()
  self.log.d('focus:', (ed - st) / 1000000, 'ms')
end

-- aerospace:updateIndicator() -> nil
-- update indicator status
-- return: nil
function AeroSpace:updateIndicator()
  for _, c in pairs(self.canvases) do
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

-- aerospace:showCanvas() -> nil
-- show canvases and set click event
-- return: nil
function AeroSpace:showCanvas()
  self.log.d('showCanvas: start')
  for _, c in pairs(self.canvases) do c:delete() end

  local e = self.canvas:canvasElements()
  self.canvases = {}
  for k, v in pairs(hs.screen.allScreens()) do
    self.log.d('allScreens:', v)
    local n = v:name()
    local p = v:fullFrame()
    local w = self.width
    local x = p.x + (p.w / 2) - (w / 2)
    local y = p.y + self.bar_offset_y
    if n == self.notch_display then y = v:frame().y end
    local c = hs.canvas.new({x=x, y=y, w=w, h=self.size_icon})
    c:replaceElements(e)
    c:mouseCallback(function(canvas, event, id, x, y)
	local monitor = nil -- monitor string
	local workspace = nil -- workspace
	local window = nil -- window

	-- find monitor, workspace, and window
	local st = hs.timer.absoluteTime()
	for k, v in pairs(self.canvases) do
	  if canvas == v then monitor = k; break end
	end
	if id < 0 then -- workspace is clicked
	  workspace = tostring(id * -1)
	else -- window is clicked
	  window = tostring(id)
	  for sid, v in pairs(self.workspaces) do
	    for wid, v in pairs(v) do
	      if wid == id then
		workspace = tostring(sid)
		break
	      end
	    end
	    if workspace then break end
	  end
	end
	self.log.d('click:', monitor, workspace, window)

	-- focus
	self:focus(tostring(self.monitors[k]), workspace, window)
    end)
    c:clickActivating(false)
    c:canvasMouseEvents(false, true, false, false)
    c:show()
    self.canvases[n] = c
  end
  self.log.d('showCanvas: end')
end

-- aerospace:addWorkspace(sid: number, offset: number) -> number
-- add workspaces information on all displays
-- sid: number = workspace id
-- offset: number = start offset in the canvas
-- return: number = start offset for next workspace
function AeroSpace:addWorkspace(sid, offset)
  local v = self.workspaces[sid]
  local alpha = 0.5
  local r, g, b = 0, 0, 0
  if self.workspaces[sid]['visible'] then
    local monitor = self.workspaces[sid]['monitor'] % 3
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
    if type(wid) == 'number' then
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
  end

  -- workspace background
  space_offset = space_offset + self.pad_space
  self.canvas:appendElements({
      type = 'rectangle',
      action = 'strokeAndFill',
      strokeColor = {red=r, green=g, blue=b, alpha=alpha-0.3},
      fillColor = {red=r, green=g, blue=b, alpha=alpha-0.5},
      roundedRectRadii = {xRadius=5, yRadius=5},
      frame = {x=space_offset, y=0, w=self.size_icon+(self.pad_app+self.size_icon)*space_count, h=self.size_icon},
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
		      })
  self.canvas:appendElements({
      id = sid * -1,
      type = 'text',
      text = labelText,
      padding = 3.0,
      frame = {x=space_offset, y=0, w=self.size_icon, h=self.size_icon},
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
		      })
  if space_count > 0 then self.canvas:appendElements(elements) end

  return offset
end

-- aerospace:display() -> nil
-- display workspaces/windows information on all displays
-- return: nil
function AeroSpace:display()
  local st = hs.timer.absoluteTime()
  self.log.d('display: start')

  -- calculate total width
  self.width = -1 * self.pad_space
  for k, v in pairs(self.workspaces) do
    local count = 0
    for k, v in pairs(v) do
      if type(k) == 'number' then
	self.width = self.width + self.pad_app + self.size_icon
	count = count + 1
      end
    end
    if count > 0 then
      self.width = self.width + self.pad_space + self.size_icon
    end
  end

  -- reset canvases
  if self.canvas then self.canvas:delete() end
  self.canvas = hs.canvas.new({x=0, y=0, w=self.width, h=self.size_icon})

  -- add workspaces/windows
  local offset = -1 * self.pad_space
  local tsid = {}
  for sid, _ in pairs(self.workspaces) do table.insert(tsid, sid) end
  table.sort(tsid)
  for _, sid in pairs(tsid) do
    local count = 0
    for k, v in pairs(self.workspaces[sid]) do
      count = count + 1
    end
    if count > 0 then
      offset = self:addWorkspace(sid, offset)
    end
  end

  -- add key indicator
  self.canvas:appendElements({
      id = 0,
      type = 'circle',
      strokeColor = {red=0, green=0, blue=0, alpha=0.5},
      fillColor = {red=0, green=0, blue=0, alpha=0.5},
      center = {x=offset-2, y=2},
      radius = 2,
      trackMouseUp = true,
      trackMouseDown = false,
      trackMouseMove = false
  })

  -- show
  self:showCanvas()

  local ed = hs.timer.absoluteTime()
  self.log.d('display: end:', (ed - st) / 1000000, 'ms')
end

-- aerospace:sync(delay: number) -> nil
-- sync windows information from aerospace
-- delay: number = delay time in second
-- return: nil
function AeroSpace:sync(delay)
  if self.task:running() then
    self.log.i('sync: skip - already waiting')
    return
  end
  if self.running then
    self.log.i('sync: skip - already running')
    self.rerun = true
    return
  end
  if not delay then delay = 0 end
  self.rerun = false
  self.task:start(delay)
end

-- aerospace:initGui() -> nil
-- init or clear gui watcher
-- return: nil
function AeroSpace:initGui()
  self.log.d('intGui: start:', self.gui)

  self.task = hs.timer.delayed.new(0, function()
    local st = hs.timer.absoluteTime()
    self.log.i('sync: start')

    if self.need_monitors then
      self.need_monitors = false
      self.monitors = {}
      local task = self:query({'list-monitors', '--format', '%{monitor-id}%{monitor-appkit-nsscreen-screens-id}'}, function(output)
	  for _, v in pairs(output) do
	    local mid = tonumber(v['monitor-id'])
	    local mid_hs = tonumber(v['monitor-appkit-nsscreen-screens-id'])
	    self.monitors[mid_hs] = mid
	  end
      end)
    end

    self.workspaces = {}
    local task = self:query({'list-windows', '--all', '--format', '%{window-id}%{workspace}%{monitor-id}%{monitor-appkit-nsscreen-screens-id}%{workspace-is-focused}%{workspace-is-visible}%{app-bundle-id}%{window-title}'}, function(output)
	for _, v in pairs(output) do
	  self.log.d('windows:', v['window-id'], v['workspace'], v['monitor-id'], v['workspace-is-focused'], v['workspace-is-visible'], v['app-bundle-id'], v['window-title'])
	  if v['app-bundle-id'] ~= 'org.mozilla.firefox' then
	    if v['window-title'] == '' then
	      goto continue
	    end
	  end
	  for _, w in pairs(self.hide_windows) do
	    if v['window-title'] == w then
	      goto continue
	    end
	  end
	  local sid = tonumber(v['workspace'])
	  local wid = tonumber(v['window-id'])
	  local mid = tonumber(v['monitor-id'])
	  if self.workspaces[sid] == nil then
	    self.workspaces[sid] = {}
	  end
	  self.workspaces[sid][wid] = v['app-bundle-id']
	  self.workspaces[sid]['monitor'] = mid
	  self.workspaces[sid]['visible'] = v['workspace-is-visible']
	  if v['workspace-is-focused'] then
	    self.focused_workspace = sid
	  end
	  ::continue::
	end
	self:display()
	local ed = hs.timer.absoluteTime()
	self.log.i('sync: end real', (ed - st) / 1000000, 'ms')
	self.running = false
    end)

    local ed = hs.timer.absoluteTime()
    self.log.i('sync: end', (ed - st) / 1000000, 'ms')

    if self.rerun then
      self.log.i('sync: rerun')
      self:sync()
    end
  end)

  self:sync()

  -- set display watcher
  self.screenWatcher = hs.screen.watcher.new(function()
      self.log.i('screen watcher')
      self.need_monitors = true
      self:sync(0.1)
  end)
  self.screenWatcher:start()

  -- set space watcher
  self.spaceWatcher = hs.spaces.watcher.new(function()
      self.log.i('space watcher')
      self:sync(0.1)
  end)
  self.spaceWatcher:start()

  -- set window watcher
  self.appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
      if eventType ~= hs.application.watcher.launched and
	eventType ~= hs.application.watcher.terminated and
	eventType ~= hs.application.watcher.activated and
	eventType ~= hs.application.watcher.deactivated then
	return
      end
      self.log.i('app watcher:', appName, eventType, appObject:bundleID())
      --self:updateWorkspaces({self.focused_workspace})
      self:sync(0.1)
  end)
  self.appWatcher:start()

  self.log.d('intGui: end')
end

-- aerospace:init(mods: table, key: string) -> nil
-- init instance
-- mods: table = mods key for prefix
-- key: string = normal key for prefix
-- return: nil
function AeroSpace:init(mods, key)
  self.log.d('init: start')

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
  self:initGui()

  self.log.d('init: end')
end

-- aerospace:new(mods: table, key: string) -> aerospace
-- create new instance
-- mods: table = mods key for prefix
-- key: string = normal key for prefix
-- return: aerospace = new instance of AeroSpace
function AeroSpace:new(mods, key)
  local _self = setmetatable({
      -- internal data
      canvas = nil, -- original canvas
      canvases = {}, -- canvas table - canvases[display index] = canvas

      workspaces = {}, -- workspaces information
                       -- workspaces[workspace id]['monitor'] = monitor id
                       -- workspaces[workspace id]['visible'] = true or not
                       -- workspaces[workspace id][window id] = app bundle id
      monitors = {}, -- monitor information - monitors[monitor-hs] = monitor
      need_monitors = true,
      focused_workspace = 0, -- focused workspace id
      width = 0, -- width of the bar -> | pad space | space | pad app | app | ...

      screenWatcher = nil,
      spaceWatcher = nil,
      appWatcher = nil,
      sleepWatcher = nil,
      sleepGui = false,

      --task = {}, -- tasks
                 -- task[i].func = function
                 -- task[i].args = argument
                 -- task[i].time = time
      task = nil, -- task to run sync function
      running = false, -- status of running sync function
      rerun = false, -- rerun sync function

      log = hs.logger.new('AeroSpace', 'info'),
  }, self)
  self.__index = self

  _self:init(mods, key)

  return _self
end

return AeroSpace
