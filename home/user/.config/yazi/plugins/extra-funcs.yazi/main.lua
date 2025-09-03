local last_tab = 0
local curr_tab = 0
local layout_backup = {
  backup = false,
}

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

local tasks = ya.sync(function(state, args)
    if layout_backup.backup then
      Tab.layout = layout_backup.layout
      Tab.build = layout_backup.build
      layout_backup.backup = false
    else
      layout_backup.layout = Tab.layout
      layout_backup.build = Tab.build
      layout_backup.backup = true

      Tab.layout = function(self)
	local main = ui.Layout()
	  :direction(ui.Layout.VERTICAL)
	  :constraints({
	      ui.Constraint.Percentage(50),
	      ui.Constraint.Percentage(50),
	  })
	  :split(self._area)
	local pane = ui.Layout()
	  :direction(ui.Layout.HORIZONTAL)
	  :constraints({
	      ui.Constraint.Percentage(50),
	      ui.Constraint.Percentage(50),
	  })
	  :split(main[1])
	self._chunks = {
	  pane[1],
	  pane[2],
	  main[2],
	}
	--ya.dbg('cx:', cx)
	--ya.dbg('tasks:', cx.tasks)
	--ya.dbg('visible:', cx.tasks.visible)
      end
      Tab.build = function(self)
      	local c = self._chunks
	self._children = {
	  Current:new(c[1]:pad(ui.Pad.x(1)), self._tab),
	  Preview:new(c[2]:pad(ui.Pad.x(1)), self._tab),
	  Tasks:new(c[3]),
	  --Rails:new(c, self._tab),
	  Marker:new(c[1], self._tab.current),
	}
      end
      --ya.dbg('cx.tasks.visible:', cx.tasks.visible)
      ya.emit("tasks:show", {})
      --[[
      Tab.redraw = function(self)
	ya.dbg('cx.tasks:', cx.tasks)
	for k, v in pairs(cx.tasks) do
	  ya.dbg(k, v)
	end
	--cx.tasks.visible = true
	local elements = self._base or {}
	for _, child in ipairs(self._children) do
	  elements = ya.list_merge(elements, ui.redraw(child))
	end
	return elements
      end
      ]]--
    end
    ui.render()
end)

local funcs = {
  ['open'] = open,
  ['find'] = find,
  ['tab_switch_last'] = tab_switch_last,
  ['tasks'] = tasks,
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
