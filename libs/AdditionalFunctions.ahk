;;;;;;;;;; Loading ;;;;;;;;;;

;;;;;;;;;; Variables ;;;;;;;;;;

;;;;;;;;;; Additional functions ;;;;;;;;;;
    AssistAim(SearchArea, A_FT, FT,Offset) {
        TimeStamp(A_Start)
        if FindText(EntityX, EntityY, SearchArea[1], SearchArea[2], SearchArea[3], SearchArea[4], A_FT, A_FT, FT) {
            moving_X := Round((EntityX - gScreenCenter[1]) / MouseSpeed) + Offset[1]
            moving_Y := Round((EntityY - gScreenCenter[2]) / MouseSpeed) + Offset[2]
            fMoveMouse(moving_X, -moving_Y)
        }
    }