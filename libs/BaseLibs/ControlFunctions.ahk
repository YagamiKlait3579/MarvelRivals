;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%SuspendKey%, SuspendScript
    Hotkey, *%ReloadScriptKey%, ReloadScript
    Hotkey, *%StopScriptKey%, StopScript

;;;;;;;;;; Functions ;;;;;;;;;;
SuspendScript() {
    Suspend, Toggle
    fSuspendGui()
}

ReloadScript() {
    Suspend, Permit
    Reload
}

StopScript() {
    Suspend, Permit
    ExitApp
}