

function Create(self)
	self.Frame = 0
	self.grow = true
	if self.PresetName == "Fungi Neck" then
		self.growTime = 300
	else
		self.growTime = 150
	end
end

function Update(self)
	self.Frame = math.min(math.floor((self.FrameCount - 1) * self.Age / self.growTime + 0.5), (self.FrameCount - 1))
	if self.Age > self.growTime then
		self.PinStrength = 0
		if self.grow then
			if self.PresetName == "Fungi Neck" then
				if self:GetNumberValue("Iteration") < 4 then
					toTerrainMO = CreateMOSRotating("Fungi Neck");
					toTerrainMO.Pos = self.Pos + Vector(self.Radius * RangeRand(0.75,1.25), 0):RadRotate(self.RotAngle)
					toTerrainMO.RotAngle = self.RotAngle + math.rad(RangeRand(-1,1) * 5.0 * math.random(1,3)) 
					toTerrainMO.HFlipped = false--self.HFlipped
					toTerrainMO:SetNumberValue("Iteration", self:GetNumberValue("Iteration") + 1)
					toTerrainMO.Frame = 0
					MovableMan:AddParticle(toTerrainMO);
					--toTerrainMO.ToSettle = true
					--toTerrainMO:EraseFromTerrain()
				else
					toTerrainMO = CreateMOSRotating("Fungi Head");
					toTerrainMO.Pos = self.Pos + Vector(self.Radius, 0):RadRotate(self.RotAngle)
					toTerrainMO.RotAngle = self.RotAngle + math.rad(RangeRand(-1,1) * 5.0) 
					toTerrainMO.HFlipped = self.HFlipped
					toTerrainMO.Frame = 0
					MovableMan:AddParticle(toTerrainMO);
				end
			else
				AudioMan:PlaySound("FGround.rte/Flora/Shared/Sounds/Pop.wav", self.Pos, -1, 0, 130, 1.2, 250, false)
			end
			self.grow = false
		end
		self.ToSettle = true
		if self.Age > self.growTime * 3 then
			self.GlobalAccScalar = 1.0
		else
			self.Vel = Vector(0, 0)
		end
	else
		self.ToSettle = false
	end
end