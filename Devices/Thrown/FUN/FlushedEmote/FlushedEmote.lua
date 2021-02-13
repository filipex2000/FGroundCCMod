function Create(self)

	self.Team = -1;
	
	self.Thrown = false
	self.SpawnCopy = true
end

function Update(self)
	if self.ID ~= self.RootID then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if MovableMan:IsActor(actor) then
			self.Team = ToActor(actor).Team;
		end
	end

	if self:IsActivated() and self.ID == self.RootID then
		if not self.Thrown then
			self.Thrown = true
		end
	end
end

function OnCollideWithMO(self, collidedMO, collidedRootMO)
	if self.Thrown then
		collidedMO = ToMOSRotating(collidedMO)
		if string.find(collidedMO.PresetName,"Head") then
			local mo = collidedMO
			
			local attachable = CreateAttachable(":flushed_mask:")
			mo:AddAttachable(attachable)
			
			if mo:NumberValueExists(":flushed:") then
				attachable.JointOffset.X = mo:GetNumberValue(":flushed:") * -1
			end
			mo:SetNumberValue(":flushed:", (mo:NumberValueExists(":flushed:") and mo:GetNumberValue(":flushed:") + 1 or 1))
		elseif IsAHuman(collidedMO) and ToAHuman(collidedMO).Head then
			local mo = ToAHuman(collidedMO).Head
			
			local attachable = CreateAttachable(":flushed_mask:")
			mo:AddAttachable(attachable)
			
			if mo:NumberValueExists(":flushed:") then
				attachable.JointOffset.X = mo:GetNumberValue(":flushed:") * -1
			end
			mo:SetNumberValue(":flushed:", (mo:NumberValueExists(":flushed:") and mo:GetNumberValue(":flushed:") + 1 or 1))
--[[seif ToAttachable(collidedMO):GetParent() and string.find(ToAttachable(collidedMO):GetParent().PresetName,"Head") then
			local mo = (ToAttachable(collidedMO):GetParent())
			
			local attachable = CreateAttachable(":flushed_mask:")
			mo:AddAttachable(attachable)
			
			if mo:NumberValueExists(":flushed:") then
				attachable.JointOffset.X = mo:GetNumberValue(":flushed:") * -1
			end
			mo:SetNumberValue(":flushed:", (mo:NumberValueExists(":flushed:") and mo:GetNumberValue(":flushed:") + 1 or 1))]]
		elseif ToAttachable(collidedMO):GetParent() and IsAHuman(ToAttachable(collidedMO):GetParent()) and ToAHuman(ToAttachable(collidedMO):GetParent()).Head then
			local mo = ToAHuman(ToAttachable(collidedMO):GetParent()).Head
			
			local attachable = CreateAttachable(":flushed_mask:")
			mo:AddAttachable(attachable)
			
			if mo:NumberValueExists(":flushed:") then
				attachable.JointOffset.X = mo:GetNumberValue(":flushed:") * -1
			end
			mo:SetNumberValue(":flushed:", (mo:NumberValueExists(":flushed:") and mo:GetNumberValue(":flushed:") + 1 or 1))
		end
		AudioMan:PlaySound("FGround.rte/Devices/Thrown/SERIOUS/FultonExtraction/Sounds/Attach"..math.random(1,2)..".wav", self.Pos)
		
		self.ToDelete = true
		self.SpawnCopy = false
		self.Thrown = false
	end
end

function OnCollideWithTerrain(self, terrainID)
	if self.Thrown and self.SpawnCopy then
		local new = CreateTDExplosive(self.PresetName)
		new.Pos = self.Pos
		new.Vel = self.Vel
		new.AngularVel = self.AngularVel
		new.RotAngle = self.RotAngle
		new.HFlipped = self.HFlipped
		MovableMan:AddParticle(new);
		
		self.ToDelete = true
		self.SpawnCopy = false
	end
end