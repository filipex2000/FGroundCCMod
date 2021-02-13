function Create(self)
	self.updateTimer = Timer();

	self.healAmount = 3;
	self.regenDelay = 200;
	self.regenTimer = Timer();
	
	self.blinkTimer = Timer()
	self.blinkResetTime = 5000
	
	self.lastWoundCount = self.TotalWoundCount;
	self.lastHealth = self.Health;
end
function Update(self)
	if self.updateTimer:IsPastSimMS(1000) then
		self.updateTimer:Reset();
		self.aggressive = self.Health < self.MaxHealth * 0.5;
	end
	--[[
	if self.Head then
		self.Head.Frame = math.floor((7 - math.min(self.blinkTimer.ElapsedSimTimeMS / 300, 1) * 3) + 0.55)--3
		if self.controller:IsState(Controller.WEAPON_FIRE) or self.aggressive then
			self.Head.Frame = self.Head.Frame - 4
		end
	end]]
	if self.Head then
		self.Head.Frame = math.floor((7 - math.min(self.blinkTimer.ElapsedSimTimeMS / 300, 1) * 3) + 0.55) + 1
		if self.controller:IsState(Controller.WEAPON_FIRE) or (self.Health > 99 or (self.Health > 47.313 and self.Health < 48.211)) then
			self.Head.Frame = self.Head.Frame - 4
		end
		
		if self.Health < 1 then
			self.Head.Frame = 7
		end
	end
	
	if self.blinkTimer:IsPastSimMS(self.blinkResetTime) then
		self.blinkResetTime = math.random(1000,6000)
		self.blinkTimer:Reset()
	end
	
	if self.regenTimer:IsPastSimMS(self.regenDelay) then
		self.regenTimer:Reset();
		if self.Health > 0 then
			local damageRatio = (self.TotalWoundCount - self.lastWoundCount)/self.TotalWoundLimit + (self.lastHealth - self.Health)/self.MaxHealth;
			if damageRatio > 0 then
				self.regenDelay = self.regenDelay * (1 + damageRatio);
			else
				local healed = self:RemoveAnyRandomWounds(1);
				if healed ~= 0 and self.Health < self.MaxHealth then
					self:AddHealth(self.healAmount);
					if self.Health > self.MaxHealth	then
						self.Health = self.MaxHealth;
					end
				end
			end
		end
		self.lastWoundCount = self.TotalWoundCount;
		self.lastHealth = self.Health;
	end
end