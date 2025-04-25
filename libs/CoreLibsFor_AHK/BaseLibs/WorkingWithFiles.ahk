;;;;;;;;;; Loading ;;;;;;;;;;
    DllCall("LoadLibrary", "Str", CheckingFiles("File", False, "gdiplus.dll")) ; for ReadImages

;;;;;;;;;; Search ;;;;;;;;;;
    CheckingFiles(SearchType := "File", CreateGlobalVars := true, params*) {
        /* 
            CheckingFiles ищет файлы или папки, указанные в params, в рабочей директории (A_WorkingDir).

            Параметры:
            SearchType - тип поиска:
                "File" (по умолчанию) - ищет только файлы
                "Folder" - ищет только папки
                "Auto" - ищет сначала файлы, затем папки (если файлы не найдены)
            CreateGlobalVars - создавать ли глобальные переменные (по умолчанию true)
                Если false, в params может быть только один элемент
            params - список имен файлов/папок для поиска

            Функция создает глобальные переменные OP_ИмяФайла/Папки (если CreateGlobalVars = true).
            Возвращает путь последнего найденного объекта или 0, если ничего не найдено.

            OP = Object path
        */
        global
        local A_Loop, A_key, filePattern, varName, folderName, LastFound, found

        ; Проверка на количество параметров, если CreateGlobalVars = false
        if (!CreateGlobalVars && params.Length() > 1) {
            MsgBox, 16, CheckingFiles Error, 
            (
            При CreateGlobalVars = false можно указать только один параметр для поиска!
            When CreateGlobalVars = false you can specify only one search parameter!
            )
            return 0
        }

        for A_Loop, A_key in params {
            found := false
            varName := InStr(A_key, ".") ? SubStr(A_key, 1, InStr(A_key, ".") - 1) : A_key

            ; Поиск файлов (если нужно)
            if (SearchType = "File" || SearchType = "Auto") {
                filePattern := InStr(A_key, ".") ? A_key : A_key ".*"
                Loop, Files, % A_WorkingDir "\" filePattern, R 
                {
                    if (A_LoopFileFullPath) { 
                        if (CreateGlobalVars) {
                            OP_%varName% := A_LoopFileFullPath
                        }
                        LastFound := A_LoopFileFullPath
                        found := true
                        Break
                    }
                }
            }

            ; Если файлы не найдены и нужно искать папки (или явно запрошены папки)
            if (!found && (SearchType = "Folder" || SearchType = "Auto")) {
                ; Удаляем возможное расширение для поиска папок
                folderName := InStr(A_key, ".") ? SubStr(A_key, 1, InStr(A_key, ".") - 1) : A_key
                Loop, Files, % A_WorkingDir "\" folderName, RD 
                {
                    if (A_LoopFileFullPath && InStr(FileExist(A_LoopFileFullPath), "D")) { 
                        if (CreateGlobalVars) {
                            OP_%varName% := A_LoopFileFullPath
                        }
                        LastFound := A_LoopFileFullPath
                        found := true
                        Break
                    }
                }
            }
        }

        Return LastFound ? LastFound : 0
    }

    ProgramSearch(params*) {
        /* 
            ProgramSearch ищет сдери установленных программ в реестре указанные в params программы по порядку,
            и возвращает путь до исполняемого файла первой найденной программы в списке.
            Если ни одной программы не найдено, функция возвращает 0.
        */
        RegKeys := ["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
                   ,"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"] 
        for A_Loop, A_key in params
            for B_Loop, RegKey in RegKeys
                Loop, Reg, %RegKey%, k 
                {            
                    RegRead, ProgramName , %RegKey%\%A_LoopRegName%, DisplayName
                    StringReplace, A_String, ProgramName, %A_key%
                    if !ErrorLevel {
                        RegRead, FilePath , %RegKey%\%A_LoopRegName%, DisplayIcon
                        Return FilePath
                    }
                }
        Return 0
    }

;;;;;;;;;; Working with ini files ;;;;;;;;;;
    LoadIniSection(FilePath, Sections*) {
        /* 
            LoadIniSection загружает все переменные из секции в INI фале в скрипт.
            Все переменные создаются глобальными, но не супер-глобальным,
            подробнее можете почитать тут https://www.autohotkey.com/docs/v1/Functions.htm#SuperGlobal.

            FilePath = Путь до или файла (включая имя самого файла, расширение .ini можно не указывать)
            
            В качестве первого парамера Sections можно указать "All" 
            для того чтобы загрузить все переменные из всех секций в файле.
        */
        global
        local A_Loop, A_Section, AllVar, AllSections, OutputVar, OutputVar1, OutputVar2

        ; Проверка расширения файла
        if !InStr(FilePath, ".ini")
            FilePath .= ".ini"

        ; Получаем список всех секций
        if (Sections.1 = "All") {
            IniRead, AllSections, %FilePath%
            Sections := []
            loop, parse, AllSections, `n 
                Sections.Push(A_LoopField)
        }

        ; Загружаем переменные из секций в списке
        for A_Loop, A_Section in Sections {
            IniRead, AllVar, %FilePath%, %A_Section%
            loop, parse, AllVar, `n 
                RegExMatch(A_LoopField, "(.*?)=(.*)", OutputVar), %OutputVar1% := OutputVar2
        }
    }

    ReadImages(DllPath, ResourceName, ResourceType = "PNG") {
        ;DllCall("LoadLibrary", "Str", "Gdiplus.dll")
        pToken := Gdip_Startup()
        
        hModule := DllCall("LoadLibraryEx", "Str", DllPath, "UInt", 0, "UInt", 2)
        hRes := DllCall("FindResource", "Ptr", hModule, "Str", ResourceName, "Str", ResourceType)
        hResData := DllCall("LoadResource", "Ptr", hModule, "Ptr", hRes)
        pResData := DllCall("LockResource", "Ptr", hResData)
        ResSize := DllCall("SizeofResource", "Ptr", hModule, "Ptr", hRes)
    
        TempImagePath := A_Temp "\TempImage_" ResourceName ".png"
        FileDelete, %TempImagePath%
        hFile := DllCall("CreateFile", "Str", TempImagePath, "UInt", 0x40000000, "UInt", 0, "UInt", 0, "UInt", 2, "UInt", 0, "UInt", 0, "Ptr")
        DllCall("WriteFile", "Ptr", hFile, "Ptr", pResData, "UInt", ResSize, "UInt*", BytesWritten, "UInt", 0)
        DllCall("CloseHandle", "Ptr", hFile)
    
        pBitmap := Gdip_CreateBitmapFromFile(TempImagePath)
    
        DllCall("FreeLibrary", "Ptr", hModule)
        FileDelete, %TempImagePath%

        Return Gdip_CreateHBITMAPFromBitmap(pBitmap)
    }