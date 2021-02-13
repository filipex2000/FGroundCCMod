

function Create(self)
	--yes
	self.ammoLoaded = 0
	self.ammoLoadTimer = Timer();
	
	self.ammoLoadDelay = self.ReloadTime * 0.55
	self.ammoLoadDelayTimer = Timer();
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
		self.ammoCounterMax = self.ammoCounter;
	else
		self.ammoCounter = 0;
		self.ammoCounterMax = 1;
		print("ERROR POP SHOT MAGAZINE BULLSHITTERY!")
	end
	
	self.rot = 0;
	
	self.reloading = false;
	
	self.ejectClip = false
	self.ejectClipTimer = Timer();
	
	self.clipEjectSound = CreateSoundContainer("Clip Eject Popshot", "FGround.rte")
	self.insertSound = CreateSoundContainer("Insert Popshot", "FGround.rte")

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
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
	
	if self.ejectClip and self.ejectClipTimer:IsPastSimMS(63) then
		self.clipEjectSound:Play(self.Pos)
		
		clip = CreateMOSRotating("Empty Clip Popshot Rifle");
		clip.Pos = self.Pos + Vector(-1*self.FlipFactor, 1):RadRotate(self.RotAngle);
		clip.Vel = self.Vel + Vector(-1*self.FlipFactor, -6):RadRotate(self.RotAngle);
		clip.RotAngle = self.RotAngle;
		--fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
		clip.HFlipped = self.HFlipped;
		MovableMan:AddParticle(clip);
		
		self.ejectClip = false
	end
	
	if self.FiredFrame then
		if self.Magazine and self.Magazine.RoundCount < 1 then
			self.ejectClip = true
			self.ejectClipTimer:Reset()
		end
		self.rot = self.rot + 1.0
	end
	
	if self.Magazine then
		self.ammoCounter = self.Magazine.RoundCount;
	end
	
	local leanTarget = 0;
	if self:IsReloading() and self.parent then
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		if not self.reloading then
			self.reloading = true;
			self.ammoLoaded = 0;
			self.ammoLoadTimer:Reset()
			self.ammoLoadDelayTimer:Reset()
		end
		
		if self.ammoLoadDelayTimer:IsPastSimMS(self.ammoLoadDelay) then
			if self.ammoLoaded < (self.ammoCounterMax - self.ammoCounter) and self.ammoLoadTimer:IsPastSimMS((self.ReloadTime - self.ammoLoadDelay) / (self.ammoCounterMax - self.ammoCounter)) then
				self.insertSound:Play(self.Pos)
				self.insertSound.Pitch = (self.ammoLoaded / self.ammoCounterMax + 2.5) / 3
				self.ammoLoaded = self.ammoLoaded + 1
				self.ammoLoadTimer:Reset()
				
				self.rot = self.rot - (self.ammoCounterMax - self.ammoCounter) * 0.15
			end
		end
		leanTarget = 1
	else
		if self.reloading then
			self.reloading = false;
		end
	end
	
	self.rot = (self.rot + leanTarget * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	local total = self.FlipFactor * math.pi / 50 * self.rot
	self.RotAngle = self.RotAngle + total;
	
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
	self.Pos = self.Pos + offsetTotal;
	
	self.StanceOffset = (Vector(3, 8) + Vector(-2, 3) * self.rot * 0.5);
end 