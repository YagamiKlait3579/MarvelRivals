;;;;;;;;;; Loading ;;;;;;;;;;
    #SingleInstance, Force
    #Persistent
    #NoEnv
    ;#NoTrayIcon
    ;--------------------------------------------------
    #KeyHistory, 0
    ;#InstallKeybdHook
    ;#InstallMouseHook
    ;#UseHook
    ;--------------------------------------------------
    #MaxHotkeysPerInterval, 9999999
    #HotkeyInterval, 9999999
    ;--------------------------------------------------
    #MaxThreads, 255
    ;#MaxThreadsPerHotkey, 255
    ;--------------------------------------------------
    Process, Priority,, A
    CoordMode, ToolTip, Screen
    CoordMode, Pixel, Screen
    ListLines Off
    SendMode, Event ; Input
    SetBatchLines -1
    SetKeyDelay, -1, -1
    SetMouseDelay, -1, -1
    SetControlDelay -1
    SetWinDelay -1

;;;;;;;;;; Run as Administrator ;;;;;;;;;;
    ; https://www.autohotkey.com/docs/v1/lib/Run.htm#RunAs
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
        try { ; leads to having the script re-launching itself as administrator
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
    full_command_line := ""

;;;;;;;;;; Include ;;;;;;;;;;
    #include %A_Scriptdir%\..\
    SetWorkingDir %A_ScriptDir%\..\
    
    #include %A_Scriptdir%\..\BaseLibs\WorkingWithFiles.ahk
    #include %A_Scriptdir%\..\AuxiliaryScripts\Gdip.ahk

;;;;;;;;;; Variables ;;;;;;;;;;
    global gScreen       := [Round(A_ScreenWidth), Round(A_ScreenHeight)]
    global gScreenCenter := [Round(A_ScreenWidth / 2), Round(A_ScreenHeight / 2)] 
    global gFontScaling  := Round(A_ScreenHeight / 1080, 2)
    global gDPI          := (96 / A_ScreenDPI) 
    global gVK, gSC

    CheckingFiles(,"Base_ICO")

;;;;;;;;;; Tray Menu ;;;;;;;;;;
    Menu, Tray, Tip, Key info
    Menu, Tray, icon, %FP_Base_ICO%,18, 1

    Menu, Tray, NoStandard
    Menu, Tray, Add, Discord, OpenDiscord
    Menu, Tray, icon, Discord, %FP_Base_ICO%,16

    Menu, Tray, Add, GitHub, OpenGitHub
    Menu, Tray, icon, GitHub, %FP_Base_ICO%,17

    Menu, Tray, Add
    Menu, Tray, Add, Reload, ReloadScript 
    Menu, Tray, icon, Reload, %FP_Base_ICO%,5

    Menu, Tray, Add, Stop (exit), StopScript 
    Menu, Tray, icon, Stop (exit), %FP_Base_ICO%,3

    Menu, Tray, Default, Stop (exit)

    OpenDiscord() { 
        Run, https://discord.gg/yrRfUMXAnk
    }

    OpenGitHub() {
        Run, https://github.com/YagamiKlait3579
    }

    ReloadScript() {
        Suspend, Permit
        Reload
    }
    
    StopScript() {
        Suspend, Permit
        ExitApp
    }

;;;;;;;;;; Gui ;;;;;;;;;;
    FontSize := Round((12 * gFontScaling) * gDPI)
    Gui, KeyInfo: +AlwaysOnTop +LastFound -DPIScale +Border -MinimizeBox +HwndKeyInfo
    
    Gui, KeyInfo: Color, 000000
    Gui, KeyInfo: Font, % " s"FontSize " q3", MS Sans Serif
    Gui, KeyInfo: Show, % " w"(A_ScreenWidth/3) " h"(A_ScreenWidth/3/16*9), Key Info
    WinGetPos, KI_X, KI_Y, KI_W, KI_H, ahk_id %KeyInfo%

    Gui, KeyInfo: Add, Picture, % "x+m y"KI_H*0.01 " w"KI_W*0.17 " h-1 +Border +BackgroundTrans gOpenDiscord", % "HBITMAP:" ReadImages(CheckingFiles(,"Base_Images.dll"), "DiscordLogo")
    Gui, KeyInfo: Add, Picture, % "x+m y"KI_H*0.01 " w"KI_W*0.19 " h-1 +Border +BackgroundTrans gOpenGitHub", % "HBITMAP:" ReadImages(CheckingFiles(,"Base_Images.dll"), "GitHubLogo")

    Gui, KeyInfo: Add, Text, % " x"KI_W*0.05 " y"KI_H*0.175 " +Section +BackgroundTrans"
    Gui, KeyInfo: Add, Text, % " xs y+ w" KI_W*0.39 " +Center +Border cLime hwndMainText vMainText", Нажмите клавишу
    WinGetPos, MI_X, MI_Y, MI_W, MI_H, ahk_id %MainText%
    
    Gui, KeyInfo: Add, Text, xs y+ +BackgroundTrans
    Gui, KeyInfo: Add, Text, % " xs y+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Right cFuchsia", VK
    Gui, KeyInfo: Add, Text, % " x+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Left  cFuchsia vVK_Text",` ------
    Gui, KeyInfo: Add, Text, % " x+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Center +Border cAqua vVK_Copy gfCopy", Copy

    Gui, KeyInfo: Add, Text, xs y+ +BackgroundTrans
    Gui, KeyInfo: Add, Text, % " xs y+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Right cFuchsia", SC
    Gui, KeyInfo: Add, Text, % " x+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Left cFuchsia vSC_Text",` ------
    Gui, KeyInfo: Add, Text, % " x+ w" MI_W/3 " h" MI_H*1.5 " +0x00000201 +Center +Border cAqua vSC_Copy gfCopy", Copy

    Gui, KeyInfo: Add, Text, xs y+ +BackgroundTrans
    Gui, KeyInfo: Font, % " s"FontSize*2 " q3", MS Sans Serif
    Gui, KeyInfo: Add, Text,% " xs y+ w"MI_W " h" MI_H*2 " +Center +0x00000201 +Border cFF8000 vKeyText", ------

    Gui, KeyInfo: Margin, 0, 0
    Gui, KeyInfo: Add, Picture, % "x0 y0 w"(A_ScreenWidth/3) " h-1", % "HBITMAP:" ReadImages(CheckingFiles(,"Base_Images.dll"), "KeyInfoBG")

;;;;;;;;;; Start ;;;;;;;;;;
    OnExit("ExitKeyInfo")
    hHookKeybd := SetWindowsHookEx() 
    OnMessage(0x6, "WM_ACTIVATE") 
Return

;;;;;;;;;; Functions ;;;;;;;;;;
    fCopy() {  
        if !gVK && !gSC
            Return
        switch A_GuiControl {
            case "VK_Copy": Clipboard := gVK
            case "SC_Copy": Clipboard := gSC
            Default: Return
        }
        GuiControl, KeyInfo: +cYellow +Redraw, MainText
        GuiControl, KeyInfo: Text, MainText, % (A_GuiControl = "VK_Copy" ? "VK" : "SC") " скопирован"
    }

    WM_ACTIVATE(wp) {
        global
        if wp { ; Активация окна
            hHookKeybd := SetWindowsHookEx() 
        } else {
            DllCall("UnhookWindowsHookEx", UInt, hHookKeybd), hHookKeybd := "" 
        }
        GuiControl, % "KeyInfo: +c" (wp ? "Lime" : "Red") " +Redraw", MainText
        GuiControl, KeyInfo: Text, MainText, % (wp ? "Нажмите клавишу" : "Активируйте окно")
    }

;;;;;;;;;; Key info ;;;;;;;;;;
    SetWindowsHookEx() { 
        Return DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A") 
        , Int, WH_KEYBOARD_LL := 13 
        , Ptr, RegisterCallback("LowLevelKeyboardProc", "Fast") 
        , Ptr, DllCall("GetModuleHandle", UInt, 0, Ptr) 
        , UInt, 0, Ptr) 
    } 

