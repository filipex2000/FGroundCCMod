
package.path = package.path..";FGround.rte/?.lua";
require("SpringFramework/SpringFramework")

--package.path = package.path..";VehicleFramework.rte/_Frameworks/?.lua";
--require("SpringFramework")

function mathSign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function Create(self)
	self.wheelOffsetA = Vector(19,9)
	self.wheelOffsetB = Vector(-16, 12)
	
	self.wheelA = CreateMOSRotating("Scooter Wheel"); -- CreateActor("Scooter Wheel");
	if self.wheelA then
		self.wheelA.Pos = self.Pos
		self.wheelA.Team = self.Team
		self.wheelA.IgnoresTeamHits = true;
		self.wheelA:SetWhichMOToNotHit(self,-1);
		MovableMan:AddParticle(self.wheelA);
		--MovableMan:AddActor(wheel);
	end
	
	self.wheelB = CreateMOSRotating("Scooter Wheel"); -- CreateActor("Scooter Wheel");
	if self.wheelB then
		self.wheelB.Pos = self.Pos
		self.wheelB.Team = self.Team
		self.wheelB.IgnoresTeamHits = true;
		self.wheelB:SetWhichMOToNotHit(self,-1);
		MovableMan:AddParticle(self.wheelB);
		--MovableMan:AddActor(wheel);
	end
	self.wheelAirTime = {0, 0}
	self.wheelAirTimeMax = 200
	
	--In Create
	local wheelLength = {4, 10}
	local wheelPrimaryTarget = 1
	local wheelStiffness = 25
	local wheelApplyForcesAtOffset = false
	local wheelLockToSpringRotation = true
	local wheelInheritsRotAngle = 1
	
	local springConfigA = {
		length = wheelLength,
		primaryTarget = wheelPrimaryTarget, --sets it to consider the chassis the primary target
		stiffness = wheelStiffness,
		stiffnessMultiplier = {self.Mass * 0.15, self.wheelA.Mass},
		offsets = Vector(self.wheelOffsetA.X, self.wheelOffsetA.Y), --probably don't need the Y one at all since the spring length should handle this for you
		applyForcesAtOffset = wheelApplyForcesAtOffset,
		lockToSpringRotation = wheelLockToSpringRotation, --whether spring framework'd objects should be forced in line with the spring
		inheritsRotAngle = wheelInheritsRotAngle,
		rotAngleOffset = -math.pi*0.5,
		outsideOfConfinesAction = {SpringFramework.OutsideOfConfinesOptions.DO_NOTHING, SpringFramework.OutsideOfConfinesOptions.MOVE_TO_REST_POSITION}, -- what to do when the spring'ed objects get too far, do nothing, break connection, force into position, etc.
		confinesToCheck = {min = true, absolute = true, max = true}, -- what should count as being out of confines, i.e. too close to each other, abs distance from rest position, too far from each other
		showDebug = false --whether to show debug visuals
	}
	
	local springConfigB = {
		length = wheelLength,
		primaryTarget = wheelPrimaryTarget, --sets it to consider the chassis the primary target
		stiffness = wheelStiffness,
		stiffnessMultiplier = {self.Mass * 0.3, self.wheelB.Mass},
		offsets = Vector(self.wheelOffsetB.X, self.wheelOffsetB.Y), --probably don't need the Y one at all since the spring length should handle this for you
		applyForcesAtOffset = wheelApplyForcesAtOffset,
		lockToSpringRotation = wheelLockToSpringRotation, --whether spring framework'd objects should be forced in line with the spring
		inheritsRotAngle = wheelInheritsRotAngle,
		rotAngleOffset = -math.pi*0.5,
		outsideOfConfinesAction = {SpringFramework.OutsideOfConfinesOptions.DO_NOTHING, SpringFramework.OutsideOfConfinesOptions.MOVE_TO_REST_POSITION}, -- what to do when the spring'ed objects get too far, do nothing, break connection, force into position, etc.
		confinesToCheck = {min = true, absolute = true, max = true}, -- what should count as being out of confines, i.e. too close to each other, abs distance from rest position, too far from each other
		showDebug = false --whether to show debug visuals
	}
	
	--local springConfigB = table.copy(springConfigA)
	--springConfigB.offsets = Vector(self.wheelOffsetB.X, 0)
	self.springA = SpringFramework.create(self, self.wheelA, springConfigA);
	self.springB = SpringFramework.create(self, self.wheelB, springConfigB);
end

function Update(self)
--- PRESS Z TO DESTROY THE VEHICLE
	if (UInputMan:KeyPressed(26)) then
		PresetMan:ReloadAllScripts();
		self:GibThis();
		ToGameActivity(ActivityMan:GetActivity()):ClearObjectivePoints();
	end
--- PRESS C TO RESET THE VEHICLE
	if UInputMan:KeyPressed(3) then
		self.RotAngle = 0;
		PresetMan:ReloadAllScripts();
		self:ReloadScripts();
	end
