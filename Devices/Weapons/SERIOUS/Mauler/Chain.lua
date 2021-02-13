
function Create(self)
	self.linkID = nil -- The MO we are connected to
	self.linked = false -- Unnecessary variable, might be used for chain link break SFX/GFX
	
	self.linkID = self.Sharpness -- Get the link connection ID from sharpness TODO: replace it with NumberValue, currently MOPixels and MOSParticles doesn't support it!
	self.Sharpness = 25
	
	self.AirResistance = self.AirResistance * RangeRand(0.5,2) -- Randomize air resistance, the chain comes in cooler shapes
	
	self.soundCollide = CreateSoundContainer("Mauler Chain Collide", "FGround.rte");
	self.soundCollide.AffectedByGlobalPitch = false
	
	self.soundBreak = CreateSoundContainer("Mauler Chain Break", "FGround.rte");
	
	self.Frame = math.random(0, self.FrameCount - 1); -- Randomize frame
end

function Update(self)
	if self.Age > 5000 then
		self.linkID = nil -- Performance fix!
		return
	end
	
	self.PinStrength = 0 -- Remove pin
	
	self.Sharpness = math.max(self.Sharpness - TimerMan.DeltaTimeSecs * math.random(15,40), 0) -- Lower sharpness
	
	if self.linkID then
		local MO = MovableMan:FindObjectByUniqueID(self.linkID)
		if MO then -- Joint Physics
			local p1 = self.Pos
			local p2 = MO.Pos
			local dif = SceneMan:ShortestDistance(p1,p2,SceneMan.SceneWrapsX)
			
			--- Spring Joint
			-- Apply a force proportional to the distance between two MOs
			local maxLength = 2
			local maxForce = 6
			local forceMultiplier = 10
			local str = math.min(math.max((dif.Magnitude / maxLength) - 1, 0), maxForce) * TimerMan.DeltaTimeSecs * forceMultiplier
			
			self.Vel = self.Vel + dif * str
			MO.Vel = MO.Vel - dif * str
			
			--- Distance Joint
			-- Limit distance between two MOs
			local maxDistance = 4
			local dst = SceneMan:ShortestDistance(self.Pos, MO.Pos, SceneMan.SceneWrapsX)
			self.Pos = MO.Pos - dst:SetMagnitude(math.min(dst.Magnitude, maxDistance));
			
			--- Distance Damp Joint
			-- Apply a force proportional to the velocity difference between MOs
			local dampMultiplier = 0.2
			local damp = (self.Vel - MO.Vel).Magnitude * TimerMan.DeltaTimeSecs * dampMultiplier
			self.Vel = self.Vel * (1 - damp)
			MO.Vel = MO.Vel * (1 - damp)
			
			self.linked = true
		else
			if self.linked then
				-- Joint has been broken!
				self.linkID = nil
				self.linked = false
				--self.Vel = self.Vel * 0.2
				if self.Vel.Magnitude > 2 then
					self.soundBreak:Play(self.Pos);
				end
			end
		end
	end
end

function OnCollideWithTerrain(self, terrainID) -- Go kabloow
	self.Sharpness = self.Sharpness * 0.3; -- Reduce terrain rape!
	if self.Vel.Magnitude > 4 and math.random(1,3) < 2 then
		--AudioMan:SetSoundPitch(AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Mauler/Sounds/ChainCollide"..math.random(1,3)..".wav", self.Pos), RangeRand(0.8,1.5))
		self.soundCollide.Volume = 0.1
		self.soundCollide.Pitch = RangeRand(0.95,1.05)
		self.soundCollide:Play(self.Pos);
	end
end