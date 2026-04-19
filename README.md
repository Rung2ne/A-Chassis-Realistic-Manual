# A-Chassis-Realistic-Manual
[![방문자수   ](https://myhits.vercel.app/api/hit/https%3A%2F%2Fgithub.com%2FRung2ne%2FA-Chassis-Realistic-Manual?color=green&label=%EB%B0%A9%EB%AC%B8%EC%9E%90%EC%88%98+++&size=small)](https://myhits.vercel.app)
![CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)<br/>
![2025](https://img.shields.io/badge/2025-43B02A?style=for-the-badge&logo=2025&logoColor=white)<br/>
![Environment](https://img.shields.io/badge/ENV-ff0000?style=for-the-badge&logo=ENV&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows%2011-%230079d5.svg?style=for-the-badge&logo=Windows%2011&logoColor=white)![Roblox Studio](https://img.shields.io/badge/Roblox%20Studio-%230a0b0b.svg?style=for-the-badge&logo=Roblox%20Studio&logoColor=white)<br/>
![Language](https://img.shields.io/badge/LAN-ff0000?style=for-the-badge&logo=LAN&logoColor=white)	![Luau](https://img.shields.io/badge/luau-%232C2D72.svg?style=for-the-badge&logo=luau&logoColor=white)<br/>
![Package](https://img.shields.io/badge/PKG-ff0000?style=for-the-badge&logo=PKG&logoColor=white) ![None](https://img.shields.io/badge/None-000000?style=for-the-badge&logo=None&logoColor=white)<br/>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Z8Z11XE7EJ)


# Roblox A-Chassis Car Realistic Manual.

> [!NOTE]
> 본 리포지토리는 Roblox A-Chassis의 수동 변속기(Manual) 기믹을 보다 현실적으로 구현하기 위한 스크립트 수정 방법을 다룹니다.

> [!WARNING]  
> 본 코드를 이용한 차량 개조 작업 중 발생하는 A-Chassis 스크립트 오류 및 고장에 대해 원작자는 일체의 책임을 지지 않습니다. **스크립트 수정 전, 반드시 정상 작동하는 기존 차량 모델 혹은 스크립트를 백업(복제)한 후 작업을 진행하시기 바랍니다.** 모든 사용 및 수정 책임은 사용자 본인에게 있습니다.

## ⚠️ 필수 준비물
* **A-Chassis**가 적용된 차량(Car) 모델이 준비되어 있어야 합니다.

## 🚀 적용 방법

1. **`Drive.luau` 스크립트 열기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Interface` > `Drive`

2. **아이들 발진 변수 추가하기**
   * 스크립트 내에서 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     local _InControls = false
     ```
   * 그 밑에 아래의 변수를 추가합니다.
     ```lua
     local LaunchBuild = 0
     local _LurchTimer = 0
     local _PrevGear = 0
     local LURCH_DURATION = 0.6   -- 아이들 발진 지속 시간
     local LURCH_PEAK    = 2.5    -- 아이들 발진 토크 배수
     ```
     * 예상 결과
     ```lua
     local _InControls = false

     local LaunchBuild = 0
     local _LurchTimer = 0
     local _PrevGear = 0
     local LURCH_DURATION = 0.6   -- 아이들 발진 지속 시간
     local LURCH_PEAK    = 2.5    -- 아이들 발진 토크 배수

     --[[Shutdown]]
     ```

3. **`function Inputs(dt)` 함수 수정하기**
   * `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
   ```lua
      function Inputs(dt)
   ```
   * 해당 함수를 전체 선택 후 아래의 함수로 교체합니다.
   ```lua
      function Inputs(dt)
          local deltaTime = (60/(1/math.max(dt, 0.001)))
          if _InThrot <= _IThrot then
              _InThrot = math.min(_IThrot,_InThrot+(_Tune.ThrotAcceldeltaTime))
          else
              _InThrot = math.max(_IThrot,_InThrot-(_Tune.ThrotDeceldeltaTime))
          end
          if _InBrake <= _IBrake then
              _InBrake = math.min(_IBrake,_InBrake+(_Tune.BrakeAcceldeltaTime))
          else
              _InBrake = math.max(_IBrake,_InBrake-(_Tune.BrakeDeceldeltaTime))
          end
      end
      ```
   
4. **`function Engine(dt)` 함수 수정하기**
   * 다시 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     function Engine(dt)
     ```
   * 해당 함수를 전체 선택 후 **`function Engine(dt).luau`** 파일 속 내용으로 교체합니다.

5. **`function Gear()` 함수 수정하기**
   * 다시 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     function Gear()
     ```
   * 해당 함수를 전체 선택 후 **`function Gear().luau`** 파일 속 내용으로 교체합니다.

4. **`AutoClutch` 비활성화하기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Interface` > `Values` > `AutoClutch`
   * 해당 위치에 있는 `AutoClutch` (BoolValue)의 **Value 체크를 해제**합니다.

5. **`A-Chassis Tune.luau` 설정 변경하기**
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
     * 악셀레이터를 누르고 있지 않을때만 변속이 되게 바꿉니다.
     ```lua
     Tune.ClutchRel         = true
     ```

## ⚖️ 라이선스
> [!NOTE]
>
> This project is licensed under **CC BY-NC-SA 4.0**.<br>
> 본 프로젝트는 **CC BY-NC-SA 4.0** 라이선스를 따릅니다.
>
> - **Non-Commercial (상업적 이용 금지):**
>   - 본 소프트웨어를 **유료로 판매**하거나 상업적인 수익 목적으로 사용할 수 없습니다.
>
> - **Attribution (저작자 표시):**
>   - 사용 시 원저작자(**Rung2ne**)를 명시해야 합니다.
>
> - **Share-Alike (동일 조건 변경 허락):**
>   - 코드를 수정하여 배포할 경우, 동일한 라이선스를 적용해야 합니다.
>
> 자세한 내용은 [LICENSE.md](./LICENSE.md) 파일을 확인하세요.
<br/><br/>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Z8Z11XE7EJ)
