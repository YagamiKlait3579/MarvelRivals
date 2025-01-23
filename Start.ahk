;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\BaseLibs\Header.ahk
    #IfWinActive, Marvel Rivals
    global PWN := "Marvel Rivals" ; Program window name

;;;;;;;;;; Setting ;;;;;;;;;;
        MouseSpeed       := 2.5       ; Скорость мыши в игре
    ;;;;; DD ;;;;; 
        DD_Key            = XButton2  ; При удержании помогает навестись на противника
        DD_BodyKey        = F13       ; При удержании вместе с основной клавишей наводится на альтернативные координаты N1
        DD_CloselyKey     = Alt       ; При удержании вместе с основной клавишей наводится на альтернативные координаты N2
        DD_SearchArea    := 1300      ; Область поиска врагов в пикселях (по ширине экрана, от центра)
        DD_AimingDelay   := 0         ; Пауза между движениями мыши (увеличьте если у вас сильно дергается экран при наведении)
        DD_Offset        := [35,19]   ; Смещение от левого верхнего угла полоски здоровья
        DD_BodyOffset    := [35,25]   ; Альтернативное смещение от левого верхнего угла полоски здоровья N1
        DD_CloselyOffset := [50,45]   ; Альтернативное смещение от левого верхнего угла полоски здоровья N2
    ;;;;; Heal ;;;;;
        Heal_Key          = XButton1  ; При удержании помогает навестись на союзника
        Heal_SearchArea  := 300       ; Область поиска союзников в пикселях (по ширине экрана, от центра)
        Heal_AimingDelay := 10        ; Пауза между движениями мыши (увеличьте если у вас сильно дергается экран при наведении)
        Heal_Offset      := [0,15]    ; Смещение от желтой стрелочки над раненным союзником

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
    DD:
        GuiControl, MainInterface: Text, T1, DD
        GuiControl, MainInterface: +cLime +Redraw, T1
        if DebugGui
            fBorder("SearchArea", {"Coords" : DD_SA})
        while GetKeyState(DD_Key, "p") {
            if GetKeyState(DD_BodyKey, "p")
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_BodyOffset)
            else if GetKeyState(DD_CloselyKey, "p")
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_CloselyOffset)
            else
                AssistAim(DD_SA, A_DD_FT, DD_FindText, DD_Offset)
            if DD_AimingDelay
                lSleep(DD_AimingDelay)
        }
        if DebugGui
            fBorder("SearchArea", "Destroy")
        GuiControl, MainInterface: Text, T1, Disabled
        GuiControl, MainInterface: +cRed +Redraw, T1
    Return

    Heal:
        GuiControl, MainInterface: Text, T1, Heal
        GuiControl, MainInterface: +cLime +Redraw, T1
        if DebugGui
            fBorder("SearchArea", {"Coords" : Heal_SA})
        while GetKeyState(Heal_Key, "p") {
                AssistAim(Heal_SA, A_Heal_FT, Heal_FindText, Heal_Offset)
            if Heal_AimingDelay
                lSleep(Heal_AimingDelay)
        }
        if DebugGui
            fBorder("SearchArea", "Destroy")
        GuiControl, MainInterface: Text, T1, Disabled
        GuiControl, MainInterface: +cRed +Redraw, T1
    Return