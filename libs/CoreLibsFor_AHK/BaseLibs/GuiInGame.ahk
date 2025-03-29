/*  
!!! Заготовка вставки для в Settings 
    ;;;;; Interface (Место интерфейса) ;;;;; 
        ; Отсчёт координат начинается с левого верхнего угла вашего монитора, от (0.1) до (0.999). 
        ; Например: 0.1 (лево или верх),    0.500 (середина),   0.999 (право или низ)
        ; Если вы хотите что бы интерфейс не был виден на экране (для записи видео, или чего то еще), ставьте число больше 1.1 
        GuiPositionX     := 0.1850   ; Вертикальная координата интерфейса
        GuiPositionY     := 0.8800   ; Горизонтальная координата интерфейса
        gTransparency    := 100      ; Прозрачность интерфейса, от 0 (прозрачно) до 255 (непрозрачно)
        gBlur            := 255      ; Размытие фона интерфейса, от 0 (без размытия) до 255 (полное размытие)
        gInterfaceScale  := 100      ; Масштаб интерфейса (В процентах)
        HideTheInterface := True     ; Скрывать интерфейс при сворачивании игры (True = Включено, False = Выключено)
        DebugGui         := True     ; Окно отладки (True = Включено, False = Выключено)

!!! Заготовка вставки для в скрипт
    ;;;;;;;;;; Gui ;;;;;;;;;;
        PlaceForTheText := "Ширина самого длинного текста"
        ;--------------------------------------------------
        UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
        GuiInGame("Start", "MainInterface")
            Gui, MainInterface: Add, Text, xm ym +Center vT1, %PlaceForTheText%
            GuiControl, MainInterface: Text, T1, Test GUI in Game
        GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
        fSuspendGui("On", "MainInterface")

!!! Дополнительные функции
    if DebugGui
        fDebugGui("Create", MainInterface)

    global PWN := "" ; Program window name
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
*/

;;;;;;;;;; Variables ;;;;;;;;;;
    global gScreen       := [Round(A_ScreenWidth), Round(A_ScreenHeight)]
    global gScreenCenter := [Round(A_ScreenWidth / 2), Round(A_ScreenHeight / 2)] 
    global gFontScaling  := Round(A_ScreenHeight / 1080, 2)
    global gDPI          := (96 / A_ScreenDPI) 
    global DGP := []

