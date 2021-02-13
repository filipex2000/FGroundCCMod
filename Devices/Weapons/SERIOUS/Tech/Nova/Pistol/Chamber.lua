

function Create(self)
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
		self.ammoCounterMax = self.ammoCounter;
	else
		self.ammoCounter = 0;
		self.ammoCounterMax = 1;
		print("ERROR NOVA PISTOL MAGAZINE BULLSHITTERY!")
	end
	
	self.animFrame = 0
	self.animFrameMax = self.FrameCount - 1
	
	self.reloading = false;
	self.chamber = false;
	self.chamberAnim = false;
	self.chamberSound = false;
	self.chamberDelay = 500
	self.chamberTime = 200
	self.chamberTimer = Timer()
	
	self.animReload = 0;

	self.recoil = 0; -- custom recoil by filipex2000
	self.recoilDetail = 0;
	
	self.recoilContr = 0; -- controller
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false;
	
	
	self.reloadChamberSound = CreateSoundContainer("Chamber Nova Pistol", "FGround.rte");
	
	self.laserOnSound = CreateSoundContainer("Laser On Nova Pistol", "FGround.rte");
	self.laserOffSound = CreateSoundContainer("Laser Off Nova Pistol", "FGround.rte");
	
	self.fireMode = 0;
	self.tacticalLaser = false;
	self.tacticalLaserTimer = Timer();
	self.tacticalLaserDelay = 70;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		if self:IsReloading() then
			actor:GetController():SetState(Controller.AIM_SHARP,false);
		end
		if actor:IsPlayerControlled() then
			if not self.chamber and actor:GetController():IsState(Controller.AIM_SHARP) == true and actor:GetController():IsState(Controller.MOVE_LEFT) == false and actor:GetController():IsState(Controller.MOVE_RIGHT) == false then
				if self.fireMode == 1 then
					self.fireMode = 0;
					self.laserOnSound:Play(self.Pos)
				end
				self.RateOfFire = 300 -- Perecision Mode
				
				-- Laser
				self.tacticalLaser = true;
			else
				if self.fireMode == 0 then
					self.fireMode = 1;
					self.laserOffSound:Play(self.Pos)
				end
				self.RateOfFire = 500 -- Cowboy Mode
				self.tacticalLaser = false;
			end
		else
			self.fireMode = 0;
			self.RateOfFire = 250
			self.tacticalLaser = false;
		end
	else
		self.fireMode = 0;
		self.RateOfFire = 250
		self.tacticalLaser = false;
		
		self.chamberTimer:Reset()
	end
	
	local animFrameTarget = 0
	local animReloadTarget = 0
	
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
	end
	
	if self.chamber then
		self:Deactivate()
		if self.chamberTimer:IsPastSimMS(self.chamberDelay) then
			self.SupportOffset = self.JointOffset + Vector(-1, -3)
		end
	else
		self.SupportOffset = self.JointOffset + Vector(-1, 0.5)
	end
	
	if self.FiredFrame then
		self.animFrame = self.animFrameMax;
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		if actor and self.fireMode == 1 then
			actor.AngularVel = actor.AngularVel + 5 * self.RotAngle
		end
		
		self.recoil = self.recoil + RangeRand(0.7,1.0)-- * 0.5
		self.recoilDetail = self.recoil + RangeRand(0.7,1.0)-- * 0.5
		--self.recoil = self.recoil + 1
		--self.recoilDetail = self.recoil + 1
		
		local poofs = 5;
		for i = 1, poofs do
			local poof = CreateMOSParticle("Tracer White Ball 1");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle + RangeRand(-0.1,0.1)) * 50 * RangeRand(0.75, 1.25) * (1.0 - (i/poofs));
			poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.6;
			poof.GlobalAccScalar = RangeRand(-1, 1) * 0.4; -- Go up and down
			MovableMan:AddParticle(poof);
		end
		--(self.Vel * rte.PxTravelledPerFrame) * (1.0 - (i/poofs))
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(1500) then
		if self.smokeDelayTimer:IsPastSimMS(120) then
			local poof = math.random(1,2) < 2 and CreateMOSParticle("Small Smoke Ball 1") or CreateMOSParticle("Tiny Smoke Ball 1");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.6;
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.7; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
		end
	end
	
	-- Relaod
	if self:IsReloading() then
		if not self.reloading then
			self.reloading = true
			if self.ammoCounter < 1 then
				self.chamber = true
			end
		end
		if self.chamber then
			animFrameTarget = self.animFrameMax - 1;
		end
		animReloadTarget = -1
	else
		if self.reloading then
			self.reloading = false
			if self.chamber and self.ammoCounter > 0 then
				--play chamber
				self.chamberAnim = true;
				self.chamberSound = true;
				self.chamberTimer:Reset()
			end
		end
		
		if self.chamber then
			if self.chamberAnim then
				if self.chamberTimer:IsPastSimMS(self.chamberDelay) then
					if self.chamberSound then
						self.reloadChamberSound:Play(self.Pos)
						self.chamberSound = false;
					end
					if self.chamberTimer:IsPastSimMS(self.chamberDelay + self.chamberTime) then
						animReloadTarget = 0
						self.chamberAnim = false
					else
						animReloadTarget = 1
						animFrameTarget = self.animFrameMax - 1;
					end
				end
			end
			if self.chamberTimer:IsPastSimMS(self.chamberDelay + self.chamberTime) and animReloadTarget == 0 and self.animReload < 0.3 then
				self.chamber = false
			end
		end
	end
	
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "ammo = ".. self.ammoCounter, true, 0);
	
	self.Frame = math.min(math.floor(self.animFrame + 0.55), self.FrameCount - 1)
	self.animFrame = (self.animFrame + animFrameTarget * TimerMan.DeltaTimeSecs * 35) / (1 + TimerMan.DeltaTimeSecs * 35);
	
	-- Recoil and Rotation
	local r1 = self.FlipFactor * -math.sin(self.recoil * math.pi * 2) * math.min(self.recoil, 1.0) * 2 -- controller targets
	local r2 = self.FlipFactor * -math.sin(self.recoilDetail * math.pi * 2) * math.min(self.recoilDetail, 1.0) * 0.1
	
	local a = 7;
	
	self.animReload = (self.animReload + animReloadTarget * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	
	self.recoilContr = (self.recoilContr + (r1 + r2) * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
	
	local total = (self.recoilContr + self.animReload * math.pi * 0.1 * self.FlipFactor)
	self.RotAngle = self.RotAngle + total;
	
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-total);
	
	self.recoil = math.max(self.recoil - TimerMan.DeltaTimeSecs * 15, 0)
	self.recoilDetail = math.max(self.recoilDetail - TimerMan.DeltaTimeSecs * 3, 0)
	
	-- Tactical Laser!!
	if self.tacticalLaser and actor then
		local offset = Vector(5 * self.FlipFactor, -0.5):RadRotate(self.RotAngle)
		local point = self.Pos + offset
		
		--PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
		PrimitiveMan:DrawLinePrimitive(point, point, 13);
		
		if self.tacticalLaserTimer:IsPastSimMS(self.tacticalLaserDelay) then
			local glow = CreateMOPixel("Glow Laser Particle");
			glow.Pos = point;
			MovableMan:AddParticle(glow);
			
			local rayVec = Vector(700 * self.FlipFactor, 0):RadRotate(self.RotAngle)
			--[[
			local terrCheck = SceneMan:CastStrengthRay(self.Pos, rayVec, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
			if terrCheck == true then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				PrimitiveMan:DrawLinePrimitive(point, rayHitPos, 13);
			else
				PrimitiveMan:DrawLinePrimitive(point, point+rayVec, 13);
			end]]
			local endPos = point + rayVec; -- This value is going to be overriden by function below, this is the end of the ray
			self.ray = SceneMan:CastObstacleRay(point, rayVec, Vector(0, 0), endPos, actor.ID, self.Team, 0, 1) -- Do the hitscan stuff, raycast
			local vec = SceneMan:ShortestDistance(point,endPos,SceneMan.SceneWrapsX);
			
			--PrimitiveMan:DrawLinePrimitive(point, point + vec, 13);
			if self.ray > 0 then
				local glow = CreateMOPixel("Glow Laser Particle");
				glow.Pos = endPos;
				MovableMan:AddParticle(glow);
				
				glow = CreateMOPixel("Glow Laser 1");
				glow.Pos = endPos;
				MovableMan:AddParticle(glow);
				PrimitiveMan:DrawLinePrimitive(endPos, endPos, 13);
			end
			
			local maxi = vec.Magnitude / GetPPM() * 1.5
			for i = 1, maxi do
				if math.random(1,3) >= 2 then
					local glow = CreateMOPixel("Glow Laser Beam "..math.random(1,4));
					glow.Pos = self.Pos + vec * math.max(math.min((1 / maxi * i) + RangeRand(-1.0,1.0) * 0.03, 1), 0);
					glow.EffectRotAngle = self.RotAngle;
					MovableMan:AddParticle(glow);
				end
			end
			
			self.tacticalLaserTimer:Reset()
		end
	end
end 