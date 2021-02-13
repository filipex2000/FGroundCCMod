

function Create(self)
	--yes
	self.ammoLoaded = 0
	self.ammoLoadTimer = Timer();
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
		self.ammoCounterMax = self.ammoCounter;
	else
		self.ammoCounter = 0;
		self.ammoCounterMax = 1;
		print("ERROR NERF GUN MAGAZINE BULLSHITTERY!")
	end
	
	self.lean = 0;
	
	self.reloading = false;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		self.Frame = math.min(actor.Team + 1, self.FrameCount - 1)
	end
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
	end
	
	if self.FiredFrame then
		local nerf = CreateMOSRotating("Nerf Gun Nerf");
		nerf.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle + RangeRand(-0.1,0.1));
		nerf.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * 50 * RangeRand(0.95, 1.05);
		nerf.RotAngle = self.RotAngle + (math.pi * (-self.FlipFactor + 1) / 2)
		if actor then
			nerf.Team = actor.Team;
			nerf.Frame = self.Frame;
			nerf.IgnoresTeamHits = true;
		end
		MovableMan:AddParticle(nerf);
		
		self.lean = self.lean + 0.5
	end
	
	local leanTarget = 0;
	if self:IsReloading() then
		if not self.reloading then
			self.reloading = true;
			self.ammoLoaded = 0;
			self.ammoLoadTimer:Reset()
		end
		
		if self.ammoLoaded < (self.ammoCounterMax - self.ammoCounter) and self.ammoLoadTimer:IsPastSimMS(self.ReloadTime / (self.ammoCounterMax - self.ammoCounter)) then
			local sound = AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/NerfGun/Sounds/InsertC.wav", self.Pos);
			AudioMan:SetSoundPitch(sound, (self.ammoLoaded / self.ammoCounterMax + 2) / 2)
			self.ammoLoaded = self.ammoLoaded + 1
			self.ammoLoadTimer:Reset()
			
			self.lean = self.lean - (self.ammoCounterMax - self.ammoCounter) * 0.3
		end
		leanTarget = 1
	else
		if self.reloading then
			self.reloading = false;
		end
	end
	
	self.lean = (self.lean + leanTarget * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	self.RotAngle = self.RotAngle + self.FlipFactor * math.pi / 20 * self.lean;
	self.StanceOffset = (Vector(7, 7) - Vector(-2, 3) * self.lean * 0.5);
end 