-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Application bindings
-- SUPER+F was: Full screen
hl.unbind("SUPER + F")
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
-- SUPER+SHIFT+B was: Browser
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + ALT + DELETE", "Activity", { tui = "btop" })
-- SUPER+SHIFT+W was: Omawrite
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })
o.bind("SUPER + N", "Network", "omarchy-shell shell toggle omarchy.network")

-- Window management
-- Monocle: toggle a tabbed group (zoom into one app) for the active workspace.
o.bind("SUPER + Z", "Monocle", function()
  local active = hl.get_active_window()
  if not active or not active.workspace then
    return
  end

  local windows = hl.get_workspace_windows(active.workspace)

  local grouped = false
  for _, win in ipairs(windows) do
    if win.group then
      grouped = true
      break
    end
  end

  if grouped then
    -- Ungroup every grouped window.
    for _, win in ipairs(windows) do
      if win.group then
        hl.dispatch(hl.dsp.focus({ window = win }))
        hl.dispatch(hl.dsp.window.move({ out_of_group = true }))
      end
    end
  else
    -- Group the active window, then pull the rest in from all directions.
    hl.dispatch(hl.dsp.group.toggle())
    for _, win in ipairs(windows) do
      if not win.group and win.mapped then
        hl.dispatch(hl.dsp.focus({ window = win }))
        hl.dispatch(hl.dsp.window.move({ into_group = "l" }))
        hl.dispatch(hl.dsp.window.move({ into_group = "r" }))
        hl.dispatch(hl.dsp.window.move({ into_group = "u" }))
        hl.dispatch(hl.dsp.window.move({ into_group = "d" }))
      end
    end
  end

  -- Return focus to the originally active window.
  hl.dispatch(hl.dsp.focus({ window = active }))
end)
-- ALT+TAB was: Focus on next window / Reveal active window on top
hl.unbind("ALT + TAB")
o.bind("ALT + TAB", nil, hl.dsp.group.next())
-- SUPER+X was: Universal cut
hl.unbind("SUPER + X")
o.bind("SUPER + X", nil, hl.dsp.window.close())
o.bind("SUPER + H", nil, hl.dsp.focus({ direction = "l" }))
-- SUPER+J was: Toggle window split
hl.unbind("SUPER + J")
o.bind("SUPER + J", nil, hl.dsp.focus({ direction = "d" }))
-- SUPER+K was: Keybindings
hl.unbind("SUPER + K")
o.bind("SUPER + K", nil, hl.dsp.focus({ direction = "u" }))
-- SUPER+L was: Toggle workspace layout
hl.unbind("SUPER + L")
o.bind("SUPER + L", nil, hl.dsp.focus({ direction = "r" }))

-- Move active window with SUPER + Arrow keys
-- Arrows were: Focus on left/right/up/down window
hl.unbind("SUPER + LEFT")
o.bind("SUPER + LEFT", nil, hl.dsp.window.move({ direction = "l" }))
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + RIGHT", nil, hl.dsp.window.move({ direction = "r" }))
hl.unbind("SUPER + UP")
o.bind("SUPER + UP", nil, hl.dsp.window.move({ direction = "u" }))
hl.unbind("SUPER + DOWN")
o.bind("SUPER + DOWN", nil, hl.dsp.window.move({ direction = "d" }))

-- Toggle floating window
-- SUPER+SHIFT+F was: File manager
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", nil, hl.dsp.window.float({ action = "toggle" }))
