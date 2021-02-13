

function Create(self)
	self.parentSet = false;

	self.uses = 3
	self.seedsPerUse = (self:NumberValueExists("SeedPerUse") and self:GetNumberValue("SeedPerUse") or 1)
	self.seedsPresetName = (self:StringValueExists("SeedPresetName") and self:GetStringValue("SeedPresetName") or nil)
	
	self.rotation = 1
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
	
	if self.parent then
		self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		
		if self.Magazine then
			self.Magazine.RoundCount = self.uses
		end
		if self.FiredFrame and self.uses > 0 then
			self.uses = self.uses - 1
			
			AudioMan:PlaySound("FGround.rte/Flora/SeedBag/Sounds/Shake"..math.random(1,2)..".wav", self.Pos, -1, 0, 130, 1, 250, false)
			
			--AudioMan:PlaySound("FGround.rte/Flora/SeedBag/Sounds/Spores"..math.random(1,3)..".wav", self.Pos, -1, 0, 130, 1, 250, false)
			AudioMan:PlaySound("FGround.rte/Flora/SeedBag/Sounds/Seeds"..math.random(1,3)..".wav", self.Pos, -1, 0, 130, 1, 250, false)
			
			for i = 1, self.seedsPerUse do
				local seed = CreateMOPixel(self.seedsPresetName);
				if seed then
					seed.Pos = self.Pos;
					seed.Vel = Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.15) * RangeRand(0.6,1.4) * 0.5
					MovableMan:AddParticle(seed)
				end
			end
			self.rotation = self.rotation - 60
		end
		
		if self.uses < 1 then
			--[[
			self.JointStrength = -1
			self.GibImpulseLimit = 1
			self.HUDVisible = false]]
			local crap = CreateMOSRotating("Seed Bag Empty");
			crap.Pos = self.Pos
			crap.Vel = self.Vel + Vector(RangeRand(-1,1),RangeRand(-1,1)) * 5
			crap.AngularVel = RangeRand(-1,1) * 1.5
			crap.RotAngle = self.RotAngle
			crap.HFlipped = self.HFlipped
			
			MovableMan:AddParticle(crap)
			
			AudioMan:PlaySound("FGround.rte/Flora/SeedBag/Sounds/Crunch"..math.random(1,5)..".wav", self.Pos, -1, 0, 130, 1, 250, false)
			
			self.ToDelete = true
		end
		
		self.RotAngle = self.RotAngle + math.rad(self.rotation) * self.FlipFactor
		self.rotation = (self.rotation) / (1 + TimerMan.DeltaTimeSecs)
	end
end


function OnCollideWithTerrain(self, terrainID)
end