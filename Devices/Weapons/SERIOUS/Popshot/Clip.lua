
function Create(self)
	self.clipHitSound = CreateSoundContainer("Clip Hit Popshot", "FGround.rte");
	self.playSound = true;	
end

function OnCollideWithTerrain(self, terrainID)
	
	if self.playSound == true then
	
		self.playSound = false;
	
		self.clipHitSound:Play(self.Pos)

	end

end