LowLevelKeyboardProc(nCode, wParam, lParam) { 
    static WM_KEYDOWN = 0x100, WM_SYSKEYDOWN = 0x104 

    Critical 
    SetFormat, IntegerFast, H 
    vk := NumGet(lParam+0, "UInt") 
    Extended := NumGet(lParam+0, 8, "UInt") & 1 
    sc := (Extended<<8)|NumGet(lParam+0, 4, "UInt") 
    sc := sc = 0x136 ? 0x36 : sc 
    Key := GetKeyNameText(sc) 

    if (wParam = WM_SYSKEYDOWN || wParam = WM_KEYDOWN) { 
        GuiControl, KeyInfo: Text, KeyText, % Key
        GuiControl, KeyInfo: Text, VK_Text, % "` "vk
        GuiControl, KeyInfo: Text, SC_Text, % "` "sc
        gVK := "vk"vk, gSC := "sc"sc
    } 

    if Key Contains Ctrl,Alt,Shift,Tab 
        Return CallNextHookEx(nCode, wParam, lParam) 

    if (Key = "F4" && GetKeyState("Alt", "P")) ; закрытие окна и выход по Alt + F4 
        Return CallNextHookEx(nCode, wParam, lParam) 

    Return nCode < 0 ? CallNextHookEx(nCode, wParam, lParam) : 1 
} 

CallNextHookEx(nCode, wp, lp) {
    Return DllCall("CallNextHookEx", Ptr, 0, Int, nCode, UInt, wp, UInt, lp)
}

GetKeyNameText(sc) {
    VarSetCapacity(Key, A_IsUnicode ? 32 : 16)
    DllCall("GetKeyNameText" . (A_IsUnicode ? "W" : "A"), UInt, sc<<16, Str, Key, UInt, 16)
    if Key in Shift,Ctrl,Alt
        Key := "Left " . Key
    Return Key
}

;;;;;;;;;; Exit ;;;;;;;;;;
    KeyInfoGuiClose:
        ExitApp
    Return

    ExitKeyInfo() {
        if hHookKeybd 
            DllCall("UnhookWindowsHookEx", Ptr, hHookKeybd) 
    }