local Yabai = {
  name = 'Yabai',
  version = '1.0',
  author = 'Seunguk Shin <seunguk.shin@gmail.com>',
  license = 'MIT - https://opensource.org/licenses/MIT',

  -- configuration
  yabai = '/opt/homebrew/bin/yabai',
  icon_size = 24,
  notch_display = 1, -- index in yabai, 0 to ignore
  refresh_timer = 0, -- in seconds, 0 to disable the timer
  places = {}, -- place table - places[app name] = space label
  renames = { -- rename table
    ['MSTeams'] = 'Microsoft Teams',
  },

  -- internal data
  log = hs.logger.new('Yabai', 'info'),
}

-- add place table item
-- name: app name
-- label: space label
-- return: none
function Yabai:addPlaceForApp(name, label)
  self.places[name] = 'label-' .. tostring(label)
end

-- clear prefix key status
-- return: none
function Yabai:clear()
  self.waitPrefix = true
  self.modal:exit()
end

-- run yabai command
-- args: arguments table for yabai
-- cb: callback function
-- return: none
function Yabai:run(args, cb)
  self.log.d('yabai', table.unpack(args))
  hs.task.new(self.yabai, function(exitCode, stdOut, stdErr)
		self.log.d('exit code:', exitCode)
		self.log.d('stderr:', stdErr)
		self.log.d('stdout:', stdOut)
		if cb ~= nil then
		  cb()
		else
		  self:displaySpaces()
		end
  end, args):start()
end

-- run a command and return stdout
-- cmd: command string
-- return: output string
function Yabai:execute(cmd)
  self.log.d(cmd)
  local handle = io.popen(cmd, 'r')
  local output = handle:read('*a')
  handle:close()
  return output
end

-- bind prefix + key to cb
-- mods: mods key for binding
-- key: normal key for binding
-- cb: callback function for binding
-- return: none
function Yabai:bind(mods, key, cb)
  self.modal:bind(mods, key, cb)
end

-- run yabai query command and extract key value
-- cmd: command string for query
-- key: key string to extract result
-- return: value of the key
function Yabai:query(cmd, key)
  local output = self:execute(self.yabai .. ' -m query ' .. cmd, 'r')
  if output == '' then
    return nil
  end
  local out = hs.json.decode(output)
  return out[key]
end

--------------------------------------------------------------------------------
-- predefined callback functions
--------------------------------------------------------------------------------

-- create a space
-- cb: callback function
-- return: none
function Yabai:createSpace(cb)
  self:run({'-m', 'space', '--create', cb})
end

-- destroy the space
-- space: label index for the space
-- cb: callback function
-- return: none
function Yabai:destroySpace(space, cb)
  self:run({'-m', 'space', '--destroy', 'label-' .. tostring(space)}, cb)
end

-- destroy the current space
-- cb: callback function
-- return: none
function Yabai:destroyActiveSpace(cb)
  spaceLabel = self:query('--spaces --space', 'label')
  self:run({'-m', 'space', '--destroy', spaceLabel}, cb)
end

-- focus the display
-- display: index for the display
-- cb: callback function
-- return: none
function Yabai:focusDisplay(display, cb)
  self:run({'-m', 'display', '--focus', tostring(display)}, cb)
end

-- focus the display
-- pos: position for the display (north, south, east, west)
-- cb: callback function
-- return: none
function Yabai:focusDisplayPos(pos, cb)
  self:run({'-m', 'display', '--focus', pos}, cb)
end

-- focus the window
-- windowId: id for the window
-- cb: callback function
-- return: none
function Yabai:focusWindowId(windowId, cb)
  self:run({'-m', 'window', '--focus', tostring(windowId)}, cb)
end

-- focus the window
-- pos: position for the window (north, south, east, west)
-- cb: callback function
-- return: none
function Yabai:focusWindowPos(pos, cb)
  self:run({'-m', 'window', '--focus', pos}, cb)
end

-- focus the previous window
-- cb: callback function
-- return: none
function Yabai:focusPreviousWindow(cb)
  --hs.window.switcher.previousWindow()
  self:run({'-m', 'window', '--focus', 'recent'}, cb)
end

-- send the current window to the space
-- space: label index for the space
-- cb: callback function
-- return: none
function Yabai:sendActiveWindowToSpace(space, cb)
  self:run({'-m', 'window', '--space', 'label-' .. tostring(space)}, cb)
end

-- show the space in the current display
-- space: label index for the space
-- cb: callback function
-- return: none
function Yabai:showSpaceInActiveDisplay(space, cb)
  display = self:query('--displays --display', 'index')
  self:run({'-m', 'space', 'label-' .. tostring(space), '--display', tostring(display)}, function()
      self:run({'-m', 'display', '--space', 'label-' .. tostring(space)}, cb)
  end)
end

