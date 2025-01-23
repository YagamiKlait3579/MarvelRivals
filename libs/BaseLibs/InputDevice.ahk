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

    fMoveMouseInParts(x, y, divide = 1, pauses = 0) {
        /* 
            Двигает мышь на нужное количество пикселей, но делает это частями вместо одного резкого движения.
            divide = за сколько движений нужно сдвинутся на X и Y пикселей
            pauses = паузы между движениями
        */
        if (divide = 1) {
            Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
            DllCall("mouse_event", "UInt", 0x01, "Int", x, "Int", -y, "UInt", 0, "Int", 0)
            Return
        }
        divide := divide > abs(x) ? (abs(x) > abs(y) ? abs(y) : abs(x)) : divide > abs(y) ? abs(y) : divide < 1 ? 1 : divide
        Move_x := Round(x / divide), Remainder_x := x -(Move_x * divide)
        Move_y := Round(y / divide), Remainder_y := y -(Move_y * divide)
        Loop, %divide% {
            Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
            DllCall("mouse_event", "UInt", 0x01, "Int", Move_x, "Int", -Move_y, "UInt", 0, "Int", 0)
            if IsFunc("lSleep")
                lSleep(pauses)
            else
                Sleep, pauses
        }
        if (Remainder_x != 0 || Remainder_y != 0) {
            Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
            DllCall("mouse_event", "UInt", 0x01, "Int", Remainder_x, "Int", -Remainder_y, "UInt", 0, "Int", 0)
        }
    }

    fMouseInput(Key = "Left", status = 25) {
        /*
            Создает действия мыши с помощью Windows API mouse_event

            Для кнопок мыши status указывает время зажатия кнопки в ms
            Для колеса мыши status указывает количество оборотов которое необходимо совершить
        */
        switch (Key) {
            case "Left":  (status = "Down" ? DllCall("mouse_event", "UInt", 0x02)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x04)  : (DllCall("mouse_event", "UInt", 0x02),  lSleep(status), DllCall("mouse_event", "UInt", 0x04))))
            case "Right": (status = "Down" ? DllCall("mouse_event", "UInt", 0x08)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x10)  : (DllCall("mouse_event", "UInt", 0x08),  lSleep(status), DllCall("mouse_event", "UInt", 0x10))))
            case "Mid":   (status = "Down" ? DllCall("mouse_event", "UInt", 0x020) : (status = "Up" ? DllCall("mouse_event", "UInt", 0x040) : (DllCall("mouse_event", "UInt", 0x020), lSleep(status), DllCall("mouse_event", "UInt", 0x040))))
            case "WheelUp":    (DllCall("mouse_event", "UInt", 0x0800, "Int", 0, "Int", 0, "UInt", status * 120, "Int", 0))
            case "WheelDown":  (DllCall("mouse_event", "UInt", 0x0800, "Int", 0, "Int", 0, "UInt", -status * 120, "Int", 0))
            case "WheelRight": (DllCall("mouse_event", "UInt", 0x01000, "Int", 0, "Int", 0, "UInt", status * 120, "Int", 0))
            case "WheelLeft":  (DllCall("mouse_event", "UInt", 0x01000, "Int", 0, "Int", 0, "UInt", -status * 120, "Int", 0))
            case "XBUTTON1": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0))))
            case "XBUTTON2": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0))))
        }
    }

;;;;;;;;;; Keyboard ;;;;;;;;;;
    KBE_Input(ScanCode, status = "") {
        /* KBE = Keybd event
            Создает действия клавиатуры с помощью Windows API keybd_event используя ScanCode

            ScanCode можно указывать как с приставкой так и без.
            Например для клавиши Space можно указать KBE_Input("sc0x39") или KBE_Input(0x39)
        */
        ScanCode := RegExReplace(ScanCode, "i)sc", "")
            if (status = "Down" || status = "")
                DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 8, "Ptr", 0)
            if (status = "Up" || status = "")
                DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 2, "Ptr", 0)
    }