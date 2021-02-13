function Create(self)
	self.moID = -1
	self.InheritsRotAngle = true
end

function Update(self)

	if self:NumberValueExists("MOToFollow") then
		self.moID = self:GetNumberValue("MOToFollow")
		self:RemoveNumberValue("MOToFollow")
	end
	
	if self.moID ~= -1 then
		local MO = MovableMan:FindObjectByUniqueID(self.moID)
		if MO then
			MO = ToMOSRotating(MO)
			
			--self.InheritsRotAngle = false
			self:ClearForces()
			self:ClearImpulseForces()
			
			self.Frame = MO.Frame
			self.RotAngle = MO.RotAngle + math.pi * 0.5 * MO.FlipFactor
		else
			self.Frame = 0
			self.InheritsRotAngle = true
		end
	else
		self.Frame = 3
		self.InheritsRotAngle = true
	end
end