function Create(self)
	self.trailM = 0;
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0;
	
	self.trailGProgress = 0;
	self.trailGLoss = -0.8;
	
	self.GlobalAccScalar = RangeRand(-0.3,0.3);
	
	self.startingVel = Vector(self.Vel.X,self.Vel.Y); -- Get starting velocity (spoiler, It doesn't work)
	
	self.explode = true;
end

function Update(self)
	if self.startingVel == nil then
		self.startingVel = Vector(self.Vel.X,self.Vel.Y); -- Get starting velocity
	end
	
	-- Epic smoke trail TM
	local smoke
	local offset = self.Vel*(17*TimerMan.DeltaTimeSecs)
	local trailLength = math.floor((offset.Magnitude+0.5) / 4)
	for i = 1, trailLength do
		if RangeRand(0,1) < (1 - self.trailGLoss) then
			smoke = math.random(1,5) < 2 and CreateMOSParticle("Fire Puff Small") or CreateMOSParticle("Flame Smoke 2");
			if smoke then
				
				local a = 10
				local b = 5;
				self.trailM = (self.trailM + self.trailMTarget * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
				self.trailMProgress = self.trailMProgress + TimerMan.DeltaTimeSecs * b;
				if self.trailMProgress > 1 then
					self.trailMTarget = RangeRand(-1,1);
					self.trailMProgress = self.trailMProgress - 1;
				end
				
				smoke.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
				smoke.Vel = self.Vel * self.trailGProgress * 0.5 + Vector(0, self.trailM * 17  * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.Vel.X, self.Vel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
				smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.7) * (1.0 + self.trailGProgress) * 0.2;
				smoke.AirResistance = smoke.AirResistance * 3;
				smoke.HitsMOs = false;
				smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
				
				MovableMan:AddParticle(smoke);
				
				local c = 1;
				self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
				self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.65, 1.0);
				
				--if math.abs(self.trailM - self.trailMTarget) < 0.1 then
				--	self.trailMTarget = RangeRand(-1,1);
				--end
			end
		end
	end
	
    self.lastPos = self.Pos;
	if self.Vel.Magnitude / self.startingVel.Magnitude < 0.3 then -- Bullets stop when they hit something, go kabloow when velocity is below 30% of starting velocity
		self.ToDelete = true
	end
	
	if self.explode and self.ToDelete then
		local explosion = CreateMOSRotating("Particle Skull Fireball Explosion"); -- Go kabloow
		explosion.Pos = self.lastPos;
		explosion:GibThis();
		MovableMan:AddParticle(explosion);
		self.explode = false
	end
end


--function OnCollideWithTerrain(self, terrainID) -- Go kabloow
--	self.GlobalAccScalar = 1;
--end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
  self.ToDelete = true;
  self.lastPos = self.Pos;
end

--[[
function Destroy(self)
	local explosion = CreateMOSRotating("Particle Inferno Explosion"); -- Go kabloow
	explosion.Pos = self.lastPos;
	explosion:GibThis();
	MovableMan:AddParticle(explosion);
end
]]