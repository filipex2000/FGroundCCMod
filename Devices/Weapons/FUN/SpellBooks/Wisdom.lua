

function Create(self)
	self.collideSound = true;
	
	self.progress = 0;
	self.progressTarget = 0;
	
	self.activated = false;
	self.lastFrame = self.Frame;
	
	self.flopTimer = Timer();
	self.delayTimer = Timer();
	
	self.soundOpenClose = nil;
	
	self.noGoingBack = false;
	self.gaspTimer = Timer();
	self.victim = nil;
	
	self.page = 0;
	self.pageMax = 17;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		if self.noGoingBack then
			if actor.Health < 30 then
				actor:GetController():SetState(Controller.BODY_CROUCH,true);
			end
			actor:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
			actor:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
			actor:GetController():SetState(Controller.WEAPON_PICKUP,false);
			actor:GetController():SetState(Controller.WEAPON_DROP,false);
			actor:GetController():SetState(Controller.BODY_JUMP,false);
			actor:GetController():SetState(Controller.BODY_JUMPSTART,false);
			actor:GetController():SetState(Controller.MOVE_LEFT,false);
			actor:GetController():SetState(Controller.MOVE_RIGHT,false);
			
			actor:GetController():SetState(Controller.AIM_UP,false);
			actor:GetController():SetState(Controller.AIM_DOWN,false);
		end
		self.collideSound = true;
	else
		if self.victim and self.victim.ID ~= 255 and self.noGoingBack then
			self.victim.Health = self.victim.Health - 100;
		end
		--self.noGoingBack = false;
	end
	
	if (self:IsActivated() and self.delayTimer:IsPastSimMS(500)) or (self.noGoingBack and actor) then
		if not self.activated then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Open.wav", self.Pos);
			self.flopTimer:Reset()
			self.activated = true;
		end
		self.progressTarget = 1;
		self.StanceOffset = Vector(13, 1);
		self.SupportOffset = Vector(0, 5);
		
		if actor and self.flopTimer:IsPastSimMS(1100 - ((100 - actor.Health) * 5)) then
			self.page = self.page + 1;
			if self.page >= self.pageMax then
				actor.Health = actor.Health - 300
			end
			self.progress = 0.54
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Flop.wav", self.Pos);
			self.flopTimer:Reset()
			
			actor.Health = actor.Health - 10 * RangeRand(0.6,1.2);
			if math.random(1,2) < 2 then
				actor:FlashWhite(200);
				actor.AngularVel = actor.AngularVel + RangeRand(-1,1) * 8
			end
			if not self.noGoingBack then
				self.noGoingBack = true
				self.gaspTimer:Reset()
				AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/WispersQuiet.wav", self.Pos);
			end
			self.victim = actor
		end
		if self.noGoingBack and self.gaspTimer:IsPastSimMS(1500 - ((100 - actor.Health) * 2)) then
			if math.random(1,2) < 2 then
				AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Breathe.wav", self.Pos);
			end
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Heartbeat.wav", self.Pos);
			self.gaspTimer:Reset()
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
		
		if self.noGoingBack then
			self:GibThis()
		end
	end
end

function OnCollideWithMO(self, mo, rootMO)
	if self.collideSound then
		self.collideSound = false;
		AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Dhud.wav", self.Pos);
		self.progress = 0
		
		if self.noGoingBack then
			self:GibThis()
		end
	end
end