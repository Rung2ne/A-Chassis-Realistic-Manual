function Engine(dt)
	local deltaTime = (60/(1/math.max(dt, 0.001)))

	if ((_CGear == 0 or _Shifting) and _IsOn) then 
		_ClPressing = true
		_Clutch = 1
		_StallOK = false
	end

	if _Shifting and _ShiftUp then _GThrot = 0 elseif _Shifting and _ShiftDn then _GThrot = (_Tune.ShiftThrot/100) else
		if (_Tune.AutoShiftVers == "Old" and _CGear==-1 and _TMode=="Auto") then _GThrot = _InBrake else _GThrot = _InThrot end
	end

	-- Exponential braking curve for heavy vehicle feel
	local brakeTarget = (_Tune.AutoShiftVers == "Old" and _CGear==-1 and _TMode=="Auto") and _InThrot or _InBrake
	_GBrake = math.pow(brakeTarget, 1.3)

	local revMin = 0
	local goalMin = _Tune.IdleRPM
	local goalMax = _Tune.Redline

	if not _IsOn then 
		ticc = tick()
		revMin = 0; goalMin = 0; _GThrot = 0
		if _TMode~="Manual" then _CGear = 0; _ClPressing = true; _Clutch = 1 end
	end

	local revThrot = _GThrot
	local maxSpin, maxCount = 0, 0
	for i,v in pairs(Drive) do maxSpin = maxSpin + v.RotVelocity.Magnitude maxCount = maxCount + 1 end
	if maxCount > 0 then maxSpin = maxSpin / maxCount end

	local gearRatio = math.abs(_Tune.Ratios[_CGear+2] or 1)
	local mechanicalAdvantage = gearRatio * fFD
	local _WheelRPM = maxSpin * mechanicalAdvantage * (30/math.pi)

	-- Torque Converter & Clutch Optimization
	if _Tune.Clutch then
		if script.Parent.Values.AutoClutch.Value and _IsOn then
			if _Tune.ClutchType == "Clutch" then
				if _ClPressing then _ClutchKick = 1 end
				_ClutchKick = _ClutchKick*(_Tune.ClutchEngage/100)        
				local ClRPMInfluence = math.max((_RPM-_Tune.IdleRPM)*_Tune.ClutchRPMMult/(_Tune.Redline-_Tune.IdleRPM),0)
				if _Tune.ClutchMode == "New" then ClRPMInfluence = 0 end
				local gearAbs = math.max(1, math.abs(_CGear)) 
				_ClutchModulate = math.min(((((script.Parent.Values.Velocity.Value.Magnitude/_Tune.SpeedEngage)/gearAbs) + ClRPMInfluence) - _ClutchKick), 1)
			elseif _Tune.ClutchType == "CVT" or (_Tune.ClutchType == "TorqueConverter" and _Tune.TQLock) then
				if (_GThrot==0 and script.Parent.Values.Velocity.Value.Magnitude<_Tune.SpeedEngage) or (_GThrot~=0 and (_RPM < _Tune.RPMEngage and _WheelRPM < _Tune.RPMEngage)) then
					_ClutchModulate = math.min(_ClutchModulate*(_Tune.ClutchEngage/100), 1)
				else
					_ClutchModulate = math.min(_ClutchModulate*(_Tune.ClutchEngage/100)+(1-(_Tune.ClutchEngage/100)), 1)
				end
			elseif _Tune.ClutchType == "TorqueConverter" and not _Tune.TQLock then
				_ClutchModulate = math.min((_RPM/math.max(_Tune.RPMEngage, _Tune.IdleRPM*1.5)), 1)
			end
			if not _ClPressing then _Clutch = math.min(1-_ClutchModulate,1) else _Clutch = 1 end
		else
			if _ClPressing then _Clutch = math.min(_Clutch + 0.125, 1) else _Clutch = math.max(_Clutch - 0.075, 0) end
		end
		_StallOK = (_Clutch<=0.01) or _StallOK
	else
		_StallOK = false
		if not _ClPressing and not _Shifting then _Clutch = 0 else _Clutch = 1 end
	end

	local clutchEngage = 1 - _Clutch

	if _GoalRPM > goalMax + 100 then revThrot = 0 end

	-- Engine Dynamics
	if _Tune.Engine then
		local targetRPM = (_RPM - _Tune.RevDecay * deltaTime) + ((_Tune.RevDecay + _Tune.RevAccel) * revThrot * deltaTime)
		local clampMin = _IsOn and _Tune.IdleRPM or 0
		_GoalRPM = math.clamp(targetRPM, clampMin, _Tune.Redline + 200)
	end

	local aRPM = (_GoalRPM * _Clutch) + (_WheelRPM * clutchEngage)
	local lerpFactor = 1
	if clutchEngage > 0.05 then
		lerpFactor = math.clamp((15 / math.max(0.1, _Tune.Flywheel)) * deltaTime, 0.05, 0.85)
	end

	local prevRPM = _RPM
	_RPM = _RPM + (aRPM - _RPM) * lerpFactor
	if _RPM < 0 then _RPM = 0 end

	-- Stall Logic
	if _IsOn and _StallOK then
		if _RPM < (_Tune.IdleRPM * 0.45) then
			if _RPM <= (_Tune.IdleRPM * 0.3) then
				_StallTimer = _StallTimer + dt
				if _StallTimer > 0.25 + (math.random() * 0.2) then 
					script.Parent.IsOn.Value = not _Tune.Stall
					_StallTimer = 0
				end
			else _StallTimer = math.max(0, _StallTimer - dt) end
		else _StallTimer = 0 end
	end

	local currentRatioForLimit = _Tune.Ratios[_CGear+2]
	if currentRatioForLimit == 0 then currentRatioForLimit = 1 end
	_spLimit = (_Tune.Redline+100) / (fFDr * math.abs(currentRatioForLimit))

	-- Turbo & Supercharger Output Calculation
	local TPsi = _TPsi/math.max(1, _TCount)
	local _BThrot = _GThrot
	if _Tune.Engine then
		if _TCount~=0 and _TCount~=2 then
			_TBoost = _TBoost + ((((((_HP*(_BThrot*1.2)/_Tune.Horsepower)/8)-(((_TBoost/TPsi*(TPsi/15)))))*((8/(_Tune.T_BoostLag/(deltaTime)))*2))/TPsi)*15)
			if _TBoost < 0.05 then _TBoost = 0.05 elseif _TBoost > 2 then _TBoost = 2 end
		else _TBoost = 0 end
		if _SCount~=0 then
			if _BThrot>sthrot then sthrot=math.min(_BThrot,sthrot+_Tune.S_Sensitivity*deltaTime)
			elseif _BThrot<sthrot then sthrot=math.max(_BThrot,sthrot-_Tune.S_Sensitivity*deltaTime) end
			_SBoost = (_RPM/_Tune.Redline)*(.5+(1.5*sthrot))
		else _SBoost = 0 end
	else _TBoost, _SBoost = 0, 0 end

	local calcRPM = math.max(_Tune.IdleRPM * 0.7, _RPM)
	local rpmIdx = math.floor(math.min(_Tune.Redline, calcRPM) / 100)
	local rpmRem = ((calcRPM - math.floor(calcRPM/100)) / 100) % 1

	if _Tune.Engine then
		local cTq = NCache[_CGear+2][rpmIdx]
		_NH = cTq.Horsepower + (cTq.HpSlope * rpmRem)
		_NT = cTq.Torque + (cTq.TqSlope * rpmRem)
		if _TCount~=0 then
			local tTq = TCache[_CGear+2][rpmIdx]
			_TH = (tTq.Horsepower + (tTq.HpSlope * rpmRem)) * (_TBoost/2)
			_TT = (tTq.Torque + (tTq.TqSlope * rpmRem)) * (_TBoost/2)
		else _TH,_TT = 0,0 end
		if _SCount~=0 then
			local sTq = SCache[_CGear+2][rpmIdx]
			_SH = (sTq.Horsepower + (sTq.HpSlope * rpmRem)) * (_SBoost/2)
			_ST = (sTq.Torque + (sTq.TqSlope * rpmRem)) * (_SBoost/2)
		else _SH,_ST = 0,0 end
		_BH = _TH+_SH; _BT = _TT+_ST
	else
		_NH,_NT, _TH,_TT, _SH,_ST, _BH,_BT = 0,0, 0,0, 0,0, 0,0
	end

	_EH,_ET = 0,0
	_HP = _NH + _BH + _EH
	if _HP ~= _HP or _RPM ~= _RPM then
		_HP, _RPM, _GoalRPM = 0, _Tune.IdleRPM, _Tune.IdleRPM
		_TBoost, _SBoost = 0.05, 0
		_TH,_TT, _SH,_ST, _BH,_BT = 0,0, 0,0, 0,0
	end

	_OutTorque = _NT + _BT + _ET
	local iComp =(car.DriveSeat.CFrame.lookVector.y)*cGrav
	if _CGear==-1 then iComp=-iComp end
	_OutTorque = _OutTorque * math.max(1,(1+iComp))

	local fwspeed, fwcount, rwspeed, rwcount = 0,0,0,0
	for i,v in pairs(car.Wheels:GetChildren()) do
		if v.Name=="FL" or v.Name=="FR" or v.Name == "F" then fwspeed=fwspeed+v.RotVelocity.Magnitude fwcount=fwcount+1
		elseif v.Name=="RL" or v.Name=="RR" or v.Name == "R" then rwspeed=rwspeed+v.RotVelocity.Magnitude rwcount=rwcount+1 end
	end
	if fwcount > 0 then fwspeed=fwspeed/fwcount end
	if rwcount > 0 then rwspeed=rwspeed/rwcount end
	local cwspeed=(fwspeed+rwspeed)/2

	--Update Wheels
	for i,v in pairs(car.Wheels:GetChildren()) do
		local diffMult, RRdiffMult, RLdiffMult, FRdiffMult, FLdiffMult = 1,1,1,1,1
		if _Tune.DifferentialType=='Old' then
			if v.Name=="FL" or v.Name=="FR" then diffMult=math.max(0,math.min(1,1+((((v.RotVelocity.Magnitude-fwspeed)/fwspeed)/(math.max(_Tune.FDiffSlipThres,1)/100))*((_Tune.FDiffLockThres-50)/50))))
			elseif v.Name=="RL" or v.Name=="RR" then diffMult=math.max(0,math.min(1,1+((((v.RotVelocity.Magnitude-rwspeed)/rwspeed)/(math.max(_Tune.RDiffSlipThres,1)/100))*((_Tune.RDiffLockThres-50)/50)))) end
		else
			if v.Name=="FR" then FRdiffMult=math.ceil(math.max(0,math.min(2,1-( ((_Tune.FDiffPower/100)*((v.RotVelocity.Magnitude/car.Wheels.FL.RotVelocity.Magnitude)-1)*(_Tune.FDiffPreload/10)*_GThrot) + ((_Tune.FDiffCoast/100)*((v.RotVelocity.Magnitude/car.Wheels.FL.RotVelocity.Magnitude)-1)*(_Tune.FDiffPreload/10)*(1-_GThrot)))))*100)/100 FLdiffMult=2-FRdiffMult
			elseif v.Name=="FL" then FLdiffMult=math.ceil(math.max(0,math.min(2,1-( ((_Tune.FDiffPower/100)*((v.RotVelocity.Magnitude/car.Wheels.FR.RotVelocity.Magnitude)-1)*(_Tune.FDiffPreload/10)*_GThrot) + ((_Tune.FDiffCoast/100)*((v.RotVelocity.Magnitude/car.Wheels.FR.RotVelocity.Magnitude)-1)*(_Tune.FDiffPreload/10)*(1-_GThrot)))))*100)/100 FRdiffMult=2-FLdiffMult
			elseif v.Name=="RR" then RRdiffMult=math.ceil(math.max(0,math.min(2,1-( ((_Tune.RDiffPower/100)*((v.RotVelocity.Magnitude/car.Wheels.RL.RotVelocity.Magnitude)-1)*(_Tune.RDiffPreload/10)*_GThrot) + ((_Tune.RDiffCoast/100)*((v.RotVelocity.Magnitude/car.Wheels.RL.RotVelocity.Magnitude)-1)*(_Tune.RDiffPreload/10)*(1-_GThrot)))))*100)/100 RLdiffMult=2-RRdiffMult
			elseif v.Name=="RL" then RLdiffMult=math.ceil(math.max(0,math.min(2,1-( ((_Tune.RDiffPower/100)*((v.RotVelocity.Magnitude/car.Wheels.RR.RotVelocity.Magnitude)-1)*(_Tune.RDiffPreload/10)*_GThrot) + ((_Tune.RDiffCoast/100)*((v.RotVelocity.Magnitude/car.Wheels.RR.RotVelocity.Magnitude)-1)*(_Tune.RDiffPreload/10)*(1-_GThrot)))))*100)/100 RRdiffMult=2-RLdiffMult end
		end

		_TCSActive, _ABSActive = false, false
		local on = script.Parent.IsOn.Value and 1 or 0
		local brake = _GBrake

		-- TC Creep Application (Idle RPM 기반 0% ~ 10% 동적 제어)
		local creepThrot = 0
		if _IsOn and _GThrot <= 0.01 and _CGear ~= 0 then
			-- _Tune.IdleThrottle 값을 참조하되, 최대 한계치를 10%(0.1)로 하드 리밋(Hard Limit) 설정
			local maxCreep = math.clamp((_Tune.IdleThrottle / 100), 0, 0.1)

			-- 현재 RPM이 IdleRPM 부근일 때 maxCreep(10%) 적용
			-- RPM이 (IdleRPM + 200) 이상으로 상승하면 출력이 0%로 선형적(Linear) 감쇠
			local creepFactor = math.clamp(((_Tune.IdleRPM + 200) - _RPM) / 200, 0, 1)
			creepThrot = creepFactor * maxCreep

			-- 에어 브레이크 압력이 50% 이상 개입될 경우, 구동축 저항 방지를 위해 크리핑 동력 강제 차단
			if brake > 0.5 then
				creepThrot = 0
			end
		end
		local tqMult = math.max(_GThrot, creepThrot)

		local currentGearRatio = gearRatio

		-- [ECU Torque Management] 저단 기어(R, 1, 2) 급발진 방지 및 출력 제한
		local torqueLimit = 1.0
		if _CGear == -1 then
			torqueLimit = 0.1  -- 후진(R): 엔진 토크의 10%만 허용 (매우 부드러운 후진)
		elseif _CGear == 1 then
			torqueLimit = 0.35  -- 1단: 엔진 토크의 35%만 허용 (묵직한 발차)
		elseif _CGear == 2 then
			torqueLimit = 0.65  -- 2단: 엔진 토크의 65%만 허용
		end

		-- 기어비와 토크 제한치를 함께 연산하여 최종 구동축 토크 도출
		local tq = (_OutTorque * currentGearRatio * torqueLimit)

		local tqABS = 1
		if _ABS and brake>0 and math.abs(v.RotVelocity.Magnitude*(v.Size.x/2) - v.Velocity.Magnitude)-_Tune.ABSThreshold>0 then tqABS = 0 end
		_ABSActive = (tqABS<1)

		local PBrakeV = _PBrake and 1 or 0
		local driven = false
		for _,a in pairs(Drive) do if a==v then driven = true end end

		if driven then
			if _Tune.Config == "AWD" then
				local bias = (_Tune.TorqueVector+1)/2
				if string.find(v.Name,"F") then tq = tq*(1-bias) elseif string.find(v.Name,"R") then tq = tq*bias end
			end

			tqTCS = 1
			if _TCS and _GThrot>0 then tqTCS = 1-(math.min(math.max(0,math.abs(v.RotVelocity.Magnitude*(v.Size.x/2) - v.Velocity.Magnitude)-_Tune.TCSThreshold)/_Tune.TCSGradient,1)*(1-(_Tune.TCSLimit/100))) end
			if tqTCS < 1 then _TCSAmt = tqTCS; _TCSActive = true end

			local dir = _CGear==-1 and -1 or 1
			local appliedTorque = (tq * tqMult)*(60/workspace:GetRealPhysicsFPS())*tqTCS*on*clutchEngage

			if v.Name=='RR' then v["#AV"].MotorMaxTorque=appliedTorque*RRdiffMult*diffMult
			elseif v.Name=='RL' then v["#AV"].MotorMaxTorque=appliedTorque*RLdiffMult*diffMult
			elseif v.Name=='FR' then v["#AV"].MotorMaxTorque=appliedTorque*FRdiffMult*diffMult
			elseif v.Name=='FL' then v["#AV"].MotorMaxTorque=appliedTorque*FLdiffMult*diffMult
			else v["#AV"].MotorMaxTorque=appliedTorque*diffMult end

			-- Reverted AngularVelocity to safely rotate without locking
			v["#AV"].AngularVelocity=_spLimit*dir

			-- Original standard A-Chassis engine brake calculation
			local engineBrake = 0
			if _IsOn and _CGear ~= 0 and not _ClPressing then
				engineBrake = EBrakeForce * ((1 - _GThrot) * (_RPM / _Tune.Redline)) * clutchEngage
			end

			if string.find(v.Name,"F") then
				v["#BV"].MotorMaxTorque=(FBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+engineBrake+(PBrakeForceF*PBrakeV)
			else
				v["#BV"].MotorMaxTorque=(RBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+engineBrake+(PBrakeForceR*PBrakeV)
			end
		else
			v["#AV"].MotorMaxTorque=0
			v["#AV"].AngularVelocity=0
			if string.find(v.Name,"F") then
				v["#BV"].MotorMaxTorque=(FBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(PBrakeForceF*PBrakeV)
			else
				v["#BV"].MotorMaxTorque=(RBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(PBrakeForceR*PBrakeV)
			end
		end
	end
end
