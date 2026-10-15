-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- 1x (non-HiDPI) setup. This machine's panel is a 1366x768 eDP display, and the
-- Omarchy 4 default of omarchy_gdk_scale = 2 assumes a HiDPI/retina screen.
-- Keep omarchy_gdk_scale equal to omarchy_monitor_scale: GDK-aware XWayland apps
-- (e.g. REAPER via libSwell's gdk_monitor_get_scale_factor) render distorted and
-- overlap when GDK_SCALE disagrees with the real monitor scale.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
