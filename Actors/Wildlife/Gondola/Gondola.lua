function Create(self)
	self.blinkTimer = Timer()
	self.blinkDuration = 100
	self.blinkTime = 4300 + self.blinkDuration
	
	self.painTimer = Timer()
	self.painTimerDuration = 100
	self.pain = false
	
	self.lastHealth = self.Health + 0
	
	self.kil = math.random() < 0.05 -- why even live without gondola legs
	
	--self.soundBlink = CreateSoundContainer("Blink Gondola", "FGround.rte");
end

function Update(self)
	self.Frame = 0
	if (self.controller and self.controller:IsState(Controller.WEAPON_FIRE)) then
		self.Frame = 4
	--elseif self.blinkTimer:IsPastSimMS(self.blinkTime - self.blinkDuration) then
	elseif not self.blinkTimer:IsPastSimMS(self.blinkDuration * 0.5) or self.blinkTimer:IsPastSimMS(self.blinkTime - self.blinkDuration * 0.5) then
		self.Frame = 2
	end
	
	if self.lastHealth > self.Health then
		local dif = math.abs(self.lastHealth - self.Health)
		if dif > 1 then
			self.painTimer:Reset()
			self.painTimerDuration = dif * 65
			self.pain = true
		end
		
		self.lastHealth = self.Health + 0
	end
	
	if (self.controller and ((self.controller:IsState(Controller.MOVE_RIGHT) and not self.HFlipped) or (self.controller:IsState(Controller.MOVE_LEFT) and self.HFlipped))) then
		self.Frame = self.Frame + 1
	end
	
	if self.Status == 1 then
		self.Frame = 8
	end
	
	self.Scale = 1
	if self.pain then
		if self.painTimer:IsPastSimMS(self.painTimerDuration) then
			self.pain = false
		else
			self.Scale = RangeRand(0.9,1.2)
			self.Frame = math.random(6,7)
		end
	end
	
	if self.Status == 4 then
		self.Frame = 9
	end
	
	if not self.FGLeg and not self.BGLeg then
		if self.kil then
			self.kil = false
			local explosion = CreateMOSRotating("Nuclear Explosion", "FGround.rte");
			explosion.Pos = self.Pos;
			explosion.Vel = self.Vel;
			MovableMan:AddParticle(explosion);
			
			self.GibThis()
		end
	end
	
	if self.blinkTimer:IsPastSimMS(self.blinkTime) then
		self.blinkTimer:Reset()
		--self.soundBlink:Play(self.Pos)
	end
end