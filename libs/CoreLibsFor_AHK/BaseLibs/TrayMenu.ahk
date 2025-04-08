;;;;;;;;;; Loading ;;;;;;;;;;
    CheckingFiles(,"Base_ICO", "Settings.ahk", "AdvancedSettings.ahk")
    
;;;;;;;;;; Tray ;;;;;;;;;;
    Menu, Tray, Tip, Game Helper
    Menu, Tray, icon, %FP_Base_ICO%,1, 1

    Menu, Tray, NoStandard

    if FP_Settings {
        Menu, Tray, Add, Settings, OpenScriptSettings
        Menu, Tray, icon, Settings, %FP_Base_ICO%,25
    }

    if FP_AdvancedSettings {
        Menu, Tray, Add, Advanced settings, OpenAdvancedSettings
        Menu, Tray, icon, Advanced settings, %FP_Base_ICO%, 10
    }

    Menu, Tray, Add, Edit script, EditTheRunningScript
    Menu, Tray, icon, Edit script, %FP_Base_ICO%, 9
    
    Menu, Tray2, Add, Key info, OpenKeyInfo
    Menu, Tray2, icon, Key info, %FP_Base_ICO%, 18

    Menu, Tray2, Add, Find text, OpenFindText
    Menu, Tray2, icon, Find text, %FP_Base_ICO%, 20

    Menu, Tray, Add
    Menu, Tray, Add, Other programs, :Tray2
    Menu, Tray, icon, Other programs, %FP_Base_ICO%, 22

    Menu, Tray, Add
    Menu, Tray, Add, Discord, OpenDiscord
    Menu, Tray, icon, Discord, %FP_Base_ICO%,16

    Menu, Tray, Add, GitHub, OpenGitHub
    Menu, Tray, icon, GitHub, %FP_Base_ICO%,17

    Menu, Tray, Add
    Menu, Tray, Add, Reload, ReloadScript 
    Menu, Tray, icon, Reload, %FP_Base_ICO%,5

    Menu, Tray, Add, Suspend, SuspendScript
    Menu, Tray, icon, Suspend, %FP_Base_ICO%,7

    Menu, Tray, Add, Stop (exit), StopScript 
    Menu, Tray, icon, Stop (exit), %FP_Base_ICO%,3
    ;--------------------------------------------------
    if !FileExist(FP_Settings)
        Menu, Tray, Default, Edit script
    Else
        Menu, Tray, Default, Settings

;;;;;;;;;; Links ;;;;;;;;;;
    OpenKeyInfo() {
        GetProgramPath := ProgramSearch("AutoHotkey 1")
        GetScriptPath := CheckingFiles(,"KeyInfo.ahk")
        Run, "%GetProgramPath%" "%GetScriptPath%"
    }

    OpenFindText() {
        GetProgramPath := ProgramSearch("AutoHotkey 1")
        GetScriptPath := CheckingFiles(,"FindText.ahk")
        Run, "%GetProgramPath%" "%GetScriptPath%"
    }

    OpenDiscord() { 
        Run, https://discord.gg/yrRfUMXAnk
    }

    OpenGitHub() {
        Run, https://github.com/YagamiKlait3579
    }

;;;;;;;;;; Open Settings ;;;;;;;;;;
    EditTheRunningScript() {
        global
        local GetProgramPath
        if GetProgramPath := ProgramSearch("Visual Studio Code", "Notepad++")
            Run, "%GetProgramPath%" "%A_ScriptFullPath%"
        else
            Run, Notepad.exe "%A_ScriptFullPath%"
    }
    
    OpenScriptSettings() {
        global
        local GetProgramPath
        if GetProgramPath := ProgramSearch("Visual Studio Code", "Notepad++")
            Run, "%GetProgramPath%" "%FP_Settings%"
        else
            Run, Notepad.exe "%FP_Settings%"
    }
    
    OpenAdvancedSettings() {
        global
        local GetProgramPath
        if GetProgramPath := ProgramSearch("Visual Studio Code", "Notepad++")
            Run, "%GetProgramPath%" "%FP_AdvancedSettings%"
        else
            Run, Notepad.exe "%FP_AdvancedSettings%"
    }