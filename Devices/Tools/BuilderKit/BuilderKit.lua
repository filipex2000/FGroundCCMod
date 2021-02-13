

function Create(self)
	self.state = 0 -- 0 -> toolbox, 1 -> object placement, ruler, 2 -> hammer, build
	self.defaultFrame = 1
	self.Frame = self.defaultFrame
	
	self:SetNumberValue("Builder Mode", -1)
	self:SetNumberValue("Cancel Blueprint", 0);
	self.hammerSkin = math.random(0,2)
	
	self.activated = false
	
	self.rulerPosA = Vector(0, 0)
	self.rulerHasPosA = false
	self.rulerPosB = Vector(0, 0)
	self.rulerHasPosB = false
	self.rulerMode = 0 -- 0 == line/vector/two-point placement, 1 == point placement
	self.rulerRayEnd = Vector(0, 0) -- For smooth animations and other stuff
	
	self.rulerSoundPoints = 0
	self.rulerSoundPointDelay = Timer()
	
	--[[
	self.blueprints = 0
	self.blueprintType = {} -- 0 == Plank
	self.blueprintPosAX = {}
	self.blueprintPosAY = {}
	self.blueprintPosBX = {}
	self.blueprintPosBY = {}
	]]
	self.blueprint = false
	self.blueprintTypeNames = {"Wooden Plank", "Metal Pipe"};
	self.blueprintType = 0 -- 0 == Plank, 1 == Pipe
	self.blueprintTypeMax = 1
	self.blueprintPosA = Vector(0, 0) 
	self.blueprintPosB = Vector(0, 0)
	self.blueprintProgress = 0;
	
	self.buildTimer = Timer() -- delay between progress changes
	self.buildDelay = 200
	
	self.rulerAnim = 0
	self.rulerAnimMax = 9
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		local ctrl = actor:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		ctrl:SetState(Controller.AIM_SHARP,false);
		
		if ctrl:IsState(Controller.PIE_MENU_ACTIVE) then
			PrimitiveMan:DrawTextPrimitive(screen, actor.AboveHUDPos + Vector(0, 26), "Blueprint Type: " .. self.blueprintTypeNames[self.blueprintType + 1], true, 1);
			--PrimitiveMan:DrawTextPrimitive(screen, actor.AboveHUDPos + Vector(0, 36), "Material: " .. 100, true, 1);
		end
		
		local team = math.min(actor.Team + 2, 5)
		if self.defaultFrame ~= team then
			self.defaultFrame = team
			actor:FlashWhite(100)
		end
		if self:GetNumberValue("Builder Mode") ~= -1 then
			if self.state == 1 and not (self:GetNumberValue("Builder Mode") == self.state) then
				self.rulerHasPosA = false
				self.rulerHasPosB = false
				self.rulerRayEnd = Vector(self.Pos.X, self.Pos.Y)
			end
			
			self.state = self:GetNumberValue("Builder Mode")
			self:SetNumberValue("Builder Mode", -1)
		end
		
		if self:GetNumberValue("Cancel Blueprint") == 1 then
			self.state = 0
			self.rulerHasPosA = false
			self.rulerHasPosB = false
			self.blueprint = false
			self:SetNumberValue("Cancel Blueprint", 0);
		end
		
		if self:GetNumberValue("Change Blueprint") ~= 0 then
			self.blueprintType = self.blueprintType + self:GetNumberValue("Change Blueprint")
			if self.blueprintType > self.blueprintTypeMax then
				self.blueprintType = 0
			elseif self.blueprintType < 0 then
				self.blueprintType = self.blueprintTypeMax
			end
			AudioMan:PlaySound("Base.rte/Sounds/Devices/DeviceSwitch"..math.random(1,3)..".wav", self.Pos);
			self:SetNumberValue("Change Blueprint", 0);
		end
		
		if self:GetNumberValue("Add Blueprint") == 1 then
			if self.rulerHasPosB and self.rulerHasPosA then
				self.blueprint = true
				self.blueprintPosA = self.rulerPosA
				self.blueprintPosB = self.rulerPosB
				self:SetNumberValue("Add Blueprint", 0);
				
				self.rulerHasPosA = false
				self.rulerHasPosB = false
				self.blueprintProgress = 0
			else
				self:SetNumberValue("Add Blueprint", 0);
			end
		end
		
		-- BUILD
		if self.state == 0 then
			self.Frame = self.defaultFrame
		elseif self.state == 1 then
			if self.blueprint then
				self.state = 2
				AudioMan:PlaySound("Base.rte/Sounds/GUIs/FocusChange.wav", self.Pos);
			else
				local rulerAnimTarget = 0
				local rulerMaxLength = 100
				local rulerMinLength = 5
				
				local rayOrigin = Vector(self.Pos.X, self.Pos.Y)
				local rayVec = SceneMan:ShortestDistance(rayOrigin, rayOrigin + Vector(self.SharpLength * self.FlipFactor, 0):RadRotate(self.RotAngle), SceneMan.SceneWrapsX);
				local rayEnd = self.Pos + rayVec
				
				local terrCheck = SceneMan:CastStrengthRay(self.Pos, rayVec, 30, Vector(), 2, 0, SceneMan.SceneWrapsX);
				if terrCheck then
					rayEnd = SceneMan:GetLastRayHitPos()
				end
				self.rulerRayEnd = (self.rulerRayEnd + SceneMan:ShortestDistance(self.rulerRayEnd, rayEnd, SceneMan.SceneWrapsX) * TimerMan.DeltaTimeSecs * 25)-- / (1 + TimerMan.DeltaTimeSecs * 25);
				
				local cursorColor = 13
				local cursorSize = 5
				if terrCheck then
					cursorSize = 3
					cursorColor = 149
				end
				-- Draw +
				for i = 0, 3 do
					local offset = Vector(2,0):RadRotate(math.pi * 0.5 * i)
					PrimitiveMan:DrawLinePrimitive(rayEnd, rayEnd + offset, cursorColor);
				end
				rayEnd = self.rulerRayEnd
				-- Draw o
				PrimitiveMan:DrawCirclePrimitive(rayEnd, cursorSize, cursorColor);
				-- Draw line
				local cursorLineVec = SceneMan:ShortestDistance(rayOrigin, rayEnd, SceneMan.SceneWrapsX);
				local maxi = math.floor((cursorLineVec.Magnitude / 10) + 0.55)
				for i = 1, maxi do
					local point1 = rayOrigin + cursorLineVec / maxi * i
					local point2 = rayOrigin + cursorLineVec / maxi * (i-0.25)
					PrimitiveMan:DrawLinePrimitive(point1, point2, cursorColor);
				end
				
				if self.rulerMode == 0 then
					
					local lineVec = Vector(0,0)
					if self.rulerHasPosB and self.rulerHasPosA then
						lineVec = SceneMan:ShortestDistance(self.rulerPosA, self.rulerPosB, SceneMan.SceneWrapsX);
					elseif self.rulerHasPosA then
						lineVec = SceneMan:ShortestDistance(self.rulerPosA, rayEnd, SceneMan.SceneWrapsX);
					end
					
					if self:IsActivated() then
						if not self.activated then 
							self.activated = true
							if terrCheck then
								self.rulerPosA = Vector(rayEnd.X, rayEnd.Y)
								self.rulerHasPosA = true
								self.rulerHasPosB = false
								AudioMan:PlaySound("Base.rte/Sounds/GUIs/PlacementGravel"..math.random(1,4)..".wav", self.Pos);
							else
								self.rulerHasPosA = false
								self.rulerHasPosB = false
								AudioMan:PlaySound("Base.rte/Sounds/GUIs/UserError.wav", self.Pos);
								--self.activated = false
							end
						end
						rulerAnimTarget = self.rulerAnimMax
					else
						if self.activated then
							self.activated = false
							if self.rulerHasPosA and lineVec.Magnitude > rulerMinLength then
								if lineVec.Magnitude > (rulerMaxLength + 3) then
									self.rulerPosB = self.rulerPosA + lineVec:SetMagnitude(math.min(lineVec.Magnitude, rulerMaxLength))
									AudioMan:PlaySound("Base.rte/Sounds/GUIs/UserError.wav", self.Pos);
								else
									self.rulerPosB = Vector(rayEnd.X, rayEnd.Y)
								end
								self.rulerHasPosB = true
								AudioMan:PlaySound("Base.rte/Sounds/GUIs/PlacementThud"..math.random(1,2)..".wav", self.Pos);
							else
								AudioMan:PlaySound("Base.rte/Sounds/GUIs/UserError.wav", self.Pos);
								self.rulerHasPosA = false
								self.rulerHasPosB = false
							end
						end
					end
					
					--if self.rulerHasPosB and self.rulerHasPosA then
					--	PrimitiveMan:DrawLinePrimitive(self.rulerPosA, self.rulerPosB, 183);
					--end
					if self.rulerHasPosA and not self.rulerHasPosB then
						local maxi = math.floor((lineVec.Magnitude / 5) + 0.55)
						for i = 1, maxi do
							local color = 147
							if (lineVec / maxi * i).Magnitude > rulerMaxLength then
								color = 46
							end
							local point = self.rulerPosA + lineVec / maxi * i
							PrimitiveMan:DrawCirclePrimitive(point, (i % 2 >= 1) and 1 or 2, color);
						end
						if self.rulerSoundPoints ~= maxi then
							if self.rulerSoundPointDelay:IsPastSimMS(40) then
								
								AudioMan:PlaySound("Base.rte/Sounds/Plopp"..math.random(1,3)..".wav", self.Pos);
								self.rulerSoundPointDelay:Reset()
							end
							self.rulerSoundPoints = maxi
						end
					elseif self.rulerHasPosB and self.rulerHasPosA then
						local color = 5
						PrimitiveMan:DrawCirclePrimitive(self.rulerPosA, 3, color);
						PrimitiveMan:DrawCirclePrimitive(self.rulerPosB, 3, color);
						
						local maxi = math.floor((lineVec.Magnitude / 5) + 0.55)
						for i = 1, maxi do
							local point = self.rulerPosA + lineVec / maxi * i
							PrimitiveMan:DrawLinePrimitive(point, point, color);
						end
					end
					
					self.rulerAnim = (self.rulerAnim + rulerAnimTarget * TimerMan.DeltaTimeSecs * 12) / (1 + TimerMan.DeltaTimeSecs * 12);
					self.Frame = 9 + math.floor(self.rulerAnim + 0.55);
				end
			end
		elseif self.state == 2 then
			if self.blueprint then
				if self.blueprintType == 0 or self.blueprintType == 1 then -- Wood/Metal Plank/Bar
					-- default
					local rectRadius = 3
					local color = 5 --77
					local density = 1
					local chunkName = "Construction Wood Chunk"
					local chunkStep = 4
					local cost = 0.25
					local buildDelayM = 1 -- Multiplier
					
					if self.blueprintType == 1 then
						cost = 5
						rectRadius = 1.5
						density = 0.6
						chunkStep = 1
						--buildDelayM = buildDelayM * 2.0
						chunkName = "Construction Metal Chunk"
					end
					
					local build = false
					local progress = self.blueprintProgress
					if self:IsActivated() then
						if self.buildTimer:IsPastSimMS(self.buildDelay * buildDelayM) then
							build = true
							color = 4
							local sound
							if self.blueprintType == 0 then
								--sound = AudioMan:PlaySound("FGround.rte/Devices/Tools/BuilderKit/Sounds/BuildWood.wav", self.Pos);
								AudioMan:PlaySound("FGround.rte/Devices/Tools/BuilderKit/Sounds/BuildWood.wav", self.Pos);
							else
								--sound = AudioMan:PlaySound("FGround.rte/Devices/Tools/BuilderKit/Sounds/BuildMetal"..math.random(1,3)..".wav", self.Pos);
								AudioMan:PlaySound("FGround.rte/Devices/Tools/BuilderKit/Sounds/BuildMetal"..math.random(1,3)..".wav", self.Pos);
							end
							--AudioMan:SetSoundPitch(sound, RangeRand(0.9,1.1))
							
							self.buildTimer:Reset()
						end
					end
					
					local vec = SceneMan:ShortestDistance(self.blueprintPosA, self.blueprintPosB, SceneMan.SceneWrapsX);
					local maxj = math.max(math.floor((rectRadius * 2 * density / 5) + 0.55), 1) --rectRadius
					local maxi = math.floor(((vec.Magnitude+rectRadius) * density / 5) + 0.55) + maxj
					if self.blueprintType == 0 then maxj = maxj * 2.0 end
					maxi = maxi + maxj
					--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "x = ".. maxi, true, 0);
					--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "maxj = ".. maxj, true, 0);
					
					local pointA1 = self.blueprintPosA + Vector(-rectRadius,  rectRadius):RadRotate(vec.AbsRadAngle)
					local pointA2 = self.blueprintPosA + Vector(-rectRadius, -rectRadius):RadRotate(vec.AbsRadAngle)
					
					local pointB1 = self.blueprintPosB + Vector(rectRadius,  rectRadius):RadRotate(vec.AbsRadAngle)
					local pointB2 = self.blueprintPosB + Vector(rectRadius, -rectRadius):RadRotate(vec.AbsRadAngle)
					if not build then
						PrimitiveMan:DrawLinePrimitive(pointA1, pointA2, color);
						PrimitiveMan:DrawLinePrimitive(pointA1, pointB1, color);
						
						PrimitiveMan:DrawLinePrimitive(pointB2, pointB1, color);
						PrimitiveMan:DrawLinePrimitive(pointB2, pointA2, color);
					end
					--PrimitiveMan:DrawCirclePrimitive(self.blueprintPosA, rectRadius, color);
					--PrimitiveMan:DrawCirclePrimitive(self.blueprintPosB, rectRadius, color);
					
					if self.blueprintProgress >= (maxi*maxj) then
						self.blueprint = false
						if self.blueprintType == 1 then
							local toTerrainMO
							
							toTerrainMO = CreateMOSRotating("Construction Metal Chunk End");
							toTerrainMO.Pos = self.blueprintPosA
							toTerrainMO.RotAngle = vec.AbsRadAngle + math.pi * math.random(0,1)
							toTerrainMO.Frame = math.random(0, toTerrainMO.FrameCount - 1);
							MovableMan:AddParticle(toTerrainMO);
							toTerrainMO.ToSettle = true
							
							toTerrainMO = CreateMOSRotating("Construction Metal Chunk End");
							toTerrainMO.Pos = self.blueprintPosB
							toTerrainMO.RotAngle = vec.AbsRadAngle + math.pi * math.random(0,1)
							toTerrainMO.Frame = math.random(0, toTerrainMO.FrameCount - 1);
							MovableMan:AddParticle(toTerrainMO);
							toTerrainMO.ToSettle = true
						end
						
						AudioMan:PlaySound("Base.rte/Sounds/GUIs/PlacementThud"..math.random(1,2)..".wav", self.Pos);
					else
						
						--self.blueprintProgress
						for i = 1, (maxi*maxj) do
							--math.ceil((1 / maxi * i)) / maxj
							local point = self.blueprintPosA + vec / maxi * (i % maxi + 0.5) - Vector(0, rectRadius):RadRotate(vec.AbsRadAngle) + Vector(0, rectRadius * 2.0):RadRotate(vec.AbsRadAngle) * (math.ceil((1 / maxi * i)) - 0.5) / maxj
							
							if i > self.blueprintProgress and i <= (self.blueprintProgress+chunkStep) and build and ActivityMan:GetActivity():GetTeamFunds(actor.Team) >= cost then
								
								local toTerrainMO = CreateMOSRotating(chunkName);
								toTerrainMO.Pos = point
								toTerrainMO.RotAngle = vec.AbsRadAngle + math.pi * math.random(0,1)
								toTerrainMO.Frame = math.random(0, toTerrainMO.FrameCount - 1);
								MovableMan:AddParticle(toTerrainMO);
								toTerrainMO.ToSettle = true
								
								progress = progress + 1
								ActivityMan:GetActivity():SetTeamFunds(ActivityMan:GetActivity():GetTeamFunds(actor.Team) - cost, actor.Team)
							end
							if i >= (self.blueprintProgress+1) and i <= (self.blueprintProgress+chunkStep+2) and build and math.random(1,3) >= 2 then
								local poof = CreateMOSParticle("Small Smoke Ball 1");
								poof.Pos = point
								poof.Lifetime = poof.Lifetime * RangeRand(0.75, 1.5);
								poof.GlobalAccScalar = poof.GlobalAccScalar * RangeRand(0, 1);
								poof.IgnoreTerrain = true
								MovableMan:AddParticle(poof);
								
								local crap = CreateMOPixel(math.random(1,3) < 2 and "Drop Oil" or "Bone Particle");
								crap.Pos = point
								crap.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)) * 5
								crap.Lifetime = 500 * RangeRand(0.1, 1.0);
								crap.RestThreshold = -1000
								crap.IgnoreTerrain = true
								MovableMan:AddParticle(crap);
								
								local spark = CreateMOPixel("Spark Yellow "..math.random(1,2));
								spark.Pos = point
								spark.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)) * 5
								spark.Lifetime = 350 * RangeRand(0.1, 1.0);
								spark.RestThreshold = -1000
								spark.IgnoreTerrain = true
								MovableMan:AddParticle(spark);
							end
							
							--if i >= self.blueprintProgress then
							--	PrimitiveMan:DrawLinePrimitive(point, point, 122);
							--end
						end
						self.blueprintProgress = progress
					end
				end
			end
			
			self.Frame = 6 + self.hammerSkin
		end
	else
		-- Disable
		self.Frame = self.defaultFrame
		self.state = 0
	end
	
	if self.state == 0 then -- Toolbox
		self.JointOffset = Vector(0,-6)
		self.SupportOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
		
		self.StanceOffset = Vector(2,7)
		self.SharpStanceOffset = Vector(self.StanceOffset.X, self.StanceOffset.Y)
	elseif self.state == 1 then -- Ruler
		self.JointOffset = Vector(-1,0)
		if self:IsActivated() then
			self.SupportOffset = Vector(3 + (self.rulerAnim / self.rulerAnimMax * 6), 3)
		else
			self.SupportOffset = Vector(70, 70)
		end
		
		self.StanceOffset = Vector(7,7) + Vector((self.rulerAnim / self.rulerAnimMax * 2), 0)
		self.SharpStanceOffset = Vector(self.StanceOffset.X, self.StanceOffset.Y)
		
		self.RotAngle = self.RotAngle + self.FlipFactor * (self.rulerAnim / self.rulerAnimMax) * math.pi * 0.5
	elseif self.state == 2 then -- Hammer
	
		self.JointOffset = Vector(0,3)
		self.SupportOffset = Vector(500, 500)
		--self.SupportOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
		
		self.StanceOffset = Vector(5,9)
		self.SharpStanceOffset = Vector(self.StanceOffset.X, self.StanceOffset.Y)
	end
end