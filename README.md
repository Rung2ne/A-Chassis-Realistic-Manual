# A-Chassis-Realistic-Manual
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
