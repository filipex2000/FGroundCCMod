function Create(self)
	self.ToToDelete = false;
end

function Update(self)
	if self.ToToDelete then self.ToDelete = true return end
	
	-- Epic glowy trail TM
	local particle
	local offset = self.Vel * rte.PxTravelledPerFrame
	local trailLength = math.max(math.floor((offset.Magnitude+2.0) / 8), 2)
	for i = 1, trailLength do
		particle = CreateMOPixel("Glow Laser Beam "..math.random(1,4));
		if particle then
			particle.Pos = self.Pos - offset * (1 - (i/trailLength)) * RangeRand(0.9, 1.1);
			particle.Vel = self.Vel;
			particle.EffectRotAngle = self.Vel.AbsRadAngle;
			
			MovableMan:AddParticle(particle);
		end
	end
end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
	--self.ToDelete = true;
	self.ToToDelete = true;
end