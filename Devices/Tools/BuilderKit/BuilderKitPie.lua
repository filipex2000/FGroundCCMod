function BuilderCancel(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Cancel Blueprint", 1);
	end
end

function BuilderAddBlueprint(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Add Blueprint", 1);
	end
end

function BuilderNextBlueprint(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Change Blueprint", 1);
	end
end

function BuilderPreviousBlueprint(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Change Blueprint", -1);
	end
end

function BuilderPlacementMode(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Builder Mode", 1);
	end
end

function BuilderConstructionMode(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		gun = ToMOSRotating(gun);
		gun:SetNumberValue("Builder Mode", 2);
	end
end