function Update(self)
	if self.Age > (self.Lifetime - 100) and not self.spawn then
		self.spawn = true
		
		if self.Sharpness == 2 then
			-- Mushroom Hat
			local particles = {"Fire Ball 4 B", "Explosion Smoke 1", "Flame Smoke 2"}
			
			local maxi = 120
			local maxj = 7
			for j = 1, maxj do
				for i = 1, maxi do
					local vel = Vector(12 * (0.3 + (j / maxj)),0):RadRotate(math.pi / maxi * i + (RangeRand(-2,2) / maxi * math.random(3,12)))  * RangeRand(0.75,1.2) + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 4
					vel = Vector(vel.X * 1.25, vel.Y * 0.8)
					
					local effect = CreateMOSParticle(particles[math.random(1, #particles)])
					effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 5
					effect.Vel = self.Vel * RangeRand(0.10, 0.25) + vel
					effect.Lifetime = effect.Lifetime * RangeRand(0.9,6) * (0.3 + (j / maxj))
					effect.AirResistance = 1.7 * RangeRand(0.9,1.1)
					effect.AirThreshold = 1
					effect.GlobalAccScalar = -0.025 * RangeRand(0.9,1.1)
					MovableMan:AddParticle(effect)
				end
			end
			
		end
		
		--self:GibThis();
	end
end