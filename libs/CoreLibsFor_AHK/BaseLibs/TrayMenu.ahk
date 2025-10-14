;;;;;;;;;; Loading ;;;;;;;;;;
    CheckingFiles("File", True, "Base_ICO", "Settings.ahk", "AdvancedSettings.ahk")
    
;;;;;;;;;; Tray ;;;;;;;;;;
    Menu, Tray, Tip, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1)
    Menu, Tray, Click, 1
    Menu, Tray, icon, %OP_Base_ICO%,1, 1

    Menu, Tray, NoStandard

    if OP_Settings {
        funcObj := Func("Tray_RunProgram").Bind("Settings")
        Menu, Tray, Add, Settings, %funcObj%
        Menu, Tray, icon, Settings, %OP_Base_ICO%,25
    }

    if OP_AdvancedSettings {
        funcObj := Func("Tray_RunProgram").Bind("AdvancedSettings")
        Menu, Tray, Add, Advanced settings, %funcObj%
        Menu, Tray, icon, Advanced settings, %OP_Base_ICO%, 10
    }

    funcObj := Func("Tray_RunProgram").Bind("RunningScript")
    Menu, Tray, Add, Edit script, %funcObj%
    Menu, Tray, icon, Edit script, %OP_Base_ICO%, 9
    
    funcObj := Func("Tray_links").Bind("KeyInfo")
    Menu, Tray2, Add, Key info, %funcObj%
    Menu, Tray2, icon, Key info, %OP_Base_ICO%, 18

    funcObj := Func("Tray_links").Bind("FindText")
    Menu, Tray2, Add, Find text, %funcObj%
    Menu, Tray2, icon, Find text, %OP_Base_ICO%, 20

    Menu, Tray, Add
    Menu, Tray, Add, Other programs, :Tray2
    Menu, Tray, icon, Other programs, %OP_Base_ICO%, 22

    Menu, Tray, Add
    funcObj := Func("Tray_links").Bind("Discord")
    Menu, Tray, Add, Discord, %funcObj%
    Menu, Tray, icon, Discord, %OP_Base_ICO%,16

    funcObj := Func("Tray_links").Bind("GitHub")
    Menu, Tray, Add, GitHub, %funcObj%
    Menu, Tray, icon, GitHub, %OP_Base_ICO%,17

    funcObj := Func("Tray_links").Bind("Donate")
    Menu, Tray, Add, Donate, %funcObj%
    Menu, Tray, icon, Donate, %OP_Base_ICO%,28

    Menu, Tray, Add
    Menu, Tray, Add, Reload, ReloadScript 
    Menu, Tray, icon, Reload, %OP_Base_ICO%,5

    Menu, Tray, Add, Suspend, SuspendScript
    Menu, Tray, icon, Suspend, %OP_Base_ICO%,7

    Menu, Tray, Add, Stop (exit), StopScript 
    Menu, Tray, icon, Stop (exit), %OP_Base_ICO%,3
    funcObj := ""
    ;--------------------------------------------------
    if !FileExist(OP_Settings)
        Menu, Tray, Default, Edit script
    Else
        Menu, Tray, Default, Settings

;;;;;;;;;; Tray functions ;;;;;;;;;;
    Tray_links(param) {
        switch param {
            case "KeyInfo"  : Run, % """" ProgramSearch("AutoHotkey 1") """" " " """" CheckingFiles("File", False, "KeyInfo.ahk") """"
            case "FindText" : Run, % """" ProgramSearch("AutoHotkey 1") """" " " """" CheckingFiles("File", False, "FindText.ahk") """"
            ;--------------------------------------------------
            case "Discord"  : Run, https://discord.gg/yrRfUMXAnk
            case "GitHub"   : Run, https://github.com/YagamiKlait3579
            case "Donate"   : Run, https://www.tbank.ru/rm/r_ZjWxmKELuP.YfEdKjOhWm/tJx2U7674/
        }
    }

    Tray_RunProgram(param) {
        global
        local GetProgramPath := ProgramSearch("Visual Studio Code", "Notepad++")
        switch param {
            case "RunningScript"    : Run, % """" (GetProgramPath ? GetProgramPath : "Notepad.exe") """ """ A_ScriptFullPath """"
            case "Settings"         : Run, % """" (GetProgramPath ? GetProgramPath : "Notepad.exe") """ """ OP_Settings """"
            case "AdvancedSettings" : Run, % """" (GetProgramPath ? GetProgramPath : "Notepad.exe") """ """ OP_AdvancedSettings """"
        }
    }