;;;;;;;;;; Mouse ;;;;;;;;;;
    fSetCursor(x, y) {
        Dllcall("SetCursorPos" , "Int", x, "Int", y)
    }

    fGetCursor() {
		VarSetCapacity(POINT, 8, 0)
		DllCall("GetCursorPos", "Uint", &POINT)
		Return {x : NumGet(POINT, 0, "Int"), y : NumGet(POINT, 4, "Int")}
	}

    fMoveMouse(x, y) {
        Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
        DllCall("mouse_event", "UInt", 0x01, "Int", x, "Int", -y, "UInt", 0, "Int", 0)
    }

    fMouseInput(Key = "Left", status = 25) {
        /*
            Функция создаёт действия мыши с помощью Windows API mouse_event.

            Параметр status:
                Для кнопок мыши:
                    Число (ms) — время зажатия кнопки в миллисекундах.
                    "Down" — кнопка нажата (зажата).
                    "Up" — кнопка отпущена.
                Для колеса мыши:
                    Число — количество прокрутов.
        */
        switch (Key) {
            case "Left":  (status = "Down" ? DllCall("mouse_event", "UInt", 0x02)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x04)  : (DllCall("mouse_event", "UInt", 0x02),  lSleep(status), DllCall("mouse_event", "UInt", 0x04))))
            case "Right": (status = "Down" ? DllCall("mouse_event", "UInt", 0x08)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x10)  : (DllCall("mouse_event", "UInt", 0x08),  lSleep(status), DllCall("mouse_event", "UInt", 0x10))))
            case "Mid":   (status = "Down" ? DllCall("mouse_event", "UInt", 0x020) : (status = "Up" ? DllCall("mouse_event", "UInt", 0x040) : (DllCall("mouse_event", "UInt", 0x020), lSleep(status), DllCall("mouse_event", "UInt", 0x040))))
            case "WheelUp", "WheelDown":
                Loop, %status%
                    (DllCall("mouse_event", "UInt", 0x0800, "Int", 0, "Int", 0, "UInt", (Key = "WheelUp" ? 120 : -120), "Int", 0))
            case "WheelRight", "WheelLeft": 
                loop, %status%
                    (DllCall("mouse_event", "UInt", 0x01000, "Int", 0, "Int", 0, "UInt", (Key = "WheelRight" ? 120 : -120), "Int", 0))
            case "XBUTTON1": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0))))
            case "XBUTTON2": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0))))
        }
    }

    fMouseInputToWin(WinTitle, Key := "Left", x := 0, y := 0, WheelRotation = 1) {
        /* 
            Функция эмулирует события мыши в указанном окне. 

            WinTitle - Заголовок или идентификатор целевого окна. 
            Подробнее тут: https://www.autohotkey.com/docs/v1/lib/WinActivate.htm

            Key - Тип действия (по умолчанию "Left").
                Кнопки: "Left", "Right", "Middle", "XButton1", "XButton2"
                Колесо: "WheelUp", "WheelDown", "WheelLeft", "WheelRight"
            x, y - Координаты внутри окна (не экрана!) для позиционирования.
                (0,0) - верхний левый угол клиентской области окна

            WheelRotation  - Количество "оборотов" прокрутки (по умолчанию 1)
        */
        static KeyList := { Left:     {Down: 0x0201, Up: 0x0202}    ; WM_LBUTTONDOWN, WM_LBUTTONUP
                          , Right:    {Down: 0x0204, Up: 0x0205}    ; WM_RBUTTONDOWN, WM_RBUTTONUP
                          , Middle:   {Down: 0x0207, Up: 0x0208}    ; WM_MBUTTONDOWN, WM_MBUTTONUP
                          , XButton1: {Down: 0x020B, Up: 0x020C} 
                          , XButton2: {Down: 0x020B, Up: 0x020C} 
                          , WheelUp:    0x020A, WheelDown: 0x020A   ; WM_MOUSEWHEEL
                          , WheelRight: 0x020E, WheelLeft: 0x020E } ; WM_MOUSEHWHEEL
        hWnd := WinExist(WinTitle)
        if !hWnd {
            MsgBox, 16, fKbInputToWin, Окно с именем %WinTitle% не найдено.`nThe window named %WinTitle% was not found.
            return
        }
        lParam := (y << 16) | (x & 0xFFFF)
        switch (Key) {
            case "WheelUp", "WheelDown", "WheelRight", "WheelLeft": {
                Loop % WheelRotation {
                    wParam := ((Key = "WheelUp" || Key = "WheelRight") ? 120 : -120) << 16
                    PostMessage, % KeyList[Key], %wParam%, %lParam%, , ahk_id %hWnd%
                }
            }
            Default : {
                if (Key = "XButton1" || Key = "XButton2")
                    wParam := (Key = "XButton1" ? 0x0001 : 0x0002) << 16
                PostMessage, % KeyList[Key].Down, % wParam, % lParam, , ahk_id %hWnd%
                PostMessage, % KeyList[Key].Up, % wParam, % lParam, , ahk_id %hWnd%
            }
        }
    }

;;;;;;;;;; Keyboard ;;;;;;;;;;
    fKbInput(Key, status = "Press") {
        /*
            Kb = Keyboard
            Функция создаёт действия клавиатуры с помощью Windows API keybd_event.

            Параметр Key можно указать одним из способов (примеры для клавиши "Пробел").
                По имени, например fKeyboardInput("Space").
                Через Virtual Key (VK), например fKeyboardInput("vk0x20").
                Через Scan Code , например fKeyboardInput("sc0x39").

            Параметр status:
                "Press" — нажатие и отпускание (по умолчанию).
                "Down" — зажатие клавиши (без отпускания).
                "Up" — отпускание клавиши.
        */
        ScanCode := Format("0x{:X}", GetKeySC(Key))
        if !ScanCode {
            MsgBox, 16, fKeyboardInput, Клавиша %Key% не найдена или указана неверно.`nThe %Key% key was not found or specified incorrectly.
            Return
        }
        if (status = "Down" || status = "Press")
            DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 8, "Ptr", 0)
        if (status = "Up" || status = "Press")
            DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 2, "Ptr", 0)
    }

    fKbInputToWin(WinTitle, Key, State := "Press", SwitchToWin := 0) {
        /* 
            Функция отправляет эмуляцию нажатий клавиатуры в указанное окно.
            ВНИМАНИЕ: Имеет серьёзные ограничения из-за особенностей Windows (см. P.S.)

            WinTitle - Заголовок или идентификатор целевого окна. 
            Подробнее тут: https://www.autohotkey.com/docs/v1/lib/WinActivate.htm

            Параметр Key можно указать одним из способов (примеры для клавиши "Пробел").
                По имени, например fKeyboardInput("Space").
                Через Virtual Key (VK), например fKeyboardInput("vk0x20").
                Через Scan Code , например fKeyboardInput("sc0x39").

            Параметр status:
                "Press" — нажатие и отпускание (по умолчанию).
                "Down" — зажатие клавиши (без отпускания).
                "Up" — отпускание клавиши.

            Параметр SwitchToWin:
                Если указано (время в ms), активирует окно на это время перед эмуляцией нажатия,
                после нажатия возвращается обратно к активному окну.
                Если не указано (по умолчанию), пытается отправить нажатие без активации окна (работает не везде).

            P.S. Важные ограничения:
                1. В Windows отправка клавиш в фоновые окна без активации работает ТОЛЬКО
                   для некоторых приложений (обычно старых или консольных)
                2. Для большинства современных программ требуется активация окна (SwitchToWin > 0)
                3. Если окно активно, рекомендуется использовать стандартные методы AHK (Send или fKbInput)
                4. Функция использует PostMessage с WM_KEYDOWN/WM_KEYUP, что не всегда равноценно реальному вводу 
                5. Использование State="Down"/"Up" чаще всего бессмысленно, так как:
                    - При PostMessage невозможно корректно эмулировать ЗАЖАТИЕ клавиши
                    - Большинство программ обрабатывают только полный цикл нажатия (Press)
                    - Может нарушаться синхронизация состояний клавиатуры
        */
        hWnd := WinExist(WinTitle)
        if !hWnd {
            MsgBox, 16, fKbInputToWin, Окно с именем %WinTitle% не найдено.`nThe window named %WinTitle% was not found.
            return
        }
        if SwitchToWin {
            activeWindow := WinExist("A")
            WinActivate, ahk_id %hWnd%
            WinWaitActive, ahk_id %hWnd%, , 0.5
            if ErrorLevel {
                MsgBox, 16, fKbInputToWin, Не удалось переключиться на окно %WinTitle%.`nCouldn't switch to %WinTitle% window. `n`nhWnd: %hWnd%
                Return
            }
            lSleep(SwitchToWin)
        }
        ScanCode   := Format("0x{:X}", GetKeySC(Key))
        VirtualKey := Format("0x{:X}", GetKeyVK(Key))
        ;isTextKey := (VirtualKey >= 0x30 && VirtualKey <= 0x5A) || VirtualKey == 0x20  ; 0-9, A-Z, Space
        if (State = "Down" || State = "Press") {
            PostMessage, 0x100, % VirtualKey, (ScanCode << 16) | 0x00000001, , ahk_id %hWnd%  ; WM_KEYDOWN
            /* 
            if (isTextKey) {
                PostMessage, 0x102, % VirtualKey, (ScanCode << 16) | 0x00000001, , ahk_id %hWnd%  ; WM_CHAR
            }
            */
        }
        if (State = "Up" || State = "Press")
            PostMessage, 0x101, % VirtualKey, (ScanCode << 16) | 0xC0000001, , ahk_id %hWnd%  ; WM_KEYUP
        if SwitchToWin {
            lSleep(SwitchToWin)
            WinActivate, ahk_id %activeWindow%
        }
    }