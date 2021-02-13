

function Create(self)
	self.honkness = 0; --very honk
	self.toHonk = false;
	self.toHonkTimer = Timer();
	self.toHonkTime = 5;
	
	self.deactivatedOffset = Vector(8, 5);
	self.activatedOffset = Vector(8 * 2.0, 5 * 0.5);
	self.originalRateOfFire = self.RateOfFire;
	
	self.collideHonk = true;
end

function Update(self)
	
	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.collideHonk = true
	end
	
	if self.FiredFrame then -- random delay to make HONK more varied
		self.toHonkTimer:Reset()
		self.toHonkTime = RangeRand(0,50);
		self.toHonk = true;
		
		self.RateOfFire = self.originalRateOfFire * RangeRand(0.9,1.1)
	end
	
	if self.toHonk and self.toHonkTimer:IsPastSimMS(self.toHonkTime) then
		self.honkness = 1
		self.Scale = 1.5
		self.toHonk = false
		AudioMan:PlaySound("FGround.rte/Devices/Weapons/FUN/HONK/Sounds/honk.ogg", self.Pos);
	end
	
	self.Scale = (self.Scale + 1 * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	self.honkness = (self.honkness) / (1 + TimerMan.DeltaTimeSecs * 7);
	self.Frame = math.floor(self.honkness * 2 + 0.55);
	
	if self.Frame ~= 0 then
		self:Deactivate();
		
		self.StanceOffset = self.activatedOffset
		self.SharpStanceOffset = self.activatedOffset
	else
		self.StanceOffset = self.deactivatedOffset
		self.SharpStanceOffset = self.deactivatedOffset
	end
	
	--[[
	if self.FiredFrame then
		self.honkness = 1
		self.Scale = 1.5
	end
	
	self.Scale = (self.Scale + 1 * TimerMan.DeltaTimeSecs * 10) / (1 + TimerMan.DeltaTimeSecs * 10);
	self.honkness = (self.honkness) / (1 + TimerMan.DeltaTimeSecs * 10);
	self.Frame = math.floor(self.honkness * 2 + 0.55);
	
	if self.Frame ~= 0 then
		self:Deactivate();
	end
	]]
end


function OnCollideWithTerrain(self, terrainID)
	if self.collideHonk then
		self:Activate();
		self.collideHonk = false;
	end
end

function OnCollideWithMO(self, mo, rootMO)
	if self.collideHonk then
		self:Activate();
		self.collideHonk = false;
	end
end