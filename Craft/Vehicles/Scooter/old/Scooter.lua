
package.path = package.path..";FGround.rte/?.lua";
require("SpringFramework/SpringFramework")

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
	
	--In Create
	local wheelLength = {2, 5, 30}
	local wheelPrimaryTarget = 1
	local wheelStiffness = 60
	local wheelApplyForcesAtOffset = true
	local wheelLockToSpringRotation = true
	local wheelInheritsRotAngle = 1
	
	local springConfigA = {
		length = wheelLength,
		primaryTarget = wheelPrimaryTarget, --sets it to consider the chassis the primary target
		stiffness = wheelStiffness,
		stiffnessMultiplier = {self.Mass * 0.1, self.wheelA.Mass * 0.6},
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
		stiffnessMultiplier = {self.Mass * 0.1, self.wheelB.Mass * 0.6},
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
	local offsetA = Vector(self.Pos.X, self.Pos.Y) + Vector(self.wheelOffsetA.X * self.FlipFactor, self.wheelOffsetA.Y):RadRotate(self.RotAngle)
	local offsetB = Vector(self.Pos.X, self.Pos.Y) + Vector(self.wheelOffsetB.X * self.FlipFactor, self.wheelOffsetB.Y):RadRotate(self.RotAngle)
	
	if (UInputMan:KeyPressed(26)) and self:IsPlayerControlled() then
		self.Health = self.Health -26
	end
	
	if UInputMan:KeyPressed(3) and self:IsPlayerControlled() then
		self.Health = self.Health -51
	end
	
	if (UInputMan:KeyPressed(24)) and self:IsPlayerControlled() then
		self.Health = self.Health -6
	end
	--self.RotAngle = 0
	--self.AngularVel = 0
	
	local offsets = {offsetA, offsetB}
	local springs = {self.springA, self.springB}
	for i, wheel in ipairs({self.wheelA, self.wheelB}) do
		if wheel and wheel.ID ~= rte.NoMOID then
			local spring = springs[i]
			--wheel.Pos = offsets[i]
			--wheel.RotAngle = self.RotAngle
			SpringFramework.update(spring);
			
			-- Wheel move out of terrain
			if wheel.HitWhatTerrMaterial ~= 0 then
				PrimitiveMan:DrawCirclePrimitive(wheel.Pos, 5, 13);
				local maxi = 7
				for i = 0, maxi do
					local checkVec = Vector(wheel.Radius * 0.75,0):RadRotate(math.pi * 2 / maxi * i + wheel.RotAngle)
					local checkOrigin = Vector(wheel.Pos.X, wheel.Pos.Y) + checkVec
					local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
					
					if checkPix > 0 then
						PrimitiveMan:DrawLinePrimitive(wheel.Pos + checkVec, wheel.Pos + checkVec, 13);
						wheel.Pos = wheel.Pos - checkVec:SetMagnitude(1)
						
						--wheel.Vel = wheel.Vel / (1 + TimerMan.DeltaTimeSecs * 12.0) -- Air Friction
					else
						PrimitiveMan:DrawLinePrimitive(wheel.Pos + checkVec, wheel.Pos + checkVec, 5);
					end
				end
			end
			
			local wheelDeviation = SceneMan:ShortestDistance(spring.targetPos[1], wheel.Pos, SceneMan.SceneWrapsX):RadRotate(-spring.rotAngle);
			wheel.Pos = spring.targetPos[1] + Vector(wheelDeviation.X, 0):RadRotate(spring.rotAngle);
		end
	end
	-- Body move out of terrain
	local maxi = 9
	for i = 0, maxi do
		local fac = i / maxi
		
		local pointA = Vector(-self.Radius * 0.92, 0)
		local pointB = Vector(self.Radius * 0.92, 0)
		local pointOffset =  Vector(0, self.Radius * 0.65)
		local point = pointA * fac + pointB * (1 - fac) + pointOffset * math.pow(math.sin(fac * math.pi), 1.0)
		point = point + Vector(0, 3)
		point = point:RadRotate(self.RotAngle) + self.Pos
		PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
		--PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(self.Radius, 0), self.Pos + Vector(-self.Radius, 0), 13);
	end
	--[[
	local wheelDeviation = SceneMan:ShortestDistance(self.springA.targetPos[1], self.wheelA.Pos, SceneMan.SceneWrapsX):RadRotate(-self.springA.rotAngle);
	self.wheelA.Pos = self.springA.targetPos[1] + Vector(wheelDeviation.X, 0):RadRotate(self.springA.rotAngle);
	
	wheelDeviation = SceneMan:ShortestDistance(self.springB.targetPos[1], self.wheelB.Pos, SceneMan.SceneWrapsX):RadRotate(-self.springB.rotAngle);
	self.wheelB.Pos = self.springB.targetPos[1] + Vector(wheelDeviation.X, 0):RadRotate(self.springB.rotAngle);
	]]
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
	
	local v = 60 * TimerMan.DeltaTimeSecs
	if ctrl:IsState(Controller.MOVE_UP) then
		self.Vel = self.Vel + Vector(0, -v)
	end
	if input ~= 0 then
		self.Vel = self.Vel + Vector(v * input, 0)-- + --Vector(v, 0)
	end
	
	PrimitiveMan:DrawCirclePrimitive(offsetA, 1, 5);
	PrimitiveMan:DrawCirclePrimitive(offsetB, 1, 5);
end
--[[
MovableObject:
    Prop HitWhatMOID, r/o
    Prop HitWhatTerrMaterial, r/o
    Prop HitWhatParticleUniqueID, r/o
]]
function Destroy(self)
	if self.wheelA.ID ~= rte.NoMOID then
		self.wheelA.RestThreshold = 10
		self.wheelA.ToSettle = true
	end
	if self.wheelB.ID ~= rte.NoMOID then
		self.wheelB.RestThreshold = 10
		self.wheelB.ToSettle = true
	end
end