;;;;;;;;;; GUI Main Function ;;;;;;;;;;
    UpdateDGP(params = "") {
        /* 
        UpdateDGP устанавливает параметры по умолчанию для отрисовки новых окон GuiInGame, fDebugGui, fSuspendGui.
        Для корректной работы при загрузке скрипта создать глобальный массив DGP.
        global DGP := []
        */
        global
        ; DGP = Default GUI Parameters (Парамеры по умолчанию для всех GUI)
        local A_Loop, A_key
        local A_DGP := {"Font"         : "MS Sans Serif" ; Стиль шрифта [MS Sans Serif, Sylfaen]
                       ,"FontColor"    : "White"         ; Цвет шрифта
                       ,"FontSize"     : 11              ; Размер шрифта
                       ,"Margin"       : [0.5, 0.125]    ; Стандартный отступ (По умолчанию в AHK [x = 1.25, y = 0.75])
                       ,"BorderColor"  : "Aqua"          ; Цвет рамки
                       ,"BorderSize"   : 1               ; Толщина рамки
                       ,"Transparency" : 100             ; Прозрачность, от 0 (прозрачно) до 255 (непрозрачно)
                       ,"Blur"         : 255             ; Размытие фона, от 0 (без размытия) до 255 (полное размытие)
                       ,"Scale"        : 100           } ; Масштаб интерфейса (В процентах)
        if (params = "SetDefault") || (params = "Default") {
            DGP := A_DGP
            Return
        }
        for A_Loop, A_key in ["Font", "FontColor","BorderColor","BorderSize","Transparency","Blur","Scale"]
            DGP[A_key] := params[A_key] ? params[A_key] : (DGP[A_key] ? DGP[A_key] : A_DGP[A_key])
        if params.FontSize || params.Scale
            DGP.FontSize := Round(((params.FontSize * gFontScaling) * gDPI) * (0.01 * DGP.Scale))
        else if !DGP.FontSize
            DGP.FontSize := Round(((A_DGP.FontSize * gFontScaling) * gDPI) * (0.01 * DGP.Scale))
        DGP.Margin := [params.Margin.1 ? params.Margin.1 : (DGP.Margin.1 ? DGP.Margin.1 : Round(DGP.FontSize * A_DGP.Margin.1))
                      ,params.Margin.2 ? params.Margin.2 : (DGP.Margin.2 ? DGP.Margin.2 : Round(DGP.FontSize * A_DGP.Margin.2))]
    }

    GuiInGame(Command, NameGui, params = "") {
        /*
        GuiInGame для автоматизации рутинных действий при подготовке и отрисовки окон в игре
        NameGui = Имя окна

        *** Создание окна ***
            При создании окна берутся текущие параметры из UpdateDGP()
            Command = "Start" Подготовка к созданию окна
            GuiInGame("Start", "MainInterface")

            Далее рисуем GUI какое вам нужно с помощью стандартных команд AHK
            Пример:
                Gui, MainInterface: Add, Text, xm ym +Center vT1, Пример текста (текст 1, строка 1)
                Gui, MainInterface: Add, Text, x+m ym +Center vT2, Пример текста (текст 2, строка 1)
                Gui, MainInterface: Add, Text, xm y+m +Center vT3, Пример текста (текст 3, строка 2)
            и т.д.

            Command = "End" Создание окна на экране
            GuiInGame("End", "MainInterface")

            params = координаты GUI (по умолчанию устанавливается центр экрана)
            Можно указать двумя способами:
            1:  GuiInGame("End", "MainInterface", {"pos" : [x,y,w,h]})
                Указываем точные координаты экрана
            2:  GuiInGame("End", "MainInterface", {"ratio" : [x,y,w,h]})
                Указываем процент от ширины и высоты экрана
                Отсчёт координат начинается с левого верхнего угла вашего монитора, от (0.1) до (0.999).
                Например: 0.1 (лево или верх),    0.500 (середина),   0.999 (право или низ)
            При любом варианте в качестве третьего и четвертого параметра можно указать ширину и высоту окна.
            Если они не указаны, ширина и высота рассчитываются автоматически.

        *** Редактирование окна ***
            Command = "Edit"
            params = параметры для редактирования
            GuiInGame("Edit", "MainInterface", {"id" : "T1", "color" : "red", "text" : "Новый текст"})
            id = обязательно указать имя объекта для изменения
            color = изменения цвета текста
            text = изменение содержимого текста

        *** Показать \ Спрятать окно ***
            Спрятать окно
            GuiInGame("Hide", "MainInterface")

            Показать окно
            GuiInGame("Show", "MainInterface")

            Можно показать\спрятать все окна AHK одной командой, 
            для этого укажите в NameGui = "All"
            GuiInGame("Hide", "All")
            GuiInGame("Show", "All")

        *** Удаление окна ***
            GuiInGame("Destroy", "MainInterface")
        */
        global
        UpdateDGP()
        switch Command {
            case "Start": {
                Gui, %NameGui%: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwnd%NameGui%
                Gui, %NameGui%: Color, 000000
                Gui, %NameGui%: Margin, % DGP.Margin.1, % DGP.Margin.2
                Gui, %NameGui%: Font, % " s"DGP.FontSize " c" DGP.FontColor " q3", % DGP.Font
            }
            case "End": {
                local MI_X, MI_Y, MI_W, MI_H, HwndGui, HwndGui_Blur
                switch {
                    case (params.ratio.1 && params.ratio.2):
                        Gui, %NameGui%: Show, % " x" Round(A_ScreenWidth * params.ratio.1) " y" Round(A_ScreenHeight * params.ratio.2) (params.ratio.3 ? " w" params.ratio.3 : "") (params.ratio.4 ? " h" params.ratio.4 : "") " NoActivate"
                    case (params.pos.1 && params.pos.2):
                        Gui, %NameGui%: Show, % " x" params.pos.1 " y" params.pos.2 (params.pos.3 ? " w" params.pos.3 : "") (params.pos.4 ? " h" params.pos.4 : "") " NoActivate"
                    Default:
                        Gui, %NameGui%: Show, NoActivate
                }
                WinSet, TransColor, 000000
                ;--------------------------------------------------
                WinGetPos, MI_X, MI_Y, MI_W, MI_H,% "ahk_id" %NameGui%
                Gui, %NameGui%BG: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwnd%NameGui%BG
                Gui, %NameGui%BG: Color, 000000
                Gui, %NameGui%BG: Show, x%MI_X% y%MI_Y% w%MI_W% h%MI_H% NoActivate
                WinSet, Transparent, % DGP.Transparency
                ;--------------------------------------------------
                Gui, %NameGui%Blur: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +Hwnd%NameGui%Blur
                Gui, %NameGui%Blur: Color, 000000
                Gui, %NameGui%Blur: Show, x%MI_X% y%MI_Y% w%MI_W% h%MI_H% NoActivate
                WinSet, Transparent, % DGP.Blur
                ;--------------------------------------------------
                StringReplace, HwndGui, %NameGui%, ""
                GroupAdd, ShowHide_GuiGroup, ahk_id %HwndGui%
                StringReplace, HwndGui_Blur, %NameGui%Blur, ""
                EnableBlur(HwndGui_Blur)
                ;--------------------------------------------------
                Gui, %NameGui%: +AlwaysOnTop 
                fBorder(NameGui, {"Hwnd" : HwndGui, "color" : DGP.BorderColor, "size" : DGP.BorderSize})
            }
            case "Edit": {
                if !params.id
                    MsgBox, 16, GuiInGame, Не указано имя строки.`nThe string name is not specified.
                if params.text    
                    GuiControl, %NameGui%: Text, % params.id, % params.text 
                if params.color
                    GuiControl, % NameGui ": +c" params.color " +Redraw", % params.id
            }
            case "Hide": {
                local HwndGui, HwndGui_BG, HwndGui_Blur
                if (NameGui = "All") {
                    SetTimer, ShowHideGui , Off, -1
                    ShowHideGui("Hide")
                } else {
                    for A_Loop, A_key in [NameGui, NameGui "BG",NameGui "Blur"] {
                        StringReplace, HwndGui, %A_key%, ""
                        WinHide, ahk_id %HwndGui%
                    }
                    fBorder(NameGui, "Hide")  
                }
            }
            case "Show": {
                local HwndGui, HwndGui_BG, HwndGui_Blur
                if (NameGui = "All") {
                    ShowHideGui("Show")
                    if HideTheInterface
                        SetTimer, ShowHideGui , 250, -1
                } else {
                    for A_Loop, A_key in [NameGui, NameGui "BG",NameGui "Blur"] {
                        StringReplace, HwndGui, %A_key%, ""
                        WinShow, ahk_id %HwndGui%
                    }
                    Gui, %NameGui%: +AlwaysOnTop 
                    fBorder(NameGui, "Show")  
                }
            }
            case "Destroy": {
                Gui, %NameGui%: Destroy
                Gui, %NameGui%BG: Destroy
                Gui, %NameGui%Blur: Destroy
                fBorder(NameGui, "Destroy")
            }
        }
    }

;;;;;;;;;; GUI functions ;;;;;;;;;;
    fBorder(NameGui, Params = "") {
        /* 
        fBorder рисует рамку вокруг выбранного окна или в выбранной области
        NameGui = имя рамки для дальнейшего редактирования или удаления

        *** Способы указания места и размера ***
            Авто координаты вокруг окна по его Hwnd
            fBorder("Name", {"Hwnd" : Hwnd Окна})

            + и - Center от центра экрана
            fBorder("Name", {"Center" : 10})

            Точные координаты (вместо [X1, Y1, X2, Y2] можно положить массив)
            fBorder("Name", {"Coords" : [X1, Y1, X2, Y2]})
            
            Точные координаты (вместо [X1, Y1, Ширина, Высот] можно положить массив)
            fBorder("Name", {"Pos" : [X1, Y1, Ширина, Высота]})

        *** Возможные параметры ***              
            fBorder("Name", {"Size" : 1})
            Толщина рамки

            fBorder("Name", {"Color" : "White"})
            Указание цвета рамки

            fBorder("Name", {"EditColor" : "White"})
            Изменение цвета существующей рамки

        *** Показать \ Спрятать рамку ***
            Спрятать окно
            fBorder("Name", "Hide")

            Показать окно
            fBorder("Name", "Show")

        *** Удаление рамки *** 
            fBorder("Name", "Destroy")                  
        */
        if Params.Destroy || Params = "Destroy" {
            Loop, 4
                Gui, %NameGui%%A_Index%: Destroy
            Return
        }
        if Params.Hide || Params = "Hide" {
            Loop, 4
                Gui, %NameGui%%A_Index%: Hide
            Return
        }
        if Params.Show || Params = "Show" {
            Loop, 4
                Gui, %NameGui%%A_Index%: Show
            Return
        }
        if Params.EditColor {
            Loop, 4
                Gui, %NameGui%%A_Index%: Color, % Params.EditColor
            Return
        }
        if (!Params.pos.1 || !Params.pos.2 || !Params.pos.3 || !Params.pos.4) && (!Params.coords.1 || !Params.coords.2 || !Params.coords.3 || !Params.coords.4) && !Params.Center  && !Params.Hwnd{
            MsgBox, 16, fBorder, Неверно указаны координаты для %NameGui%.`nThe coordinates are incorrectly specified for %NameGui%.
            Return 1
        }
        Params.size := Params.size > 0 ? Params.size : (DGP.BorderSize ? DGP.BorderSize : 1)
        Params.color := Params.color ? Params.color : (DGP.BorderColor ? DGP.BorderColor : "White")
        Loop, 4 {
            Gui, %NameGui%%A_Index%: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20
            Gui, %NameGui%%A_Index%: Color, % Params.color
            WinSet, Transparent, 255
        }
        if Params.Center {
            X1 := gScreenCenter.1 - Params.Center - Params.size
            Y1 := gScreenCenter.2 - Params.Center - Params.size
            X2 := gScreenCenter.1 + Params.Center
            Y2 := gScreenCenter.2 + Params.Center
            W := (Params.Center * 2) + (Params.size * 2)
            H := (Params.Center * 2) + Params.size
        } else if (Params.coords.1 && Params.coords.2 && Params.coords.3 && Params.coords.4) {
            X1 := Params.coords.1 - Params.size
            Y1 := Params.coords.2 - Params.size
            X2 := Params.coords.3
            Y2 := Params.coords.4
            W := Params.coords.3 - Params.coords.1 + (Params.size * 2)
            H := Params.coords.4 - Params.coords.2 + Params.size
        } else if (Params.pos.1 && Params.pos.2 && Params.pos.3 && Params.pos.4) {
            X1 := Params.pos.1 - Params.size
            Y1 := Params.pos.2 - Params.size
            X2 := Params.pos.1 + Params.pos.3
            Y2 := Params.pos.2 + Params.pos.4
            W := Params.pos.3 + (Params.size * 2) 
            H := Params.pos.4 + Params.size
        } else {
            WinGetPos, X1, Y1, W, H, % "ahk_id" Params.Hwnd
            X1 := X1 - Params.size
            Y1 := Y1 - Params.size
            X2 := X1 + W + Params.size
            Y2 := Y1 + H + Params.size
            W := W + (Params.size * 2) 
            H := H + Params.size
        }
        Gui, %NameGui%1: Show, % "x" X1 " y" Y1 " w" W " h" Params.size " NoActivate"
        Gui, %NameGui%2: Show, % "x" X1 " y" Y1 " w" Params.size " h" H " NoActivate"
        Gui, %NameGui%3: Show, % "x" X1 " y" Y2 " w" W " h" Params.size " NoActivate"
        Gui, %NameGui%4: Show, % "x" X2 " y" Y1 " w" Params.size " h" H " NoActivate"
    }

    fDebugGui(Command, param1 = "", param2 = "", params = "") {
        /*
            fDebugGui Создает дополнительное окно для отладки во время тестирования чего либо.

        *** Создание окна ***
            Command = "Create"

            param1 = Hwnd окна которое будет считаться основным,
            и от которого будут рассчитываться остальные параметры.

            param2 = Количество строк для отладки. По умолчанию = 1 

            Перед созданием окна берутся текущие параметры из UpdateDGP()
            params = Дополнительные параметры при создании которые можно указать
            width  = ширина окна. По умолчанию равна ширине основного окна
            offset = отступ от основного окна (по умолчанию берется из UpdateDGP())
            color1 = цвет текста первого столбца (по умолчанию 0xff7d19)
            color2 = цвет текста второго столбца (по умолчанию Fuchsia)
            pos    = с какой стороны от основного окна создать окно Debug,
            ("Up","Down","Left","Right"), по умолчанию "Up"

        *** Редактирование окна ***
            Command = "Edit"

            param1 = текст первого столбца (по умолчанию оставляет прошлое значение)
            param2 = текст второго столбца (по умолчанию оставляет прошлое значение)

            params = дополнительные параметры 
            line   = строка для редактирования (по умолчанию 1)
            color1 = изменить цвет текста первого столбца
            color2 = изменить цвет текста второго столбца
            !если line не указана color1 или color2 меняет цвет во всех строках
            BorderColor = меняет цвет рамки

        *** Удаление окна ***
            fDebugGui("Destroy")
        */

        ; DG = DebugGui
        ; MI = MainInterface
        global
        static LineAmount
        Switch Command {
            case "Create": {
                UpdateDGP()
                local MI_X, MI_Y, MI_W, MI_H
                local DG_X, DG_Y, DG_W, DG_H, DG_W2, DG_Offset
                if !param1 {
                    MsgBox, 16, fDebugGui, Не указан Hwnd основного окна, или указан не верно.`n`nThe Hwnd of the main window is not specified, or it is specified incorrectly.
                    Return 1
                }
                param2 := !param2 ? 1 : param2
                LineAmount := param2
                WinGetPos, MI_X, MI_Y, MI_W, MI_H, % "ahk_id" param1
                if !MI_X && !MI_Y && !MI_W && !MI_H {
                    MsgBox, 16, fDebugGui, Координаты окна ориентира не найдены.`nThe coordinates of the landmark window have not been found.
                    Return 1
                }
                DG_W2 := !params.width ? ((MI_W - (DGP.Margin.1 * 3)) / 2) : ((params.width - (DGP.Margin.1 * 3)) / 2)
                DG_Offset := { "x" : (!params.Offset ? (DGP.BorderSize * 4) : params.Offset), "y" : (!params.Offset ? (DGP.BorderSize * 4) : params.Offset)}
                Gui, DebugGui: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndDebugGui
                Gui, DebugGui: Color, 000000
                Gui, DebugGui: Margin, % DGP.Margin.1, % DGP.Margin.2
                Gui, DebugGui: Font, % " s"DGP.FontSize " c" DGP.FontColor " q3", % DGP.Font
                Loop, %param2% {
                    Gui, DebugGui: Add, Text, % " xm y+m w" DG_W2 " +c"(params.color1 = "" ? "ff7d19" : params.color1) " +Right vDG_T1_L"A_Index, ------------
                    Gui, DebugGui: Add, Text, % " x+m w" DG_W2 " +c"(params.color2 = "" ? "Fuchsia" : params.color2) " +Center +Border vDG_T2_L"A_Index, ------------
                }
                Gui, DebugGui: Show, x0 y0 NoActivate
                GroupAdd, ShowHide_GuiGroup, ahk_id %DebugGui%
                WinGetPos, DG_X, DG_Y, DG_W, DG_H, ahk_id %DebugGui%
                switch params.pos {
                    case "Up":    DG_X := MI_X,                         DG_Y := MI_Y - DG_H - DG_Offset.y
                    case "Down":  DG_X := MI_X,                         DG_Y := MI_Y + MI_H + DG_Offset.y
                    case "Left":  DG_X := MI_X - DG_W - DG_Offset.x,    DG_Y := MI_Y
                    case "Right": DG_X := MI_X + MI_W + DG_Offset.x,    DG_Y := MI_Y
                    Default:      DG_X := MI_X,                         DG_Y := MI_Y - DG_H - DG_Offset.y
                }
                Gui, DebugGui: Show, x%DG_X% y%DG_Y% NoActivate
                WinSet, TransColor, 000000
                ;--------------------------------------------------
                Gui, DebugGuiBG: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndDebugGuiBG
                Gui, DebugGuiBG: Color, 000000
                Gui, DebugGuiBG: Show, x%DG_X% y%DG_Y% w%DG_W% h%DG_H% NoActivate
                WinSet, Transparent, % DGP.Transparency
                ;--------------------------------------------------
                Gui,DebugGuiBlur: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndDebugGuiBlur
                Gui,DebugGuiBlur: Color, 000000
                Gui,DebugGuiBlur: Show, x%DG_X% y%DG_Y% w%DG_W% h%DG_H% NoActivate
                WinSet, Transparent, % DGP.Blur
                EnableBlur(DebugGuiBlur)
                ;--------------------------------------------------
                Gui, DebugGui: +AlwaysOnTop
                fBorder("DebugGui", {"Hwnd" : DebugGui, "Color" : DGP.BorderColor, "Size" : DGP.BorderSize}) 
            }
            case "Edit": {
                local Line
                Line := !params.line ? (!params ? 1 : params) : params.line
                if param1
                    GuiControl, DebugGui: Text, DG_T1_L%Line%, %param1%
                if param2
                    GuiControl, DebugGui: Text, DG_T2_L%Line%, %param2%
                for A_Loop, A_key in [params.color1, params.color2]
                    if A_key {
                        if params.line
                            GuiControl, % "DebugGui: +c" A_key " +Redraw", % "DG_T" A_Loop "_L" params.line
                        else
                            Loop, %LineAmount%
                                GuiControl, % "DebugGui: +c" A_key " +Redraw", % "DG_T" A_Loop "_L" A_Index
                    }
                if params.BorderColor
                    fBorder("DebugGui", {"EditColor" : params.BorderColor}) 
            }
            case "Destroy": {
                Gui, DebugGui: Destroy
                Gui, DebugGuiBG: Destroy
                Gui, DebugGuiBlur: Destroy
                fBorder("DebugGui", "Destroy")
            }
        }
    }

    fSuspendGui(Command = "", Hwnd = "", Params = "") {
        /*
            fSuspendGui рисует или удаляет окно для уведомления о состоянии A_IsSuspended в скрипте
            Для работы функции необходимо ее запустить при запуске скрипта,
            для этого вызовите функцию с параметрами fSuspendGui("On", "NameGUI")
            В NameGUI указать Hwnd окна относительно которого будет отображаться окно fSuspendGui

            При запуске функции берутся текущие параметры из UpdateDGP()
            params = Дополнительные параметры которые можно указать при запуске функции

            pos    = с какой стороны от основного окна создать окно Debug,
            ("Up","Down","Left","Right"), по умолчанию "Right"

            width  = ширина окна. По умолчанию если параметр pos задан "Up"или"Down,
            ширина будет равна ширине окна относительно которого создается функция,
            иначе будет минимальная ширина необходимая для написания текста "HotKey OFF"

            height = высота окна. По умолчанию если параметр pos задан "Left"или"Right,
            высота будет равна высоте окна относительно которого создается функция,
            иначе будет минимальная высота необходимая для написания текста "HotKey OFF"

            color = цвет текста в окне. (по умолчанию "Red")

            offset = отступ от основного окна (по умолчанию берется из UpdateDGP())
            
            Для работы функции просто вызываете ее без дополнительных параметров в функции где вы меняете состояние A_IsSuspended,
            она автоматически создаст или удалит окно в зависимости от состояния A_IsSuspended в скрипте.
        */
        global
        Static A_Hwnd
        UpdateDGP()
        if (Command = "On") {
            static A_SGS := [] ;  Suspend gui settings
            local MI_X, MI_Y, MI_W, MI_H
            WinGetPos, MI_X, MI_Y, MI_W, MI_H, % "ahk_id" %Hwnd%
            A_Hwnd := Hwnd
            A_SGS.pos := Params.pos ? Params.pos : "Right"
            A_SGS.width := Params.width ? Params.width : "Auto"
            A_SGS.height := Params.height ? Params.height : "Auto"
            A_SGS.color := Params.color ? Params.color : "Red"
            A_SGS.Offset := { "x" : (!params.Offset ? (DGP.BorderSize * 4) : params.Offset), "y" : (!params.Offset ? (DGP.BorderSize * 4) : params.Offset)}
            Return
        }
        if (A_IsSuspended && A_Hwnd) {
            local MI_X, MI_Y, MI_W, MI_H
            WinGetPos, MI_X, MI_Y, MI_W, MI_H, % "ahk_id" %A_Hwnd%
            local SGS_X, SGS_Y, SGS_W, SGS_H
            Gui, SuspendGui: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndSuspendGui
            Gui, SuspendGui: Color, 000000
            Gui, SuspendGui: Margin, % DGP.Margin.1, % DGP.Margin.2
            Gui, SuspendGui: Font, % " s"DGP.FontSize " c" DGP.FontColor " q3", % DGP.Font
            ;--------------------------------------------------
            switch A_SGS.pos {
                case "Up":    SGS_W := ((A_SGS.width = "Auto") ? " w"MI_W : " w"A_SGS.width),   SGS_H := ((A_SGS.height = "Auto") ? "": " h" A_SGS.height)   
                case "Down":  SGS_W := ((A_SGS.width = "Auto") ? " w"MI_W : " w"A_SGS.width),   SGS_H := ((A_SGS.height = "Auto") ? "": " h" A_SGS.height)   
                case "Left":  SGS_W := ((A_SGS.width = "Auto") ? "" : " w" A_SGS.width),        SGS_H := ((A_SGS.height = "Auto") ? " h"MI_H : " h" A_SGS.height)
                case "Right": SGS_W := ((A_SGS.width = "Auto") ? "" : " w" A_SGS.width),        SGS_H := ((A_SGS.height = "Auto") ? " h"MI_H : " h" A_SGS.height)
                Default:      SGS_W := ((A_SGS.width = "Auto") ? "" : " w" A_SGS.width),        SGS_H := ((A_SGS.height = "Auto") ? " h"MI_H : " h" A_SGS.height)
            }
            Gui, SuspendGui: Add, Text, % " x0 y0" SGS_W SGS_H " +Center +0x00000201 +c" A_SGS.color,`   HotKey OFF  `
            ;--------------------------------------------------
            Gui, SuspendGui: Show, % "x0 y0" SGS_W SGS_H " NoActivate"
            GroupAdd, ShowHide_GuiGroup, ahk_id %SuspendGui%
            WinGetPos, SGS_X, SGS_Y, SGS_W, SGS_H, ahk_id %SuspendGui%
            switch A_SGS.pos {
                case "Up":    SGS_X := MI_X,                            SGS_Y := MI_Y - SGS_H - A_SGS.Offset.y
                case "Down":  SGS_X := MI_X,                            SGS_Y := MI_Y + MI_H + A_SGS.Offset.y
                case "Left":  SGS_X := MI_X - SGS_W - A_SGS.Offset.x,   SGS_Y := MI_Y                      
                case "Right": SGS_X := MI_X + MI_W + A_SGS.Offset.x,    SGS_Y := MI_Y                       
                Default:      SGS_X := MI_X,                            SGS_Y := MI_Y - SGS_H - A_SGS.Offset.y
            }
            Gui, SuspendGui: Show, % " x" SGS_X " y" SGS_Y "NoActivate"
            WinSet, TransColor, 000000
            ;--------------------------------------------------
            WinGetPos, SGS_X, SGS_Y, SGS_W, SGS_H, ahk_id %SuspendGui%
            Gui, SuspendGuiBG: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndSuspendGuiBG
            Gui, SuspendGuiBG: Color, 000000
            Gui, SuspendGuiBG: Show, x%SGS_X% y%SGS_Y% w%SGS_W% h%SGS_H% NoActivate
            WinSet, Transparent, % DGP.Transparency
            ;--------------------------------------------------
            Gui, SuspendGuiBlur: +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow -DPIScale +E0x20 +HwndSuspendGuiBlur
            Gui, SuspendGuiBlur: Color, 000000
            Gui, SuspendGuiBlur: Show, x%SGS_X% y%SGS_Y% w%SGS_W% h%SGS_H% NoActivate
            WinSet, Transparent, % DGP.Blur
            EnableBlur(SuspendGuiBlur)
            ;--------------------------------------------------
            Gui, SuspendGui: +AlwaysOnTop
            fBorder("SuspendGui", {"Hwnd" : SuspendGui, "Color" : DGP.BorderColor, "Size" : DGP.BorderSize}) 
        }
        if (!A_IsSuspended && A_Hwnd) {
            Gui, SuspendGui: Destroy
            Gui, SuspendGuiBG: Destroy
            Gui, SuspendGuiBlur: Destroy
            fBorder("SuspendGui", "Destroy")
        }
    }


;;;;;;;;;; Other functions ;;;;;;;;;;
    EnableBlur(gHwnd) {
        ;Function by qwerty12 and jNizM (found on https://autohotkey.com/boards/viewtopic.php?t=18823)

        ; WindowCompositionAttribute
        WCA_ACCENT_POLICY := 19

        ; AccentState
        ACCENT_DISABLED := 0,
        ACCENT_ENABLE_GRADIENT := 1,
        ACCENT_ENABLE_TRANSPARENTGRADIENT := 2
        ACCENT_ENABLE_BLURBEHIND := 3
        ACCENT_INVALID_STATE := 4

        accentStructSize := VarSetCapacity(AccentPolicy, 4*4, 0)
        NumPut(ACCENT_ENABLE_BLURBEHIND, AccentPolicy, 0, "UInt")

        padding := A_PtrSize == 8 ? 4 : 0
        VarSetCapacity(WindowCompositionAttributeData, 4 + padding + A_PtrSize + 4 + padding)
        NumPut(WCA_ACCENT_POLICY, WindowCompositionAttributeData, 0, "UInt")
        NumPut(&AccentPolicy, WindowCompositionAttributeData, 4 + padding, "Ptr")
        NumPut(accentStructSize, WindowCompositionAttributeData, 4 + padding + A_PtrSize, "UInt")

        DllCall("SetWindowCompositionAttribute", "Ptr", gHwnd, "Ptr", &WindowCompositionAttributeData)
    }

    ShowHideGui(param = "") {
        /*
            ShowHideGui автоматически скрывает все окна AHK если окно указанной программы не активно,
            и отображает их вновь если окно программы становится активным. 

            Для работы функции укажите в глобальной переменной PWN имя окна программы.
            Пример: global PWN := "Window Name" ; Program window name

            Для запуска функций используйте SetTimer.
            Установите приоритет -1, чтобы случайно эта функция не помешала работе другим функциям в скрипте.
            Пример: SetTimer, ShowHideGui , 250, -1

            P.s Функция автоматически находит все Hwnd созданные с помощью AHK и запоминает их,
            поэтому она должна работать корректно всегда, но в редких случаях возможны ошибки
            если вы создали окна не с помощью функций GuiInGame, fBorder, fDebugGui, fSuspendGui.
            Все зависит как именно вы создавали окна в этом случае.
        */
        global
        if (!PWN && !param) {
            SetTimer, ShowHideGui , off
            MsgBox, 16, ShowHideGui, PWN не задан.`nPWN is not set.
            Return 
        }
        Critical, On
        local A_Loop, A_Key
        static once, ArrayHwnd
        if (!WinActive(PWN) && !once) || (param = "Hide") {
            once := !once
            ArrayHwnd := []
            DetectHiddenWindows, On
            WinGet, A_PID, PID, ahk_id %A_ScriptHwnd%
            WinGet, AllHwnd, List, ahk_pid %A_PID%
            Loop, % AllHwnd {
                if (AllHwnd%A_Index% = A_ScriptHwnd)
                    Continue
                ArrayHwnd.Push(AllHwnd%A_Index%)
            }
            for A_Loop, A_Key in ArrayHwnd
                WinHide, ahk_id %A_Key%
            DetectHiddenWindows, Off
        }
        if (WinActive(PWN) && once) || (param = "Show") {
            once := !once
            for A_Loop, A_Key in ArrayHwnd
                WinShow, ahk_id %A_Key%
            WinHide, ahk_group ShowHide_GuiGroup
            WinShow, ahk_group ShowHide_GuiGroup
        }
        Critical, Off
    }

    GuiLineWidth(Hwnd_A, Hwnd_B = "") {
        WinGetPos, X_1,, W_1,, ahk_id %Hwnd_A%
        if Hwnd_B {
            WinGetPos, X_2,, W_2,, ahk_id %Hwnd_B%
            Return % (X_2 + W_2) - X_1
        }
        Return W_1
    }