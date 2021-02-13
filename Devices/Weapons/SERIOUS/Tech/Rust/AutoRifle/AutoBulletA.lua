
function Create(self)
	for i = 1, 3 do
		local poof = CreateMOSParticle(math.random(1,2) < 2 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = self.Vel * RangeRand(0.1, 0.9) * 1.0;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.3
		MovableMan:AddParticle(poof);
	end
	self.startVel = Vector(self.Vel.X, self.Vel.Y) * 2.0 * RangeRand(0.9,1.1)
	self.Frame = 1
	self.tracer = 3
	--self.smoke = math.random(1,4) < 2
	self.smoke = false
	
	--if self.smoke then
	-- FANCY TRAIL BY FILIPEX2000
	self.trailM = 0; -- DONT TOUCH
	self.trailMTarget = RangeRand(-1,1);
	self.trailMProgress = 0; -- DONT TOUCH
	
	self.trailGProgress = 0; -- DONT TOUCH
	self.trailGLoss = -0.5; -- Trail lifetime offset (lower number, stays 100% longer)
	
	-- FINE TUNE!
	self.LifetimeMulti = 0.9; -- How long the particles stay alive
	self.TrailRandomnessMulti = 0.5; -- Wave modulation target speed
	self.TrailWavenessSpeed = 0.5; -- Wave modulation controller speed
	--end
end

function Update(self)
	self.Vel = Vector();
	self.startVel = self.startVel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
	--self.Vel.Magnitude
	local endPos = Vector(self.Pos.X, self.Pos.Y); -- This value is going to be overriden by function below, this is the end of the ray
	--self.ray = SceneMan:CastObstacleRay(self.Pos, Vector(1, 0):RadRotate(self.RotAngle) * step, Vector(0, 0), endPos, 0 , self.Team, 0, 1) -- Do the hitscan stuff, raycast
	self.ray = SceneMan:CastObstacleRay(self.Pos, self.startVel * rte.PxTravelledPerFrame, Vector(0, 0), endPos, 0 , self.Team, 0, 1) -- Do the hitscan stuff, raycast
	
	local travel = SceneMan:ShortestDistance(self.Pos,endPos,SceneMan.SceneWrapsX);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + travel, 13);
	
	-- Tracer Trail
	if math.random(1,5) < 2 and self.tracer > 0 then
		local maxi = travel.Magnitude/ GetPPM() * 1.5
		for i = 0, maxi do
			--PrimitiveMan:DrawCirclePrimitive(self.Pos + travel / maxi * i, 2 + i / maxi * 3, 166);
			local particle = CreateMOPixel("Bullet Rust Auto Rifle Glow");
			particle.Pos = self.Pos + travel / maxi * i * RangeRand(1.1,0.9);
			--particle.Vel = travel:SetMagnitude(30)
			particle.EffectRotAngle = self.RotAngle;
			MovableMan:AddParticle(particle);
		end
		self.tracer = self.tracer - 1
		if not self.smoke then
			self.smoke = math.random(1,3) < 2
		end
	end
	
	--Micro Smoke Ball 1
	
	if self.ray > -1 then
		self.Pos = endPos
		
		-- Damage
		local pixel = CreateMOPixel("Bullet Rust Auto Rifle Damage");
		pixel.Vel = Vector(1, 0):RadRotate(self.RotAngle) * 70;
		pixel.Pos = self.Pos - Vector(2, 0):RadRotate(self.RotAngle);
		pixel.Team = self.Team
		pixel.IgnoresTeamHits = true;
		MovableMan:AddParticle(pixel);
		
		local smoke = CreateMOSParticle("Small Smoke Ball 1");
		smoke.Pos = self.Pos - Vector(2, 0):RadRotate(self.RotAngle);
		smoke.Vel = Vector(-1, 0):RadRotate(self.RotAngle + RangeRand(-0.3,0.3)) * RangeRand(0.2, 4);
		smoke.Lifetime = smoke.Lifetime * RangeRand(0.6, 1.6) * 0.4; -- Randomize lifetime
		MovableMan:AddParticle(smoke);
		
		local effect = CreateMOSRotating("Rust Auto Rifle Hit Effect");
		if effect then
			effect.Pos = self.Pos
			MovableMan:AddParticle(effect);
			effect:GibThis();
		end
		
		AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Tech/Rust/AutoRifle/Sounds/Hit"..math.random(1,5)..".wav", self.Pos);
		
		self.ToDelete = true
	else
		self.Pos = endPos
	end
	
	-- Epic Trail
	if self.smoke then
		local smoke
		local offset = travel
		local trailLength = math.floor((offset.Magnitude+0.5) / 4)
		for i = 1, trailLength do
			if RangeRand(0,1) < (1 - self.trailGLoss) then
				smoke = CreateMOPixel("Micro Smoke Ball "..math.random(1,4));
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
					smoke.Vel = self.startVel * self.trailGProgress * 0.25 + Vector(0, self.trailM * 12  * RangeRand(0.9, 1.1) * self.trailGProgress):RadRotate(Vector(self.startVel.X, self.startVel.Y).AbsRadAngle);-- * RangeRand(0.5, 1.2) * 0.5;
					smoke.Lifetime = smoke.Lifetime * RangeRand(0.1, 1.9) * (1.0 + self.trailGProgress) * 0.3 * self.LifetimeMulti;
					smoke.GlobalAccScalar = RangeRand(-1, 1) * 0.15; -- Go up and down
					MovableMan:AddParticle(smoke);
					
					local c = 1;
					self.trailGProgress = math.min(self.trailGProgress + TimerMan.DeltaTimeSecs * c, 1.0)
					self.trailGLoss = math.min(self.trailGLoss + TimerMan.DeltaTimeSecs * 0.65, 1.0);
				end
			end
		end
	end
	
end