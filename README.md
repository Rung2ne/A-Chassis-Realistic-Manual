# A-Chassis-Realistic-Manual
[![방문자수   ](https://myhits.vercel.app/api/hit/https%3A%2F%2Fgithub.com%2FRung2ne%2FA-Chassis-Realistic-Manual?color=green&label=%EB%B0%A9%EB%AC%B8%EC%9E%90%EC%88%98+++&size=small)](https://myhits.vercel.app)<br/>
![2025](https://img.shields.io/badge/2025-43B02A?style=for-the-badge&logo=2025&logoColor=white)<br/>
![Environment](https://img.shields.io/badge/ENV-ff0000?style=for-the-badge&logo=ENV&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows%2011-%230079d5.svg?style=for-the-badge&logo=Windows%2011&logoColor=white)![Roblox Studio](https://img.shields.io/badge/Roblox%20Studio-%230a0b0b.svg?style=for-the-badge&logo=Roblox%20Studio&logoColor=white)<br/>
![Language](https://img.shields.io/badge/LAN-ff0000?style=for-the-badge&logo=LAN&logoColor=white)	![Luau](https://img.shields.io/badge/luau-%232C2D72.svg?style=for-the-badge&logo=luau&logoColor=white)<br/>
![Package](https://img.shields.io/badge/PKG-ff0000?style=for-the-badge&logo=PKG&logoColor=white) ![None](https://img.shields.io/badge/None-000000?style=for-the-badge&logo=None&logoColor=white)
## Roblox A-Chassis Car Realistic Manual.

> [!NOTE]  
> 본 리포지토리는 Roblox A-Chassis의 수동 변속기(Manual) 기믹을 보다 현실적으로 구현하기 위한 스크립트 수정 방법을 다룹니다.

Roblox A-Chassis Car Realistic Manual 적용 가이드입니다.

## ⚠️ 필수 준비물
* **A-Chassis**가 적용된 차량(Car) 모델이 준비되어 있어야 합니다.

## 🚀 적용 방법

1. **`Drive.lua` 스크립트 열기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Interface` > `Drive`

2. **`Gear()` 함수 수정하기**
   * 스크립트 내에서 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     function Gear()
     ```
   * 해당 함수 부분을 동봉된 **`function gear().luau`** 파일 속 내용으로 교체합니다.

3. **`_Tune.Clutch` 구문 수정하기**
   * 다시 `Ctrl + F`를 눌러 아래의 코드를 검색합니다.
     ```lua
     if _Tune.Clutch then
     ```
   * 해당 조건문 부분을 동봉된 **`if _Tune.Clutch.luau`** 파일 속 내용으로 교체합니다.

4. **`AutoClutch` 비활성화하기**
   * 탐색기(Explorer) 경로: `Car` > `A-Chassis Interface` > `Values` > `AutoClutch`
   * 해당 위치에 있는 `AutoClutch` (BoolValue)의 **Value 체크를 해제**합니다.

5. **`A-Chassis Tune.lua` 설정 변경하기**
   * 차량 설정 스크립트인 `A-Chassis Tune.lua`를 열고, 다음과 같은 설정으로 값을 변경합니다.
     ```lua
     Tune.Clutch            = true
     Tune.TransModes        = {"Manual"}

     Tune.Stall             = true
     Tune.ClutchRel         = true
     ```

## 📄 라이선스
본 프로젝트는 **MIT License**를 따릅니다.
<br><sub>본 스크립트 수정 및 사용으로 인해 발생하는 모든 문제(오류 등)에 대해 원작자는 어떠한 법적 책임도 지지 않습니다. 모든 사용 책임은 사용자 본인에게 있습니다.</sub>
