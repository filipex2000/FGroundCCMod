function Create(self)
	self.rotation = -math.pi * 0.5
end

function Update(self)
	if self.RootID == nil or self.RootID == rte.NoMOID then
		self:GibThis()
		return
	end
	
	if self:NumberValueExists("Rotation") then
		self.rotation = self:GetNumberValue("Rotation")
		self:RemoveNumberValue("Rotation")
	end
	--self.rotation = self.rotation + TimerMan.DeltaTimeSecs * 3
	self.RotAngle = self.rotation + (self.HFlipped and math.pi or 0)
	--print(self.RotTarget)
	self.RotTarget = self.rotation + (self.HFlipped and math.pi or 0)
end