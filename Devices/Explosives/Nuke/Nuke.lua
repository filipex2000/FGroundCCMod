
function Create(self)
	self.soundFlyby = CreateSoundContainer("Flyby Nuke", "FGround.rte");
	self.soundFlyby:Play(self.Pos)
	
	self.GlobalAccScalar = 0.1
end

function Update(self)
	self.soundFlyby.Pos = self.Pos
	
	self.GlobalAccScalar = math.min(1.8, self.GlobalAccScalar + 1.5 * TimerMan.DeltaTimeSecs)
end

function Destroy(self)
	self.soundFlyby:Stop(-1)
end

function OnCollideWithMO(self, collidedMO, collidedRootMO)
	self:GibThis()
end

function OnCollideWithTerrain(self, terrainID)
	self:GibThis()
end