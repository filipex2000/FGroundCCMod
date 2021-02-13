

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
	self.minions = {};
	self.healthTransfer = 20;
	
	self.soundOpenClose = nil;
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		self.collideSound = true;
		
		if not actor:IsPlayerControlled() and actor.Health >= 60 and #self.minions < 1 then
			self:Activate()
			actor:GetController():SetState(Controller.MOVE_LEFT,false);
			actor:GetController():SetState(Controller.MOVE_RIGHT,false);
			actor:GetController():SetState(Controller.BODY_CROUCH,true);
		end
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
		
		if self.flopTimer:IsPastSimMS(self.flopTime) then
			self.progress = 0.54
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/Flop.wav", self.Pos);
			self.flopTime = RangeRand(300, 500);
			self.flopTimer:Reset()
			
			for i, minion in ipairs(self.minions) do
				if minion == nil or minion.ID == rte.NoMOID then
					table.remove(self.minions, i)
				end
			end
			
			if #self.minions < 5 then
				if actor then
					local summonPos = self.Pos
					
					for i = 1, 3 do
						local smoke = CreateMOSParticle("Explosion Smoke 1");
						smoke.Pos = summonPos;
						smoke.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1))
						smoke.Lifetime = smoke.Lifetime * RangeRand(0.75, 1.5); -- Randomize lifetime
						MovableMan:AddParticle(smoke);
					end
					
					-- SUMMON
					self.close = true;
					local minion = CreateActor("Skull Minion");
					if minion then
						minion.Pos = summonPos;
						if actor.Health - self.healthTransfer < 0 then 
							minion.Team = -1;
						else
							minion.Team = actor.Team;
						end
						minion.Health = self.healthTransfer;
						minion.IgnoresTeamHits = true;
						actor.Health = actor.Health - self.healthTransfer;
						actor:FlashWhite(500);
						minion:FlashWhite(500);
						MovableMan:AddActor(minion);
						
						AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/SpellBooks/Sounds/SummonSkull.wav", self.Pos);
						
						table.insert(self.minions, minion)
					end
					
					--[[
					if actor.Health <= 0 then
						for i, minion in ipairs(self.minions) do
							if minion ~= nil and minion.ID ~= rte.NoMOID and MovableMan:IsActor(minion) then
								local b = ToActor(minion)
								--b.Team = -1; 
								MovableMan:ChangeActorTeam(b, -1) -- THEY ARE WILD NOW
							end
						end
					end
					]]
				end
			else
				self.close = true;
			end
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