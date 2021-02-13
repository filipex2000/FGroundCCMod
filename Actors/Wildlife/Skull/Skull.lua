
function Create(self)
	self.hoverPosTarget = Vector(self.Pos.X, self.Pos.Y);
	self.hoverVelocityTarget = 0;
	self.hoverVelocity = 0;
	self.hoverDirectionTarget = 0;
	self.hoverDirection = 0;
	
	self.accsin = 0;
	self.GlobalAccScalar = 0.1;
	
	self.randHTimer = Timer();
	self.randVec = Vector()
	
	self.HUDTimer = Timer();
	self.lastHealth = self.Health;
	
	self.FrameTilt = 0;
	self.FrameTiltTarget = 0;
	self.lastTilt = 0;
	
	self.laughsin = 0;
	self.laughing = false;
	self.laughTimer = Timer();
	self.laughDelay = RangeRand(5000,12000);
	self.laughAnim = Timer();
	
	self.regenTimer = Timer();
	
	self.dead = false
	self.master = nil;
	self.bond = false;
	
	self.target = nil;
	self.targetCheckM = RangeRand(0.9,1.1); -- avoid regular checking
	self.targetCheckDelay = 150;
	
	self.targetCheckTimer = Timer();
	
	self.decayTimer = Timer();
	
	-- Attack mechanic
	self.attackType = math.random(0,2); -- 0 - FIREBALL, 1 - FIRE BREATH, 2 - LASERS
	self.attackTimer = Timer();
	self.attackTimerMulti = RangeRand(0.9,1.1);
	self.attackMouthOpenTimer = Timer();
	
	self.revolt = false; -- Wild boy
end

