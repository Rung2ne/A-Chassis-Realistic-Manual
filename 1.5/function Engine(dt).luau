function Engine(dt)
	local deltaTime = (60/(1/math.max(dt, 0.001)))

	if _LurchTimer > 0 then
		_LurchTimer = math.max(0, _LurchTimer - dt)
	end

	if ((_CGear == 0 or _Shifting) and _IsOn) then 
		_ClPressing = true
		_Clutch = 1
		_StallOK = false
	end

	local revMin = 0
	local goalMin = _Tune.IdleRPM
	local goalMax = _Tune.Redline

	if _Shifting and _ShiftUp then 
		_GThrot = 0
	elseif _Shifting and _ShiftDn then
		_GThrot = (_Tune.ShiftThrot/100)
	else
		if (_Tune.AutoShiftVers == "Old" and _CGear==-1 and _TMode=="Auto") then
			_GThrot = _InBrake
		else
			_GThrot = _InThrot
		end
	end

	if (_Tune.AutoShiftVers == "Old" and _CGear==-1 and _TMode=="Auto") then
		_GBrake = _InThrot - (_Tune.IdleThrottle/100)
	else
		_GBrake = _InBrake
	end

	if not _IsOn then 
		ticc = tick()
		revMin = 0 
		goalMin = 0
		_GThrot = _Tune.IdleThrottle/100
		if _TMode~="Manual" then 
			_CGear = 0 
			_ClPressing = true 
			_Clutch = 1 
		end
	end

	if script.Parent.Values:FindFirstChild("LimiterActive") and script.Parent.Values.LimiterActive.Value == true then
		_GThrot = script.Parent.Values.ThrottleCap.Value
		_GBrake = script.Parent.Values.BrakeCap.Value
	end

	local governor = 0
	if _RPM < _Tune.IdleRPM and _IsOn and _GThrot <= _Tune.IdleThrottle/100 then
		governor = math.clamp((_Tune.IdleRPM - _RPM) / (_Tune.IdleRPM * 0.8), 0, 0.4)
	end
	local effectiveThrot = math.max(_GThrot + governor, _Tune.IdleThrottle/100)

	if ((_ClPressing and _CGear == 0) or (_PlayerClutch and _CGear ~= 0)) and _Tune.NeutralLimit then
		if (_CGear == 0 and not _Tune.LimitClutch) or _Tune.LimitClutch then
			goalMax = _Tune.NeutralRevRPM
		end
	end