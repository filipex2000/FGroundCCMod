

function Create(self)
	--yes
	self.pump = 0;
	self.pumpTarget = 0;
	self.pumpState = 0;
	
	self.pressureMax = 200
	self.pressure = self.pressureMax
	
	self.tick = true;
	
	self.originalRateOfFire = self.RateOfFire;
	
	self.burstSound = nil;
	self.playBurstSound = true;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
	end
	
	if self.pump > 0 or self.pressure < 10 then
		self:Deactivate();
	end
	
	if self.pump > 0.4 then
		self.SupportOffset = Vector(2, self.SupportOffset.Y)
	else
		self.SupportOffset = Vector(5, self.SupportOffset.Y)
	end
	
	
	if self.FiredFrame then
		self.pressure = math.floor(self.pressure * 0.975);
		
		for i = 1, 2 do
			local water = CreateMOPixel("Water Gun Particle "..math.random(1,3));
			water.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle + RangeRand(-0.1,0.1));
			water.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * 40 * RangeRand(0.75, 1.25) * (0.5 + (self.pressure / self.pressureMax)) / 1.5;
			water.Lifetime = water.Lifetime * RangeRand(0.6, 1.6) * 0.6;
			if actor then
				water.Team = actor.Team;
				water.IgnoresTeamHits = true;
			end
			MovableMan:AddParticle(water);
		end
	end
	
	if self:IsReloading() then
		if self.pumpState == 0 then
			self.pumpState = 1
			self.pumpTarget = 1;
			
			self.pressure = math.min(math.floor(self.pressure + self.pressureMax / 7), self.pressureMax)
		end
	end
	
	self.RateOfFire = self.originalRateOfFire * (0.5 + (self.pressure / self.pressureMax)) / 1.5
	
	if self:IsActivated() then
		if self.tick then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/WaterGun/Sounds/Tick.wav", self.Pos);
			self.tick = false
		end
		if self.playBurstSound and self.burstSound == nil then
			self.burstSound = AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/WaterGun/Sounds/Burst.wav", self.Pos);
			self.playBurstSound = false;
		end
		if self.burstSound then
			AudioMan:SetSoundPitch(self.burstSound, (0.6 + (self.pressure / self.pressureMax)) / 1.7 + 0.15)
			AudioMan:SetSoundPosition(self.burstSound, self.Pos)
		end
	else
		if self.burstSound then
			self.burstSound:Stop()
			self.burstSound = nil;
		end
		self.tick = true
		self.playBurstSound = true
	end
	
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "pressure = ".. self.pressure, true, 0);
	
	if self.pumpState == 1 and math.abs(self.pump - self.pumpState) < 0.05 then
		self.pumpState = 2
		self.pumpTarget = 0;
	elseif self.pumpState == 2 and self.pump < 0.05 then
		self.pumpState = 0
		self.pumpTarget = 0;
		self.pump = 0;
	end
	self.pump = (self.pump + self.pumpTarget * TimerMan.DeltaTimeSecs * 20) / (1 + TimerMan.DeltaTimeSecs * 20);
	self.Frame = math.floor(self.pump * 2 + 0.55);
	
	if self.Magazine ~= nil then
		if self.pressure >= self.pressureMax * 0.99 or self.pump > 0 then
			self.Magazine.RoundCount = 2;
		elseif self.pressure < 5 then
			self.Magazine.RoundCount = 0;
		else
			self.Magazine.RoundCount = 1;
		end
	end
	
	self.RotAngle = self.RotAngle + self.FlipFactor * math.pi / 20 * self.pump;
end