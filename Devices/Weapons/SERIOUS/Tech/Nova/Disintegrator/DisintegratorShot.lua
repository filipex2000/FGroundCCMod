function Create(self)
	self.Lifetime = self.Lifetime * RangeRand(0.8,1.2)
	self.Vel = self.Vel * RangeRand(0.9,1.1)
	
	self.lifeTime = self.Lifetime
	self.lifeTimer = Timer();
	self.Lifetime = self.Lifetime + 100
	
	self.animAcc = RangeRand(0,self.FrameCount - 1)
	self.sineAcc = RangeRand(0,2);
	
	self.AngularVel = RangeRand(-1,1) * 5
	
	self.target = nil
	self.targetHitPos = Vector(0,0)
end

function Update(self)
	
	self.sineAcc = (self.sineAcc + TimerMan.DeltaTimeSecs * 6) % 2;
	self.animAcc = (self.animAcc + TimerMan.DeltaTimeSecs * 16) % (self.FrameCount - 1);
	self.Frame = math.floor(self.animAcc + 0.55)
	self.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.sin(self.sineAcc * math.pi) * TimerMan.DeltaTimeSecs * 0.5)
	--self.GlobalAccScalar = math.sin(self.sineAcc * math.pi) * 0.6;
	self.Vel = self.Vel + Vector(self.Vel.X, self.Vel.Y):SetMagnitude(TimerMan.DeltaTimeSecs * RangeRand(-1,1) * 25)
	
	local glow = CreateMOPixel("Nova Disintegrator Shot Glow "..math.random(1,2));
	glow.Pos = self.Pos + self.Vel * GetPPM() * TimerMan.DeltaTimeSecs;
	glow.Lifetime = TimerMan.DeltaTimeSecs * 1500
	MovableMan:AddParticle(glow);
	
	if self.target and self.target.ID ~= rte.NoMOID then
		self.Pos = self.targetHitPos
		
		local damage = 150 / (1 / ((1 * self.target.DamageMultiplier) / (self.target.Mass + self.target.Material.StructuralIntegrity)))
		damage = damage * 11
		if (self.target.Health - damage) < 1 and not self.target:NumberValueExists("Disintegrated") then -- DISINTEGRATE
			self.target:SetNumberValue("Disintegrated", 1)
			--[[
			-- Simple Dematerialization
			self.target:FlashWhite(3000);
			self.target.GlobalAccScalar = 0.0
			self.target.Health = self.target.Health - 100
			self.target.Lifetime = 1000
			self.target.Age = 0
			]]
			
			--[[
			-- Simple Destruction
			for limb in self.target.Attachables do
				limb:GibThis();
			end
			self.target:GibThis();
			]]
			
			-- Advanced Dematerialization
			local center = Vector(self.target.Pos.X, self.target.Pos.Y)
			
			local highest = 0
			local lowest = 0
			local right = 0
			local left = 0
			for limb in self.target.Attachables do
				local pos = Vector(limb.Pos.X, limb.Pos.Y)
				local offset = center - pos
				if (offset.X + limb.IndividualRadius) > right then right = offset.X + limb.IndividualRadius end
				if (offset.X - limb.IndividualRadius) < left then left = offset.X - limb.IndividualRadius end
				
				if (offset.Y - limb.IndividualRadius) < lowest then lowest = offset.Y - limb.IndividualRadius end
				if (offset.Y + limb.IndividualRadius) > highest then highest = offset.Y + limb.IndividualRadius end
				--[[
				for gear in limb.Attachables do
					local pos = Vector(gear.Pos.X, gear.Pos.Y)
					local offset = center - pos
					if (offset.X + gear.IndividualRadius) > right then right = offset.X + gear.IndividualRadius end
					if (offset.X - gear.IndividualRadius) < left then left = offset.X - gear.IndividualRadius end
					
					if (offset.Y - gear.IndividualRadius) < lowest then lowest = offset.Y - gear.IndividualRadius end
					if (offset.Y + gear.IndividualRadius) > highest then highest = offset.Y + gear.IndividualRadius end
				end]]
				
				--limb:GibThis();
				--limb.ToDelete = true
			end
			
			local density = 1.0--0.5
			local maxi = (math.abs(right) + math.abs(left)) * density
			local maxj = (math.abs(lowest) + math.abs(highest)) * density
			for i = 0, maxi do
				local x = 0
				local y = 0
				for j = 0, maxj do
					--x = right - (right+left) / maxi*i
					--y = lowest - (lowest+highest) / maxj*j
					
					x = left + (right - left) / maxi*i
					y = ((-lowest) - (-highest)) / maxj*j - highest
					--y = highest + (lowest - highest) / maxj*j
					
					local checkPix = SceneMan:GetMOIDPixel(center.X + x,center.Y + y);
					if checkPix ~= rte.NoMOID then
						for i = 1, 1 / density do
							local drop = CreateMOPixel("Disintegrator Goo Particle "..math.random(1,4));
							drop.Pos = center + Vector(x, y) + Vector(RangeRand(-1,1),RangeRand(-1,1)) * math.abs(1 - density) * 2.0;
							drop.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1,1) * 0.15) * RangeRand(0,1) * 0.25 * math.random(0,2)
							drop.GlobalAccScalar = RangeRand(0.5,1)
							drop.Lifetime = drop.Lifetime * RangeRand(0.7,1.3)
							MovableMan:AddParticle(drop);
						end
					end
					--local marker = CreateMOSRotating("MARKER");
					--marker.Pos = center + Vector(x, y);
					--MovableMan:AddParticle(marker);
				end
			end
			--]]
			self.target.ToDelete = true
			--self.target:GibThis();
			--self.target:FlashWhite(1000);
			--self.target.GlobalAccScalar = 0.0
			--self.target.Health = self.target.Health - 100
			--self.target.Lifetime = 100
			--self.target.Age = 0
			
		else
			self.target.Health = self.target.Health - damage
			self.target:FlashWhite(130);
		end
		self:GibThis();
		return
	else
		local rayOrigin = self.Pos
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			--self.Pos = rayHitPos
			self.targetHitPos = Vector(rayHitPos.X, rayHitPos.Y)
			if IsMOSRotating(MO) then
				local root = MovableMan:GetMOFromID(MO.RootID);
				local actor = nil
				if MovableMan:IsActor(MO) then
					actor = ToActor(MO)
				elseif root and root.ID ~= rte.NoMOID and MovableMan:IsActor(root) then 
					actor = ToActor(root) 
				end
				
				if actor then
					self.target = actor
					--[[
					local damage = 150 / (1 / ((1 * actor.DamageMultiplier) / (actor.Mass + actor.Material.StructuralIntegrity)))
					actor.Health = actor.Health - damage * 11
					actor:FlashWhite(130);
					]]
				end
			end
		end
	end
	
	if self.lifeTimer:IsPastSimMS(self.lifeTime) then
		self:GibThis();
	end

end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
	if math.random(1,6) < 2 then
		self:GibThis();
	else
		self.GlobalAccScalar = 1
	end
end