;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    ;#IfWinActive, 
    ;global PWN := "" ; Program window name
    ;CheckForUpdates("YagamiKlait3579",, "main", CheckingFiles("File", False, "Header.ahk"))

;;;;;;;;;; Setting ;;;;;;;;;;

;;;;;;;;;; Variables ;;;;;;;;;;

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, BaseScript

;;;;;;;;;; Gui ;;;;;;;;;;
    PlaceForTheText := " Ширина самого длинного текста "
    ;--------------------------------------------------
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Center vT1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T1, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1)
    GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
    fSuspendGui("On", "MainInterface")
    if DebugGui
        fDebugGui("Create", MainInterface)
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
Return

;;;;;;;;;; Scripts ;;;;;;;;;;
    BaseScript:
    
    Return