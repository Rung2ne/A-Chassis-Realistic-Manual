# A-Chassis-Realistic-Manual 1.4
> [!NOTE]
> 본 리포지토리는 Roblox A-Chassis의 수동 변속기(Manual) 기믹을 보다 현실적으로 구현하기 위한 스크립트 수정 방법을 다룹니다.
> 
> 현실성을 높이고, 본 기믹 업그레이드의 효과를 극대화하기 위해선 **실차의 마력, rpm, 기어비 세팅**으로 맞춰주셔야 합니다.

> [!WARNING]  
> 본 코드를 이용한 차량 개조 작업 중 발생하는 A-Chassis 스크립트 오류 및 고장에 대해 원작자는 일체의 책임을 지지 않습니다.
> ## 스크립트 수정 전, 반드시 정상 작동하는 기존 차량 모델 혹은 스크립트를 백업(복제)한 후 작업을 진행하시기 바랍니다.
> 모든 사용 및 수정 책임은 사용자 본인에게 있습니다.

## 🚀 적용 방법

1. **`Drive.luau` 스크립트 열기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Tune` > `A-Chassis Interface` > `Drive`

2. **아이들 발진 변수 추가하기**
   * 스크립트 내에서 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     local _InControls = false
     ```
     * 그 밑에 아래의 변수를 추가합니다.
     ```lua
     local LaunchBuild = 0
     local _LurchTimer = 0
     local _StallTimer = 0
     local _PrevGear = 0
     local LURCH_DURATION = 0.6   -- 아이들 발진 지속 시간
     local LURCH_PEAK    = 2.5    -- 아이들 발진 토크 배수
     ```

예상 결과:
     ```lua
     local _InControls = false

     local LaunchBuild = 0
     local _LurchTimer = 0
     local _StallTimer = 0
     local _PrevGear = 0
     local LURCH_DURATION = 0.6   -- 아이들 발진 지속 시간
     local LURCH_PEAK    = 2.5    -- 아이들 발진 토크 배수

--[[Shutdown]]
```

3. **`deltaTime` 변숫값 수정하기**
   * `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
   ```lua
      local deltaTime = (60/(1/dt))
   ```
   * 해당되는 모든 변숫값을 아래의 변숫값으로 교체합니다.
   ```lua
      local deltaTime = (60/(1/math.max(dt, 0.001)))
      ```

4. **`function Gear()` 함수 수정하기**
   * 다시 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     function Gear()
     ```
   * 해당 함수를 전체 선택 후 **[function Gear().luau](./function%20Gear().luau)** 파일 속 내용으로 교체합니다.

5. **`function Engine(dt)` 함수 수정하기**
   * 다시 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     function Engine(dt)
     ```
   * 해당 함수를 전체 선택 후 **[function Engine(dt).luau](./function%20Engine(dt).luau)** 파일 속 내용으로 교체합니다.


6. **`AutoClutch` 비활성화하기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Interface` > `Values` > `AutoClutch`
   * 해당 위치에 있는 `AutoClutch` (BoolValue)의 **Value 체크를 해제**합니다.

7. **`A-Chassis Tune.luau` 설정 변경하기**
   * 차량 설정 스크립트인 `A-Chassis Tune.luau`를 열고, 다음과 같은 설정으로 값을 변경합니다.
     * 구동계를 수동으로 변경합니다.
     ```lua
     Tune.Clutch            = true
     Tune.TransModes        = {"Manual"}
     ```
     * 플라이휠의 값은 1~10을 추천합니다.
     ```lua
     Tune.Flywheel          = 1
     ```
     * 시동이 꺼지게 합니다.
     ```lua
     Tune.Stall             = true
     ```
     * 악셀레이터를 누르고 있지 않을때만 변속이 되게 바꿉니다. (선택사항)
     ```lua
     Tune.ClutchRel         = true
     ```