-- show the window in the display
-- windowId: id for the window
-- display: index for the display
-- cb: callback function
-- return: none
function Yabai:showWindowIdInDisplay(windowId, display, cb)
  spaceIndex = self:query('--windows --window ' .. tostring(windowId), 'space')
  self:run({'-m', 'space', tostring(spaceIndex), '--display', tostring(display)}, function()
      self:run({'-m', 'display', '--space', tostring(spaceIndex)}, function()
	  self:run({'-m', 'windows', '--focus', tostring(windowId)}, cb)
      end)
  end)
end

-- toggle the current window as fullscreen
-- cb: callback function
-- return: none
function Yabai:toggleFullscreen(cb)
  self:run({'-m', 'window', '--toggle', 'zoom-fullscreen'}, cb)
end

--------------------------------------------------------------------------------
-- display
--------------------------------------------------------------------------------

-- get the unused space label
-- return: the unused space label
function Yabai:findUnusedLabel()
  for i = 1, 10 do
    local label = 'label-' .. tostring(i)
    if self.labels[label] == nil then
      return label
    end
  end
  self.log.e('cannot find an unused label')
  return ''
end

-- reset canvases
-- return: none
function Yabai:resetCanvases()
  for _, c in pairs(self.canvases) do c:delete() end
  self.canvases = {}
  for k, v in pairs(self.displays) do
    local w = self.labels_size * self.icon_size + self.apps_size * self.icon_size
    local x = v.x + (v.w / 2) - (w / 2)
    local y = v.y
    if k == self.notch_display then
      local s = hs.screen.find({x=v.x, y=v.y})
      if s ~= nil then y = s:frame().y end
    end
    local c = hs.canvas.new({x=x, y=y, w=w, h=self.icon_size})
    self.canvases[k] = c
  end
end

-- insert the element to all canvases
-- element: the element to be added
-- return: none
function Yabai:insertElement(element, index)
  for _, c in pairs(self.canvases) do
    c:insertElement(element, index + 1)
  end
end

-- show canvases and set click event
-- return: none
function Yabai:showCanvases()
  self.log.d('show canvases')
  for _, c in pairs(self.canvases) do
    c:mouseCallback(function(canvas, event, id, x, y)
	-- find display
	local dispaly = nil
	for k, v in pairs(self.canvases) do
	  self.log.d('canvas:', k, v, canvas)
	  if v:topLeft().x == canvas:topLeft().x then display = k end
	end
	-- find window
	local window = self.ids[math.floor(x / self.icon_size) + 1]
	-- show
	self:focusDisplay(display, function()
			    if window > 0 then
			      self:showWindowIdInDisplay(window, display, nil)
			    else
			      self:showSpaceInActiveDisplay(window * -1, nil)
			    end
	end)
    end)
    c:canvasMouseEvents(false, true, false, false)
    c:show()
  end
end

-- update indicator status
-- return: none
function Yabai:updateIndicator()
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

-- display spaces/windows information on all displays
-- return: none
function Yabai:displaySpaces()
  -- reset canvases
  self:resetCanvases()
  -- add spaces
  self.ids = {}
  local index = 0
  local keys = {}
  for k, v in pairs(self.labels) do table.insert(keys, k) end
  table.sort(keys, function(a, b) return tonumber(string.sub(a, 7)) < tonumber(string.sub(b, 7)) end)
  for _, k in pairs(keys) do
    local alpha = 0.5
    if self.labels[k].visible then alpha = 1.0 end
    local labelText = hs.styledtext.new(string.sub(k, 7), {
					  font={size=20},
					  color={red=0, green=0, blue=0, alpha=alpha},
					  paragraphStyle={alignment='center'}
    })
    self:insertElement({
	type = 'text',
	text = labelText,
	padding = 3.0,
	frame = {x=self.icon_size*index, y=0, w=self.icon_size, h=self.icon_size}
    }, index)
    table.insert(self.ids, tonumber(string.sub(k, 7)) * -1)
    index = index + 1
    -- add windows
    if self.apps[k] ~= nil then
      for k, v in pairs(self.apps[k]) do
	local name = v.name
	if self.renames[v.name] ~= nil then name = self.renames[v.name] end
	local app = hs.appfinder.appFromName(name)
	if app ~= nil then
	  local appBundle = app:bundleID()
	  local appImage = hs.image.imageFromAppBundle(appBundle)
	  self:insertElement({
	      type = 'image',
	      image = appImage,
	      frame = {x=self.icon_size*index, y=0, w=self.icon_size, h=self.icon_size},
	      imageAlpha = alpha
	  }, index)
	  table.insert(self.ids, v.id)
	end
	index = index + 1
      end
    end
  end
  -- add key indicator
  self:insertElement({
      type = 'circle',
      strokeColor = {red=0, green=0, blue=0, alpha=0.5},
      fillColor = {red=0, green=0, blue=0, alpha=0.5},
      center = {x=self.icon_size*index-2, y=2},
      radius = 1,
  }, index)
  -- show
  self:showCanvases()
