

function Create(self)
	self.collideSound = true;
	
	self.progress = 0;
	self.progressTarget = 0;
	
	self.activated = false;
	self.lastFrame = self.Frame;
	
	self.flopTimer = Timer();
	self.flopTime = RangeRand(2500, 3500);
	self.delayTimer = Timer();
	
	self.soundOpenClose = nil;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		self.collideSound = true;
		
		if not actor:IsPlayerControlled() then
			self:Activate()
			actor:GetController():SetState(Controller.MOVE_LEFT,false);
			actor:GetController():SetState(Controller.MOVE_RIGHT,false);
			actor:GetController():SetState(Controller.BODY_CROUCH,true);
		end
	end
	
	if self:IsActivated() and self.delayTimer:IsPastSimMS(500) then
		if not self.activated then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Open.wav", self.Pos);
			self.flopTimer:Reset()
			self.activated = true;
		end
		self.progressTarget = 1;
		self.StanceOffset = Vector(13, 1);
		self.SupportOffset = Vector(0, 5);
		
		if self.flopTimer:IsPastSimMS(self.flopTime) then
			self.progress = 0.54
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Flop.wav", self.Pos);
			self.flopTime = RangeRand(2500, 3500);
			self.flopTimer:Reset()
		end
	else
		if self.activated then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Close.wav", self.Pos);
			self.activated = false;
			self.delayTimer:Reset()
		end
		self.progressTarget = 0;
		self.StanceOffset = Vector(3, 9);
		self.SupportOffset = Vector(500, 500);
	end
	
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