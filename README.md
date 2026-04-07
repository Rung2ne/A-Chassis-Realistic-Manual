# A-Chassis-Realistic-Manual
![2025](https://img.shields.io/badge/2025-43B02A?style=for-the-badge&logo=2025&logoColor=white)<br/>
![Environment](https://img.shields.io/badge/ENV-ff0000?style=for-the-badge&logo=ENV&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows%2011-%230079d5.svg?style=for-the-badge&logo=Windows%2011&logoColor=white)![Roblox Studio](https://img.shields.io/badge/Roblox%20Studio-%230a0b0b.svg?style=for-the-badge&logo=Roblox%20Studio&logoColor=white)<br/>
![Language](https://img.shields.io/badge/LAN-ff0000?style=for-the-badge&logo=LAN&logoColor=white)	![Luau](https://img.shields.io/badge/luau-%232C2D72.svg?style=for-the-badge&logo=luau&logoColor=white)<br/>
![Package](https://img.shields.io/badge/PKG-ff0000?style=for-the-badge&logo=PKG&logoColor=white) ![None](https://img.shields.io/badge/None-000000?style=for-the-badge&logo=None&logoColor=white)
## Roblox A-Chassis Car Realistic Manual.

## - Drive.lua 열기
Car.A-Chassis Interface.Drive

## - Ctrl+F 누르고 아래의 내용 검색하기

`function Gear()`

그 부분을 아래의 코드 파일 속 내용으로 교체하기.

(function gear().luau)

## - Ctrl+F 누르고 아래의 내용 검색하기

`if _Tune.Clutch then`

그 부분을 아래의 코드 파일 속 내용으로 교체하기.

(if _Tune.Clutch.luau)

## - 'Autoclutch'라는 BoolValue 찾기

Car.A-Chassis Interface.Values.AutoClutch

Vaule 체크 해제하기

## - A-Chassis Tune.lua 열기

다음과 같은 설정으로 바꾸기

```lua
Tune.Clutch            = true
Tune.TransModes        = {"Manual"}

Tune.Stall            = true
Tune.ClutchRel        = true
```
