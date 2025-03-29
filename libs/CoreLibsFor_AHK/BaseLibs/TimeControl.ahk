;;;;;;;;;; Loading ;;;;;;;;;;
    ;Process, Priority,, A
    ;SetBatchLines -1

;;;;;;;;;; Variables ;;;;;;;;;;
global Frequency
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
;--------------------------------------------------
global SettingFPS := SettingFPS ? SettingFPS : 60
global OneFrameTime := Round((1000 / (SettingFPS > 500 ? 500 : SettingFPS < 60 ? 60 : SettingFPS)), 2)

;;;;;;;;;; Main functions ;;;;;;;;;;
lSleep(s_time, ByRef start = "") {
    ;Critical
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    CounterBefore := start != "" ? start : CounterBefore
    if (s_time > 40) {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        ;Critical Off
        Sleep % (s_time - (1000 * (CounterAfter - CounterBefore) / Frequency)) - 20
    }
    ;Critical
    End := (CounterBefore + ( Frequency * (s_time/1000))) - 1
    loop
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    Until (End <= CounterAfter)
    ;Critical Off
}

fSleep(QuantityFPS, s_time = 0, ByRef start = "") {
    ;Critical
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    CounterBefore := start != "" ? start : CounterBefore    
    f_time := (OneFrameTime * QuantityFPS) + s_time
    if (f_time > 40) {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        ;Critical Off
        Sleep % (f_time - (1000 * (CounterAfter - CounterBefore) / Frequency)) - 20
    }
    ;Critical
    End := (CounterBefore + ( Frequency * (f_time/1000))) - 1
    loop
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    Until (End <= CounterAfter)
    ;Critical Off
}

;;;;;;;;;; Other functions ;;;;;;;;;;
TimeStamp(ByRef StampName = "") {
    DllCall("QueryPerformanceCounter", "Int64*", StampName)
    Return StampName					
}

TimePassed(Start, End = "", TimeType = "ms") {
    DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    CounterAfter := End != "" ? End : CounterAfter
    if (TimeType = "ms")
        Return Round(1000 * (CounterAfter - Start) / Frequency, 3)
    if (TimeType = "sec")
        Return Round((CounterAfter - Start) / Frequency, 3)
}

WorldTimeStamp(ByRef StampName = "") {
    ; Timestamp from Seconds since Jan 01 1970. (UTC)
    DllCall("GetSystemTimeAsFileTime", "Int64P", A_Stamp)
    Return StampName := A_Stamp - 116444736000000000
}

WorldTimePassed(Start, End = "", TimeType = "ms") {
    DllCall("GetSystemTimeAsFileTime", "Int64P", CounterAfter)
    CounterAfter := End != "" ? End : (CounterAfter - 116444736000000000)
    if (TimeType = "ms")
        Return Round(1000 * (CounterAfter - Start) / Frequency, 3)
    if (TimeType = "sec")
        Return Round((CounterAfter - Start) / Frequency, 3)
}

