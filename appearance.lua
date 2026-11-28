-- Hyprland-only palette adapter. nullshell owns and persists the effective appearance mode.
-- Use the shell's effective mode with this configuration's own colours.
-- Window borders use a quieter blue than the shell's interactive accent.
local M = {}

function M.apply(mode)
  if not mode then
    local state = os.getenv("XDG_STATE_HOME")
    if not state or state == "" then state = os.getenv("HOME") .. "/.local/state" end
    local file = io.open(state .. "/nullshell/appearance-mode", "r")
    if file then
      mode = file:read("*a"):match("^%s*(.-)%s*$")
      file:close()
    end
    -- A missing, empty or damaged saved snapshot must still apply a complete palette.
    if mode ~= "dark" and mode ~= "light" then mode = "dark" end
  end
  if mode ~= "dark" and mode ~= "light" then return end

  local dark = mode == "dark"
  local active = dark and "rgba(568ec2ff)" or "rgba(3d82bdff)"
  local inactive = dark and "rgba(3e424b80)" or "rgba(8e95a080)"
  local locked = dark and "rgba(e5bc82ff)" or "rgba(7d5112ff)"
  hl.config({
    general = {
      ["col.active_border"] = active,
      ["col.inactive_border"] = inactive,
    },
    decoration = {
      shadow = { color = dark and "rgba(00000066)" or "rgba(0f141c22)" },
    },
    group = {
      ["col.border_active"] = active,
      ["col.border_inactive"] = inactive,
      ["col.border_locked_active"] = locked,
      ["col.border_locked_inactive"] = dark and "rgba(69707aff)" or "rgba(8e95a080)",
      groupbar = {
        text_color = dark and "rgba(f2f4f6ff)" or "rgba(17191cff)",
        ["col.active"] = dark and "rgba(1b3d5cff)" or "rgba(b8def8ff)",
        ["col.inactive"] = dark and "rgba(16181bf5)" or "rgba(f3f4f5fa)",
        ["col.locked_active"] = dark and "rgba(51432dff)" or "rgba(f0e3cdff)",
        ["col.locked_inactive"] = dark and "rgba(202227ff)" or "rgba(e2e4e7ff)",
      },
    },
  })
end

return M
