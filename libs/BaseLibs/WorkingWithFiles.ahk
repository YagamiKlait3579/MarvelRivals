;;;;;;;;;; Loading ;;;;;;;;;;
    DllCall("LoadLibrary", "Str", CheckingFiles(,"gdiplus.dll"))

;;;;;;;;;; Search ;;;;;;;;;;
    CheckingFiles(SearchDir = "", params*) {
        /* 
            CheckingFiles ищет файлы указанные в params по порядку в рабочей директории,
            и возвращает переменную в виде FP_ИмяФайла в которой находится путь до файла с именем и расширением самого файла.
            Если имя файла указано без расширения то будет найдем первый попавшийся файл.
            Поиск происходит в директории запуска исполняемого файла скрипта и во всех вложенных папках.
            Если файл не найден, переменная FP_ИмяФайла не создается.
            Сама функция также возвращает путь с именем и расширением фала последнего найденного файла.
            Если не было найдено ни одного файла, возвращается 0.
            FP = File path
        */
        global
        local A_Loop, A_key, filePattern, varName, LastFile
        SearchDir := !SearchDir ? A_WorkingDir : SearchDir
        for A_Loop, A_key in params {
            filePattern := InStr(A_key, ".") ? A_key : A_key "*.*"
            varName := InStr(A_key, ".") ? SubStr(A_key, 1, InStr(A_key, ".") - 1) : A_key
            Loop, Files, % SearchDir "\" filePattern, R 
            {
                if A_LoopFileFullPath { 
                    FP_%varName% := A_LoopFileFullPath
                    LastFile := A_LoopFileFullPath
                    Break
                }
            }
        }
        Return LastFile ? LastFile : 0
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
        if !InStr(FilePath, ".ini")
            FilePath .= ".ini"
        if (Sections.1 = "All") {
            IniRead, AllSections, %FilePath%
            Sections := []
            loop, parse, AllSections, `n 
                Sections.Push(A_LoopField)
        }
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