

function Create(self)
	self.collideSound = true;
	
	self.progress = 0;
	self.progressTarget = 0;
	
	self.activated = false;
	self.lastFrame = self.Frame;
	
	self.flopTimer = Timer();
	self.flopTime = RangeRand(300, 500);
	self.delayTimer = Timer();
	
	self.close = false;
	
	self.soundOpenClose = nil;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		self.collideSound = true;
	end
	
	if self:IsActivated() and self.delayTimer:IsPastSimMS(500) and not self.close then
		if not self.activated then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Open.wav", self.Pos);
			self.flopTimer:Reset()
			self.activated = true;
		end
		self.progressTarget = 1;
		self.StanceOffset = Vector(13, 1);
		self.SupportOffset = Vector(0, 5);
		
		if self.flopTimer:IsPastSimMS(self.flopTime) and actor then
			self.progress = 0.54
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Flop.wav", self.Pos);
			self.flopTime = RangeRand(300, 500);
			self.flopTimer:Reset()
			
			self.close = true;
			
			actor:FlashWhite(50);
			
			local actorSize = math.ceil(5 + actor.Radius * 0.5);
			for i = 1, actorSize do
				local part = CreateMOPixel("Heal Glow", "Base.rte");
				local vec = Vector(actorSize * 1.5, 0):RadRotate(6.28/actorSize * i);
				part.Pos = actor.Pos + Vector(0, -actorSize * 0.3):RadRotate(actor.RotAngle) + vec;
				part.Vel = actor.Vel * 0.5 - Vector(vec.X, vec.Y) * 0.25;
				MovableMan:AddParticle(part);
			end
			--local cross = CreateMOSParticle("Particle Heal Effect", "Base.rte");
			--cross.Pos = actor.AboveHUDPos + Vector(0, 5);
			--MovableMan:AddParticle(cross);
			for limb in actor.Attachables do
				limb.GibWoundLimit = math.max(limb.GibWoundLimit * 0.7, 1)
				limb.GibImpulseLimit = math.max(limb.GibImpulseLimit * 0.7, 1)
			end
			actor.Health = actor.Health + actor.MaxHealth * 0.6
			actor.DamageMultiplier = actor.DamageMultiplier * 1.2
			actor.GibWoundLimit = math.max(actor.GibWoundLimit * 0.7, 1)
			actor.GibImpulseLimit = math.max(actor.GibImpulseLimit * 0.8, 1)
			--actor.ImpulseDamageThreshold = actor.ImpulseDamageThreshold * 0.5
			
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Heal.wav", self.Pos);
		end
	else
		if not self:IsActivated() then
			self.close = false;
		end
		if self.activated then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Close.wav", self.Pos);
			self.activated = false;
			self.delayTimer:Reset()
		end
		self.progressTarget = 0;
		self.StanceOffset = Vector(3, 9);
		self.SupportOffset = Vector(500, 500);
	end
	--for i, minion in ipairs(self.minions) do
	--	print(i.." : "..minion.ID)
	--end
	
	self.progress = (self.progress + self.progressTarget * TimerMan.DeltaTimeSecs * 5) / (1 + TimerMan.DeltaTimeSecs * 5);
	self.Frame = math.floor(self.progress * (self.FrameCount - 1) + 0.55);
	if self.lastFrame ~= self.Frame then
		if self.Frame == 3 and self.lastFrame == 4 then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Dhud.wav", self.Pos);
		end
		self.lastFrame = self.Frame;
	end
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "progress = ".. self.progress, true, 0);
	
	if actor then
		self.RotAngle = self.RotAngle - self.FlipFactor * math.pi / 6 * (1 - self.progress) - self.FlipFactor * math.pi / 6;
	else
		self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 5);
	end
end


function OnCollideWithTerrain(self, terrainID)
	if self.collideSound then
		self.collideSound = false;
		AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Dhud.wav", self.Pos);
		self.progress = 0
	end
end

function OnCollideWithMO(self, mo, rootMO)
	if self.collideSound then
		self.collideSound = false;
		AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Dhud.wav", self.Pos);
		self.progress = 0
	end
end