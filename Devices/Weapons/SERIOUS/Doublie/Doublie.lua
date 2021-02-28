function Create(self)
	self.setRecoilAngle = 0;
	self.recoilAngleSize = 1/math.sqrt(self.IndividualRadius);
	self.recoilAngleVariation = 0.03;
	
	self.state = 0
	self.mode = -1 -- 0 - normal, 1 - offhand
	
	self.fireTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	self.reloadTimer = Timer()
	
	self.reloading = false
	self.reloadTimer = Timer()
	self.activated = false
	
	self.chamber = false
	self.canChamber = false
	self.chamberTimer = Timer()
	self.chamberDelay = math.random(300,500)
	
	if self.Magazine then
		self.RoundCountMax = self.Magazine.RoundCount
	end
	
	self.originalSharpLength = self.SharpLength
	
	self.lastAge = self.Age
	
	self.originalRateOfFire = self.RateOfFire
end
function Update(self)

	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		self.mode = -1
	end
	
	self.lastAge = self.Age

	local arm = self:GetParent()
	if arm then
		--
		local actor = arm:GetParent()
		if actor then
			actor = ToAHuman(actor)
			self:Deactivate()
			if actor:IsPlayerControlled() then
				self.RateOfFire = self.originalRateOfFire
			else
				self.RateOfFire = self.originalRateOfFire * 0.75
			end
			
			local offhand = actor.EquippedBGItem and actor.EquippedBGItem.UniqueID == self.UniqueID
			if self.mode == -1 then
				self.mode = (offhand and 1 or 0)
			else
				
				if actor:GetController():IsState(Controller.WEAPON_FIRE) and not self.chamber then
					if not self.activated then
						self.activated = true
						if self.mode == 0 or not actor.EquippedBGItem then
							self:Activate()
						end
						self.mode = (self.mode + 1) % 2
					end
				else
					if self.activated then
						self.activated = false
					end
				end
				
				if self:IsReloading() then
					actor:GetController():SetState(Controller.AIM_SHARP,false)
				else
					local FGItem = actor.EquippedItem
					if offhand and FGItem then
						self.RotAngle = FGItem.RotAngle
						
						if ToHDFirearm(FGItem):IsReloading() and (not self.Magazine or self.Magazine.RoundCount < self.RoundCountMax) then
							self:Reload()
						end
					end
				end
				
				if not self.Magazine or self.Magazine.RoundCount < 1 then
					if self.reloadTimer:IsPastSimMS(700) then
						self:Reload()
					end
				else
					self.reloadTimer:Reset()
				end
			end
			
		end
	end
	
	self.SharpLength = self.originalSharpLength * (0.925 + math.pow(math.min(self.fireTimer.ElapsedSimTimeMS / 60, 3), 1.0) * 0.075)
	if self.chamber then
		self.Frame = 2
	else
		self.Frame = math.floor((1 - math.min(self.fireTimer.ElapsedSimTimeMS / 200, 1)) * 2 + 0.55)
	end
	
	if self:IsReloading() then
		if not self.reloading then
			self.reloading = true
			self.reloadTimer:Reset()
		end
		self.chamberTimer:Reset()
		
		self.setRecoilAngle = math.sin(self.reloadTimer.ElapsedSimTimeMS / self.ReloadTime * math.pi * 0.5) * math.pi * -4
	else
		if self.chamber and self.canChamber and self.chamberTimer:IsPastSimMS(self.chamberDelay) then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Doublie/Sounds/Chamber.wav", self.Pos)
			self.chamber = false
			self.canChamber = false
			
			self.chamberDelay = math.random(300,500)
		end
		
		if self.reloading then
			self.reloading = false
			if self.chamber then
				self.canChamber = true
			end
			-- Reset mode when something goes wrong
			self.mode = -1
			
			self.setRecoilAngle = 0
		end
		if self.setRecoilAngle > 0 then
			self.setRecoilAngle = self.setRecoilAngle - (0.0025 * (10 + math.sqrt(self.RateOfFire) * math.pow(self.setRecoilAngle, 2)));
			if self.setRecoilAngle < 0 then
				self.setRecoilAngle = 0;
			end
		end
	end
	if self.FiredFrame then
		self.fireTimer:Reset()
		self.canSmoke = true
		
		if not self.Magazine or self.Magazine.RoundCount < 1 then
			self.chamber = true
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Doublie/Sounds/LastRound.wav", self.Pos)
		end
		
		for i = 1, math.random(3,5) do
			local puff = CreateMOSParticle("Tiny Smoke Ball 1")
			puff.Pos = self.MuzzlePos;
			puff.Vel = self.Vel + Vector(45 * RangeRand(0.1,1.0) * self.FlipFactor, 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.1)
			puff.Lifetime = puff.Lifetime * RangeRand(0.8,1.2) * 0.325
			MovableMan:AddParticle(puff)
		end
		
		for i = 1, math.random(3,5) do
			local puff = CreateMOSParticle("Tracer Smoke Ball 1")
			puff.Pos = self.MuzzlePos;
			puff.Vel = self.Vel + Vector(60 * RangeRand(0.1,1.0) * self.FlipFactor, 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.05)
			puff.Lifetime = puff.Lifetime * RangeRand(0.8,1.2) * 0.2
			MovableMan:AddParticle(puff)
		end
		
		for i = 1, math.random(3,5) do
			local puff = CreateMOSParticle("Tracer Spark Ball "..math.random(1,3))
			puff.Pos = self.MuzzlePos;
			puff.Vel = self.Vel + Vector(85 * RangeRand(0.1,1.0) * self.FlipFactor, 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.05)
			puff.Lifetime = puff.Lifetime * RangeRand(0.8,1.2) * 0.1
			MovableMan:AddParticle(puff)
		end
		
		self.setRecoilAngle = self.setRecoilAngle + (self.recoilAngleSize * RangeRand(self.recoilAngleVariation, 1))/(1 + self.setRecoilAngle);
	end
	local angle = self.setRecoilAngle * self.FlipFactor
	
	self.RotAngle = self.RotAngle + (angle);
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-angle);
	
	if self.canSmoke and not self.fireTimer:IsPastSimMS(1500) then
		if self.smokeDelayTimer:IsPastSimMS(60) then
			
			local poof = CreateMOPixel("Micro Smoke Ball "..math.random(1,4))
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
			
		end
	end
end