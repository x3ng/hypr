-- Autostart (exec-once equivalent)
hl.on("hyprland.start", function()
  -- Start independent shell components once with native Quickshell config discovery.
  hl.exec_cmd("quickshell -c nullshell/lock --no-duplicate")
  hl.exec_cmd("quickshell -c nullshell/polkit --no-duplicate")
  hl.exec_cmd("quickshell -c nullshell --no-duplicate")
  -- Helper: logind sleep coordination, which Quickshell does not provide.
  hl.exec_cmd("nullshell sleep-bridge")
  hl.exec_cmd("clipse -listen")
  hl.exec_cmd("udiskie")
  -- Fcitx5 starts through XDG Autostart (handled by UWSM in this session).
  -- Do not also launch it here: --replace races with the session's instance.
end)
