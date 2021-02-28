
function Create(self)
	self.PinStrength = 99000
	self.PreMO = "Nuclear Pre Blast"
	self.PostMO = "Nuclear Post Blast"
	self.DelayMS = 286 - 26
	
	self.Timer = Timer();
end

function Update(self)
	if self.PreMO then
		local effect = CreateMOSRotating(self.PreMO, "FGround.rte")
		if effect then
			effect.Pos = self.Pos
			MovableMan:AddParticle(effect);
			effect:GibThis();
		end
		
		-- Lasting Smoke
		for s = 0, 1 do
			local side = (s - 0.5) * 2
			for i = 1, 15 do
				local effect = CreatePEmitter("Nuclear Lasting Smoke", "FGround.rte")
				effect.Pos = self.Pos + Vector(RangeRand(-2,2) * i, -2)
				effect.Vel = Vector(70 * side, math.random(1,15)) * RangeRand(0.7,1.3)
				effect.Lifetime = effect.Lifetime * RangeRand(0.5,1)
				MovableMan:AddParticle(effect)
			end
		end
		
		self.PreMO = nil
	end
	
	if self.Timer:IsPastSimMS(self.DelayMS) then
		local effect = CreateMOSRotating(self.PostMO, "FGround.rte")
		if effect then
			effect.Pos = self.Pos
			MovableMan:AddParticle(effect);
			effect:GibThis();
			
			-- Shockwave
			local maxi = 240
			for i = 1, maxi do
				local effect = CreateMOSParticle("Fire Ball 4 B", "FGround.rte")
				effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1))
				effect.Vel = Vector(160 * RangeRand(0.95,1.05) * 0.7,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
				effect.Lifetime = effect.Lifetime * math.random(1,8) * 0.3
				MovableMan:AddParticle(effect)
			end
			
			-- Fragment Blast
			maxi = 180
			for i = 1, maxi do
				local effect = CreatePEmitter("Nuclear Fragment Blast", "FGround.rte")
				effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1))
				effect.Vel = Vector(300 * RangeRand(0.95,1.05) * 0.7,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
				effect.Lifetime = effect.Lifetime * RangeRand(3,5)
				MovableMan:AddParticle(effect)
			end
			
			-- Trail 1
			for i = 0, 4 do
				local trail = CreateAEmitter("Nuclear Blast Trail 1", "FGround.rte")
				trail.Pos = self.Pos + Vector(RangeRand(-2,2) * i, -2)
				trail.Vel = Vector(math.random(-2 * i, 2 * i), -70 / ((2 + i) * 0.5))
				trail.Sharpness = i == 0 and 2 or 1
				MovableMan:AddParticle(trail)
			end
			
			-- Ring
			for s = 0, 1 do
				local side = (s - 0.5) * 2
				for i = 1, 30 do
					local effect = CreatePEmitter("Fuel Fire Trace Black", "FGround.rte")
					effect.Pos = self.Pos + Vector(RangeRand(-2,2) * i, -2)
					effect.Vel = self.Vel * RangeRand(0.15, 0.35) + Vector(85 * side * RangeRand(0.7,1.3), math.random(1,15)) * RangeRand(0.7,1.3)
					effect.Lifetime = effect.Lifetime * RangeRand(0.5,1)
					MovableMan:AddParticle(effect)
				end
			end
		end
		self.PostMO = nil
		
		-- GFX
		
		self.ToDelete = true
	end
end