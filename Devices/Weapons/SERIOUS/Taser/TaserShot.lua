
function Create(self)
	local glow = CreateMOPixel("Glow Taser Particle 4", "FGround.rte");
	glow.Pos = self.Pos;
	MovableMan:AddParticle(glow);
	
	self.stickSound = CreateSoundContainer("Taser Stick", "FGround.rte");
	self.dischargeSound = CreateSoundContainer("Taser Discharge", "FGround.rte");
	self.tazerLoop = CreateSoundContainer("Taser Loop", "FGround.rte");
	
	-- Initialize projectiles
	self.projectilePhysicsTimer = Timer();
	
	self.projectiles = 2; --DO NOT CHANGE THIS
	self.projectileVelX = {}
	self.projectileVelY = {}
	self.projectilePosX = {}
	self.projectilePosY = {}
	self.projectileStuck = {}
	
	for i = 1, self.projectiles do
		--self.projectilePos[i] = Vector(self.Pos.X, self.Pos.Y)
		--self.projectileVel[i] = Vector(self.Vel.Magnitude,0):RadRotate(self.RotAngle + RangeRand(-1.0,1.0) * 0.1)
		table.insert(self.projectilePosX, i, 0)
		table.insert(self.projectilePosY, i, 0)
		local v = Vector(Vector(self.Vel.X, self.Vel.Y).Magnitude * RangeRand(0.95,1.05),0):RadRotate(self.RotAngle + RangeRand(-1.0,1.0) * 0.05)
		table.insert(self.projectileVelX, i, v.X)
		table.insert(self.projectileVelY, i, v.Y)
		table.insert(self.projectileStuck, i, false)
	end
	
	self.wireValues = {}
	self.wirePoints = 5
	for i = 1, self.wirePoints do
		table.insert(self.wireValues, i, RangeRand(-1, 1))
	end
	
	self.defaultIndex = 171;--169;
	self.zapIndex = 223;
	
	self.colorIndex = self.defaultIndex;
	
	self.Vel = Vector();
	self.flash = false
	self.charges = 1; -- avoid more than one DISCHARGE's
	
	self.DischargeTimer = Timer(); -- stop being CHARGED when certain time has passed
	
	self.collisions = 0; -- DISCHARGE only when collided twice
	
	self.target = nil;
	self.electrocuteStopTimer = Timer();
end

