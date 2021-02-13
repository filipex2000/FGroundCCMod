
function Create(self)
	self.lastPos = nil; -- Important stuff
	
	self.raycast = true; -- Make sure to raycast once
	
	self.normalizedVel = Vector(1, 0):RadRotate(self.RotAngle); -- Get rotation and use this as direction (no more fucked up trajectory when flying)
	--self.normalizedVel = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(1); -- Get starting velocity and use this as direction (unreliable, please replace)
	self.PinStrength = 1000; -- Stop
	self.Vel = Vector(0, 0); -- Stop even more
	
	self.particlePerMetre = 2.0 -- This variable defines quality of the trail, higher number --> more particles, lower number --> less particles
	
	self.impactSound = CreateSoundContainer("Bullet Impact Popshot", "FGround.rte");
end

function Update(self)
	if self.lastPos == nil then
		self.lastPos = Vector(self.Pos.X,self.Pos.Y) - self.normalizedVel * 10.0; -- Important stuff, get the starting pos for hitscan stuff
	end
	
	if self.raycast == true then -- Do the magic stuff
		local endPos = Vector(self.Pos.X, self.Pos.Y); -- This value is going to be overriden by function below, this is the end of the ray
		self.Pos = self.Pos - Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(5) -- Offset back
		self.ray = SceneMan:CastObstacleRay(self.Pos, Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(60 * GetPPM()), Vector(0, 0), endPos, 0 , self.Team, 0, 1) -- Do the hitscan stuff, raycast
		self.Pos = endPos; -- Go to the end of the ray
		
		--GFX
		local leng = SceneMan:ShortestDistance(self.lastPos,self.Pos,SceneMan.SceneWrapsX).Magnitude
		local max_i = (leng / GetPPM() * self.particlePerMetre)
		local particle
		-- Create cool effects along the hitscan bullet path - raycast line
		for i = 0, max_i * 2 do
			for j = 0, 1 do
				particle = CreateMOSParticle("Tracer Spark Ball 3");
				particle.Pos = self.lastPos + (SceneMan:ShortestDistance(self.lastPos,self.Pos,SceneMan.SceneWrapsX) / (max_i * 2) * i);
				particle.Vel = Vector(RangeRand(0,4), math.sin(i * 0.04 * math.pi) * (j - 0.5) * 5.0):RadRotate(self.normalizedVel.AbsRadAngle);
				particle.GlobalAccScalar = 0
				particle.Lifetime = particle.Lifetime * RangeRand(0.8, 1.4) * 0.3 * math.random(1,3); -- Randomize lifetime
				MovableMan:AddParticle(particle);
			end
		end
		
		self.impactSound:Play(self.Pos)
		
		-- Damage, create a pixel that makes a hole
		if self.ray > 5 then -- But only when not too close
			for i = 1, 3 do
				local pixel = CreateMOPixel("Bullet Popshot Rifle Damage");
				pixel.Vel = (Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(120)):RadRotate(math.pi * RangeRand(-0.1, 0.1));
				pixel.Pos = self.Pos - Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(5);
				pixel.Team = self.Team -- It doesn't work, somehow
				pixel.IgnoresTeamHits = true;
				MovableMan:AddParticle(pixel);
			end
		end
		
		-- Create cool particles at the hit pos
		particle = CreateMOSParticle("Blast Ball Small 1");
		particle.Pos = self.Pos;
		particle.GlobalAccScalar = 0;
		particle.Lifetime = particle.Lifetime * 0.76;
		MovableMan:AddParticle(particle);
		
		-- Add addational particles - the yellow sparks and more
		for i = 1, 3 do
			local bzzt = CreateMOPixel("Spark White 1");
			bzzt.Pos = self.Pos - Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(1);
			bzzt.Vel = (Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(1)):RadRotate(math.pi * RangeRand(-0.3, 0.3)) * RangeRand(0.5, 1.0) * -100.0;
			bzzt.GlobalAccScalar = 0;
			bzzt.Lifetime = bzzt.Lifetime * RangeRand(0.6, 1.6) * 0.5;
			MovableMan:AddParticle(bzzt);
			
			local buh = CreateMOSParticle("Small Smoke Ball 1");
			buh.Pos = self.Pos - Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(1);
			buh.Vel = (Vector(self.normalizedVel.X,self.normalizedVel.Y):SetMagnitude(1)):RadRotate(math.pi * RangeRand(-0.3, 0.3)) * RangeRand(0.5, 1.0) * -20.0;
			buh.Lifetime = buh.Lifetime * RangeRand(0.6, 1.6) * 0.5;
			MovableMan:AddParticle(buh);
		end
		
		self.raycast = false;
	end
	--A line for debugging
	--PrimitiveMan:DrawLinePrimitive(self.lastPos, self.lastPos + SceneMan:ShortestDistance(self.lastPos,self.Pos,SceneMan.SceneWrapsX), 254);
end

function OnCollideWithTerrain(self, terrainID) -- I'm not sure why did I put it here
  self.ToDelete = true;
  self.raycast = false;
end