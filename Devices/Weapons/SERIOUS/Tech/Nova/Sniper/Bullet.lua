function Create(self)
	self.trailM = 0; -- DONT TOUCH
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0; -- DONT TOUCH
	
	self.trailGProgress = 0; -- DONT TOUCH
	self.trailGLoss = -1.8; -- Trail lifetime offset (lower number, stays 100% longer)
	
	self.ParticleName = "Nova Dot"; -- Trail's particle
	
	self.damageWounds = 6
	
	self.entrySound = CreateSoundContainer("Bullet Entry Nova Sniper", "FGround.rte");
	self.exitSound = CreateSoundContainer("Bullet Exit Nova Sniper", "FGround.rte");
	
	self.stateSound = 0
end

function Update(self)
	self.Vel = self.Vel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * self.GlobalAccScalar -- Gravity
	
	local travelStart = Vector(self.Pos.X, self.Pos.Y)
	local travelVec = Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame
	local travelPos = travelStart + travelVec
	local terrCheck = SceneMan:CastStrengthRay(travelStart, travelVec, 30, Vector(), 5, 0, SceneMan.SceneWrapsX)--SceneMan:CastStrengthSumRay(travelStart, travelPos, 2, 0); -- Raycast
	
	if terrCheck then
		local rayHitPos = SceneMan:GetLastRayHitPos()
		travelPos = Vector(rayHitPos.X, rayHitPos.Y)
		
		self.entrySound:Play(rayHitPos)
		self.exitSound:Play(rayHitPos)
		
		-- TO DO, FIND BETTER ONE
		local effect = CreateMOSRotating("Nova Bullet Effect");
		effect.Pos = rayHitPos - Vector(travelVec.X, travelVec.Y):SetMagnitude(8);
		MovableMan:AddParticle(effect);
		effect:GibThis();
		
		self.ToDelete = true
	end
	self.Pos = Vector(travelPos.X, travelPos.Y)
	
	local hit = false
	
	local travel = SceneMan:ShortestDistance(travelStart,travelPos,SceneMan.SceneWrapsX)
	local maxi = travel.Magnitude / GetPPM() * 5
	for i = 0, maxi do
		if self.damageWounds > 0 then
			local checkOrigin = travelStart + travel / maxi * i
			local checkPix = SceneMan:GetMOIDPixel(checkOrigin.X, checkOrigin.Y)
			if checkPix and checkPix ~= rte.NoMOID and MovableMan:GetMOFromID(checkPix).Team ~= self.Team then
				local MO = MovableMan:GetMOFromID(checkPix)
				if IsMOSRotating(MO) then
					MO = ToMOSRotating(MO)
					
					self.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1,1) * 0.1) * 0.8
					self.Lifetime = self.Lifetime + math.random(13, 26)
					
					local woundName = MO:GetEntryWoundPresetName()
					local woundNameExit = MO:GetExitWoundPresetName()
					local woundOffset = (checkOrigin - MO.Pos):RadRotate(MO.RotAngle * -1.0)
					if woundName then
						local wound = CreateAEmitter(woundName)
						if wound then
							wound.RotAngle = self.Vel.AbsRadAngle
							wound.RotTarget = self.Vel.AbsRadAngle
							wound.InheritsRotAngle = false
							
							MO:AddWound(wound, woundOffset, true)
							self.damageWounds = self.damageWounds - 1
							hit = true
						end
					end
					local effect = CreateMOSParticle("Tracer White Ball 1");
					effect.Pos = checkOrigin
					effect.Lifetime = effect.Lifetime * 0.5
					effect.GlobalAccScalar = 0
					MovableMan:AddParticle(effect);
				end
				--PrimitiveMan:DrawCirclePrimitive(checkOrigin, 1, 13);
			end
		end
	end
	
	if self.stateSound == 0 and hit then
		self.entrySound:Play(self.Pos)
		self.stateSound = 1
	elseif self.stateSound == 1 and not hit then
		self.exitSound:Play(self.Pos)
		self.stateSound = 0
	end
	
	
	-- Epic smoke trail TM by filipex2000, 2020
	local smoke
	local offset = SceneMan:ShortestDistance(travelStart, travelPos, SceneMan.SceneWrapsX)--(travelPos - travelStart)
	local trailLength = math.floor((offset.Magnitude+0.5) * 0.5)
	for i = 1, trailLength do
		if RangeRand(0,1) < (1 - self.trailGLoss) then
			smoke = CreateMOPixel(self.ParticleName);
			if smoke then
				
				local a = 10;
				local b = 5;
				self.trailM = (self.trailM + self.trailMTarget * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
				self.trailMProgress = self.trailMProgress + TimerMan.DeltaTimeSecs * b;
				if self.trailMProgress > 1 then
					self.trailMTarget = RangeRand(-1,1);
					self.trailMProgress = self.trailMProgress - 1;
				end
				
				smoke.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
				smoke.Vel = self.Vel * self.trailGProgress * 0.5 + Vector(0, self.trailM * 10 * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.Vel.X, self.Vel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.5, 1.5) * (1.0 + self.trailGProgress) * 0.1;
				smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.1; -- Go up and down
				MovableMan:AddParticle(smoke);
				
				local c = 1;
				self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
				self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.25, 1.0);
			end
		end
	end
	
end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
  self.ToDelete = true;
end