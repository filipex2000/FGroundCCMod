

function Create(self)
	self.parentSet = false;
	
	self.soundFire = CreateSoundContainer("Bow Fire", "FGround.rte");
	self.soundDraw = CreateSoundContainer("Bow Draw", "FGround.rte");
	self.soundDrop = CreateSoundContainer("Bow Arrow Bounce", "FGround.rte");
	
	
	self.pastReloadTimer = Timer()
	
	self.chargeTimer = Timer()
	self.chargeTime = 1000
	self.lastChargeFactor = 0
	self.charging = false
	
	self.arrowVelocityMax = 65
	self.arrowVelocityMin = 15
	
	self.shoot = false
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	
	self.lastAge = self.Age + 0
	
	self.laserTimer = Timer();
	self.guideTable = {};

	self.projectileVel = 30;
	if self.Magazine ~= null and self.Magazine.RoundCount ~= 0 then
		self.projectileVel = self.Magazine.NextRound.FireVel;
	end

	self.maxTrajectoryPars = 120;
end

function Update(self)
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	local sharpaiming = false
	local stanceOffset = Vector()
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		--
		self.chargeTimer:Reset()
		self.charging = false
		self.shoot = false
		self.lastChargeFactor = 0
	end
	self.lastAge = self.Age + 0
	
	if self.parent then
		sharpaiming = self.parent:GetController():IsState(Controller.AIM_SHARP) == true and self.parent:GetController():IsState(Controller.MOVE_LEFT) == false and self.parent:GetController():IsState(Controller.MOVE_RIGHT) == false
		
		if self:DoneReloading() then
			--
			self.chargeTimer:Reset()
			self.charging = false
			self.shoot = false
			
			self.pastReloadTimer:Reset()
			
			self.JointOffset = self.originalJointOffset
			
			self.Frame = 0
		elseif self:IsReloading() then
			--
			self.chargeTimer:Reset()
			self.charging = false
			self.shoot = false
			
			self.pastReloadTimer:Reset()
			
			--self.JointOffset = self.originalJointOffset
			self.JointOffset = (self.JointOffset + self.originalJointOffset * TimerMan.DeltaTimeSecs * 15) / (1 + TimerMan.DeltaTimeSecs * 15)
			
			self.Frame = 0
		else
			local active = self:IsActivated()
			self:Deactivate()
			
			local chargeFactor = math.min(self.chargeTimer.ElapsedSimTimeMS / self.chargeTime, 1)
			if self.Magazine then
				self.Magazine.JointOffset.X = chargeFactor * 8 - 5
				
				--self.JointOffset = Vector(self.Magazine.JointOffset.X * -0.5 - 6, self.Magazine.JointOffset.Y)
				
				self.JointOffset = (self.JointOffset + Vector(self.Magazine.JointOffset.X * -0.5 - 6, self.Magazine.JointOffset.Y) * TimerMan.DeltaTimeSecs * 15) / (1 + TimerMan.DeltaTimeSecs * 15)
				
				--self.StanceOffset = Vector((1 - chargeFactor) * 2 + 1, self.originalStanceOffset.Y)
				--self.StanceOffset = self.originalStanceOffset + Vector(chargeFactor * -5, 0) - Vector(-self.Magazine.JointOffset.X - 8, self.Magazine.JointOffset.Y)
				
				stanceOffset = Vector((1 - chargeFactor) * 3 + 2, self.originalStanceOffset.Y)
				
				self.Frame = math.floor(chargeFactor * 2 + 0.5)
				
				--self.lastChargeFactor = chargeFactor
			else
				self.JointOffset = self.originalJointOffset
				self.Frame = 0
			end
			
			if active and self.Magazine then
				if not self.charging then
					self.charging = true
					self.chargeTimer:Reset()
					self.soundDraw:Play(self.Pos)
				end
			else
				if self.charging then
					self.charging = false
					self.shoot = true
					self.lastChargeFactor = chargeFactor
				end
				self.chargeTimer:Reset()
			end
			
			self.projectileVel = self.arrowVelocityMin + (self.arrowVelocityMax - self.arrowVelocityMin) * chargeFactor
			
			if self.shoot then
				self:Activate()
			end
			
			if self.pastReloadTimer:IsPastSimMS(60) then
				if self.FiredFrame then
					
					--
					local arrow = CreateMOSRotating("Bow Arrow");
					arrow.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle + RangeRand(-0.1,0.1));
					arrow.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * (self.arrowVelocityMin + (self.arrowVelocityMax - self.arrowVelocityMin) * self.lastChargeFactor) * RangeRand(0.95, 1.05);
					arrow.RotAngle = self.RotAngle + (math.pi * (-self.FlipFactor + 1) / 2)
					
					arrow.Team = self.parent.Team;
					arrow.IgnoresTeamHits = true;
					
					MovableMan:AddParticle(arrow);
					
					self.lastChargeFactor = 0
					
					self.soundFire:Play(self.Pos)
					
					self.soundDraw:Stop()
					
					self.shoot = false
					self.chargeTimer:Reset()
				end
			elseif self.Magazine and self.Magazine.RoundCount < 1 then
				self.Magazine.RoundCount = 1
			end
		end
		

	end
	local stringMode = 0
	
	if self.Magazine then
		if self.Magazine.RoundCount < 1 then
			self.Magazine.Scale = 0
		else
			self.Magazine.Scale = 1
			
			stringMode = 1
		end
	end
	
	local stringStartPosA = self.Pos + Vector((-3 - self.Frame) * self.FlipFactor, -10):RadRotate(self.RotAngle)
	local stringStartPosB = self.Pos + Vector((-3 - self.Frame) * self.FlipFactor, 10):RadRotate(self.RotAngle)
	local stringMiddlePos = self.Pos + Vector((-3 - self.Frame) * self.FlipFactor, 0):RadRotate(self.RotAngle)
	local stringColor = 168
	
	if stringMode == 1 then
		local arrowPos = self.Magazine.Pos + Vector(-6 * self.Magazine.FlipFactor, 0):RadRotate(self.Magazine.RotAngle)
		arrowPos = SceneMan:ShortestDistance(stringMiddlePos,arrowPos,SceneMan.SceneWrapsX)
		arrowPos:RadRotate(-self.Magazine.RotAngle)
		arrowPos.X = math.min(arrowPos.X, 0)
		arrowPos:RadRotate(self.Magazine.RotAngle)
		arrowPos = arrowPos + stringMiddlePos
		
		PrimitiveMan:DrawLinePrimitive(stringStartPosA, stringStartPosA + SceneMan:ShortestDistance(stringStartPosA,arrowPos,SceneMan.SceneWrapsX), stringColor)
		PrimitiveMan:DrawLinePrimitive(stringStartPosB, stringStartPosB + SceneMan:ShortestDistance(stringStartPosB,arrowPos,SceneMan.SceneWrapsX), stringColor)
	else
		PrimitiveMan:DrawLinePrimitive(stringStartPosA, stringStartPosA + SceneMan:ShortestDistance(stringStartPosA,stringStartPosB,SceneMan.SceneWrapsX), stringColor)
	end
	
	if self:IsReloading() or not self.Magazine then
		self.SharpStanceOffset = Vector(10,4)
		self.StanceOffset = Vector(10,4)
	else
		self.SharpStanceOffset = stanceOffset + Vector(1, -2)
		self.StanceOffset = stanceOffset
	end
	
	
	--
	local actor = self.parent
	if self.charging and not self:IsReloading() and MovableMan:IsActor(actor) and ToActor(actor):IsPlayerControlled() and ToActor(actor):GetController():IsState(Controller.AIM_SHARP) then
		if self.laserTimer:IsPastSimMS(25) then
			self.laserTimer:Reset();

			self.guideTable = {};
			self.guideTable[1] = Vector(self.MuzzlePos.X,self.MuzzlePos.Y);

			local actor = ToActor(actor);
			local guideParPos = self.MuzzlePos;
			local guideParVel = Vector(self.projectileVel * self.FlipFactor,0):RadRotate(self.RotAngle)
			--local guideParVel = Vector(self.projectileVel,0):RadRotate(actor:GetAimAngle(true));
			for i = 1, self.maxTrajectoryPars do
				guideParVel = guideParVel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs;
				guideParPos = guideParPos + guideParVel * rte.PxTravelledPerFrame;
				-- No need to wrap the seam manually, primitives can handle out-of-scene coordinates correctly
				--if SceneMan.SceneWrapsX == true then
				--	if guideParPos.X > SceneMan.SceneWidth then
				--		guideParPos = Vector(guideParPos.X - SceneMan.SceneWidth,guideParPos.Y);
				--	elseif guideParPos.X < 0 then
				--		guideParPos = Vector(SceneMan.SceneWidth + guideParPos.X,guideParPos.Y);
				--	end
				--end
				if SceneMan:GetTerrMatter(guideParPos.X,guideParPos.Y) == 0 then
					self.guideTable[#self.guideTable+1] = guideParPos;
				else
					local hitPos = Vector(self.guideTable[#self.guideTable].X,self.guideTable[#self.guideTable].Y);
					SceneMan:CastStrengthRay(self.guideTable[#self.guideTable],SceneMan:ShortestDistance(self.guideTable[#self.guideTable],guideParPos,false),0,hitPos,3,0,false);
					self.guideTable[#self.guideTable+1] = hitPos;
					break;
				end
			end
		end
	else
		self.guideTable = {};
	end

	if #self.guideTable > 1 then
		--[[
		for i = 1, #self.guideTable-1 do
			PrimitiveMan:DrawLinePrimitive(self.guideTable[i],self.guideTable[i+1],120);
		end]]
		for i = 1, #self.guideTable do
			PrimitiveMan:DrawLinePrimitive(self.guideTable[i],self.guideTable[i],120);
		end
		--PrimitiveMan:DrawCirclePrimitive(self.guideTable[#self.guideTable],4,120);
	end
end 

function OnCollideWithTerrain(self, terrainID) -- delet
	if self.Magazine then
		self.Magazine.JointStrength = -5
		self.soundDrop:Play(self.Pos)
	end
end