

function Create(self)
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
		self.ammoCounterMax = self.ammoCounter;
	else
		self.ammoCounter = 0;
		self.ammoCounterMax = 1;
		print("ERROR AUTO RIFLE MAGAZINE BULLSHITTERY!")
	end
	
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
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		if self:IsReloading() then
			actor:GetController():SetState(Controller.AIM_SHARP,false);
		end
	else
		self.chamberTimer:Reset()
	end
	local animReloadTarget = 0
	
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
	end
	
	if self.chamber then
		self:Deactivate()
	end
	
	if self.FiredFrame then
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		if actor and self.fireMode == 1 then
			actor.AngularVel = actor.AngularVel + 5 * self.RotAngle
		end
		
		self.recoil = self.recoil + RangeRand(0.7,1.0)-- * 0.5
		self.recoilDetail = self.recoil + RangeRand(0.7,1.0)-- * 0.5
		--self.recoil = self.recoil + 1
		--self.recoilDetail = self.recoil + 1
	end
	
	-- Relaod
	if self:IsReloading() then
		if not self.reloading then
			self.reloading = true
			if self.ammoCounter < 1 then
				self.chamber = true
			end
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
						AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Tech/Rust/AutoRifle/Sounds/Chamber.wav", self.Pos);
						self.chamberSound = false;
					end
					if self.chamberTimer:IsPastSimMS(self.chamberDelay + self.chamberTime) then
						animReloadTarget = 0
						self.chamberAnim = false
					else
						animReloadTarget = 1
					end
				end
			end
			if self.chamberTimer:IsPastSimMS(self.chamberDelay + self.chamberTime) and animReloadTarget == 0 and self.animReload < 0.3 then
				self.chamber = false
			end
		end
	end
	
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "ammo = ".. self.ammoCounter, true, 0);
	
	-- Recoil and Rotation
	local r1 = self.FlipFactor * -math.sin(self.recoil * math.pi * 2) * math.min(self.recoil, 1.0) * 0.25 -- controller targets
	local r2 = self.FlipFactor * -math.sin(self.recoilDetail * math.pi * 2) * math.min(self.recoilDetail, 1.0) * 0.025
	
	local a = 4;
	
	self.animReload = (self.animReload + animReloadTarget * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	
	self.recoilContr = (self.recoilContr + (r1 + r2) * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
	
	local total = (self.recoilContr + self.animReload * math.pi * 0.1 * self.FlipFactor)
	self.RotAngle = self.RotAngle + total;
	-- + self.recoilContr * 15
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-total);
	self.Pos = self.Pos + Vector(self.recoilContr * -5, 0):RadRotate(self.RotAngle);
	
	self.recoil = math.max(self.recoil - TimerMan.DeltaTimeSecs * 15, 0)
	self.recoilDetail = math.max(self.recoilDetail - TimerMan.DeltaTimeSecs * 3, 0)
	
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
end 