function Update(self)
	if (self.Health < 1 or self.Status == Actor.DEAD or self.Status == Actor.DYING) then
		if not self.dead then
			if math.random(1,3) >= 2 then
				self.dead = true
				self:GibThis();
				return
			else
				self.dead = true
				self:FlashWhite(300)
				self.GlobalAccScalar = 1.0;
			end
		end
		--self.ToSettle = true;
		return
	end
	
	if self.laughTimer:IsPastSimMS(self.laughDelay) and not self.laughing then
		AudioMan:PlaySound("FGround.rte/Actors/Wildlife/Skull/Sounds/Laugh"..math.random(1,5)..".wav", self.Pos);
		self.laughing = true;
		self.laughDelay = RangeRand(5000,12000);
		self.laughAnim:Reset()
		self.laughTimer:Reset()
	end
	if self.laughing then
		if self.laughTimer:IsPastSimMS(750) then
			self.laughing = false
		end
		self.laughsin = (self.laughsin + TimerMan.DeltaTimeSecs * 4) % 1;
	end
	
	-- Regenerate
	if self.TotalWoundCount > 0 and self.regenTimer:IsPastSimMS(500) then
		if math.random(1,3) < 2 then
			self:RemoveAnyRandomWounds(1);
			self:FlashWhite(200);
			self.HUDTimer:Reset()
		end
		self.regenTimer:Reset()
	end
	
	if self.lastHealth ~= self.Health then
		self.HUDTimer:Reset()
		self.lastHealth = self.Health
	end
	
	if not self.HUDTimer:IsPastSimMS(2000) then
		self.HUDVisible = true;
	else
		self.HUDVisible = false;
	end
	
	self.accsin = (self.accsin + TimerMan.DeltaTimeSecs * 2) % 2;
	self.GlobalAccScalar = math.sin(self.accsin * math.pi) * 0.2;
	
	--self:MoveOutOfTerrain(555)
	--self:MoveOutOfTerrain(0)
	
	--if self.master and self.master.ID ~= rte.NoMOID then
	--self.hoverPosTarget = self.master.Pos;
	if self.bond or self.revolt then -- find target
		local range = 500
		self.FrameTiltTarget = 0;
		
		if not self.target then
			if self.targetCheckTimer:IsPastSimMS(self.targetCheckDelay * self.targetCheckM) then
				local shortestDist;
				for actor in MovableMan.Actors do
					if actor.ID ~= self.ID and actor.Team ~= self.Team and actor.Status ~= Actor.DEAD and actor.Status ~= Actor.DYING and actor.ClassName ~= "ADoor" then
						local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
						if dist.Magnitude <= range then
							
							local tVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
							local terrCheck = SceneMan:CastStrengthRay(self.Pos, tVec, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
							if terrCheck == false then
								--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + tVec,  147);
								
								if not shortestDist or dist.Magnitude < shortestDist then
									shortestDist = dist.Magnitude;
									self.target = actor;
								end
							--else
								--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + tVec,  47);
							end
						end
					end
				end
				self.targetCheckM = RangeRand(0.9,1.1);
				self.targetCheckTimer:Reset()
			end
		else
			if self.target ~= nil and self.target.ID ~= rte.NoMOID and self.target.Status ~= Actor.DEAD and self.target.Status ~= Actor.DYING then
				local tVec = SceneMan:ShortestDistance(self.Pos, self.target.Pos, SceneMan.SceneWrapsX);
				
				self.FrameTiltTarget = tVec.X / 15
				
				-- ATTACK
				if self.attackType == 0 then
					
					if self.attackTimer:IsPastSimMS(2000 * self.attackTimerMulti) then
						AudioMan:PlaySound("FGround.rte/Actors/Wildlife/Skull/Sounds/Fire"..math.random(1,5)..".wav", self.Pos);
						local fireball = CreateMOPixel("Skull Fireball");
						fireball.Vel = tVec:SetMagnitude(50):RadRotate(RangeRand(-0.05,0.05)) * RangeRand(0.9,1.1);
						fireball.Pos = self.Pos + Vector(0, 3);
						fireball:SetWhichMOToNotHit(self,-1);
						fireball.Team = self.Team
						fireball.IgnoresTeamHits = true;
						MovableMan:AddParticle(fireball);
						
						for i = 1, 3 do
							local glow = CreateMOPixel("Particle Attack Skull Glow "..i);
							glow.Pos = self.Pos + Vector(0, 3);
							glow.GlobalAccScalar = 0;
							MovableMan:AddParticle(glow);
						end
						
						for i = 1, 4 do
							local smoke = CreateMOSParticle("Flame Smoke 2");
							smoke.Vel = self.Vel + tVec:SetMagnitude(15):RadRotate(RangeRand(-0.15,0.15)) * RangeRand(0.00,1.5);
							smoke.Pos = self.Pos + Vector(0, 3);
							smoke.AirResistance = smoke.AirResistance * RangeRand(2,3);
							smoke.GlobalAccScalar = 0;
							smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.3);
							MovableMan:AddParticle(smoke);
						end
						
						self.attackTimer:Reset()
						self.attackTimerMulti = RangeRand(0.9,1.1);
						self.attackMouthOpenTimer:Reset()
					end
				elseif self.attackType == 1 then
					
					if self.attackTimer:IsPastSimMS(200 * self.attackTimerMulti) then
						if math.random(1,3) < 2 then
							AudioMan:PlaySound("FGround.rte/Actors/Wildlife/Skull/Sounds/Woosh.wav", self.Pos);
						end
						for i = 1, 3 do
							local fireball = math.random(1,5) > 2 and CreateMOSParticle("Flame Hurt Short Float") or CreateMOSParticle("Flame Hurt Short");
							fireball.Vel = tVec:SetMagnitude(50):RadRotate(RangeRand(-0.15,0.15)) * RangeRand(0.3,1.3);
							fireball.Pos = self.Pos + Vector(0, 3) + tVec:SetMagnitude(6);
							fireball:SetWhichMOToNotHit(self,-1);
							fireball.Team = self.Team
							fireball.IgnoresTeamHits = true;
							MovableMan:AddParticle(fireball);
						end
						
						for i = 1, 3 do
							local glow = CreateMOPixel("Particle Attack Skull Glow "..i);
							glow.Pos = self.Pos + Vector(0, 3);
							glow.GlobalAccScalar = 0;
							MovableMan:AddParticle(glow);
						end
						
						for i = 1, 10 do
							local smoke = CreateMOSParticle("Flame Smoke 2");
							smoke.Vel = self.Vel + tVec:SetMagnitude(15):RadRotate(RangeRand(-0.2,0.2)) * RangeRand(0.00,2.5);
							smoke.Pos = self.Pos + Vector(0, 3);
							smoke.AirResistance = smoke.AirResistance * RangeRand(2,3);
							smoke.GlobalAccScalar = 0;
							smoke.HitsMOs = false;
							smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.3);
							MovableMan:AddParticle(smoke);
						end
						
						for i = 1, 3 do
							local smoke = CreateMOSParticle("Fire Puff Medium");
							smoke.Vel = self.Vel + tVec:SetMagnitude(20):RadRotate(RangeRand(-0.2,0.2)) * RangeRand(0.00,2.5);
							smoke.Pos = self.Pos + Vector(0, 3);
							smoke.AirResistance = smoke.AirResistance * RangeRand(1,2);
							smoke.Lifetime = smoke.Lifetime * RangeRand(0.7, 1.3);
							smoke.HitsMOs = false;
							MovableMan:AddParticle(smoke);
						end
						
						self.attackTimer:Reset()
						self.attackTimerMulti = RangeRand(0.9,1.1);
						self.attackMouthOpenTimer:Reset()
					end
				elseif self.attackType == 2 then
					
					local eye1 = self.Pos + Vector(( 2 + 3 * (self.lastTilt / 2)) * self.FlipFactor,-2):RadRotate(self.RotAngle)
					local eye2 = self.Pos + Vector((-2 + 3 * (self.lastTilt / 2)) * self.FlipFactor,-2):RadRotate(self.RotAngle)
					
					if self.attackTimer:IsPastSimMS(600 * self.attackTimerMulti) then
						AudioMan:PlaySound("FGround.rte/Actors/Wildlife/Skull/Sounds/PewB"..math.random(1,4)..".wav", self.Pos);
						
						if math.random(1,7) < 2 then
							local laser = CreateMOSRotating("Particle Laser Shot 1");
							laser.Pos = eye1
							laser.RotAngle = tVec.AbsRadAngle + RangeRand(-0.1,0.1)
							laser:SetWhichMOToNotHit(self,-1);
							laser.Team = self.Team
							MovableMan:AddParticle(laser);
							laser = nil
							
							laser = CreateMOSRotating("Particle Laser Shot 1");
							laser.Pos = eye2
							laser.RotAngle = tVec.AbsRadAngle + RangeRand(-0.1,0.1)
							laser:SetWhichMOToNotHit(self,-1);
							laser.Team = self.Team
							MovableMan:AddParticle(laser);
							
							self.attackTimerMulti = RangeRand(0.7,1.3) * 2.0;
						else
							local laser = CreateMOSRotating("Particle Laser Shot 1");
							if math.random(1,2) < 2 then
								laser.Pos = eye1
							else
								laser.Pos = eye2
							end
							laser.RotAngle = tVec.AbsRadAngle + RangeRand(-0.1,0.1)
							laser:SetWhichMOToNotHit(self,-1);
							laser.Team = self.Team
							MovableMan:AddParticle(laser);
							if math.random(1,7) < 2 then
								self.attackTimerMulti = RangeRand(0.7,1.3) * 0.35;
							else
								self.attackTimerMulti = RangeRand(0.7,1.3);
							end
						end
						
						local glow1 = CreateMOPixel("Particle Attack Laser Skull Glow");
						glow1.Pos = eye1;
						glow1.Vel = self.Vel
						glow1.GlobalAccScalar = 0;
						MovableMan:AddParticle(glow1);
						
						glow1 = CreateMOPixel("Particle Attack Skull Glow 1");
						glow1.Pos = eye1;
						glow1.Vel = self.Vel
						glow1.GlobalAccScalar = 0;
						MovableMan:AddParticle(glow1);
						
						local glow2 = CreateMOPixel("Particle Attack Laser Skull Glow");
						glow2.Pos = eye2;
						glow2.Vel = self.Vel
						glow2.GlobalAccScalar = 0;
						MovableMan:AddParticle(glow2);
						
						glow2 = CreateMOPixel("Particle Attack Skull Glow 1");
						glow2.Pos = eye2;
						glow2.Vel = self.Vel
						glow2.GlobalAccScalar = 0;
						MovableMan:AddParticle(glow2);
						
						-- Special effect!
						PrimitiveMan:DrawCirclePrimitive(eye1, 1, 10 + math.random(0,3));
						PrimitiveMan:DrawCirclePrimitive(eye2, 1, 10 + math.random(0,3));
						
						self.attackTimer:Reset()
					end
				end
				
				--PrimitiveMan:DrawCirclePrimitive(self.Pos, tVec.Magnitude, 166);
				if self.targetCheckTimer:IsPastSimMS(self.targetCheckDelay * self.targetCheckM) then
					local terrCheck = SceneMan:CastStrengthRay(self.Pos, tVec, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
					if terrCheck == true or tVec.Magnitude >= range or self.target == self.Team then
						self.target = nil
					end
					self.targetCheckM = RangeRand(0.9,1.1);
					self.targetCheckTimer:Reset()
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + tVec,  112);
				else
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + tVec,  122);
				end
			else
				self.target = nil
			end
		end
		
		--PrimitiveMan:DrawCirclePrimitive(self.Pos, range, 166);
	end
	
	if self.revolt then
		-- Follow enemies
		if self.target ~= nil and self.target.ID ~= rte.NoMOID then
			if self.randHTimer:IsPastSimMS(2000) then
				self.randVec = Vector(RangeRand(-1,1), RangeRand(-0.6,0.3)) * 20.0
				self.randHTimer:Reset()
			end
			
			self.hoverPosTarget = self.target.Pos + Vector(0, - (self.target.Height * 0.25 + self.target.Radius * 1.5) / 2) + self.randVec;
		end
		
		if self.decayTimer:IsPastSimMS(10000) then
			self.Health = self.Health - 2;
		end
	elseif self.bond then
		-- Follow master
		if self.master and self.master.ID ~= rte.NoMOID then
			
			if self.randHTimer:IsPastSimMS(2000) then
				self.randVec = Vector(RangeRand(-1,1), RangeRand(-0.6,0.3)) * 20.0
				self.randHTimer:Reset()
			end
			
			--self.hoverPosTarget = self.master.Pos + Vector(0, - self.master.Radius * 1.5) + self.randVec;
			if self.attackType == 1 and self.target ~= nil and self.target.ID ~= rte.NoMOID then  -- Close Range Attack
				self.hoverPosTarget = (self.target.Pos + (self.master.Pos + Vector(0, - (self.master.Height * 0.25 + self.master.Radius * 1.5) / 2) + self.randVec) * 3.0) / 4.0;
			else
				self.hoverPosTarget = self.master.Pos + Vector(0, - (self.master.Height * 0.25 + self.master.Radius * 1.5) / 2) + self.randVec;
			end
			
			if self.master.Status == Actor.DEAD or self.master.Status == Actor.DYING then
				self.revolt = true
				self.master = nil
				MovableMan:ChangeActorTeam(self, -1)
				self.Team = -1
				self.decayTimer:Reset()
			end
		else
			self.revolt = true
			self.master = nil
			MovableMan:ChangeActorTeam(self, -1)
			self.Team = -1
			self.decayTimer:Reset()
		end
	else
		-- Find master
		local shortestDist;
		for actor in MovableMan.Actors do
			if actor.ID ~= self.ID and actor.Team == self.Team and IsAHuman(actor) then
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
				if not shortestDist or dist.Magnitude < shortestDist then
					shortestDist = dist.Magnitude;
					self.master = actor;
					self.bond = true;
				end
			end
		end
	end
	
	--PrimitiveMan:DrawCirclePrimitive(self.hoverPosTarget, 6, 13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(self.hoverVelocityTarget, 0):RadRotate(self.hoverDirectionTarget), 122);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(self.hoverVelocity, 0):RadRotate(self.hoverDirection), 5);
	
	
	-- Define howery
	local vec = SceneMan:ShortestDistance(Vector(self.Pos.X, self.Pos.Y),self.hoverPosTarget,SceneMan.SceneWrapsX)
	self.hoverDirectionTarget = vec.AbsRadAngle;
	self.hoverVelocityTarget = math.min(vec.Magnitude, 60) / 2;
	
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + vec, 116);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(10,0):RadRotate(vec.AbsRadAngle), 149);
	
	self.hoverVelocity = (self.hoverVelocity + self.hoverVelocityTarget * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10)
	
	-- Frotate self.hoverDirection
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.hoverDirectionTarget - self.hoverDirection;
	local result;
	
	local range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		local ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	self.hoverDirection = (self.hoverDirection + result * TimerMan.DeltaTimeSecs * 15)
	--self.hoverDirection = self.hoverDirectionTarget
	
	result = 0
	ret = 0
	
	-- Frotate self.RotAngle
	value = self.RotAngle;
	
	range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	self.RotAngle = (self.RotAngle - result * TimerMan.DeltaTimeSecs * 15)
	
	self.Vel = (self.Vel + Vector(self.hoverVelocity * 0.5, 0):RadRotate(self.hoverDirection) * TimerMan.DeltaTimeSecs * 7) / (1 + TimerMan.DeltaTimeSecs * 7);
	--self.Vel = Vector(self.hoverVelocity * 0.5, 0):RadRotate(self.hoverDirection)
	self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 10) - self.Vel.X * TimerMan.DeltaTimeSecs * 6
	self.FrameTilt = (self.FrameTilt + self.FrameTiltTarget * TimerMan.DeltaTimeSecs * 7) / (1 + TimerMan.DeltaTimeSecs * 7);
	
	local FrameOffset = 0;
	if (self.laughing and self.laughsin > 0.5) or not self.attackMouthOpenTimer:IsPastSimMS(500) then
		FrameOffset = 3;
	end
	
	self.HFlipped = (self.Vel.X+self.FrameTilt) < 0;
	self.lastTilt = math.min(math.abs((self.Vel.X+self.FrameTilt) / 5), 2);
	self.Frame = math.min(math.floor((2 - self.lastTilt) + 0.55), 2) + FrameOffset;
