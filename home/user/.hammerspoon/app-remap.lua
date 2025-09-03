local AppRemap = {
  name = 'AppRemap',
  version = '1.0',
  author = 'Seunguk Shin <seunguk.shin@gmail.com>',
  license = 'MIT - https://opensource.org/licenses/MIT',

  -- internal data
  log = hs.logger.new('AppRemap', 'info'),
}

-- register app name
-- appName: app name string
-- return: none
function AppRemap:addAppName(appName)
  self.appNames[appName] = true
end

-- register multiple app names
-- appNames: app name table {name1, name2, ...}
-- return: none
function AppRemap:setAppNames(appNames)
  for _, v in pairs(appNames) do
    self.appNames[v] = true
  end
end

-- set contain condition
-- isContained: true or false
--   - true: binds are activated when app is focused
--   - false: binds are activated when app is not foucsed
-- return: none
function AppRemap:setContained(isContained)
  self.isContained = isContained
end

-- register key binding
-- fromMods: source modifier keys
-- fromKey: source key
-- fromMods: destination modifier keys
-- toKey: destination key
-- return: none
function AppRemap:bind(fromMods, fromKey, toMods, toKey)
  self.modal:bind(fromMods, fromKey, nil, function() hs.eventtap.keyStroke(toMods, toKey, 0) end)
end

-- apply binding
-- prevAppName: app name losing the focus
-- currAppName: app name getting the focus
-- return: none
function AppRemap:apply(prevAppName, currAppName)
  if (prevAppName and self.appNames[prevAppName] == self.appNames[currAppName]) then
    return
  end
  if self.isContained then
    if self.appNames[currAppName] then self.modal:enter(); self.log.d('activate', self.name);
    else                               self.modal:exit(); self.log.d('deactivate', self.name);
    end
  else
    if self.appNames[currAppName] then self.modal:exit(); self.log.d('deactivate', self.name);
    else                               self.modal:enter(); self.log.d('activate', self.name);
    end
  end
end

-- start binding
-- return: none
function AppRemap:start()
  self.watcher = hs.application.watcher.new(function(appName, eventType, appObjectz)
      if eventType == hs.application.watcher.activated or
	eventType == hs.application.watcher.deactivated then
	self.eventAppNames[eventType] = appName
	self.log.d(self.eventAppNames[hs.application.watcher.deactivated], '->', self.eventAppNames[hs.application.watcher.activated])
	self:apply(self.eventAppNames[hs.application.watcher.deactivated], self.eventAppNames[hs.application.watcher.activated])
      end
  end)
  self.watcher:start()
  self:apply(nil, hs.application.frontmostApplication():name())
end

-- create new instance
-- paramName: name of this instance
-- return: new instance
function AppRemap:new(paramName)
  local _self = setmetatable({
      -- internal data
      name = paramName,
      appNames = {}, -- appNames[name] = true
      isContained = true,
      modal = hs.hotkey.modal.new(),
      watcher = nil,
      eventAppNames = {},
			     }, self)
  self.__index = self

  return _self
end

return AppRemap