end

-- sync windows information from yabai
-- return: none
function Yabai:syncApps()
  -- reset windows info.
  self.apps = {}
  self.apps_size = 0
  local output = self:execute(self.yabai .. ' -m query --windows', 'r')
  if output == '' then
    return
  end
  local windows = hs.json.decode(output)
  for k, v in pairs(windows) do
    if self.apps[self.spaces[v.space]] == nil then
      self.apps[self.spaces[v.space]] = {}
    end
    table.insert(self.apps[self.spaces[v.space]], {name=v.app, id=v.id})
    self.apps_size = self.apps_size + 1
  end
end

-- sync spaces information from yabai
-- return: none
function Yabai:syncSpaces()
  -- reset spaces info.
  self.labels = {}
  self.spaces = {}
  self.labels_size = 0
  -- import existing labels
  local output = self:execute(self.yabai .. ' -m query --spaces', 'r')
  if output == '' then
    return
  end
  local spaces = hs.json.decode(output)
  for k, v in pairs(spaces) do
    if string.sub(v['label'], 1, 6) == 'label-' then
      self.labels[v['label']] = {index=v['index'], visible=v['is-visible']}
      self.spaces[v['index']] = v['label']
      self.labels_size = self.labels_size + 1
    end
  end
  -- set new labels
  for k, v in pairs(spaces) do
    if string.sub(v['label'], 1, 6) ~= 'label-' then
      self.log.d(k, v['label'], v['index'])
      local label = self:findUnusedLabel()
      self:run({'-m', 'space', tostring(v['index']), '--label', label}, nil)
      self.labels[label] = {index=v['index'], visible=v['is-visible']}
      self.spaces[v['index']] = label
      self.labels_size = self.labels_size + 1
    end
  end
end

-- sync displays information from yabai
-- return: none
function Yabai:syncDisplays()
  -- reset displays info.
  self.displays = {}
  -- import displays
  local output = self:execute(self.yabai .. ' -m query --displays', 'r')
  if output == '' then
    return
  end
  local displays = hs.json.decode(output)
  for k, v in pairs(displays) do
    self.displays[v['index']] = v['frame']
  end
end

-- replace apps
-- return: none
function Yabai:replaceApps()
  for k, v in pairs(self.apps) do
    for _, v in pairs(v) do
      self.log.d('replace:', k, v.name)
      if self.places[v.name] ~= nil and k ~= self.places[v.name] then
	self:run({'-m', 'window', tostring(v.id), '--space', self.places[v.name]}, nil)
      end
    end
  end
  self:syncApps()
  self:displaySpaces()
end

-- init instance
-- mods: mods key for prefix
-- key: normal key for prefix
-- return: none
function Yabai:init(mods, key)
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

  -- sync displays, spaces, windows
  self:syncDisplays()
  self:syncSpaces()
  self:syncApps()
  -- display spaces
  self:displaySpaces()

  -- set refresh timer
  if self.refresh_timer > 0 then
    self.timer = hs.timer.new(refresh_timer, function()
				self:syncDisplay()
				self:syncSpaces()
				self:syncApps()
				self:displaySpaces()
    end)
    self.timer:start()
  end

  -- set display watcher
  self.screenWatcher = hs.screen.watcher.new(function()
      self.log.d('screen watcher')
      self:syncDisplays()
      self:syncSpaces()
      self:syncApps()
      self:displaySpaces()
  end)
  self.screenWatcher:start()

  -- set space watcher
  self.spaceWatcher = hs.spaces.watcher.new(function()
      self.log.d('space watcher')
      self:syncSpaces()
      self:syncApps()
      self:displaySpaces()
  end)
  self.spaceWatcher:start()

  -- set window watcher
  self.appWatcher = hs.application.watcher.new(function()
      self.log.d('app watcher')
      self:syncApps()
      self:displaySpaces()
  end)
  self.appWatcher:start()
end

-- create new instance
-- mods: mods key for prefix
-- key: normal key for prefix
-- return: new instance
function Yabai:new(mods, key)
  local _self = setmetatable({
      -- internal data
      displays = {}, -- display index table - displays[display index] = {x=x, y=y, w=w, h=h}

      labels = {}, -- space label table - labels[label] = {index=index, visible=true/false}
      spaces = {}, -- space index table - spaces[index] = label
      labels_size = 0, -- size of labels

      apps = {}, -- app id table - apps[space label][app] = {name=name, id=id}
      apps_size = 0, -- size of apps

      canvases = {}, -- canvas table - canvases[display index] = canvas
      ids = {}, -- window id table

      timer = nil, -- refresh timer

      screenWatcher = nil,
      spaceWatcher = nil,
      appWatcher = nil,
			     }, self)
  self.__index = self

  _self:init(mods, key)

  return _self
end

return Yabai
