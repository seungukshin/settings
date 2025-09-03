local last_tab = 0
local curr_tab = 0

local open = ya.sync(function(state, args)
    local i = cx.active.current.hovered
    if not i then return end
    if i.cha.is_dir then
      ya.emit('enter', { i.url })
    else
      ya.emit('open', { i.url })
    end
end)

local find = ya.sync(function(state, args)
    local f = cx.active.finder
    if f then
      cmd = 'find_arrow'
      arg = {}
    else
      cmd = 'find'
      arg = { smart = true }
    end
    arg.previous = args.previous
    ya.emit(cmd, arg)
end)

local tab_switch_last = ya.sync(function(state, args)
    local current = last_tab
    last_tab = curr_tab
    curr_tab = current
    ya.emit('tab_switch', { current - 1 })
end)

local funcs = {
  ['open'] = open,
  ['find'] = find,
  ['tab_switch_last'] = tab_switch_last,
}

return {
  setup = function(state, opts)
    ps.sub('hover', function(payload)
	     local current = cx.tabs.idx
	     if curr_tab ~= current then
	       last_tab = curr_tab
	       curr_tab = current
	     end
    end)
  end,
  entry = function(_, job)
    local action = job.args[1]
    if not action then return end
    local func = funcs[action]
    if not func then return end
    func(job.args)
  end,
}
