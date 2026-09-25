
-- OpenWhispr (omarchy-config: openwhispr)
-- Calls the running OpenWhispr over D-Bus; starts it when it is not running.
-- Voxtype keeps F9 / SUPER+CTRL+X.
local openwhispr = "dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App."
o.bind("SUPER + SHIFT + K", "OpenWhispr dictation", openwhispr .. "Toggle || uwsm-app -- openwhispr")
o.bind("SUPER + SHIFT + J", "OpenWhispr meeting", openwhispr .. "ToggleMeeting || uwsm-app -- openwhispr")
