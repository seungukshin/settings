local wezterm = require('wezterm')
local mux = wezterm.mux
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- helper functions for shell command
--------------------------------------------------------------------------------
-- prompt should be escaped by % before special characters '( ) . % + - * ? [ ^ $'
-- end of prompt $ should be added to prevent the command is append to other characters
-- useage:
--     local prompt = 'test%-server:~%$$'
--     if exec_command(pane, prompt, 'sleep 4', 10) then
--       wezterm.log_info('done')
--     else
--       wezterm.log_info('timeout')
--     end

function wait_prompt(pane, prompt, timeout)
  local t = os.clock()
  while os.clock() - t < 1 do end -- wait 1 sec.
  t = os.clock()
  while os.clock() - t < timeout do
    local output = pane:get_logical_lines_as_text(1)
    if output:find(prompt) then
      return true
    end
  end
  return false
end

function exec_command(pane, prompt, command, timeout)
  if not wait_prompt(pane, prompt, timeout) then return false end
  pane:send_text(command .. '\n')
  if not wait_prompt(pane, prompt, timeout) then return false end
  return true
end

function add_escape(line)
  line = line:gsub('%(', '%%(')
  line = line:gsub('%)', '%%)')
  line = line:gsub('%.', '%%.')
  line = line:gsub('%%', '%%%%')
  line = line:gsub('%+', '%%+')
  line = line:gsub('%-', '%%-')
  line = line:gsub('%*', '%%*')
  line = line:gsub('%?', '%%?')
  line = line:gsub('%[', '%%[')
  line = line:gsub('%^', '%%^')
  line = line:gsub('%$', '%%$')
  return line
end

--------------------------------------------------------------------------------

-- shell
if wezterm.target_triple:find('windows') then
  config.default_prog = { 'powershell.exe' }
end

-- plugins
local resurrect = nil
if not wezterm.target_triple:find('windows') then
  resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
end

-- color
local LIGHTBLUE='#00afff'
local WHITE='#e4e4e4'
local YELLOW='#ffff00'
local PINK='#ff00af'
local LIGHTGRAY='#8a8a8a'
local GRAY='#303030'
local DARKGRAY='#080808'
local RED='#d70000'

-- appearance
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- colors
config.window_background_opacity = 0.7
config.color_scheme = 'Monokai (dark) (terminal.sexy)'
config.color_schemes = {
  ['Monokai (dark) (terminal.sexy)'] = {
    background = DARKGRAY,
  },
}
config.colors = {
  tab_bar = {
    background = DARKGRAY,
    new_tab = {
      bg_color = DARKGRAY,
      fg_color = LIGHTGRAY,
    }
  }
}

-- tab
--config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

-- font
config.font = wezterm.font('Inconsolata Nerd Font', { weight = 'Bold' })
config.font_size = 16

-- key bindings
--config.debug_key_events = true
--config.disable_default_key_bindings = true
local act = wezterm.action
config.leader = { key = 't', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
  { key = 't', mods = 'ALT',    action = act.DisableDefaultAssignment },

  { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
  {
    key = 't',
    mods = 'LEADER',
    action = act.Multiple({
      act.ActivateLastTab,
      act.EmitEvent('activate-tab')
    })
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = act.Multiple({
      act.ActivateTabRelative(-1),
      act.EmitEvent('activate-tab')
    })
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.Multiple({
      act.ActivateTabRelative(1),
      act.EmitEvent('activate-tab')
    })
  },

  { key = '|', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection('Right') },
  {
    key = 'o',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local pane_id = pane:pane_id()
      local next_pane = nil
      local first = true
      local save = false
      for _, v in pairs(window:active_tab():panes()) do
	if first then
	  next_pane = v
	  first = false
	end
	if save then
	  next_pane = v
	  break
	end
	if v:pane_id() == pane_id then
	  save = true
	end
      end
      next_pane:activate()
    end)
  },
  {
    key = 'O',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local pane_id = pane:pane_id()
      local prev_pane = nil
      local last = false
      for _, v in pairs(window:active_tab():panes()) do
	if not last and v:pane_id() == pane_id then
	  if prev_pane == nil then
	    last = true
	  else
	    break
	  end
	end
	prev_pane = v
      end
      prev_pane:activate()
    end)
  },

  { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize({ 'Left', 5 }) },
  { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize({ 'Down', 5 }) },
  { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize({ 'Up', 5 }) },
  { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize({ 'Right', 5 }) },

  { key = 'Y', mods = 'CTRL',   action = act.PasteFrom('Clipboard') },
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine({
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
	if line then window:active_tab():set_title(line) end
      end)
    })
  },

  {
    key = 's',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      if not resurrect then return end
      window:toast_notification('wezterm', 'save a session', nil, 3000)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      resurrect.window_state.save_window_action()
      resurrect.tab_state.save_tab_action()
    end)
  },
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      if not resurrect then return end
      window:toast_notification('wezterm', 'restore a session', nil, 3000)
      resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$") -- match after '/'
        id = string.match(id, "(.+)%..+$") -- remove file extention
        local opts = {
	  close_open_tabs = true,
	  window = pane:window(),
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.state_manager.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "window" then
          local state = resurrect.state_manager.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.state_manager.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end)
  },
}
local shift_num = { '!', '@', '#', '$', '%', '^', '&', '*', '(' }
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.Multiple({
      act.ActivateTab(i - 1),
      act.EmitEvent('activate-tab')
    })
  })
  table.insert(config.keys, {
    key = shift_num[i],
    mods = 'LEADER',
    action = act.MoveTab(i - 1)
  })
