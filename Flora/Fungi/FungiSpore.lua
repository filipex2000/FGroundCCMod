function Create(self)
	self.checkForSoil = false
	
	self.stuckTimer = Timer()
end

function Update(self)
	self.ToSettle = false;
	self.ToDelete = false;
	
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 1, (self.grow and 162 or 13));
	
	if self.checkForSoil then
		
		local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(math.random(-4,4), math.random(-4,4))
		local material = SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y))
		if material ~= 0 then
			
			self.ToDelete = true
			
			local direction = math.pi * 0.5
			
			local normal = Vector()
			local maxi = 8
			for i = 1, maxi do
				local vec =Vector(3,0):RadRotate(math.pi * 2 * (i / maxi))
				local checkPos = self.Pos + vec
				local checkPix = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
				if checkPix == 0 then
					normal = normal + vec
				end
			end
			direction = normal.AbsRadAngle
			
			toTerrainMO = CreateMOSRotating("Fungi Neck");
			toTerrainMO.Pos = self.Pos
			toTerrainMO.RotAngle = direction + math.rad(RangeRand(-1,1) * 5.0) 
			toTerrainMO.HFlipped = math.random(1,2) < 2
			toTerrainMO.Frame = 0
			toTerrainMO:SetNumberValue("Iteration", 0)
			MovableMan:AddParticle(toTerrainMO);
			--toTerrainMO.ToSettle = true
			toTerrainMO:EraseFromTerrain()
		end
	end
	
	if self.stuckTimer:IsPastSimMS(3600) then
		self.ToDelete = true
	end
end

function OnCollideWithTerrain(self, terrainID)
	self.checkForSoil = true
end