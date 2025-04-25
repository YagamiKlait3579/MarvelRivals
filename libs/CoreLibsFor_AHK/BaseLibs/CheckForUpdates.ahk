;;;;;;;;;; Loading ;;;;;;;;;;
    global CheckForUpdates_IsRunning ; for CheckForUpdates

;;;;;;;;;; Check for updates ;;;;;;;;;;
    CheckForUpdates(nameUser, nameRepo, nameBranch = "main", controlFile = "") {
        global
        local funcObj
    
        ; Проверка ошибок вызова функции
        if (!nameUser || !nameRepo) {
            MsgBox, 16, CheckForUpdates Error, Не указан nameUser или nameRepo! `nNameUser or nameRepo is not specified!
            return 0
        }
    
        ; Проверка ini файла
        if !CheckingFiles("File", False, "CoreSettings.ini") {
            CheckingFiles("Folder", True, "Resources")
            IniWrite, %A_YYYY%, %OP_Resources%\CoreSettings.ini, Check for updates, CheckForUpdates_Year
            IniWrite, %A_YDay%, %OP_Resources%\CoreSettings.ini, Check for updates, CheckForUpdates_Day
            IniWrite, 0, %OP_Resources%\CoreSettings.ini, Check for updates, CheckForUpdates_OffUpdates
        }
        LoadIniSection(CheckingFiles("File", True, "CoreSettings.ini"), "Check for updates")
    
        ; Редактирование Tray menu
        ; CFU - Check for updates
        funcObj := Func("CheckForUpdates_Run").Bind("OnUpdates")
        Menu, TrayCFU, Add, Enable update check, %funcObj%
        funcObj := Func("CheckForUpdates_Run").Bind("OffUpdates")
        Menu, TrayCFU, Add, Disable update check, %funcObj%
        funcObj := Func("CheckForUpdates_Run").Bind("Download", "https://github.com/" nameUser "/" nameRepo "/archive/refs/heads/" nameBranch ".zip")
        Menu, TrayCFU, Add, Download latest version, %funcObj%
        Menu, TrayCFU, icon, Download latest version, %OP_Base_ICO%, 29
    
        if CheckForUpdates_OffUpdates 
            Menu, TrayCFU, Check, Disable update check
        Else
            Menu, TrayCFU, Check, Enable update check
    
        Menu, Tray, Insert, Reload, Updates, :TrayCFU
        Menu, Tray, icon, Updates, %OP_Base_ICO%, 27
        Menu, Tray, Insert, Reload
    
        ; Проверяем, включена ли проверка обновлений.
        ; Проверка даты (Не более одного сообщения в день!)
        if ((CheckForUpdates_Year >= A_YYYY) && (CheckForUpdates_Day >= A_YDay) || CheckForUpdates_OffUpdates)
            Return
    
        ; Создание окна интерфейса
        CheckForUpdates_IsRunning := True
        if ((controlFile = "") || !FileExist(controlFile))
            controlFile := A_ScriptFullPath
        ;--------------------------------------------------
        local FontSize := Round(((15 * gFontScaling) * gDPI) * (0.01 * gInterfaceScale))
        local Margin   := [Round(FontSize * 1.25), Round(FontSize * 0.75)]
        local w1 := A_ScreenWidth / 2.5
        local h1 := (w1 / 16) * 9
        Gui, CheckForUpdates: +AlwaysOnTop +LastFound -DPIScale +Border -MinimizeBox +HwndCheckForUpdates
        Gui, CheckForUpdates: Color, 151515
        Gui, CheckForUpdates: Margin, % Margin.1, % Margin.2
        Gui, CheckForUpdates: Font, % " s"FontSize " q3 w1000", MS Sans Serif
        Gui, CheckForUpdates: Add, Picture, x0 y0 w%w1% h-1, % "HBITMAP:" ReadImages(CheckingFiles("File", False,"Base_Images.dll"), "CheckForUpdates")
        ;--------------------------------------------------
        Gui, CheckForUpdates: Add, Text, xm ym +center +Border c007BFF vText1 +HwndText1, Подождите, `n идет проверка обновлений... `n`Please wait, `n checking for updates...
        ;--------------------------------------------------
        FontSize := Round(((13 * gFontScaling) * gDPI) * (0.01 * gInterfaceScale))
        Gui, CheckForUpdates: Font, % " s"FontSize " q3 wNorm", MS Sans Serif
        ;--------------------------------------------------
        Gui, CheckForUpdates: Add, Text, xm y+m wp +center +Border c00e1e1 vButton1,` Скачать последнюю версию. `nDownload the latest version.
        funcObj := Func("CheckForUpdates_Run").Bind("Download", "https://github.com/" nameUser "/" nameRepo "/archive/refs/heads/" nameBranch ".zip")
        GuiControl CheckForUpdates: +g, Button1, %FuncObj%
        Gui, CheckForUpdates: Add, Text, xm y+m wp +center +Border c00e1e1 vButton2,` Откл. проверку обновлений! `nDisable the update check! `
        funcObj := Func("CheckForUpdates_Run").Bind("OffUpdates")
        GuiControl CheckForUpdates: +g, Button2, %FuncObj%
        ;--------------------------------------------------
        Gui, CheckForUpdates: Add, Picture, xm y+m w-1 hp +Border +BackgroundTrans vDiscordGUI, % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "GitHubLogo")
        funcObj := Func("Tray_links").Bind("Discord")
        GuiControl KeyInfo: +g, DiscordGUI, %funcObj%
        Gui, CheckForUpdates: Add, Picture, xm y+m w-1 hp +Border +BackgroundTrans vGitHubGUI, % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "DiscordLogo")
        funcObj := Func("Tray_links").Bind("GitHub")
        GuiControl KeyInfo: +g, GitHubGUI, %funcObj%
        ;--------------------------------------------------
        Gui, CheckForUpdates: Show, w%w1% h%h1%, Checking for updates
    
        try {
            ; Получаем дату последнего коммита (UTC)
            local apiUrl := "https://api.github.com/repos/" nameUser "/" nameRepo "/commits/" nameBranch
            local req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            req.Open("GET", apiUrl, true)
            req.SetRequestHeader("User-Agent", "AHK-Update-Checker")
            req.Send()
            req.WaitForResponse()
            if (req.Status != 200)
                throw, req.Status
        
            ; Парсим дату из GitHub (UTC время)
            if !RegExMatch(req.ResponseText, """date"":\s*""([^""]+)""", match)
                throw, req.Status
        
            ; Преобразуем GitHub дату в формат YYYYMMDDHH24MISS
            RegExMatch(match1, "(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z", dt)
            local gitTime := dt1 dt2 dt3 dt4 dt5 dt6  ; UTC время

            ; Получаем время создания файла (локальное время)
            local fileLocalTime
            FileGetTime, fileLocalTime, %controlFile%, C
    
            ; Сравниваем времена
            if (gitTime > (fileLocalTime - (A_Now - A_NowUTC))) {
                GuiControl, CheckForUpdates: +c00e100 +Redraw, Text1
                GuiControl, CheckForUpdates: Text, Text1, `nДоступна новая версия!`nA new version is available!
                CheckForUpdates_Run("End")
                WinWaitClose, ahk_id %CheckForUpdates% 
                return true
            }
            throw, ""
        }
        catch e { ; Обработка ошибок
            local ErrorCode := (e != "") ? e : "Null"
            GuiControl, CheckForUpdates: +ce11919 +Redraw, Text1
            GuiControl, CheckForUpdates: Text, Text1, Ошибка при проверке обновлений.`nUpdate check failed.`nError code: [ %ErrorCode% ].
        }
        CheckForUpdates_Run("End")
        WinWaitClose, ahk_id %CheckForUpdates% 
        return false
    }
    
    CheckForUpdates_Run(param, param2 = "") {
        global
        switch param {
            case "Download" : {
                Run, %param2%
            }
            case "OffUpdates" : {
                IniWrite, 1, %OP_CoreSettings%, Check for updates, CheckForUpdates_OffUpdates
                Menu, TrayCFU, Check, Disable update check
                Menu, TrayCFU, UnCheck, Enable update check
            }
            case "OnUpdates" : {
                IniWrite, 0, %OP_CoreSettings%, Check for updates, CheckForUpdates_OffUpdates
                Menu, TrayCFU, UnCheck, Disable update check
                Menu, TrayCFU, Check, Enable update check
            }
            case "End" : {
                CheckForUpdates_IsRunning := False
                IniWrite, %A_YYYY%, %OP_CoreSettings%, Check for updates, CheckForUpdates_Year
                IniWrite, %A_YDay%, %OP_CoreSettings%, Check for updates, CheckForUpdates_Day
            }
        }
    }
    
    CheckForUpdatesGuiClose() {
        global
        if CheckForUpdates_IsRunning
            Return, 1
        Else
            Gui, CheckForUpdates: Destroy
    }