
-- Passwords key: 1Password -> Bitwarden (omarchy-config: bitwarden)
-- Omarchy default: o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })
-- The binary is `bitwarden-desktop`. focus "^Bitwarden$" matches only the window class Bitwarden.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^Bitwarden$" })
