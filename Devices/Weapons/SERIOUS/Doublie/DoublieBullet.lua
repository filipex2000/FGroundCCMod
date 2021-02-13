function Create(self)
	self.trailLength = 50;
	local trail = CreateMOPixel("Doublie Bullet Trail Glow 0");
	trail.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.5;
	trail.EffectRotAngle = self.Vel.AbsRadAngle;
	MovableMan:AddParticle(trail);
	
	self.hit = CreateMOSRotating("Doublie Bullet Hit Effect");
	self.hitTerrain = false
end
function Update(self)
	if not self.hitTerrain then
		local velFactor = math.floor(1 + math.sqrt(self.Vel.Magnitude)/(1 + self.Age * 0.01));
		
		local glowNumber = self.Vel.Magnitude > 60 and 1 or (self.Vel.Magnitude > 40 and 2 or (self.Vel.Magnitude > 20 and 3 or 4));
		local trail = CreateMOPixel("Doublie Bullet Trail Glow ".. glowNumber);
		trail.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.min(self.Vel.Magnitude * rte.PxTravelledPerFrame, self.trailLength) * 0.5);
		trail.EffectRotAngle = self.Vel.AbsRadAngle;
		MovableMan:AddParticle(trail);
	end

	if self.ToDelete or self.hitTerrain then
		if not self.hitTerrain and self.Age < self.Lifetime then
			local hitPos = Vector(self.Pos.X, self.Pos.Y);
			local trace = Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame;
			local skipPx = 2;
			local obstacleRay = SceneMan:CastObstacleRay(Vector(self.Pos.X, self.Pos.Y), trace, Vector(), hitPos, rte.NoMOID, self.Team, rte.airID, skipPx);
			if obstacleRay >= 0 then
				self.hit.Pos = hitPos;
				MovableMan:AddParticle(self.hit);
				self.hit:GibThis()
			end
		elseif self.hitTerrain then
			self.hit.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(2);
			MovableMan:AddParticle(self.hit);
			self.hit:GibThis()
			self.ToDelete = true
			
			for i = 1, math.random(2,4) do
				AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Doublie/Sounds/Hit"..math.random(1,4)..".wav", self.Pos, -1, 0, 10, RangeRand(0.7,1.6), math.random(100,350), false)
			end
		end
	end
end

function OnCollideWithTerrain(self, terrainID)
	self.hitTerrain = true
end