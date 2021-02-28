function Create(self)
	self.parentSet = false;
	
	local startVel = Vector(0,0)
	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsActor(actor) then
		startVel = Vector(actor.Vel.X, actor.Vel.Y)
	end
	
	self.chutePoints = {}
	local maxi = 7
	for i = 1, maxi do
		local point = {}
		
		local posOffsetX = ((i-1) / (maxi-1) - 0.5) * 2 * 20
		point.Pos = Vector(self.Pos.X + posOffsetX, self.Pos.Y - 10)
		point.Vel = startVel--Vector(0,0)
		point.AirResistance = RangeRand(3,5)
		point.AirDrag = 7.5
		
		point.IsConnectedToRoot = i <= 1 or i >= maxi
		point.Stuck = false
		
		point.ConnectedPointsID = {}
		
		point.ConnectedPointsID[1] = i+1
		point.ConnectedPointsID[2] = i-1
		
		for j, ID in ipairs(point.ConnectedPointsID) do
			if ID < i or ID > maxi then
				point.ConnectedPointsID[j] = nil
			end
		end
		
		self.chutePoints[i] = point
	end
	
	self.chuteCloth = {}
	for i = 1, (#self.chutePoints-1) do
		local cloth = CreateAttachable("Parachute Cloth")
		self:AddAttachable(cloth)
		table.insert(self.chuteCloth, cloth.UniqueID)
	end
	
	-- Point-Root joints
	self.chuteRootJointMaxLength = 45
	
	-- Point-Point joints
	self.chuteSpringJointMaxLength = 5
	self.chuteSpringJointMaxForce = 6
	self.chuteSpringJointForceMultiplier = 10
	
	self.landed = false
	self.landedDetachTimer = Timer()
	self.landedDetachDelay = 1000
	
	self.pulling = false
	
	
	self.pullSound = CreateSoundContainer("Pull Parachute", "FGround.rte");
	self.landSound = CreateSoundContainer("Land Parachute", "FGround.rte");
	self.loopSound = CreateSoundContainer("Loop Parachute", "FGround.rte");
	
	self.loopSound:Play(self.Pos)
end

function Update(self)

	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsActor(actor) then
			self.parent = ToActor(actor);
			self.parentSet = true;
		end
	end
	
	self.loopSound.Pos = self.Pos
	
	if self.parent then
		self.parent:GetController():SetState(Controller.BODY_JUMP, false);
		self.parent:GetController():SetState(Controller.BODY_JUMPSTART, false)
		if IsAHuman(self.parent) then
			self.parent = ToAHuman(self.parent)
			--self.FGFoot 
			if ToAHuman(self.parent).Jetpack then
				ToAHuman(self.parent).Jetpack:EnableEmission(false)
			end
			
			local inputLeft = self.parent:GetController():IsState(Controller.HOLD_LEFT)
			local inputRight = self.parent:GetController():IsState(Controller.HOLD_RIGHT)
			if inputLeft or inputRight then
				if not self.pulling then
					self.pullSound:Play(self.Pos)
					self.pulling = true
				end
				
				local pullVel = 20
				if inputRight then
					self.parent.Vel = Vector(self.parent.Vel.X + (pullVel - math.max(math.min(self.parent.Vel.X, pullVel), 0)) * TimerMan.DeltaTimeSecs, self.parent.Vel.Y)
				elseif inputLeft then
					self.parent.Vel = Vector(self.parent.Vel.X - (pullVel + math.max(math.min(self.parent.Vel.X, 0), -pullVel)) * TimerMan.DeltaTimeSecs, self.parent.Vel.Y)
				end
			else
				self.pulling = false
			end
		end
		
		if not self.landed and SceneMan:FindAltitude(self.Pos, 35, 3) < 30 then
			self.landSound:Play(self.Pos)
			self.landed = true
			
			self.parent.Vel = Vector(0,0)
		end
		--self.parent.Vel = self.parent.Vel - SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
	end
	
	if self.landed then
		if self.landedDetachTimer:IsPastSimMS(self.landedDetachDelay) then
			--if self:IsAttached() then ToMOSRotating(self:GetParent()):RemoveAttachable(self, true, false) end
			if self.landedDetachTimer:IsPastSimMS(self.landedDetachDelay + 4000) then
				self:GibThis()
			end
		end
		
		self.loopSound:Stop(-1);
	else
		self.landedDetachTimer:Reset()
	end
	
	
	
	-- Simulate the "parachute points"
	for i, point in ipairs(self.chutePoints) do
		
		--PrimitiveMan:DrawCirclePrimitive(point.Pos, 1, 5)
		if point.ConnectedPointsID and #point.ConnectedPointsID > 0 then
			for j, ID in ipairs(point.ConnectedPointsID) do
			
				if ID and self.chutePoints[ID] then
					local connectedPoint = self.chutePoints[ID]
					local dif = SceneMan:ShortestDistance(point.Pos, connectedPoint.Pos, SceneMan.SceneWrapsX)
					
					--- Spring Joint
					-- Apply a force proportional to the distance between two MOs
					local str = math.min(math.max((dif.Magnitude / self.chuteSpringJointMaxLength) - 1, 0), self.chuteSpringJointMaxForce) * TimerMan.DeltaTimeSecs * self.chuteSpringJointForceMultiplier * 0.5
					
					point.Vel = point.Vel + dif * str
					connectedPoint.Vel = connectedPoint.Vel - dif * str
					
					--PrimitiveMan:DrawLinePrimitive(point.Pos, point.Pos + dif, 5)
					
					-- Drag???
					local angle = dif.AbsRadAngle
					local newVel = Vector(point.Vel.X, point.Vel.Y):RadRotate(-angle)
					newVel = Vector(newVel.X, newVel.Y / (1 + TimerMan.DeltaTimeSecs * point.AirDrag))
					point.Vel = Vector(newVel.X, newVel.Y):RadRotate(angle)
				end
			end
			
		end
		
		if point.IsConnectedToRoot then
			PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + SceneMan:ShortestDistance(self.Pos, point.Pos, SceneMan.SceneWrapsX), 203)
			
			local root = self.parent or self
			if root then
				local dif = SceneMan:ShortestDistance(point.Pos, root.Pos, SceneMan.SceneWrapsX)
				
				local ropeLength = self.chuteRootJointMaxLength
				if self.parent and IsAHuman(self.parent) then
					local factor = ((i-1) / (#self.chutePoints-1) - 0.5) * 2
					if self.parent:GetController():IsState(Controller.HOLD_RIGHT) and factor < 0 then
						ropeLength = ropeLength - ropeLength * 0.2
					elseif self.parent:GetController():IsState(Controller.HOLD_LEFT) and factor > 0 then
						ropeLength = ropeLength - ropeLength * 0.2
					end
				end
				
				--- Spring Joint
				-- Apply a force proportional to the distance between two MOs
				local str = math.min(math.max((dif.Magnitude / ropeLength) - 1, 0), self.chuteSpringJointMaxForce) * TimerMan.DeltaTimeSecs * self.chuteSpringJointForceMultiplier
				
				local mass = (math.min(math.max(root.Mass / 30, 2.6), 6) + 3) * 0.5
				point.Vel = point.Vel + dif * str * mass
				root.Vel = root.Vel - dif * str / mass
				
				--- Distance Joint
				-- Limit distance between two MOs
				--root.Pos = point.Pos + Vector(dif.X, dif.Y):SetMagnitude(math.min(dif.Magnitude, ropeLength + 5));
				
				-- Pull left and right to fix bullshit issues I don't want to talk about
				if not self.landed then
					local factor = ((i-1) / (#self.chutePoints-1) - 0.5) * 2
					point.Vel = Vector(point.Vel.X, point.Vel.Y) + Vector(0, math.min(root.Vel.Magnitude, 25) * factor * 0.4):RadRotate((root.Vel + SceneMan.GlobalAcc).AbsRadAngle)
				end
			end
		end
		if not self.landed then
			point.Vel = point.Vel / (1 + TimerMan.DeltaTimeSecs * point.AirResistance) -- Air Friction
		end
		
		point.Vel = point.Vel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs -- Gravity
		
		if not point.Stuck then
			point.Pos = point.Pos + point.Vel * GetPPM() * TimerMan.DeltaTimeSecs -- Move/Travel
			
			point.Stuck = SceneMan:GetTerrMatter(point.Pos.X, point.Pos.Y) ~= 0
		else
			--point.IsConnectedToRoot = false
			point.Vel = Vector(0,0) -- Stuck/Pinned
			if not self.landed then
				self.landSound:Play(self.Pos)
				self.landed = true
			end
		end
	end
	
	for i, ID in ipairs(self.chuteCloth) do
		local MO = ToAttachable(MovableMan:FindObjectByUniqueID(ID))
		if MO and self.chutePoints[i] then
			local point1 = self.chutePoints[i]
			if self.chutePoints[i].ConnectedPointsID[1] then
				local point2 = self.chutePoints[point1.ConnectedPointsID[1]]
				local dif = SceneMan:ShortestDistance(point1.Pos, point2.Pos, SceneMan.SceneWrapsX)
				MO.Pos = point1.Pos + dif * 0.5
				MO.Frame = math.floor(math.min(dif.Magnitude, 20) * 0.5 + 0.55)
				MO.RotAngle = dif.AbsRadAngle + math.pi
			elseif self.chutePoints[i].ConnectedPointsID[2] then
				local point2 = self.chutePoints[point1.ConnectedPointsID[1]]
				local dif = SceneMan:ShortestDistance(point1.Pos, point2.Pos, SceneMan.SceneWrapsX)
				MO.Pos = point1.Pos + dif * 0.5
				MO.Frame = math.floor(math.min(dif.Magnitude, 20) * 0.5 + 0.55)
				MO.RotAngle = dif.AbsRadAngle + math.pi
			end
		end
	end
	
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + travel, 5)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5)
end

function Destroy(self)
	self.loopSound:Stop(-1);
end