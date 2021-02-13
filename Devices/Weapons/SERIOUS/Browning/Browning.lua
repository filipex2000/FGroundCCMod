function Create(self)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	
	self.deployCounter = 0
	self.deployDuration = 1000
	
	self.delayedFireTimer = Timer()
	self.delayedFireTime = 100
	self.delayedFirePre = false
	self.delayedFirePreSound = CreateSoundContainer("Pre Browning", "FGround.rte");
	
	self.maxRateOfFire = self.RateOfFire
	self.minRateOfFire = self.RateOfFire - 300
	
	self.lastHFlipped = self.HFlipped
	
	self.deployed = false
	self.deploying = false
	
	self.deploySound = CreateSoundContainer("Deploy Browning", "FGround.rte");
	self.deployFinishSound = CreateSoundContainer("Deploy Finish Browning", "FGround.rte");
	
	self.undeploySound = CreateSoundContainer("Undeploy Browning", "FGround.rte");
	self.undeploy = true
	self.undeployFinishSound = CreateSoundContainer("Undeploy Finish Browning", "FGround.rte");
	self.undeployFinish = true
	
	self.fireStartSound = CreateSoundContainer("Mech Start Browning", "FGround.rte");
	self.fireStart = true
	
	self.fireNoiseSound = CreateSoundContainer("Noise Browning", "FGround.rte");
	
	
	self.attachableTable = {}
	for attachable in self.Attachables do
		self.attachableTable[#self.attachableTable + 1] = attachable
	end
end
function Update(self)
	local parent = self:GetRootParent();
	local playerControlled;
	if IsActor(parent) then
		parent = ToActor(parent);
		playerControlled = parent:IsPlayerControlled();
	else
		parent = nil;
	end
	
	if self.lastHFlipped ~= self.HFlipped then
		self.deployed = false
		self.deployCounter = self.deployCounter * 0.5
		self.lastHFlipped = self.HFlipped
	end
	
	if parent then
		local activated = self:IsActivated()
		local controller = parent:GetController()
		
		local isMoving = controller:IsState(Controller.MOVE_LEFT) == true or controller:IsState(Controller.MOVE_RIGHT) == true
		
		-- Limited aim
		if self.deployed then
			-- Frotate
			local min_value = -math.pi;
			local max_value = math.pi;
			local value = self.RotAngle -- (self.HFlipped and math.pi or 0)
			local result;
			
			local range = max_value - min_value;
			if range <= 0 then
				result = min_value;
			else
				local ret = (value - min_value) % range;
				if ret < 0 then ret = ret + range end
				result = ret + min_value;
			end
			
			local range = math.rad(45)
			self.RotAngle = math.max(math.min(result, range), -range) --+ (self.HFlipped and math.pi or 0)
		end
		local deployedPos = parent.Pos + Vector(26 * self.FlipFactor, 0) + Vector(6 * self.FlipFactor, -2):RadRotate(self.RotAngle)
		
		if (activated or (not isMoving and controller:IsState(Controller.AIM_SHARP))) then
			if self.deployed then
				self.deploying = false
			else
				if isMoving then
					controller:SetState(Controller.MOVE_LEFT, false)
					controller:SetState(Controller.MOVE_RIGHT, false)
				end
				if not self.deploying then
					self.deploying = true
					self.deploySound:Play()
				end
			end
		else
			if self.deployed then
				if isMoving then
					self.deployed = false
				end
			else
				self.deploying = false
			end
		end
		
		if self.deployed then
			
		else
			controller:SetState(Controller.AIM_SHARP, false)
			
			if self.deploying and self.Vel.Magnitude < 3 then
				self.deployCounter = math.min(self.deployCounter + TimerMan.DeltaTimeSecs * 1000, self.deployDuration + 200)
				self.undeployFinish = true
				self.undeploy = true
			else
				self.deployCounter = math.max(self.deployCounter - TimerMan.DeltaTimeSecs * 1000, 0)
				if self.undeploy then
					self.undeploySound:Play(self.Pos)
					self.undeploy = false
				end
				if self.undeployFinish and self.deployCounter <= 200 then
					self.undeployFinishSound:Play(self.Pos)
					self.undeploySound:Stop(-1)
					self.undeployFinish = false
				end
			end
			if self.deployCounter >= self.deployDuration then
				self.deployed = true
				if self.deploying then
					self.deployFinishSound:Play()
					self.deploySound:Stop(-1)
					self.deploying = false
				end
			end
		end
		
		if not self.deployed then
			self:Deactivate()
		end
		
		if self:IsActivated() then
			if not self.delayedFireTimer:IsPastSimMS(self.delayedFireTime) then
				self:Deactivate()
				if self.delayedFirePre then
					self.delayedFirePreSound:Play(self.Pos)
					self.delayedFirePre = false
				end
			end
			
			if self.FiredFrame and self.fireStart then
				self.fireStart = false
				self.fireStartSound:Play(self.Pos)
				
				self.fireNoiseSound:Stop(-1)
				self.fireNoiseSound.Pitch = 0.85
				self.fireNoiseSound:Play(self.Pos)
			end
			
			controller:SetState(Controller.MOVE_LEFT, false)
			controller:SetState(Controller.MOVE_RIGHT, false)
			
			self.RateOfFire = math.min(self.RateOfFire + TimerMan.DeltaTimeSecs * 150, self.maxRateOfFire)
		else
			self.delayedFirePre = true
			self.delayedFireTimer:Reset()
			
			self.fireStart = true
			
			self.RateOfFire = math.max(self.RateOfFire - TimerMan.DeltaTimeSecs * 250, self.minRateOfFire)
		end
		
		if self.deployed then
			--local factorSin = math.sin(self.RotAngle)
			--local factorCos = math.cos(self.RotAngle)
			
			--local offset = Vector(math.abs(factorSin * 5), math.abs(factorSin) * 10)
			
			--self.StanceOffset = Vector(self.originalStanceOffset.X ,self.originalStanceOffset.Y):RadRotate(-self.RotAngle * self.FlipFactor) + offset
			--self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X ,self.originalSharpStanceOffset.Y):RadRotate(-self.RotAngle * self.FlipFactor) + offset
			
			
			self.Pos = deployedPos
		else
			local stanceOffset = Vector(5, 5)
			
			self.StanceOffset = Vector(stanceOffset.X ,stanceOffset.Y):RadRotate(-self.RotAngle * self.FlipFactor)
			self.SharpStanceOffset = Vector(stanceOffset.X ,stanceOffset.Y):RadRotate(-self.RotAngle * self.FlipFactor)
			
			local factor = math.sin((1 - (self.deployCounter / self.deployDuration)) * math.pi * 0.5)
			
			local total = (- self.RotAngle + math.rad(125) * self.FlipFactor) * factor
			
			self.RotAngle = self.RotAngle + total;
			
			local jointOffset = Vector(self.originalJointOffset.X * self.FlipFactor, self.originalJointOffset.Y):RadRotate(self.RotAngle);
			local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
			self.Pos = self.Pos + offsetTotal-- * factor;
			
			local dif = SceneMan:ShortestDistance(parent.Pos, self.Pos,SceneMan.SceneWrapsX)
			self.Pos = self.Pos - dif
			dif:SetMagnitude(math.min(dif.Magnitude, 22))
			self.Pos = self.Pos + dif
			
			self.Pos = self.Pos + SceneMan:ShortestDistance(self.Pos, deployedPos,SceneMan.SceneWrapsX) * math.pow(1 - factor,3)
		end
	end
	
	for i, attachable in ipairs(self.attachableTable) do
		if attachable and IsAttachable(attachable) then
			attachable = ToAttachable(attachable)
			attachable.RotAngle = self.RotAngle
			
			local isLeg = false
			local side = 0
			if attachable.PresetName == "Leg Browning Left" then
				isLeg = true
				side = -1
			elseif attachable.PresetName == "Leg Browning Right" then
				isLeg = true
				side = 1
			elseif attachable.PresetName == "Leg Browning BG" or attachable.PresetName == "Leg Browning" or attachable.PresetName == "Leg Browning Middle" then
				isLeg = true
			end
			
			if isLeg then
				local factor = math.sin((1 - (self.deployCounter / self.deployDuration)) * math.pi * 0.5)
				-- Frotate
				local min_value = -math.pi;
				local max_value = math.pi;
				local value = self.RotAngle -- (self.HFlipped and math.pi or 0)
				local result;
				
				local range = max_value - min_value;
				if range <= 0 then
					result = min_value;
				else
					local ret = (value - min_value) % range;
					if ret < 0 then ret = ret + range end
					result = ret + min_value;
				end
				
				if side ~= 0 and not attachable:NumberValueExists("Arc") then
					attachable:SetNumberValue("Arc", 35)
				end
				local arc = side == 0 and 0 or attachable:GetNumberValue("Arc")
				
				attachable.RotAngle = (math.rad(arc) * side) * (1 - factor) + (value + math.rad(90) * (side ~= 0 and side or -self.FlipFactor)) * factor
				
				local h = (side ~= 0 and 14 or 11)
				
				local lengthMax = h * (1 - math.pow(factor, 2))
				local length = lengthMax
				local jointOffset = Vector(attachable.JointOffset.X * self.FlipFactor, attachable.JointOffset.Y):RadRotate(attachable.RotAngle)
				local parentOffset = Vector(attachable.ParentOffset.X * self.FlipFactor, attachable.ParentOffset.Y):RadRotate(self.RotAngle)
				
				if parent then
					local castVec = Vector(0, lengthMax * 2):RadRotate(attachable.RotAngle)
					--PrimitiveMan:DrawLinePrimitive(self.Pos + parentOffset, self.Pos + parentOffset + castVec, 13);
					length = SceneMan:CastObstacleRay(self.Pos + parentOffset, castVec, Vector(0, 0), Vector(), parent.ID, parent.Team, 0, 1) -- Do the hitscan stuff, raycast
					if length == -1 or lengthMax <= 1 then
						length = lengthMax
					else
						length = length - h
					end
					if attachable:NumberValueExists("Arc") then
						arc = math.min(math.max(arc - 100 * TimerMan.DeltaTimeSecs + math.abs((1 - length / h) * 300) * TimerMan.DeltaTimeSecs, 5), 90)
						attachable:SetNumberValue("Arc", arc)
					end
					--print()
				end
				attachable.JointOffset.Y = (attachable.JointOffset.Y + (-length + 4 * factor) * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10)
			end
			attachable.Pos = self.Pos + Vector(attachable.ParentOffset.X * self.FlipFactor, attachable.ParentOffset.Y):RadRotate(self.RotAngle) - Vector(attachable.JointOffset.X * self.FlipFactor, attachable.JointOffset.Y):RadRotate(attachable.RotAngle)
		else
			print("ERROR, MO FOR ROTATION MISSING: "..i)
		end
	end
end

function OnAttach(self)
	self.undeployFinishSound:Play(self.Pos)
end

function OnDetach(self)
	self.deployed = false
	self.deployCounter = 0
end