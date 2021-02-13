function Create(self)
	self.shieldBeltPresetName = self.PresetName .. " Attachable"
end

function Update(self)
	
	if self:IsActivated() then
		parent = MovableMan:GetMOFromID(self.RootID);
		if parent and IsActor(parent) then
			parent = ToActor(parent);
			
			for attachable in self.Attachables do
				local MO = IsAttachable(attachable) and ToAttachable(attachable) or attachable
				if string.find(MO.PresetName,"Shield Belt") then
					MO.JointStrength = -1
				end
			end
			
			local shieldBelt = CreateAttachable(self.shieldBeltPresetName);
			parent:AddAttachable(shieldBelt);
			self.ToDelete = true
		end
	end
end