function Create(self)
	self.trailM = 0; -- DONT TOUCH
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0; -- DONT TOUCH
	
	self.trailGProgress = 0; -- DONT TOUCH
	self.trailGLoss = -0.8; -- Trail lifetime offset (lower number, stays 100% longer)
	
	-- FINE TUNE!
	self.LifetimeMulti = 1; -- How long the particles stay alive
	self.TrailRandomnessMulti = 1; -- Wave modulation target speed
	self.TrailWavenessSpeed = 1; -- Wave modulation controller speed
	
	--self.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.4
	
	self.ParticleName = "Tracer White Ball 1"; -- Trail's particle
	--[[
	local poof;
	local poofs = 5;
	for i = 1, poofs do
		poof = CreateMOSParticle(self.ParticleName);
		poof.Pos = self.Pos - (self.Vel * rte.PxTravelledPerFrame) * 0.5 * (1.0 - (i/poofs)) - (self.Vel * rte.PxTravelledPerFrame);
		poof.Vel = self.Vel * 0.1;
		poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.4;
		poof.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
		MovableMan:AddParticle(poof);
	end]]
end

function Update(self)
	

	if self.ToDelete then
		if self.Age < self.Lifetime then
			local hitPos = Vector(self.Pos.X, self.Pos.Y);
			local trace = Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame;
			local skipPx = 2;
			local obstacleRay = SceneMan:CastObstacleRay(Vector(self.Pos.X, self.Pos.Y), trace, Vector(), hitPos, rte.NoMOID, self.Team, rte.airID, skipPx);
			if obstacleRay >= 0 then
				local effect = CreateMOSRotating("Nova Bullet Effect");
				effect.Pos = hitPos;
				MovableMan:AddParticle(effect);
				effect:GibThis();
			end
		end
		return
	end
	
	
	-- Epic smoke trail TM by filipex2000, 2020
	
	local smoke
	local offset = self.Vel*(17*TimerMan.DeltaTimeSecs)
	local trailLength = math.floor((offset.Magnitude+0.5) / 3)
	for i = 1, trailLength do
		if RangeRand(0,1) < (1 - self.trailGLoss) then
			smoke = CreateMOSParticle(self.ParticleName);
			if smoke then
				
				local a = 10 * self.TrailWavenessSpeed;
				local b = 5 * self.TrailRandomnessMulti;
				self.trailM = (self.trailM + self.trailMTarget * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
				self.trailMProgress = self.trailMProgress + TimerMan.DeltaTimeSecs * b;
				if self.trailMProgress > 1 then
					self.trailMTarget = RangeRand(-1,1);
					self.trailMProgress = self.trailMProgress - 1;
				end
				
				smoke.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
				smoke.Vel = self.Vel * self.trailGProgress * 0.5 + Vector(0, self.trailM * 17  * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.Vel.X, self.Vel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.7) * (1.0 + self.trailGProgress) * 0.3 * self.LifetimeMulti;
				smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.2; -- Go up and down
				MovableMan:AddParticle(smoke);
				
				local c = 1;
				self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
				self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.65, 1.0);
			end
		end
	end
	
end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
  self.ToDelete = true;
end