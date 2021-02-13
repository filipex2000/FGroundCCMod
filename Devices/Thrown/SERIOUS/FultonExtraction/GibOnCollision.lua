function Create(self)
end

function OnCollideWithTerrain(self, terrainID)
	self:GibThis()
end