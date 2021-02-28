
function Create(self)
	self.GibTimer = Timer();
	self.GibTimer:SetSimTimeLimitMS(2000 + self.InventorySize * 100);
	-- Choose a random horizontal direction
	local randomDirection = math.random() > 0.5 and 1 or -1;
	-- Randomize velocities
	--self.AngularVel = -randomDirection * math.random(1, 5);
	self.Vel = Vector(randomDirection * math.random(1, 13), 5);
	self.GlobalAccScalar = 0.5;
	self.GibImpulseLimit = self.GibImpulseLimit * math.random(1,3);
	
	self.landSound = CreateSoundContainer("Land Cardboard", "FGround.rte");
	
	self.anim = 0;
	self.animate = true;
	
	for i = 1, 2 do
		local fire = CreateMOSParticle("Flame 2 Hurt");
		fire.Pos = self.Pos + Vector(RangeRand(-self.IndividualRadius, self.IndividualRadius), RangeRand(-self.IndividualRadius, self.IndividualRadius))
		fire.Vel = self.Vel * RangeRand(0.5,1.2);
		MovableMan:AddParticle(fire);
		
		local smoke = CreateMOSParticle("Explosion Smoke 2");
		smoke.Pos = self.Pos + Vector(RangeRand(-self.IndividualRadius, self.IndividualRadius), RangeRand(-self.IndividualRadius, self.IndividualRadius))
		smoke.Vel = self.Vel * RangeRand(0.5,1.2);
		smoke.Lifetime = smoke.Lifetime * RangeRand(0.7,1.3) * 2.0;
		MovableMan:AddParticle(smoke);
	end
end

function Update(self)
	-- Apply damage to the actors inside based on impulse forces
	if self.TravelImpulse.Magnitude > self.Mass then
		for i = 1, self.InventorySize do
			local actor = self:Inventory();
			if actor and IsActor(actor) and string.find(actor.Material.PresetName, "Flesh") then
				actor = ToActor(actor);
				-- The following method is a slightly revised version of the hardcoded impulse damage system
				local impulse = self.TravelImpulse.Magnitude - actor.ImpulseDamageThreshold;
				local damage = impulse / (actor.GibImpulseLimit * 0.1 + actor.Material.StructuralIntegrity * 10);
				actor.Health = damage > 0 and actor.Health - damage or actor.Health;
				actor.Status = actor.Status < Actor.DYING and Actor.UNSTABLE or actor.Status;
			end
			self:SwapNextInventory(actor, true);
		end
	end
	if self.GibTimer:IsPastSimTimeLimit() then
		self:GibThis();
	elseif self.Vel.Largest > 5 or self.AIMode == Actor.AIMODE_STAY then
		self.GibTimer:Reset();
	end
	if self.animate then
		self.anim = math.fmod(self.anim + TimerMan.DeltaTimeSecs * 3, 1);
		self.RotAngle = self.RotAngle + math.sin(self.anim * math.pi * 2) * math.pi / 50;
		self.AngularVel = math.sin(self.anim * math.pi * 2) * math.pi / 50;
	else
		self.anim = math.max(self.anim - TimerMan.DeltaTimeSecs * 2, 0)
	end
		self.Frame = math.floor(self.anim * (self.FrameCount - 1) + 0.55);
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end

function OnCollideWithTerrain(self, terrainID)
	if self.animate then
		self.animate = false
		self.landSound:Play(self.Pos)
	end
end

function OnCollideWithMO(self, mo, rootMO)
	--self.animate = false
end