function Update(self)
	-- Update projectiles
	self.flash = false;
	
	if self.DischargeTimer:IsPastSimMS(1000) then
		self.charges = 0
	end
	
	for i = 1, self.projectiles do
		local j = (self.projectiles - i) + 1
		if self.projectileStuck[i] == false then -- Fly
			if self.projectilePhysicsTimer:IsPastSimMS(70) then -- Addational physics
				local v = Vector(self.projectileVelX[i], self.projectileVelY[i]):RadRotate(RangeRand(-1,1) * 0.1)
				
				local p1 = self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i])
				local p2 = self.Pos + Vector(self.projectilePosX[j], self.projectilePosY[j])
				local dif = SceneMan:ShortestDistance(p1,p2,SceneMan.SceneWrapsX)
				
				--if dif.Magnitude > 25 then
				--	v = v + dif * 0.1
				--end
				v = v + dif * math.min(math.max((dif.Magnitude / 25) - 1, 0), 3) * 0.3
				
				self.projectileVelX[i] = v.X
				self.projectileVelY[i] = v.Y
				self.projectilePhysicsTimer:Reset()
			end
			local v = Vector(self.projectileVelX[i], self.projectileVelY[i]) + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs -- Basic physics
			v = v / (1 + TimerMan.DeltaTimeSecs * 1.0)
			self.projectileVelX[i] = v.X
			self.projectileVelY[i] = v.Y
			
			local length = v.Magnitude * rte.PxTravelledPerFrame + 2.0
			local terrCheck = SceneMan:CastStrengthRay(self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i]), v:SetMagnitude(length), 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
			
			--PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i]), self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i]) + v:SetMagnitude(length), 5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i]) + v:SetMagnitude(length), 1, 5);
			
			if terrCheck == true then
				local rayHitPos = SceneMan:GetLastRayHitPos() - self.Pos
				self.projectilePosX[i] = rayHitPos.X
				self.projectilePosY[i] = rayHitPos.Y
				self.projectileStuck[i] = true
				self.collisions = self.collisions + 1
				
				self.stickSound:Play(self.Pos)
				
				-- DISCHARGE
				if self.charges > 0 and self.collisions > 1 then
					local glow = CreateMOPixel("Glow Taser Particle 1", "FGround.rte");
					glow.Pos = rayHitPos + self.Pos;
					MovableMan:AddParticle(glow);
					
					--AudioMan:SetSoundPitch(sound, RangeRand(0.9,1.05))
					self.flash = true;
					self.charges = self.charges - 1;
				end
			else
				self.projectilePosX[i] = self.projectilePosX[i] + self.projectileVelX[i] * rte.PxTravelledPerFrame
				self.projectilePosY[i] = self.projectilePosY[i] + self.projectileVelY[i] * rte.PxTravelledPerFrame
			end
		end
		
		--local position = self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i])
		-- Render dots
		--PrimitiveMan:DrawCirclePrimitive(position, 1, self.colorIndex);
	end
	
	-- Check for targets
	if self.charges > 0 then
		for i = 1, self.projectiles do
			local j = (self.projectiles - i) + 1
			
			local v = Vector(self.projectileVelX[i], self.projectileVelY[i])
			local length = v.Magnitude * rte.PxTravelledPerFrame + 2.0
			
			local p1 = self.Pos + Vector(self.projectilePosX[i], self.projectilePosY[i])
			local p2 = (self.Pos + Vector(self.projectilePosX[j], self.projectilePosY[j]) + p1) / 2
			moCheck = SceneMan:CastMORay(p1, SceneMan:ShortestDistance(p1, p2 + v:SetMagnitude(length),SceneMan.SceneWrapsX), self.ID, self.Team, 0, false, 5); -- Raycast
			
			--PrimitiveMan:DrawLinePrimitive(p1, p2 + v:SetMagnitude(length), 5);
			if moCheck and moCheck ~= rte.NoMOID then
				local mo = MovableMan:GetMOFromID(moCheck);
				local rootMo = MovableMan:GetMOFromID(mo.RootID);
				local actor = (IsActor(mo) and ToActor(mo)) or (rootMo and IsActor(rootMo) and ToActor(rootMo))
				
				-- DISCHARGE
				if self.charges > 0 then
					local glow = CreateMOPixel("Glow Taser Particle 3", "FGround.rte");
					glow.Pos = ToMOSRotating(mo).Pos;
					MovableMan:AddParticle(glow);
					
					
					
					if actor and actor.ClassName ~= "ADoor" and actor.ClassName ~= "ACraft" then
						local glow = CreateMOPixel("Glow Taser Particle 4", "FGround.rte");
						glow.Pos = actor.Pos;
						MovableMan:AddParticle(glow);
						
						actor:FlashWhite(130);
						self.target = actor;
						self.electrocuteStopTimer:Reset();
						
						if actor.ClassName == "ACrab" or actor.ClassName == "AHuman" then
							actor.Status = 1
						end
						
						--print((actor.Mass / 50) * (actor.GibWoundLimit / 10))
						local damage = 150 / (1 / ((1 * actor.DamageMultiplier) / (actor.Mass + actor.Material.StructuralIntegrity)))
						actor.Health = actor.Health - damage * 11
						
						actor:GetController():SetState(Controller.BODY_CROUCH,true);
						actor:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
						actor:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
						actor:GetController():SetState(Controller.WEAPON_FIRE,false);
						actor:GetController():SetState(Controller.AIM_SHARP,false);
						actor:GetController():SetState(Controller.WEAPON_PICKUP,false);
						actor:GetController():SetState(Controller.WEAPON_DROP,true);
						actor:GetController():SetState(Controller.BODY_JUMP,false);
						actor:GetController():SetState(Controller.BODY_JUMPSTART,false);
						if math.random(1,2) < 2 then
							actor:GetController():SetState(Controller.MOVE_LEFT,true);
							actor:GetController():SetState(Controller.MOVE_RIGHT,false);
						else
							actor:GetController():SetState(Controller.MOVE_LEFT,false);
							actor:GetController():SetState(Controller.MOVE_RIGHT,true);
						end
					end
					
					--AudioMan:SetSoundPitch(sound, RangeRand(0.9,1.05))
					self.flash = true;
					self.charges = self.charges - 1;
					
					self.projectilePosX[i] = self.projectilePosX[i] + self.projectileVelX[i] * rte.PxTravelledPerFrame
					self.projectilePosY[i] = self.projectilePosY[i] + self.projectileVelY[i] * rte.PxTravelledPerFrame
					
					self.projectileVelX[i] = self.projectileVelX[i] * 0.3;
					self.projectileVelY[i] = self.projectileVelY[i] * 0.3;
					
					self.projectileVelX[j] = self.projectileVelX[j] * 0.3;
					self.projectileVelY[j] = self.projectileVelY[j] * 0.3;
				end
			end
		end
	elseif not self.electrocuteStopTimer:IsPastSimMS(1800) and self.target and MovableMan:ValidMO(self.target) and self.target.ID ~= rte.NoMOID then
		local actor = self.target;
		actor:GetController():SetState(Controller.BODY_CROUCH,true);
		actor:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
		actor:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
		actor:GetController():SetState(Controller.WEAPON_FIRE,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		actor:GetController():SetState(Controller.WEAPON_PICKUP,false);
		actor:GetController():SetState(Controller.BODY_JUMP,false);
		actor:GetController():SetState(Controller.BODY_JUMPSTART,false);
		if math.random(1,2) < 2 then
			if math.random(1,2) < 2 then
				actor:GetController():SetState(Controller.MOVE_LEFT,true);
				actor:GetController():SetState(Controller.MOVE_RIGHT,false);
			else
				actor:GetController():SetState(Controller.MOVE_LEFT,false);
				actor:GetController():SetState(Controller.MOVE_RIGHT,true);
			end
		else
			actor:GetController():SetState(Controller.MOVE_LEFT,false);
			actor:GetController():SetState(Controller.MOVE_RIGHT,false);
		end
	end
	
	local p1 = self.Pos + Vector(self.projectilePosX[1], self.projectilePosY[1])
	local p2 = self.Pos + Vector(self.projectilePosX[2], self.projectilePosY[2])
	local vec = SceneMan:ShortestDistance(p1,p2,SceneMan.SceneWrapsX)
	
	-- Render cable/wire/line
	if self.flash == true or (math.random(1,3) < 2 and self.charges > 0) then
		self.colorIndex = self.zapIndex;
		
		if self.flash == true or math.random(1,3) < 2 then
			local lastPoint = p1
			for i = 1, self.wirePoints do
				local fac = 1 / self.wirePoints * (i-0.5)
				
				local point = p1 + vec * fac
				
				local glows = math.max(math.floor((vec.Magnitude / 15) * 8 + 0.55), 1)
				for j = 1, glows do 
					
					if math.random(1,15) < 2 then
						local r = (j / glows)
						local spark = CreateMOPixel("Particle Taser Spark", "FGround.rte");
						spark.Pos = (lastPoint + point * r) / (1 + r)
						spark.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)):SetMagnitude(RangeRand(5, 15))
						spark.Lifetime = spark.Lifetime * RangeRand(0.35,1.0)
						MovableMan:AddParticle(spark);
					end
				end
				
			end
		end
	else
		self.colorIndex = self.defaultIndex;
	end
	
	-- Simple
	--PrimitiveMan:DrawLinePrimitive(p1, p1 + vec, self.colorIndex);
	
	--self.wireValues
	
	-- Advanced
	local lastPoint = p1
	for i = 1, self.wirePoints do
		local fac = 1 / self.wirePoints * (i-0.5)
		local tension = math.min(math.max(1 - (vec.Magnitude / 35), 0), 1) + 0.2
		
		local point = p1 + vec * fac + Vector(0, self.wireValues[i] * 3 * tension):RadRotate(vec.AbsRadAngle)
		
		if self.flash == true then
			local glows = math.max(math.floor((vec.Magnitude / 15) * 8 + 0.55), 1)
			for j = 1, glows do 
				local glow = CreateMOPixel("Glow Taser Particle "..math.random(1,4), "FGround.rte");
				local r = (j / glows)--((j / glows) + RangeRand(-0.5,1.5)) / 2
				glow.Pos = (lastPoint + point * r) / (1 + r);
				MovableMan:AddParticle(glow);
			end
		end
		
		--if i == 1 then
		--	PrimitiveMan:DrawLinePrimitive(p1, point, self.colorIndex);
		if i == self.wirePoints then
			PrimitiveMan:DrawLinePrimitive(p2, p2 + SceneMan:ShortestDistance(p2,point,SceneMan.SceneWrapsX), self.colorIndex);
			PrimitiveMan:DrawLinePrimitive(lastPoint, lastPoint + SceneMan:ShortestDistance(lastPoint,point,SceneMan.SceneWrapsX), self.colorIndex);
		else
			PrimitiveMan:DrawLinePrimitive(lastPoint, lastPoint + SceneMan:ShortestDistance(lastPoint,point,SceneMan.SceneWrapsX), self.colorIndex);
		end
		--PrimitiveMan:DrawCirclePrimitive(point, 1, 13); -- Debug
		lastPoint = point
	end
	
	if self.flash == true then
		local pos = self.Pos + (Vector(self.projectilePosX[1], self.projectilePosY[1]) + Vector(self.projectilePosX[2], self.projectilePosY[2])) / 2
		self.dischargeSound:Play(self.Pos)
	end
	
	if self.charges > 0 then
		if not self.tazerLoop:IsBeingPlayed() then
			self.tazerLoop:Play(self.Pos);
		end
		
		self.tazerLoop.Pos = self.Pos + (Vector(self.projectilePosX[1], self.projectilePosY[1]) + Vector(self.projectilePosX[2], self.projectilePosY[2])) / 2
		self.tazerLoop.Pitch = 1.5 - (math.min(self.Age / 1000, 1) * 0.5)
	else
		self.tazerLoop:Stop(-1);
	end
end