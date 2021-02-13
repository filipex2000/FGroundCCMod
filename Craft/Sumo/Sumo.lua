
function Create(self)
	self.door = nil;
	for attachable in self.Attachables do
		if attachable.PresetName == "Sumo Door" then
			self.door = attachable;
		end
	end
end

function Update(self)
	if self.door and self.door.ID ~= rte.NoMOID and self.HatchState == ACraft.OPEN then
		self.door:GibThis();
	end
	if (self.door == nil or self.door.ID == rte.NoMOID) and self:IsInventoryEmpty() then
		if self.HatchState == ACraft.OPEN then
			self:CloseHatch();
		end
	end
end

function Destroy(self)
	if self.door and self.door.ID ~= rte.NoMOID then
		self.door:GibThis();
	end
end
