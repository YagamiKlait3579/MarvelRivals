;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    #IfWinActive, Marvel Rivals
    global PWN := "Marvel Rivals" ; Program window name
    CheckForUpdates("YagamiKlait3579", "MarvelRivals", "main", CheckingFiles("File", False, "Header.ahk"))

;;;;;;;;;; Setting ;;;;;;;;;;

;;;;;;;;;; Variables ;;;;;;;;;;
    global MouseSpeed := MouseSpeed < 1 ? 1 : MouseSpeed
    DD_SA := [gScreenCenter.1 - (DD_SearchArea / 2), gScreenCenter.2 - (Round((DD_SearchArea / 16) * 9) / 2), gScreenCenter.1 + (DD_SearchArea / 2), gScreenCenter.2 + (Round((DD_SearchArea / 16) * 9) / 2)]
    Heal_SA := [gScreenCenter.1 - (Heal_SearchArea / 2), gScreenCenter.2 - (Round((Heal_SearchArea / 16) * 9) / 2), gScreenCenter.1 + (Heal_SearchArea / 2), gScreenCenter.2 + (Round((Heal_SearchArea / 16) * 9) / 2)]

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%DD_Key%, DD
    Hotkey, *%Heal_Key%, Heal

;;;;;;;;;; Gui ;;;;;;;;;;
    PlaceForTheText := " Disabled "
    ;--------------------------------------------------
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Right, Marvel Rivals:
        Gui, MainInterface: Add, Text, x+m +Center +Border cRed vT1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T1, Disabled
    GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
    fSuspendGui("On", "MainInterface")
    if DebugGui
        fDebugGui("Create", MainInterface)
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
Return

;;;;;;;;;; Scripts ;;;;;;;;;;
    DD() {
        global
        GuiInGame("Edit", "MainInterface", {"id" : "T1", "Color" : "Lime", "Text" : "DD"})
        if DebugGui
            fBorder("SearchArea", {"Coords" : DD_SA})
        while GetKeyState(DD_Key, "p") {
            TimeStamp(A_Stamp)
            if GetKeyState(DD_BodyKey, "p")
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_BodyOffset)
            else if GetKeyState(DD_CloselyKey, "p")
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_CloselyOffset)
            else
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_Offset)
            fDebugGui("Edit", "Cycle time", TimePassed(A_Stamp) " ms")
            if DD_AimingDelay
                lSleep(DD_AimingDelay)
            
        }
        if DebugGui
            fBorder("SearchArea", "Destroy")
        GuiInGame("Edit", "MainInterface", {"id" : "T1", "Color" : "Red", "Text" : "Disabled"})
    }

    Heal() {
        global
        GuiInGame("Edit", "MainInterface", {"id" : "T1", "Color" : "Lime", "Text" : "Heal"})
        if DebugGui
            fBorder("SearchArea", {"Coords" : Heal_SA})
        while GetKeyState(Heal_Key, "p") {
            TimeStamp(A_Stamp)
                AssistAim(Heal_SA, A_Heal_FT, Heal_FindText, Heal_Offset)
            fDebugGui("Edit", "Cycle time", TimePassed(A_Stamp) " ms")
            if Heal_AimingDelay
                lSleep(Heal_AimingDelay)
        }
        if DebugGui
            fBorder("SearchArea", "Destroy")
        GuiInGame("Edit", "MainInterface", {"id" : "T1", "Color" : "Red", "Text" : "Disabled"})
    }