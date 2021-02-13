function Create(self)
	
	self.deviceList = {} -- Table for devices when no actors are preset
	self.actorList = {} -- Table for actors and their inventories
	
	
	-- Read the inventory and write EVERYTHING into 2 tables
	if self:IsInventoryEmpty() == false then
		for item in self.Inventory do
			if item and IsActor(item) then
				table.insert(self.actorList, item)
			elseif item and IsHeldDevice(item) then -- In that case there must be no actors!
				table.insert(self.deviceList, item)
			end
		end
	end
	
	local pos = self.Pos
	if #self.actorList > 0 then -- Create all the actors with parachutes attached to them
		for _, actor in ipairs(self.actorList) do
			if actor then
				local scatterX = 20 + 30 * #self.actorList
				local scatterXVel = 20
				
				local startYVel = RangeRand(5,25)
				
				-- Add the actor itself
				
				actor = ToActor(actor):Clone()
				MovableMan:AddActor(actor)
				
				if actor.ClassName == "AHuman" then
					if math.random(1,3) < 2 then
						actor.Status = 1
					end
				end
				
				actor.Pos = pos + Vector(RangeRand(-scatterX, scatterX), 0)
				actor.Vel = Vector(RangeRand(-scatterXVel, scatterXVel), startYVel)
				
				-- Attach the parachute
				local parachuteBelt = CreateAttachable("Parachute Attachable", "FGround.rte");
				actor:AddAttachable(parachuteBelt)
			end
		end
	elseif #self.deviceList > 0 then -- Create a drop crate with all the items inside, with a parachute attached of course
		
	end
	
	self.deploySound = CreateSoundContainer("Deploy Parachute", "FGround.rte");
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