end

function OnCollideWithTerrain(self, terrainID)
	if self.Status == Actor.DEAD or self.Status == Actor.DYING then return end
	
	if self.bond and self.master and self.master.ID ~= rte.NoMOID then
		local dist = SceneMan:ShortestDistance(self.Pos, self.master.Pos, SceneMan.SceneWrapsX).Magnitude;
		if (dist > 150 and self.target == nil) or dist > 250 then
			self.Pos = self.master.Pos
			
			local effect = CreateMOSRotating("Skull Warp Teleport Effect");
			if effect then
				effect.Pos = self.Pos;
				MovableMan:AddParticle(effect);
				effect:GibThis();
			end
		end
	end
	
	-- Custom move out of terrain script, EXPERIMENTAL
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.Radius, 13);
	local maxi = 8
	for i = 1, maxi do
		local offset = Vector(self.Radius, 0):RadRotate(((math.pi * 2) / maxi) * i)
		local endPos = self.Pos + offset; -- This value is going to be overriden by function below, this is the end of the ray
		self.ray = SceneMan:CastObstacleRay(self.Pos + offset, offset * -1.0, Vector(0, 0), endPos, 0 , self.Team, 0, 1)
		if self.ray == 0 then
			--self.Pos = self.Pos - offset * 0.1;
			self.Pos = self.Pos - offset * 0.05;
			self.Vel = self.Vel * 0.5;
		end
		--PrimitiveMan:DrawLinePrimitive(self.Pos + offset, self.Pos - offset, 46);
		--PrimitiveMan:DrawLinePrimitive(self.Pos + offset, endPos, 116);
	end
	
end