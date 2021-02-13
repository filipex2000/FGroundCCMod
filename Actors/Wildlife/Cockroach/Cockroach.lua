
function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function playVocal(self, name, priority)
	if self.vocalSound == nil or not self.vocalSound:IsBeingPlayed() or (self.vocalSound:IsBeingPlayed() and self.vocalPriority < priority) then
		self.vocalSound = AudioMan:PlaySound(name, self.Pos, -1, 0, 130, 1, 400, false);
		self.vocalPriority = priority
	end
end

function playVocalContainer(self, container, priority)
	if self.vocalSound == nil or not self.vocalSound:IsBeingPlayed() or (self.vocalSound:IsBeingPlayed() and self.vocalPriority < priority) then
		self.vocalSound = AudioMan:PlaySound(string.insert(container["Path"], container["Variations"] > 1 and math.random(1, container["Variations"]) or "", -5), self.Pos, -1, 0, 130, 1, 400, false);
		self.vocalPriority = priority
	end
end

function Create(self)
	self.lastHealth = self.Health - 0
	
	-- Sounds Start
	
	self.vocalSound = nil
	self.vocalPriority = 0
	
	self.painSounds = {["Variations"] = 3,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/Pain.wav"};
	
	
	self.turnSounds = {["Variations"] = 2,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/Turn.wav"};
	
	self.jumpSounds = {["Variations"] = 3,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/Jump.wav"};
	
	
	self.chatterSounds = {["Variations"] = 4,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/Chatter.wav"};
	
	self.idleSounds = {["Variations"] = 4,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/Idle.wav"};
	
	self.idleUncommonSounds = {["Variations"] = 4,
	["Path"] = "FGround.rte/Actors/Wildlife/Cockroach/Sounds/IdleRare.wav"};
	
	self.idleSoundTimer = Timer()
	self.idleSoundDelay = math.random(700,5000)
	
	self.lastFlipFactor = self.FlipFactor
	
	-- Sounds End
	
	
	-- Movement Start
	--[[
	self.fakeLegUniqueIDs = {}
	self.legUniqueIDs = {}
	
	local i = 0
	for attachable in self.Attachables do
		i = i + 1
		if string.find(attachable.PresetName, "Leg Middle") then
			self.fakeLegUniqueIDs[i] = attachable.UniqueID
			attachable.Frame = 3
			print(attachable)
		elseif string.find(attachable.PresetName, "Leg") then
			self.legUniqueIDs[i] = attachable.UniqueID
		end
	end]]
	
	fakeLegs = {}
	legs = {}
	
	self.Normal = Vector(0,1)
	
	for attachable in self.Attachables do
		if string.find(attachable.PresetName, "Leg Middle") then
			table.insert(fakeLegs, attachable)
			attachable.Frame = 3
		elseif string.find(attachable.PresetName, "Leg") then
			table.insert(legs, attachable)
			--print(ToAttachable(attachable).InheritsRotAngle)
		end
	end
	
	for i = 1, #fakeLegs do
		fakeLegs[i]:SetNumberValue("MOToFollow", legs[math.random(1,#legs)].UniqueID)
	end
	
	-- Movement End
	
	-- AI Start
	self.AISticky = math.random(1,2) < 2
	-- AI End
end

function Update(self)
	if self.Status == Actor.DEAD or self.Status == Actor.DYING then 
		if self.vocalSound ~= nil then
			self.vocalSound:Stop()
			self.vocalSound = nil
		end
		return
	end
	
	local ctrl = self:GetController()
	local player = false
	if self:IsPlayerControlled() then
		player = true
	end
	
	if self.vocalSound then
		self.vocalSound:SetPosition(self.Pos)
	end
	
	if self.lastHealth > self.Health then
		local diff = math.abs(self.lastHealth - self.Health)
		
		if diff > 3 then
			playVocalContainer(self, self.painSounds, 5)
		end
		
		self.lastHealth = self.Health - 0
	end
	
	if ctrl:IsState(Controller.BODY_JUMPSTART) then
		playVocalContainer(self, self.jumpSounds, math.max(self.vocalPriority - 1, 2))
	end
	
	if self.idleSoundTimer:IsPastSimMS(self.idleSoundDelay) then
		if math.random(1,4) < 2 then
			playVocalContainer(self, self.idleUncommonSounds, 1)
		else
			if math.random(1,2) < 2 then
				playVocalContainer(self, self.chatterSounds, 1)
			else
				playVocalContainer(self, self.idleSounds, 1)
			end
		end
		self.idleSoundTimer:Reset()
		self.idleSoundDelay = math.random(700,5000)
	end
	
	if self.lastFlipFactor ~= self.FlipFactor then
		if self.idleSoundTimer:IsPastSimMS(self.idleSoundDelay * 0.75) then
			
			playVocalContainer(self, self.turnSounds, 2)
			self.idleSoundTimer:Reset()
			self.idleSoundDelay = math.random(700,5000)
		end
		
		self.lastFlipFactor = self.FlipFactor
	end
	
	-- Stick to surfaces + movement
	
	local input = 0
	if ctrl:IsState(Controller.MOVE_LEFT) then
		input = -1
	elseif ctrl:IsState(Controller.MOVE_RIGHT) then
		input = 1
	end
	
	if self.Status == 0 and (player and ctrl:IsState(Controller.MOVE_DOWN)) or (not player and self.AISticky) then
		local detections = 0
		local maxi = 10
		for j = -1, 0 do
			for i = 0, maxi do
				local checkVec = Vector(self.Radius * (1.2 + 0.3 * j),0):RadRotate(math.pi * 2 / maxi * i) 
				--checkVec = Vector(checkVec.X * 1.2, checkVec.Y)
				checkVec:RadRotate(self.RotAngle)
				
				local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + checkVec + Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.3 + Vector(0,3):RadRotate(self.RotAngle) 
				local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
				
				if checkPix > 0 then
					if detections < 1 then
						self.Normal = checkVec
					else
						self.Normal = self.Normal + checkVec
					end
					detections = detections + 1
				--	PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 5)
				--else
				--	PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 13)
				end
			end
		end
		if detections > 0 then
			self.Normal = self.Normal / detections
			--PrimitiveMan:DrawLinePrimitive(Vector(self.Pos.X, self.Pos.Y), Vector(self.Pos.X, self.Pos.Y) + self.Normal, 5)
			
			-- Balance
			local min_value = -math.pi;
			local max_value = math.pi;
			local value = self.RotAngle - (Vector(self.Normal.X,self.Normal.Y):RadRotate(math.pi * 0.5)).AbsRadAngle;
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
			
			if input ~= 0 then
				local force = Vector(25 * input, -5):RadRotate((Vector(self.Normal.X,self.Normal.Y):RadRotate(math.pi * 0.5)).AbsRadAngle)
				--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + force, 122)
				
				self.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(-self.RotAngle)
				self.Vel = Vector(self.Vel.X / (1 + TimerMan.DeltaTimeSecs * 4), self.Vel.Y):RadRotate(self.RotAngle)
				
				self.Vel = self.Vel + force * TimerMan.DeltaTimeSecs
			end
			
			local a = self.Vel.Magnitude * 0.3
			self.RotAngle = (self.RotAngle - result * TimerMan.DeltaTimeSecs * (4 + a))
			self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * (8 + a))-- - self.Vel.X * TimerMan.DeltaTimeSecs * 6
			self.AngularVel = (self.AngularVel - result * 1.0 * TimerMan.DeltaTimeSecs * (15 + a))
			
			self.Vel = self.Vel - SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
			self.Vel = self.Vel + Vector(SceneMan.GlobalAcc.X, SceneMan.GlobalAcc.Y):RadRotate((Vector(self.Normal.X,self.Normal.Y):RadRotate(math.pi * 0.5)).AbsRadAngle) * TimerMan.DeltaTimeSecs * 1.5
		end
	end
end

function Destroy(self)
	for attachable in self.Attachables do
		attachable:GibThis()
	end
end