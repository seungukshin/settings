function Linemode:size_mtime_perm()
  local time = math.floor(self._file.cha.mtime or 0)
  if time == 0 then
    time = ""
  else
    time = os.date("%y-%m-%d %H:%M", time)
  end

  local size = self._file:size()
  local perm = self._file.cha:perm() or "-"
  return string.format("%s %s %s", size and ya.readable_size(size) or "-", time, perm)
end

Header:children_add(function()
    if ya.target_family() ~= "unix" then
      return ""
    end
    return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)

Status:children_add(function()
    local h = cx.active.current.hovered
    if not h or ya.target_family() ~= "unix" then
      return ""
    end

    return ui.Line {
      ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
      ":",
      ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
      " ",
    }
end, 500, Status.RIGHT)

require("projects"):setup({
    save = {
      method = "lua", -- yazi | lua
      yazi_load_event = "@projects-load", -- event name when loading projects in `yazi` method
      lua_save_path = os.getenv("HOME") .. "/.local/state/yazi/projects.json",
      -- path of saved file in `lua` method, comment out or assign explicitly
      -- default value:
      -- windows: "%APPDATA%/yazi/state/projects.json"
      -- unix: "~/.local/state/yazi/projects.json"
    },
    last = {
      update_after_save = true,
      update_after_load = true,
      load_after_start = true,
    },
    merge = {
      event = "projects-merge",
      quit_after_merge = false,
    },
    event = {
      save = {
	enable = true,
	name = "project-saved",
      },
      load = {
	enable = true,
	name = "project-loaded",
      },
      delete = {
	enable = true,
	name = "project-deleted",
      },
      delete_all = {
	enable = true,
	name = "project-deleted-all",
      },
      merge = {
	enable = true,
	name = "project-merged",
      },
    },
    notify = {
      enable = true,
      title = "Projects",
      timeout = 3,
      level = "info",
    },
})

require("extra-funcs"):setup({})