end

config.key_tables = {
  copy_mode = {
    { key = 'b', mods = 'CTRL', action = act.CopyMode('MoveLeft') },
    { key = 'n', mods = 'CTRL', action = act.CopyMode('MoveDown') },
    { key = 'p', mods = 'CTRL', action = act.CopyMode('MoveUp') },
    { key = 'f', mods = 'CTRL', action = act.CopyMode('MoveRight') },

    { key = 'b', mods = 'ALT', action = act.CopyMode('MoveBackwardWord') },
    { key = 'f', mods = 'ALT', action = act.CopyMode('MoveForwardWord') },

    { key = 'e', mods = 'CTRL', action = act.CopyMode('MoveToEndOfLineContent') },
    { key = 'a', mods = 'CTRL', action = act.CopyMode('MoveToStartOfLine') },

    { key = 'v', mods = 'CTRL', action = act.CopyMode('PageDown') },
    { key = 'v', mods = 'ALT', action = act.CopyMode('PageUp') },

    { key = 'Space', mods = 'CTRL', action = act.CopyMode({ SetSelectionMode = 'Cell' }) },
    { key = 'Enter', mods = 'ALT', action = act.CopyMode({ SetSelectionMode = 'Block' }) },

    { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
    {
      key = 'w',
      mods = 'ALT',
      action = act.Multiple({
	{ CopyTo = 'ClipboardAndPrimarySelection' },
	{ CopyMode = 'Close' },
      })
    },
  }
}

-- command palette
config.ssh_domains = wezterm.default_ssh_domains()
local ssh_list = {}
for _, v in pairs(config.ssh_domains) do
  if v.name:find('SSH:') then
    table.insert(ssh_list, {
      id = v.name,
      label = v.name,
    })
  end
end
wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Shell: New Tab (Domain SSH:*)',
      icon = 'md_ssh',
      action = act.InputSelector({
	title = 'ssh to',
	choices = ssh_list,
        action = wezterm.action_callback(function(window, pane, id, label)
          if id then
	    local mux_window = window:mux_window()
	    local tab, _, _ = mux_window:spawn_tab({
	      domain = { DomainName = id }
	    })
	    tab:set_title(id:sub(5, -1))
          end
        end),
      })
    },
    {
      brief = 'Shell: Current Tab (Domain SSH:*)',
      icon = 'md_ssh',
      action = act.InputSelector({
	title = 'ssh to',
	choices = ssh_list,
        action = wezterm.action_callback(function(window, pane, id, label)
          if id then
            local tab_id = window:active_tab():tab_id()
            window:perform_action(act.CloseCurrentTab({ confirm = false }), pane)
	    local mux_window = window:mux_window()
	    local tab, npane, _ = mux_window:spawn_tab({
	      domain = { DomainName = id }
	    })
	    tab:set_title(id:sub(5, -1))
            window:perform_action(act.MoveTab(tab_id), npane)
          end
        end),
      })
    },
  }
