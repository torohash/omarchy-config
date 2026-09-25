
-- OpenWhispr launcher (omarchy-config: openwhispr)
-- Running `openwhispr` again opens the existing Control Panel, so no focus pattern is needed
-- (a focus pattern would match the small "Voice Recorder" panel of the same window class).
o.bind("SUPER + SHIFT + V", "OpenWhispr", { launch = "openwhispr" })
