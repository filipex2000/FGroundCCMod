function Create(self)
	self.parentSet = false;
	
	--[[
	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
		self.parentSet = true;
		
		if self.parent:NumberValueExists("Shield Belt Battery Amout") then
			self.parent:SetNumberValue("Shield Belt Battery Amout", self.parent:GetNumberValue("Shield Belt Battery Amout") + 3)
		else
			self.parent:SetNumberValue("Shield Belt Battery Amout", 3)
		end
	end]]
	
	self.battery = nil
	self.batteryPresetName = "Shield Belt Battery"
	
	self.batteryLoadNew = false
	self.batteryLoadTimer = Timer();
	self.batteryLoadDelay = 1000
	
	self.beepTimer = Timer()
	self.beepTimerDelayMax = 500
	self.beepTimerDelayMin = 150
	self.beepPitchMax = 1.15
	self.beepPitchMin = 0.95
	
	self.shieldState = 0
	
end

function Update(self)

	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	if self.parent then
		if (self.battery == nil or self.batteryLoadNew) and self.batteryLoadTimer:IsPastSimMS(self.batteryLoadDelay) then
			local battery = CreateAttachable(self.batteryPresetName)
			for attachable in self.Attachables do
				local MO = IsAttachable(attachable) and ToAttachable(attachable) or attachable
				if (MO.PresetName == self.batteryPresetName) then
					MO.JointStrength = -1
					MO.Frame = 1
					
					MO.Vel = MO.Vel + Vector(math.random(-5,5), math.random(-3,6))
					
					local smokeTrail = CreateAEmitter("Smoke Trail Medium")
					MO:AddAttachable(smokeTrail)
				end
			end
			self:AddAttachable(battery)
			AudioMan:PlaySound("FGround.rte/Devices/Tools/ShieldBelts/Sounds/ShieldCharge.ogg", self.Pos, -1, 0, 130, 1, 350, false)
			
			local glow = CreateMOPixel("Shieldbelt Battery Glow Green");
			glow.Pos = self.Pos;
			MovableMan:AddParticle(glow)
			
			glow = CreateMOPixel("Shieldbelt Battery Glow Green B");
			glow.Pos = self.Pos;
			MovableMan:AddParticle(glow)

			local newBattery = {["UniqueID"] = battery.UniqueID, ["Charge"] = 100};
			self.battery = newBattery
			
			self.shieldState = 1
			
			self.batteryLoadNew = false
		elseif self.batteryLoadNew then
			-- beep
			local factor = self.batteryLoadTimer.ElapsedSimTimeMS / self.batteryLoadDelay
			
			local delay = self.beepTimerDelayMax * factor + self.beepTimerDelayMin * (1 - factor)
			local pitch = self.beepPitchMin * factor + self.beepPitchMax * (1 - factor)
			
			if self.beepTimer:IsPastSimMS(delay) then
				AudioMan:PlaySound("FGround.rte/Devices/Tools/ShieldBelts/Sounds/ShieldBeep.ogg", self.Pos, -1, 0, 130, pitch, 350, false)
				
				local glow = CreateMOPixel("Shieldbelt Recharge Stripe Glow Red");
				glow.Pos = self.Pos;
				MovableMan:AddParticle(glow)
				
				glow = CreateMOPixel("Shieldbelt Recharge Stripe Glow Red B");
				glow.Pos = self.Pos;
				MovableMan:AddParticle(glow)
				
				
				self.beepTimer:Reset()
			end
			self.shieldState = 0
		end
		
		if self.battery then
			local batteryMO = MovableMan:FindObjectByUniqueID(self.battery.UniqueID)
			if batteryMO then
				batteryMO = ToAttachable(batteryMO)
				if self.battery.Charge < 1 and not self.batteryLoadNew then
					self.batteryLoadNew = true
					self.batteryLoadDelay = 6000
					self.batteryLoadTimer:Reset()
					
					AudioMan:PlaySound("FGround.rte/Devices/Tools/ShieldBelts/Sounds/ShieldHit.ogg", self.Pos, -1, 0, 130, 0.9, 350, false)
					
					batteryMO.Frame = 1
					
					self.beepTimer:Reset()
					self.shieldState = 0
				elseif not self.batteryLoadNew then
					self.shieldState = 1
				end
				
			else
				self.shieldState = 0
				
				self.battery = nil
				self.batteryLoadDelay = 1000
				self.batteryLoadTimer:Reset()
			end
		end
	end
end