end)

-- status
--[[
wezterm.on('update-status', function(window)
  local success, stdout, stderr
  local uptime = ''
  if wezterm.target_triple:find('windows') then
    success, stdout, stderr = wezterm.run_child_process({'powershell.exe', '$uptime=(Get-Date)-(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime; Write-Host ("{0:d2} days {1:d2}:{2:d2}" -f $uptime.days, $uptime.hours, $uptime.minutes)'})
    uptime = stdout:gsub('[\n\r]', '')
  else
    success, stdout, stderr = wezterm.run_child_process({'uptime'})
    uptime = stdout:gsub('^.*up', '')
    uptime = uptime:gsub(', %d+ user.*', '')
    uptime = uptime:gsub(',', '')
    uptime = uptime:gsub('  ', ' ')
  end

  local cpu = ''
  if wezterm.target_triple:find('darwin') then
    success, stdout, stderr = wezterm.run_child_process({'top', '-R', '-F', '-n0', '-l2'})
    local cpu_line = ''
    for v in stdout:gmatch('%d+.%d+%% idle') do
      cpu_line = v
    end
    local cpu_len = cpu_line:find('%%')
    cpu = string.format('%.1f%%', 100 - tonumber(cpu_line:sub(0, cpu_len - 1)))
  elseif wezterm.target_triple:find('windows') then
    success, stdout, stderr = wezterm.run_child_process({'powershell.exe', '$cpu = (Get-Counter \'\\Processor(_total)\\% Processor Time\').Countersamples.CookedValue; Write-Host ("{0:n1}%" -f $cpu)'})
    cpu = stdout:gsub('[\n\r]', '')
  else
  end

  local mem = ''
  if wezterm.target_triple:find('darwin') then
    success, stdout, stderr = wezterm.run_child_process({'vm_stat'})
    local key = ''
    local used = 0
    local cached = 0
    local free = 0
    for v in stdout:gmatch('[^:\n]+') do
      if key == 'used' then used = used + v:gsub('[ .]', '')
      elseif key == 'cached' then cached = cached + v:gsub('[ .]', '')
      elseif key == 'free' then free = free + v:gsub('[ .]', '')
      end

      if     v == 'Pages free' then                   key = 'free'
      elseif v == 'Pages active' then                 key = 'used'
      elseif v == 'Pages inactive' then               key = 'used'
      elseif v == 'Pages speculative' then            key = 'used'
      elseif v == 'Pages wired down' then             key = 'used'
      elseif v == 'Pages purgeable' then              key = 'cached'
      elseif v == 'File-backed pages' then            key = 'cached'
      elseif v == 'Pages occupied by compressor' then key = 'used'
      else                                            key = ''
      end
    end
    mem = string.format('%.1f%%', 100 * (used - cached) / (used + free))
  elseif wezterm.target_triple:find('windows') then
    success, stdout, stderr = wezterm.run_child_process({'powershell.exe', '$total = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum; $free = (Get-Counter \'\\Memory\\Available MBytes\').Countersamples.CookedValue; $used = $total - (1048576 * $free); Write-Host ("{0:n1}%" -f (100 * $used / $total))'})
    mem = stdout:gsub('[\n\r]', '')
  else
  end

  local battery = ''
  for _, b in ipairs(wezterm.battery_info()) do
    if b.state == 'Charging' or b.state == 'Full' then
      if     b.state_of_charge > 0.9  then battery = ' 󰂅 '
      elseif b.state_of_charge > 0.8  then battery = ' 󰂋 '
      elseif b.state_of_charge > 0.7  then battery = ' 󰂊 '
      elseif b.state_of_charge > 0.6  then battery = ' 󰢞 '
      elseif b.state_of_charge > 0.5  then battery = ' 󰂉 '
      elseif b.state_of_charge > 0.4  then battery = ' 󰢝 '
      elseif b.state_of_charge > 0.3  then battery = ' 󰂈 '
      elseif b.state_of_charge > 0.2  then battery = ' 󰂇 '
      elseif b.state_of_charge > 0.1  then battery = ' 󰂆 '
      elseif b.state_of_change > 0.05 then battery = ' 󰢜 '
      else                                 battery = ' 󰢟 '
      end
    else
      if     b.state_of_charge > 0.9  then battery = ' 󰁹 '
      elseif b.state_of_charge > 0.8  then battery = ' 󰂂 '
      elseif b.state_of_charge > 0.7  then battery = ' 󰂁 '
      elseif b.state_of_charge > 0.6  then battery = ' 󰂀 '
      elseif b.state_of_charge > 0.5  then battery = ' 󰁿 '
      elseif b.state_of_charge > 0.4  then battery = ' 󰁾 '
      elseif b.state_of_charge > 0.3  then battery = ' 󰁽 '
      elseif b.state_of_charge > 0.2  then battery = ' 󰁼 '
      elseif b.state_of_charge > 0.1  then battery = ' 󰁻 '
      elseif b.state_of_change > 0.05 then battery = ' 󰁺 '
      else                                 battery = ' 󰂃 '
      end
    end
    battery = battery .. string.format('%.0f%%', b.state_of_charge * 100)
  end

  success, stdout, stderr = wezterm.run_child_process({'whoami'})
  local id = stdout:gsub('[\n\r]', '')

  window:set_left_status(wezterm.format({
    { Background = { Color = YELLOW } },
    { Foreground = { Color = DARKGRAY } },
    { Text = ' ❐ ' .. window:active_workspace() .. ' ' },
    { Background = { Color = PINK } },
    { Foreground = { Color = YELLOW } },
    { Text = '' },
    { Background = { Color = PINK } },
    { Foreground = { Color = WHITE } },
    { Text = ' ' .. uptime .. ' ' },
    { Background = { Color = DARKGRAY } },
    { Foreground = { Color = PINK } },
    { Text = '' },
  }))
  window:set_right_status(wezterm.format({
    { Background = { Color = DARKGRAY } },
    { Foreground = { Color = LIGHTGRAY } },
    { Text = ' C:' .. cpu .. ' M:' .. mem .. ' ' .. battery .. '  ' .. wezterm.strftime('%m-%d %H:%M') .. ' ' },
    { Background = { Color = DARKGRAY } },
    { Foreground = { Color = RED } },
    { Text = '' },
    { Background = { Color = RED } },
    { Foreground = { Color = WHITE } },
    { Text = ' ' .. id .. ' ' },
    { Background = { Color = WHITE } },
    { Foreground = { Color = DARKGRAY } },
    { Text = ' ' .. wezterm.hostname() .. ' ' },
    }))
end)
]]--
wezterm.on('format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local title = tab.tab_title
    if not title or #title == 0 then
      title = tab.active_pane.title
    end
    if title:len() > (config.tab_max_width - 9) then
      title = title:sub(1, config.tab_max_width - 9)
    end

    if tab.is_active then
      return {
        { Background = { Color = LIGHTBLUE } },
        { Foreground = { Color = DARKGRAY } },
        { Text = ' ' .. tab.tab_index+1 .. '  '  .. title .. ' ' },
        { Background = { Color = DARKGRAY } },
        { Foreground = { Color = LIGHTBLUE } },
        { Text = '' },
      }
    end
    --[[if tab.is_last_active then
      return {
        { Background = { Color = GRAY } },
        { Foreground = { Color = DARKGRAY } },
        { Text = ' ' .. tab.tab_index+1 .. '  '  .. title .. ' ' },
        { Background = { Color = DARKGRAY } },
        { Foreground = { Color = GRAY } },
        { Text = '' },
      }
    end]]--
    return {
      { Background = { Color = DARKGRAY } },
      { Foreground = { Color = LIGHTBLUE } },
      { Text = '  ' .. tab.tab_index+1 .. '  '  .. title .. '  ' },
    }
end)

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window({})
  window:gui_window():maximize()
end)

-- connect to the server automatically
-- if the tab name is the same with a server name
wezterm.on('activate-tab', function(window, pane)
  local title = window:active_tab():get_title()
  if title == '' then return end
  local cmd = pane:get_foreground_process_name()
  if cmd and cmd:find('ssh') then return end
  local ssh_domain = wezterm.default_ssh_domains()
  for k, v in pairs(ssh_domain) do
    if title == v['name']:sub(8) then
      pane:send_text('ssh ' .. title .. ' -t "tmux at || tmux -2"\n')
      break
    end
  end
end)

return config
