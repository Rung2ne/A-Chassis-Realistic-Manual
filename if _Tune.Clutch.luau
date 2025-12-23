if _Tune.Clutch then
    if script.Parent.Values.AutoClutch.Value and _IsOn then
        if _Tune.ClutchType == "Clutch" then
            if _ClPressing then _ClutchKick = 1 end
            _ClutchKick = _ClutchKick*(_Tune.ClutchEngage/100)        
            local ClRPMInfluence = math.max((_RPM-_Tune.IdleRPM)*_Tune.ClutchRPMMult/(_Tune.Redline-_Tune.IdleRPM),0)
                if _Tune.ClutchMode == "New" then ClRPMInfluence = 0 end
                _ClutchModulate = math.min(((((script.Parent.Values.Velocity.Value.Magnitude/_Tune.SpeedEngage)/math.abs(_CGear)) + ClRPMInfluence) - _ClutchKick), 1)
            elseif _Tune.ClutchType == "CVT" or (_Tune.ClutchType == "TorqueConverter" and _Tune.TQLock) then
                if (_GThrot-(_Tune.IdleThrottle/100)==0 and script.Parent.Values.Velocity.Value.Magnitude<_Tune.SpeedEngage) or (_GThrot-(_Tune.IdleThrottle/100)~=0 and (_RPM < _Tune.RPMEngage and _WheelRPM < _Tune.RPMEngage)) then
                    _ClutchModulate = math.min(_ClutchModulate*(_Tune.ClutchEngage/100), 1)
                else
                    _ClutchModulate = math.min(_ClutchModulate*(_Tune.ClutchEngage/100)+(1-(_Tune.ClutchEngage/100)), 1)
                end
            elseif _Tune.ClutchType == "TorqueConverter" and not _Tune.TQLock then
                _ClutchModulate = math.min((_RPM/_Tune.Redline)*0.7, 1)
            end
            if not _ClPressing then _Clutch = math.min(1-_ClutchModulate,1) else _Clutch = 1 end
        else
            if _ClPressing then
                _Clutch = math.min(_Clutch + 0.125, 1) 
            else
                _Clutch = math.max(_Clutch - 0.075, 0) 
            end
        end
        _StallOK = (_Clutch<=0.01) or _StallOK
    else
        _StallOK = false
        if not _ClPressing and not _Shifting then _Clutch = 0 else _Clutch = 1 end
    end