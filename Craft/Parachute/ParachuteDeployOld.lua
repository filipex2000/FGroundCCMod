function Create(self)
	
	self.deviceList = {} -- Table for devices when no actors are preset
	self.actorList = {} -- Table for actors and their inventories
	
	self.deploySound = CreateSoundContainer("Deploy Parachute", "FGround.rte");
	
	-- Read the inventory and write EVERYTHING into 2 tables
	if self:IsInventoryEmpty() == false then
		for i = 1, self.InventorySize do
			local item = self:Inventory();
			
			--print(item.PresetName)
			if item and IsActor(item) then
				local actorTable = {item.PresetName, item.ClassName}
				
				if IsAHuman(item) then -- Regural AHumans
					item = ToAHuman(item)
					
					local itemsTable = {}
					
					if ToAHuman(item).EquippedItem then -- Get the first/equipped weapon from the item list, somehow it doesn't show up as inventory item so...
						local subitem = ToAHuman(item).EquippedItem
						table.insert(itemsTable, {subitem.PresetName, subitem.ClassName, PresetMan:GetDataModule(subitem.ModuleID).FileName})
						--print("FG - "..ToAHuman(item).EquippedItem.PresetName)
					end
					
					if ToAHuman(item).EquippedBGItem then -- Get the secondary/BG equipped weapon from the item list, somehow it doesn't show up as inventory item so...
						local subitem = ToAHuman(item).EquippedBGItem
						table.insert(itemsTable, {subitem.PresetName, subitem.ClassName, PresetMan:GetDataModule(subitem.ModuleID).FileName})
						--print("BG - "..ToAHuman(item).EquippedItem.PresetName)
					end
					
					if item:IsInventoryEmpty() == false then -- Get all items from AHuman's actual inventory
						for i = 1, item.InventorySize do
							local subitem = item:Inventory();
							if subitem and IsHeldDevice(subitem) then
								table.insert(itemsTable, {subitem.PresetName, subitem.ClassName, PresetMan:GetDataModule(subitem.ModuleID).FileName})
								--print("-- "..subitem.PresetName)
							end
							item:SwapNextInventory(subitem, true);
						end
					end
					table.insert(actorTable, itemsTable)
					table.insert(self.actorList, actorTable)
				else -- ACrabs, custom Actors, etc.
					table.insert(self.actorList, actorTable)
				end
			elseif item and IsHeldDevice(item) then -- In that case there must be no actors!
				table.insert(self.deviceList, item.PresetName)
			end
			
			self:SwapNextInventory(item, true);
		end
	end
	
	local pos = self.Pos
	if #self.actorList > 0 then -- Create all the actors with parachutes attached to them
		for _, actorData in ipairs(self.actorList) do
			local actorName = actorData[1]
			local actorClass = actorData[2]
			local actorInventory = actorData[3]
			
			if actorClass == "AHuman" then
				actor = CreateAHuman(actorName)
				if math.random(1,3) < 2 then
					actor.Status = 1
				end
			elseif actorClass == "ACrab" then
				actor = CreateACrab(actorName)
			elseif actorClass == "Actor" then
				actor = CreateActor(actorName)
			end
			
			if actor then
				local scatterX = 20 + 30 * #self.actorList
				local scatterXVel = 20
				
				local startYVel = RangeRand(5,25)
				
				-- Add the actor itself
				actor.Pos = pos + Vector(RangeRand(-scatterX, scatterX), 0)
				actor.Vel = actor.Vel + Vector(RangeRand(-scatterXVel, scatterXVel), startYVel)
				actor.Team = self.Team
				actor.IgnoresTeamHits = true
				MovableMan:AddActor(actor)
				
				-- Add inventory items
				if actorInventory and #actorInventory > 0 then
					for i, itemData in ipairs(actorInventory) do
						local itemName = itemData[1]
						local itemClass = itemData[2]
						local itemModuleName = itemData[3]
						print(itemModuleName)
						if itemClass == "HDFirearm" then
							device = CreateHDFirearm(itemName, itemModuleName)
						elseif itemClass == "TDExplosive" then
							device = CreateTDExplosive(itemName, itemModuleName)
						elseif itemClass == "HeldDevice" then
							device = CreateHeldDevice(itemName, itemModuleName)
						elseif itemClass == "ThrownDevice" then
							device = CreateThrownDevice(itemName, itemModuleName)
						end
						actor:AddInventoryItem(device)
					end
				end
				
				-- Attach the parachute
				local parachuteBelt = CreateAttachable("Parachute Attachable");
				actor:AddAttachable(parachuteBelt)
			end
		end
	elseif #self.deviceList > 0 then -- Create a drop crate with all the items inside, with a parachute attached of course
		
	end
	
	self.deploySound:Play(self.Pos)
	
	self.ToDelete = true
end
function Update(self)
	self.ToDelete = true
	--self:GibThis()
end
--function Destroy(self)
--	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
--end