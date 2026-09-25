
-- Personal overrides (omarchy-config: hyprland-input)
-- Keyboard: US layout instead of the vconsole-derived layout.
-- Touchpad: natural (inverse) scrolling, flipped from Omarchy's default false.
hl.config({
  input = {
    kb_layout = "us",
    touchpad = {
      natural_scroll = true,
    },
  },
})
