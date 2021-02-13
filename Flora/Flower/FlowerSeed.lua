function Create(self)
	self.checkForSoil = false
	
	self.grow = false
	self.growAmout = math.random(15,25)
	self.growPos = Vector(math.floor(self.Pos.X), math.floor(self.Pos.Y))
	self.growTimer = Timer()
	self.growDelayMax = 60
	self.growDelayMin = 30
	self.growDelay = math.random(self.growDelayMax, self.growDelayMin)
	
	self.stuckTimer = Timer()
end

function Update(self)
	self.ToSettle = false;
	self.ToDelete = false;
	
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 1, (self.grow and 162 or 13));
	
	if self.checkForSoil and not self.grow then
		
		local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(math.random(-4,4), math.random(-4,4))
		local material = SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y))
		if string.find(material.PresetName,"Soil") or string.find(material.PresetName,"Topsoil") then
			self.grow = true
			self.growPos = Vector(math.floor(self.Pos.X), math.floor(self.Pos.Y))
			
			toTerrainMO = CreateMOSRotating("Flower Root");
			toTerrainMO.Pos = self.growPos + Vector(0,2)
			toTerrainMO.RotAngle = 0--math.random(1,4) * math.pi * 0.5
			toTerrainMO.HFlipped = math.random(1,2) < 2
			toTerrainMO.Frame = math.random(0, toTerrainMO.FrameCount - 1);
			MovableMan:AddParticle(toTerrainMO);
			toTerrainMO.ToSettle = true
			toTerrainMO:EraseFromTerrain()
		end
	elseif self.grow then
		if self.growAmout > 0 then
			if self.growTimer:IsPastSimMS(self.growDelay) then
				--print("growing...")
				local checkOrigin = Vector(self.growPos.X, self.growPos.Y) + Vector(math.random(-1,1), math.random(-1,0))
				local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
				local interrupted = SceneMan:GetMOIDPixel(checkOrigin.X, checkOrigin.Y) ~= 255
				
				--PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 5);
				--print(checkPix)
				if checkPix == 0 then
					self.growPos = Vector(checkOrigin.X, checkOrigin.Y)
					
					self.stuckTimer:Reset()
					
					local pixel = CreateMOPixel("Particle Flower Neck "..math.random(1,3));
					pixel.Pos = self.growPos
					pixel.Lifetime = 1000
					MovableMan:AddParticle(pixel)
					pixel.ToSettle = true
					
					self.growAmout = self.growAmout - 1
					
					self.growDelay = math.random(self.growDelayMax, self.growDelayMin)
				else
					self.growDelay = math.random(self.growDelayMax, self.growDelayMin) * 0.5
				end
				
				if interrupted then self.ToDelete = true end -- INTERSECTION WITH AN OBJECT
				
				self.growTimer:Reset()
			end
		else
			local toTerrainMO
			
			toTerrainMO = CreateMOSRotating("Flower Head");
			toTerrainMO.Pos = self.growPos
			toTerrainMO.RotAngle = math.random(1,4) * math.pi * 0.5
			toTerrainMO.HFlipped = math.random(1,2) < 2
			toTerrainMO.Frame = math.random(0, toTerrainMO.FrameCount - 1);
			MovableMan:AddParticle(toTerrainMO);
			toTerrainMO.ToSettle = true
			
			self.ToDelete = true
		end
	end
	
	if self.stuckTimer:IsPastSimMS(self.growDelayMax * 72) then
		self.ToDelete = true
	end
end

function OnCollideWithTerrain(self, terrainID)
	self.checkForSoil = true
	--self.grow = true
end