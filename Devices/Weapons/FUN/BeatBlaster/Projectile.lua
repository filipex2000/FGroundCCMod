function Create(self)
	
	self.trailM = 0; -- DONT TOUCH
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0; -- DONT TOUCH
	
	self.trailGProgress = 0; -- DONT TOUCH
	self.trailGLoss = -0.8; -- Trail lifetime offset (lower number, stays 100% longer)
	
	-- FINE TUNE!
	self.LifetimeMulti = 0.5; -- How long the particles stay alive
	self.TrailRandomnessMulti = 1; -- Wave modulation target speed
	self.TrailWavenessSpeed = 1; -- Wave modulation controller speed
end
function Update(self)
	
	-- Epic smoke trail TM by filipex2000, 2020
	local smoke
	local offset = self.Vel*(17*TimerMan.DeltaTimeSecs)
	local trailLength = math.floor((offset.Magnitude+0.5) / 3)
	for i = 1, trailLength do
		if RangeRand(0,1) < (1 - self.trailGLoss) then
			local a = 10 * self.TrailWavenessSpeed;
			local b = 5 * self.TrailRandomnessMulti;
			self.trailM = (self.trailM + self.trailMTarget * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
			self.trailMProgress = self.trailMProgress + TimerMan.DeltaTimeSecs * b;
			if self.trailMProgress > 1 then
				self.trailMTarget = RangeRand(-1,1);
				self.trailMProgress = self.trailMProgress - 1;
			end
			
			local c = 1;
			self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
			self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.65, 1.0);
			
			smoke = (math.random() < 0.3 and CreateMOSParticle("The Beat Blaster Projectile Trail") or nil)
			if smoke then
				
				smoke.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
				smoke.Vel = self.Vel * self.trailGProgress * 0.5 + Vector(0, self.trailM * 5  * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.Vel.X, self.Vel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.7) * (1.0 + self.trailGProgress) * 0.6 * self.LifetimeMulti;
				smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
				MovableMan:AddParticle(smoke);
			end
			
			local note = (math.random() < 0.05 and CreateMOSParticle("Beat Blaster Note "..math.random(1,3), "FGround.rte") or nil)
			if note then
				
				note.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
				note.Vel = Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
				note.Lifetime = note.Lifetime * RangeRand(0.9, 1.6)
				MovableMan:AddParticle(note);
				
				self.fired = false
				self.beatCurrentMusicScore = self.beatCurrentMusicScore + 1
			end
		end
	end
end

function OnCollideWithTerrain(self, terrainID)
	self.ToDelete = true
	self.Sharpness = 1
end