function Create(self)

	self.Team = -1;
	
	self.Thrown = false
	self.SpawnCopy = true
	
	self.hasBalloon = true
	
	self.stickMOUniqueID = -1
	self.balloonMOUniqueID = -1
	
	self.balloonOpenTimer = Timer();
	self.balloonOpenDelay = 500
	
	self.balloonPopTimer = Timer();
	self.balloonPopDelay = 5000
end

function Update(self)

	if self.stickMOUniqueID ~= -1 then
		local MO = MovableMan:FindObjectByUniqueID(self.stickMOUniqueID)
		if MO then
			MO = ToMOSRotating(MO)
			self.Pos = MO.Pos
			self.RotAngle = MO.RotAngle
			self.Vel = MO.Vel
			self.AngularVel = MO.AngularVel
			self.PinStrength = 1000
			
			self.GetsHitByMOs = false
			self.HitsMOs = false
			--if self.ID ~= self.RootID then
			--	self.stickMOUniqueID = -1
			--end
			
			if self.hasBalloon and self.balloonOpenTimer:IsPastSimMS(self.balloonOpenDelay) then
				AudioMan:PlaySound("FGround.rte/Devices/Thrown/SERIOUS/FultonExtraction/Sounds/BalloonOpen.wav", self.Pos)
				
				local balloon = CreateMOSRotating("Fulton Extraction Balloon");
				balloon.Pos = self.Pos + Vector(0,-9);
				balloon.Vel = self.Vel + Vector(0,-13);
				balloon.Scale = 0
				MovableMan:AddParticle(balloon);
				
				self.balloonMOUniqueID = balloon.UniqueID
				
				self.hasBalloon = false
			elseif self.balloonMOUniqueID then
				local balloon = MovableMan:FindObjectByUniqueID(self.balloonMOUniqueID)
				if balloon then
					balloon = ToMOSRotating(balloon) 
					
					balloon.Scale = math.min(balloon.Scale + TimerMan.DeltaTimeSecs * 2, 1)
					balloon.GlobalAccScalar = math.min(balloon.GlobalAccScalar + TimerMan.DeltaTimeSecs * 0.25, 1)
					balloon.ToSettle = false
					
					local ld = SceneMan:ShortestDistance(self.Pos,balloon.Pos,SceneMan.SceneWrapsX)
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + ld + Vector(4,16):RadRotate(balloon.RotAngle) * balloon.Scale,  20);
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + ld + Vector(-4,16):RadRotate(balloon.RotAngle) * balloon.Scale,  20);
					PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + ld * 0.5,  20);
					PrimitiveMan:DrawCirclePrimitive(self.Pos + ld * 0.5, 1, 171)
					PrimitiveMan:DrawLinePrimitive(self.Pos + ld * 0.5, self.Pos + ld * 0.5,  172);
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + ld * 0.5,  20);
					
					PrimitiveMan:DrawLinePrimitive(self.Pos + ld * 0.5, self.Pos + ld + Vector(4,16):RadRotate(balloon.RotAngle) * balloon.Scale,  20);
					PrimitiveMan:DrawLinePrimitive(self.Pos + ld * 0.5, self.Pos + ld + Vector(-4,16):RadRotate(balloon.RotAngle) * balloon.Scale,  20);
					
					-- Balance
					local min_value = -math.pi;
					local max_value = math.pi;
					local value = balloon.RotAngle
					local result;
					local ret = 0
					
					local range = max_value - min_value;
					if range <= 0 then
						result = min_value;
					else
						ret = (value - min_value) % range;
						if ret < 0 then ret = ret + range end
						result = ret + min_value;
					end
					
					balloon.RotAngle = (balloon.RotAngle - result * TimerMan.DeltaTimeSecs * 1)
					balloon.AngularVel = (balloon.AngularVel - result * 2.0 * TimerMan.DeltaTimeSecs * 2)
					balloon.AngularVel = (balloon.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 1)
					
					local p1 = self.Pos
					local p2 = balloon.Pos
					local dif = SceneMan:ShortestDistance(p1,p2,SceneMan.SceneWrapsX)
					
					--- Spring Joint
					-- Apply a force proportional to the distance between two MOs
					local maxLength = 42
					local maxForce = 4
					local forceMultiplier = 2
					local str = math.min(math.max((dif.Magnitude / maxLength) - 1, 0), maxForce) * TimerMan.DeltaTimeSecs * forceMultiplier
					
					--self.Vel = self.Vel + dif * str
					local bstr = 10
					
					balloon.Vel = balloon.Vel - dif * str * 0.5
					balloon.AngularVel = (dif * str).X * TimerMan.DeltaTimeSecs * 45
					MO.Vel = MO.Vel + dif * str * bstr / MO.Mass * 30
					if IsAttachable(MO) then
						local MOParent = ToAttachable(MO):GetParent()
						if MOParent then
							MOParent = ToMOSRotating(MOParent)
							MOParent.Vel = MOParent.Vel + dif * str * bstr / MOParent.Mass * 30
							
							-- Lord have mercy for this ugly code
							--[[
							if IsAttachable(MOParent) then
								local MOParentParent = ToAttachable(MOParent):GetParent()
								if MOParentParent then
									MOParent = ToMOSRotating(MOParent)
									MOParent.Vel = MOParent.Vel + dif * str * bstr
								end
							end]]
							
						end
						
					end
					
					if self.balloonPopTimer:IsPastSimMS(self.balloonPopDelay) then
						balloon:GibThis()
						AudioMan:PlaySound("FGround.rte/Devices/Thrown/SERIOUS/FultonExtraction/Sounds/BalloonPop.wav", self.Pos)
						self.balloonMOUniqueID = -1
						
						self.PinStrength = 0
						self.stickMOUniqueID = -1
					end
				else
					self.balloonMOUniqueID = -1
				end
			end
		else
			self.PinStrength = 0
			self.stickMOUniqueID = -1
		end
	else
		self.GetsHitByMOs = true
		self.HitsMOs = true
		self.PinStrength = 0
		
		if self.ID ~= self.RootID then
			local actor = MovableMan:GetMOFromID(self.RootID);
			if MovableMan:IsActor(actor) then
				self.Team = ToActor(actor).Team;
			end
		end

		if self:IsActivated() and self.ID == self.RootID then
			if not self.Thrown then
				self.Thrown = true
				AudioMan:PlaySound("FGround.rte/Devices/Thrown/SERIOUS/FultonExtraction/Sounds/Click.wav", self.Pos)
			end
		end
	end
end

function OnCollideWithMO(self, collidedMO, collidedRootMO)
	if self.Thrown and self.stickMOUniqueID == -1 and IsMOSRotating(collidedRootMO) then-- and not string.find(collidedMO.PresetName,"Helmet") and not string.find(collidedMO.PresetName,"Hat")  then
		self.stickMOUniqueID = collidedRootMO.UniqueID
		AudioMan:PlaySound("FGround.rte/Devices/Thrown/SERIOUS/FultonExtraction/Sounds/Attach"..math.random(1,2)..".wav", self.Pos)
		
		self.balloonOpenTimer:Reset()
		self.balloonPopTimer:Reset()
	end
end

function OnCollideWithTerrain(self, terrainID)
	if not self.hasBalloon then
		self:GibThis()
	elseif self.Thrown and self.SpawnCopy then
		local new = CreateTDExplosive(self.PresetName)
		new.Pos = self.Pos
		new.Vel = self.Vel
		new.AngularVel = self.AngularVel
		new.RotAngle = self.RotAngle
		new.HFlipped = self.HFlipped
		MovableMan:AddParticle(new);
		
		self.ToDelete = true
		self.SpawnCopy = false
	end
end