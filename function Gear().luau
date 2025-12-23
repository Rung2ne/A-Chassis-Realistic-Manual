function Gear()
    local maxSpin=0
    for i,v in pairs(Drive) do if v.RotVelocity.Magnitude>maxSpin then maxSpin = v.RotVelocity.Magnitude end end

    if _TMode == "Manual" and _Tune.Clutch and _CGear == 0 and (_ShiftUp or _ShiftDn) and not _PlayerClutch then
        script.Parent.IsOn.Value = false
        _ShiftUp = false
        _ShiftDn = false
        return
    end

    if _ShiftUp and not _Shifting then
        if (_TMode == "Manual" and not _ClPressing) or (_TMode == "Manual" and _Tune.ClutchRel and (_InThrot-(_Tune.IdleThrottle/100)>0)) or _CGear == #_Tune.Ratios-2 or (_TMode ~= "Manual" and not _IsOn) then _ShiftUp = false return end
        local NextGear = math.min(_CGear+3,#_Tune.Ratios)
        if _TMode~="Manual" then
            _Shifting = true
            if _CGear>0 then 
                if _Tune.AutoShiftType=="DCT" then 
                    wait(_Tune.ShiftUpTime)
                elseif _Tune.AutoShiftType=="Rev" then
                    repeat wait() until _RPM<=math.max(math.min(maxSpin*_Tune.Ratios[NextGear]*fFDr,_Tune.Redline-_Tune.RevBounce),_Tune.IdleRPM) or not _IsOn or _ShiftDn 
                end
            end
        end
        _ShiftUp = false
        _Shifting = false
        if _TMode ~= "Manual" and not _IsOn then return end
        _CGear = math.min(_CGear+1,#_Tune.Ratios-2)
        if _TMode ~= "Manual" and _IsOn then
            _ClPressing = false
        end
    end
    if _ShiftDn and not _Shifting then
        if (_TMode == "Manual" and not _ClPressing) or _CGear == -1 or (_TMode ~= "Manual" and not _IsOn) then _ShiftDn = false return end
        local PrevGear = math.min(_CGear+1,#_Tune.Ratios)
        if _TMode~="Manual" then
            _Shifting = true
            if _CGear>1 then 
                if _Tune.AutoShiftType=="DCT" then 
                    wait(_Tune.ShiftDnTime)
                elseif _Tune.AutoShiftType=="Rev" then
                    repeat wait() until _RPM>=math.max(math.min(maxSpin*_Tune.Ratios[PrevGear]*fFDr,_Tune.Redline-_Tune.RevBounce),_Tune.IdleRPM) or not _IsOn or _ShiftUp
                end
            end
        end
        _ShiftDn = false
        _Shifting = false
        if _TMode ~= "Manual" and not _IsOn then return end
        _CGear = math.max(_CGear-1,-1)
        if _TMode ~= "Manual" and _IsOn then
            _ClPressing = false
        end
    end
end