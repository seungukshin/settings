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
  notch_display = 1, -- index in yabai, 0 to ignore
  refresh_timer = 0, -- in seconds, 0 to disable the timer
  places = {}, -- place table - places[app name] = space label
  renames = { -- rename table
    ['MSTeams'] = 'Microsoft Teams',
  },

  -- internal data
  log = hs.logger.new('AeroSpace', 'debug'),
}

-- add place table item
-- name: app name
-- label: space label
-- return: none
function AeroSpace:addPlaceForApp(name, space)
  if name ~= nil then
    self.places[name] = space
  end
end

-- replace apps
-- return: none
function AeroSpace:replaceApps()
  for k, v in pairs(self.workspaces) do
    local sid = k
    for k, v in pairs(v) do
      local wid = k
      local name = v
      self.log.d(sid, wid, name)
      if self.places[name] ~= nil and self.places[name] ~= sid then
	self.log.d(sid, wid, name, '->', self.places[name])
	--self:execute(self.aerospace .. ' focus --window-id ' .. tostring(wid))
	--self:execute(self.aerospace .. ' move-node-to-workspace ' .. tostring(self.places[name]))
	self:run({'move-node-to-workspace', '--window-id', tostring(wid), tostring(self.places[name])}, nil)
      end
    end
  end
  if not self.update:running() then
    self.update:start()
  end
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
-- return: none
function AeroSpace:run(args, cb)
  --self.log.d('run:', table.unpack(args))
  hs.task.new(self.aerospace, function(exitCode, stdOut, stdErr)
		--self.log.d('run:exitCode:', exitCode)
		--self.log.d('run:stdErr:', stdErr)
		--self.log.d('run:stdOut:', stdOut)
		if cb ~= nil then
		  cb()
		end
  end, args):start()
end

-- run a command and return stdout
-- cmd: command string
-- return: output string
function AeroSpace:execute(cmd)
  --self.log.d('execute:', cmd)
  local handle = io.popen(cmd, 'r')
  local output = handle:read('*a')
  handle:close()
  --self.log.d('execute:output:', output)
  return output
end

-- run aerospace query command and extract key value
-- cmd: command string for query
-- key: key string to extract result
-- return: value of the key
function AeroSpace:query(cmd, key)
  local output = self:execute(self.aerospace .. ' ' .. cmd .. ' --json', 'r')
  if output == '' then
    return nil
  end
  local out = hs.json.decode(output)
  if key ~= nil then
    return out[key]
  end
  return out
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
  for _, c in pairs(self.canvases[1]) do
    local count = c:elementCount() -- the last element is the indicator
    if self.waitPrefix then
      c:elementAttribute(count, 'strokeColor', {red=0, green=0, blue=0, alpha=0.5})
      c:elementAttribute(count, 'fillColor', {red=0, green=0, blue=0, alpha=0.5})
    else
      c:elementAttribute(count, 'strokeColor', {red=1, green=0, blue=0, alpha=0.5})
      c:elementAttribute(count, 'fillColor', {red=1, green=0, blue=0, alpha=0.5})
    end
  end
  for _, c in pairs(self.canvases[2]) do
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

-- show canvases and set click event
-- index: index of double buffering canvases
-- return: none
function AeroSpace:showCanvases(index)
  --self.log.d('show canvases:', index)
  for _, c in pairs(self.canvases[index]) do
    c:mouseCallback(function(canvas, event, id, x, y)
	-- focus display
	for k, v in pairs(self.canvases[index]) do
	  if v:topLeft().x == canvas:topLeft().x then
	    self:execute(self.aerospace .. ' focus-monitor ' .. tostring(k))
	  end
	end
	-- focus workspace or app
	--self.log.d('click:', id)
	if id > 0 then
	  self:run({'focus', '--window-id', tostring(id)}, nil)
	else
	  self:run({'summon-workspace', tostring(id * -1)}, nil)
	end
    end)
    c:clickActivating(false)
    c:canvasMouseEvents(false, true, false, false)
    c:show()
  end
  hindex = (index == 1) and 2 or 1
  for _, c in pairs(self.canvases[hindex]) do
    c:hide()
  end
end

-- append the elements to all canvases
-- elements: the elements to be added
-- cindex: index of double buffering canvases
-- return: none
function AeroSpace:appendElements(elements, cindex)
  --self.log.d('append:', cindex)
  for _, c in pairs(self.canvases[cindex]) do
    c:appendElements(elements)
  end
end

-- reset canvases
-- index: index of double buffering canvases
-- return: none
function AeroSpace:resetCanvases(index)
  for _, c in pairs(self.canvases[index]) do c:delete() end
  self.canvases[index] = {}
  for k, v in pairs(hs.screen.allScreens()) do
    local p = v:fullFrame()
    local w = self.width
    local x = p.x + (p.w / 2) - (w / 2)
    local y = p.y
    if k == self.notch_display then y = v:frame().y end
    local c = hs.canvas.new({x=x, y=y, w=w, h=self.size_icon})
    --self.log.d('reset:', index, x, y, w, h)
    self.canvases[index][k] = c
  end
end