--- PRESS N TO MOVE THE VEHICLE SIDEWAYS, PRESS CTRL + N AND CTRL + SHIFT + N TO ROTATE THE VEHICLE
    if (UInputMan:KeyPressed(14)) then
        if (UInputMan.FlagCtrlState) then
            if (UInputMan.FlagShiftState) then
                self.RotAngle = self.RotAngle + math.pi/8;
            else
                self.RotAngle = self.RotAngle - math.pi/8;
            end
        else
            self.Pos.X = self.Pos.X + (self.HFlipped and -50 or 50);
        end
    end
    
--- PRESS M AND SHIFT M TO MOVE THE VEHICLE UP AND DOWN, PRESS ALT + SHIFT + M TO PIN THE VEHICLE IN PLACE
    if (UInputMan:KeyPressed(13)) then
        if (UInputMan.FlagAltState and UInputMan.FlagShiftState) then
            self.PinStrength = 10000 - self.PinStrength;
            return;
        end
        if (UInputMan.FlagShiftState) then
            self.Pos.Y = self.Pos.Y + 10;
        else
            self.Pos.Y = self.Pos.Y - 100;
        end
    end


	local offsetA = Vector(self.Pos.X, self.Pos.Y) + Vector(self.wheelOffsetA.X * self.FlipFactor, self.wheelOffsetA.Y):RadRotate(self.RotAngle)
	local offsetB = Vector(self.Pos.X, self.Pos.Y) + Vector(self.wheelOffsetB.X * self.FlipFactor, self.wheelOffsetB.Y):RadRotate(self.RotAngle)
	
	local groundContact = false
	
	if (UInputMan:KeyPressed(26)) and self:IsPlayerControlled() then
		self.Health = self.Health -26
	end
	
	if UInputMan:KeyPressed(3) and self:IsPlayerControlled() then
		self.Health = self.Health -51
	end
	
	if (UInputMan:KeyPressed(24)) and self:IsPlayerControlled() then
		self.Health = self.Health -6
	end
	
	local ctrl = self:GetController()
	local player = false
	if self:IsPlayerControlled() then
		player = true
	end
	
	local input = 0
	if ctrl:IsState(Controller.MOVE_LEFT) then
		input = -1
		if not self.HFlipped then
			self.HFlipped = true
		end
	elseif ctrl:IsState(Controller.MOVE_RIGHT) then
		input = 1
		if self.HFlipped then
			self.HFlipped = false
		end
	end
	local finalNormal = Vector(0, 0.01):RadRotate(self.RotAngle)
	
	-- Wheel Physics
	local offsets = {offsetA, offsetB}
	local springs = {self.springA, self.springB}
	for i, wheel in ipairs({self.wheelA, self.wheelB}) do
		if wheel and wheel.ID ~= rte.NoMOID then
			local spring = springs[i]
			local touching = false
			--wheel.Pos = offsets[i]
			--wheel.RotAngle = self.RotAngle
			SpringFramework.update(spring);
			
			local normal = Vector(0, 0.01):RadRotate(self.RotAngle)
			for j = 0, 2 do
				if wheel.HitWhatTerrMaterial ~= 0 then
					--PrimitiveMan:DrawCirclePrimitive(wheel.Pos, 5, 13);
					local maxi = 13
					for i = 0, maxi do
						local checkVec = Vector(wheel.IndividualRadius * (0.75 - 0.15 * j),0):RadRotate(math.pi * 2 / maxi * i + wheel.RotAngle)
						local checkOrigin = Vector(wheel.Pos.X, wheel.Pos.Y) + checkVec + Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.3
						local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
						
						if checkPix > 0 then
							--PrimitiveMan:DrawLinePrimitive(wheel.Pos + checkVec, wheel.Pos + checkVec, 13);
							if j == 0 then -- Stick to the ground
								wheel.Vel = wheel.Vel + Vector(checkVec.X, checkVec.Y):SetMagnitude(50 - self.Vel.Magnitude) * TimerMan.DeltaTimeSecs
								--wheel.Pos = wheel.Pos + checkVec:SetMagnitude(1)
							else
								wheel.Vel = wheel.Vel - Vector(checkVec.X, checkVec.Y):SetMagnitude(50 + self.Vel.Magnitude) * TimerMan.DeltaTimeSecs
								wheel.Pos = wheel.Pos - Vector(checkVec.X, checkVec.Y):SetMagnitude(1)
							end
							self.Vel = self.Vel - Vector(checkVec.X, checkVec.Y):SetMagnitude(30 + self.Vel.Magnitude) * TimerMan.DeltaTimeSecs / maxi
							wheel.AngularVel = (wheel.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 1)
							
							normal = (normal + checkVec) * 0.5
							touching = true
							groundContact = true
						--else
							--PrimitiveMan:DrawLinePrimitive(wheel.Pos + checkVec, wheel.Pos + checkVec, 5);
						end
					end
				end
			end
			finalNormal = (finalNormal + normal) * 0.5
			--PrimitiveMan:DrawLinePrimitive(wheel.Pos, wheel.Pos + Vector(normal.X, normal.Y):SetMagnitude(20), 5);
			
			if touching then
				self.wheelAirTime[i] = self.wheelAirTimeMax
			else
				self.wheelAirTime[i] = math.max(self.wheelAirTime[i] - TimerMan.DeltaTimeSecs * 1000, 0)
			end
			local v = 30 * TimerMan.DeltaTimeSecs * (self.wheelAirTime[i] / self.wheelAirTimeMax)
			
			-- Accelerate
			if input ~= 0 then
				local force = Vector(v * input, 0):RadRotate((Vector(normal.X,normal.Y):RadRotate(math.pi * 0.5)).AbsRadAngle)
				self.Vel = self.Vel + force
				wheel.Vel = wheel.Vel + force
			end
		
			if input ~= 0 then
				wheel.AngularVel = wheel.AngularVel + 100 * TimerMan.DeltaTimeSecs * input
			end
			
			local wheelDeviation = SceneMan:ShortestDistance(spring.targetPos[1], wheel.Pos, SceneMan.SceneWrapsX):RadRotate(-spring.rotAngle);
			wheel.Pos = spring.targetPos[1] + Vector(wheelDeviation.X, 0):RadRotate(spring.rotAngle);
		end
	end
	
	PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + (Vector(finalNormal.X,finalNormal.Y):RadRotate(math.pi * 0.5)):SetMagnitude(40), 5);
	
	-- Body move out of terrain
	local maxi = 9
	for i = 0, maxi do
		local fac = i / maxi
		
		local pointA = Vector(-self.IndividualRadius * 0.92, 0) + Vector(self.Vel.X, self.Vel.Y):RadRotate(-self.RotAngle) * rte.PxTravelledPerFrame
		local pointB = Vector(self.IndividualRadius * 0.92, 0) + Vector(self.Vel.X, self.Vel.Y):RadRotate(-self.RotAngle) * rte.PxTravelledPerFrame
		local pointOffset =  Vector(0, self.IndividualRadius * 0.65)
		local vec = pointA * fac + pointB * (1 - fac) + pointOffset * math.pow(math.sin(fac * math.pi), 0.5)
		vec = vec + Vector(0, 3)
		local point = Vector(vec.X, vec.Y):RadRotate(self.RotAngle) + self.Pos
		PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
		
		local checkPix = SceneMan:GetTerrMatter(point.X, point.Y)
		if checkPix > 0 then
			PrimitiveMan:DrawLinePrimitive(point, point, 13);
			self.Vel = self.Vel - (Vector(vec.X, vec.Y):RadRotate(self.RotAngle)):SetMagnitude(15 + self.Vel.Magnitude) * TimerMan.DeltaTimeSecs
		else
			PrimitiveMan:DrawLinePrimitive(point, point, 5);
		end
		--PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(self.IndividualRadius, 0), self.Pos + Vector(-self.IndividualRadius, 0), 13);
	end
	
	-- Balance
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.RotAngle - (Vector(finalNormal.X,finalNormal.Y):RadRotate(math.pi * 0.5)).AbsRadAngle;
	local result;
	local ret = 0
	
	local range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	--self.RotAngle = 0
	--self.AngularVel = 0
	
	--self.RotAngle = (self.RotAngle - result * TimerMan.DeltaTimeSecs * 6)
	--self.AngularVel = (self.AngularVel - result * 2.0 * TimerMan.DeltaTimeSecs * 7)
	--self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 10)-- - self.Vel.X * TimerMan.DeltaTimeSecs * 6
	
	local a = self.Vel.Magnitude * 0.3
	if groundContact then
		self.RotAngle = (self.RotAngle - result * TimerMan.DeltaTimeSecs * (2 + a))
		self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * (4 + a))-- - self.Vel.X * TimerMan.DeltaTimeSecs * 6
	end
	self.AngularVel = (self.AngularVel - result * 1.0 * TimerMan.DeltaTimeSecs * (13 + a))
	
	--PrimitiveMan:DrawCirclePrimitive(offsetA, 1, 5);
	--PrimitiveMan:DrawCirclePrimitive(offsetB, 1, 5);
end
--[[
MovableObject:
    Prop HitWhatMOID, r/o
    Prop HitWhatTerrMaterial, r/o
    Prop HitWhatParticleUniqueID, r/o
]]
function Destroy(self)
	if self.wheelA.ID ~= rte.NoMOID then
		--self.wheelA.RestThreshold = 10
		--self.wheelA.ToSettle = true
		self.wheelA:GibThis()
	end
	if self.wheelB.ID ~= rte.NoMOID then
		--self.wheelB.RestThreshold = 10
		--self.wheelB.ToSettle = true
		self.wheelB:GibThis()
	end
end