{
  stdenv,
  makeSetupHook,
}:

if stdenv.hostPlatform.isDarwin then
  null
else
  makeSetupHook {
    name = "headlessDisplayCheckHook";
  } ./headless-display-check-hook.sh
