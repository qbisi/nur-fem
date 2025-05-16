preCheckHooks+=('setupHeadlessDisplay')
preInstallCheckHooks+=('setupHeadlessDisplay')

setupHeadlessDisplay() {
  if [[ -n "$DISPLAY" ]]; then
    echo "DISPLAY already set. Skipping..."
    return
  fi

  if command -v weston >/dev/null 2>&1; then
      export XDG_RUNTIME_DIR=$(mktemp -d)
      mkdir -p /tmp/.X11-unix
      weston --backend=headless-backend.so --xwayland --idle-time=0 >/dev/null &
      export DISPLAY=:0
  elif command -v Xvfb >/dev/null 2>&1; then
      Xvfb :99 -screen 0 1920x1080x24 >/dev/null &
      export DISPLAY=:99
  else
      echo "Error: Neither 'weston' nor 'Xvfb' found in PATH."
      echo "Hint: please add 'weston' or 'xvfb' to nativeCheckInputs."
      exit 1
  fi
}