-- display spaces/windows information on all displays
-- return: none
function AeroSpace:display()
  -- toggle double buffering
  self.cindex = (self.cindex == 1) and 2 or 1
  -- reset canvases
  self:resetCanvases(self.cindex)
  -- add items
  local offset = -1 * self.pad_space
  for k, v in pairs(self.workspaces) do
    -- workspace
    local alpha = 0.5
    if self.active_workspaces[k] then alpha = 1.0 end
    local labelText = hs.styledtext.new(tostring(k), {
					  font={size=20},
					  color={red=0, green=0, blue=0, alpha=alpha},
					  paragraphStyle={alignment='center'}
    })

    local space_offset = offset
    local space_count = 0
    local elements = {}
    offset = offset + self.pad_space + self.size_icon
    for k, v in pairs(v) do
      -- apps
      --self.log.d('item:', k, v)
      local name = v
      if self.renames[v] ~= nil then name = self.renames[v] end
      local app = hs.appfinder.appFromName(name)
      if app ~= nil then
	local appBundle = app:bundleID()
	local appImage = hs.image.imageFromAppBundle(appBundle)
	offset = offset + self.pad_app
	table.insert(elements, {
	    id = k,
	    type = 'image',
	    image = appImage,
	    frame = {x=offset, y=0, w=self.size_icon, h=self.size_icon},
	    imageAlpha = alpha,
	    trackMouseUp = true
	})
	offset = offset + self.size_icon
	space_count = space_count + 1
      end
    end

    space_offset = space_offset + self.pad_space
    self:appendElements({
	type = 'rectangle',
	action = 'strokeAndFill',
	strokeColor = {red=0, green=0, blue=0, alpha=alpha-0.3},
	fillColor = {red=0, green=0, blue=0, alpha=alpha-0.5},
	roundedRectRadii = {xRadius=5, yRadius=5},
	frame = {x=space_offset, y=0, w=self.size_icon+(self.pad_app+self.size_icon)*space_count, h=self.size_icon},
	trackMouseUp = true
    }, self.cindex)
    self:appendElements({
	id = k * -1,
	type = 'text',
	text = labelText,
	padding = 3.0,
	frame = {x=space_offset, y=0, w=self.size_icon, h=self.size_icon},
	trackMouseUp = true
    }, self.cindex)
    if space_count > 0 then self:appendElements(elements, self.cindex) end
  end
  -- add key indicator
  self:appendElements({
      id = 0,
      type = 'circle',
      strokeColor = {red=0, green=0, blue=0, alpha=0.5},
      fillColor = {red=0, green=0, blue=0, alpha=0.5},
      center = {x=offset-2, y=2},
      radius = 1,
      trackMouseUp = true
  }, self.cindex)
  -- show
  self:showCanvases(self.cindex)
end

-- sync windows information from aerospace
-- return: none
function AeroSpace:sync()
  self.workspaces = {}
  self.active_workspaces = {}
  self.width = -1 * self.pad_space
  local output = self:query('list-workspaces --all', nil)
  for _, v in pairs(output) do
    local sid = tonumber(v['workspace'])
    self.workspaces[sid] = {}
    self.width = self.width + self.pad_space + self.size_icon
    local output = self:query('list-windows --workspace ' .. sid, nil)
    for _, v in pairs(output) do
      local wid = tonumber(v['window-id'])
      local name = v['app-name']
      self.workspaces[sid][wid] = name
      self.width = self.width + self.pad_app + self.size_icon
    end
    self.active_workspaces[sid] = false
  end
  local output = self:query('list-workspaces --monitor all --visible', nil)
  for _, v in pairs(output) do
    local sid = tonumber(v['workspace'])
    self.active_workspaces[sid] = true
  end
end

-- init instance
-- mods: mods key for prefix
-- key: normal key for prefix
-- return: none
function AeroSpace:init(mods, key)
  --self.log.d('init')
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

  self.update = hs.timer.delayed.new(0.0, function()
				       self:sync()
				       self:display()
  end)

  -- set refresh timer
  if self.refresh_timer > 0 then
    self.timer = hs.timer.new(refresh_timer, function()
				if not self.update:running() then
				  self.update:start()
				end
    end)
    self.timer:start()
  end

  -- set display watcher
  self.screenWatcher = hs.screen.watcher.new(function()
      self.log.d('screen watcher')
      if not self.update:running() then
	self.update:start()
      end
  end)
  self.screenWatcher:start()

  -- set space watcher
  self.spaceWatcher = hs.spaces.watcher.new(function()
      self.log.d('space watcher')
      if not self.update:running() then
	self.update:start()
      end
  end)
  self.spaceWatcher:start()

  -- set window watcher
  self.appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
      if (eventType ~= hs.application.watcher.activated) then
	return
      end
      if self.update:running() then
	return
      end
      self.log.d('app watcher', appName, eventType, appObject)
      self.update:start()
  end)
  self.appWatcher:start()

  self.update:start()
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

      workspaces = {}, -- workspaces[workspace id][window id] = app name
      active_workspaces = {}, -- active_workspaces[workspace id] = true or false
      width = 0, -- width of the bar -> | pad space | space | pad app | app | ...

      update = nil, -- delayed to sync and update canvases

      timer = nil, -- refresh timer

      screenWatcher = nil,
      spaceWatcher = nil,
      appWatcher = nil,
  }, self)
  self.__index = self

  _self:init(mods, key)

  return _self
end

return AeroSpace
