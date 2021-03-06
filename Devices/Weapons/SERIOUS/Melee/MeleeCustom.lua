
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function Create(self)
	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	self.defaultAttackOffset = Vector(self:NumberValueExists("AttackOffsetX") and self:GetNumberValue("AttackOffsetX") or 10,self:NumberValueExists("AttackOffsetY") and self:GetNumberValue("AttackOffsetY") or 1)--Vector(10,-5)
	self.attackOffset = self.defaultAttackOffset
	self.chargedAttackOffset = Vector(self:NumberValueExists("ChargedAttackOffsetX") and self:GetNumberValue("ChargedAttackOffsetX") or 10,self:NumberValueExists("ChargedAttackOffsetY") and self:GetNumberValue("ChargedAttackOffsetY") or 1) -- non side attack
	self.chargeOffset = Vector(self:NumberValueExists("ChargeOffsetX") and self:GetNumberValue("ChargeOffsetX") or -4,self:NumberValueExists("ChargeOffsetY") and self:GetNumberValue("ChargeOffsetY") or -8)
	
	--self.attackPrepareOffset = Vector(-6,0)
	--self.attackSwingOffset = Vector(15,-3)
	--self.attackRecoverOffset = Vector(3,-5)
	self.attackPrepareOffset = Vector(self:NumberValueExists("AttackPrepareOffsetX") and self:GetNumberValue("AttackPrepareOffsetX") or -6,self:NumberValueExists("AttackPrepareOffsetY") and self:GetNumberValue("AttackPrepareOffsetY") or 0)
	self.attackSwingOffset = Vector(self:NumberValueExists("AttackSwingOffsetX") and self:GetNumberValue("AttackSwingOffsetX") or 15,self:NumberValueExists("AttackSwingOffsetY") and self:GetNumberValue("AttackSwingOffsetY") or -3)
	self.attackRecoverOffset = Vector(self:NumberValueExists("AttackRecoverOffsetX") and self:GetNumberValue("AttackRecoverOffsetX") or 3,self:NumberValueExists("AttackRecoverOffsetY") and self:GetNumberValue("AttackRecoverOffsetY") or -5)
	
	
	self.attackAngle = math.pi * (self:NumberValueExists("AttackAngle") and self:GetNumberValue("AttackAngle") or -1.0)
	self.chargeAngle = math.pi * (self:NumberValueExists("AttackDelay") and self:GetNumberValue("ChargeAngle") or 0.3)
	
	self.chargeSound = nil;
	self.attackSound = nil;
	
	self.attackDelayTimer = Timer()
	self.attackDelay = self:NumberValueExists("AttackDelay") and self:GetNumberValue("AttackDelay") or 200
	
	self.attackTimeDefault = self:NumberValueExists("AttackDuration") and self:GetNumberValue("AttackDuration") or 100
	self.attackTime = self.attackTimeDefault
	
	self.attackLastPos = Vector(self.Pos.X, self.Pos.Y)
	self.attackVel = Vector(0, 0)
	
	-- << SOUNDS >>
	self.AttackSound = self:GetStringValue("AttackSound")
	self.AttackSoundVariants = self:GetNumberValue("AttackSoundVariants")
	
	self.AttackChargedSound = self:GetStringValue("AttackChargedSound")
	self.AttackChargedSoundVariants = self:GetNumberValue("AttackChargedSoundVariants")
	
	self.AttackDeflectSound = self:GetStringValue("AttackDeflectSound")
	self.AttackDeflectSoundVariants = self:GetNumberValue("AttackDeflectSoundVariants")
	
	self.ChargeSound = self:GetStringValue("ChargeSound")
	self.ChargeSoundVariants = self:GetNumberValue("ChargeSoundVariants")
	
	self.ChargeEndSound = self:GetStringValue("ChargeEndSound")
	self.ChargeEndSoundVariants = self:GetNumberValue("ChargeEndSoundVariants")
	
	self.HitDefaultSound = self:GetStringValue("HitDefaultSound")
	self.HitDefaultSoundVariants = self:GetNumberValue("HitDefaultSoundVariants")
	
	self.HitFleshSound = self:GetStringValue("HitFleshSound")
	self.HitFleshSoundVariants = self:GetNumberValue("HitFleshSoundVariants")
	
	self.HitMetalSound = self:GetStringValue("HitMetalSound")
	self.HitMetalSoundVariants = self:GetNumberValue("HitMetalSoundVariants")
	
	self.UseChargedHits = self:GetNumberValue("UseChargedHits")
	
	self.ChargedHitFleshSound = self:GetStringValue("ChargedHitFleshSound")
	self.ChargedHitFleshSoundVariants = self:GetNumberValue("ChargedHitFleshSoundVariants")
	
	self.ChargedHitMetalSound = self:GetStringValue("ChargedHitMetalSound")
	self.ChargedHitMetalSoundVariants = self:GetNumberValue("ChargedHitMetalSoundVariants")
	
	self.HitTerrainSoftSound = self:GetStringValue("HitTerrainSoftSound")
	self.HitTerrainSoftSoundVariants = self:GetNumberValue("HitTerrainSoftSoundVariants")
	
	self.HitTerrainHardSound = self:GetStringValue("HitTerrainHardSound")
	self.HitTerrainHardSoundVariants = self:GetNumberValue("HitTerrainHardSoundVariants")
	
	self.ChargedHitTerrainSoftSound = self:GetStringValue("ChargedHitTerrainSoftSound")
	self.ChargedHitTerrainSoftSoundVariants = self:GetNumberValue("ChargedHitTerrainSoftSoundVariants")
	
	self.ChargedHitTerrainHardSound = self:GetStringValue("ChargedHitTerrainHardSound")
	self.ChargedHitTerrainHardSoundVariants = self:GetNumberValue("ChargedHitTerrainHardSoundVariants")
	-- << SOUNDS >>
	
	self.anim = 0.0 -- -1 - 1 for animation/interpolation, delay, -1 == charge, 0 == idle/default, 1 == attack
	self.animSpeed = self:NumberValueExists("AnimSpeed") and self:GetNumberValue("AnimSpeed") or 1
	
	self.activated = false;
	
	self.charged = false;
	self.chargeStartTimer = Timer()
	self.charging = false;
	self.chargeProgress = 0;
	self.chargeSpeed = self:NumberValueExists("ChargeSpeed") and self:GetNumberValue("ChargeSpeed") or 1
	
	self.attack = false
	self.attackCustomRecover = false
	self.attackCustom = false
	self.attackStun = false -- Trigerred when hit a handheld device (block)
	self.attackState = 0 -- Prepare, Swing, Recover
	self.attackTimer = Timer()
	self.attackPrepareDuration = self:NumberValueExists("SideAttackPrepareDuration") and self:GetNumberValue("SideAttackPrepareDuration") or 100
	self.attackSwingDuration = self:NumberValueExists("SideAttackSwingDuration") and self:GetNumberValue("SideAttackSwingDuration") or 150
	self.attackRecoverDuration = self:NumberValueExists("SideAttackRecoverDuration") and self:GetNumberValue("SideAttackRecoverDuration") or 250
	self.attackDuration = self.attackPrepareDuration + self.attackSwingDuration + self.attackRecoverDuration
	
	self.PrepareFrames = self:NumberValueExists("PrepareFrames") and self:GetNumberValue("PrepareFrames") or 5
	self.SwingFrames = self:NumberValueExists("SwingFrames") and self:GetNumberValue("SwingFrames") or 6
	self.RecoverFrames = self:NumberValueExists("RecoverFrames") and self:GetNumberValue("RecoverFrames") or 8
	
	--self.switchAnimations = false
	self.switchAnimations = self:NumberValueExists("SwitchAnimations") and self:GetNumberValue("SwitchAnimations") == 1 or false
	
	self.anim = 0.0
	self.animType = 1
	self.rot = 0.0
end

function Update(self)
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	local player = false
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	local animTarget = 0
	local attacked = false
	
	if self.attack or self.anim > 0.2 or self.attackCustomRecover then
		self:Deactivate()
	end
	if player then -- Charge attack only for players, AI is too dumb :-(
		if self:IsActivated() then-- and self.attackDelayTimer:IsPastSimMS(self.attackDelay) then
			if not self.activated then
				self.activated = true
				self.chargeStartTimer:Reset()
			end
			if not self.charging and self.chargeStartTimer:IsPastSimMS(50) then
				if self.chargeSound == nil then
					AudioMan:PlaySound(stringInsert(self.ChargeSound, self.ChargeSoundVariants > 1 and math.random(1, self.ChargeSoundVariants) or "", -5), self.Pos);
				end
				self.charging = true
			end
			if not self.switchAnimations and self.chargeStartTimer:IsPastSimMS(50) then
				self.Frame = 1
			end
			
			if not self.charged and self.chargeProgress > 0.9 then
				self.charged = true
			end
			
			self.chargeProgress = math.min(1, self.chargeProgress + TimerMan.DeltaTimeSecs * 4.0 * self.chargeSpeed)
		else
			self.charging = false
			if not self:IsActivated() then
				self.chargeStartTimer:Reset()
			end
			
			if self.activated then
				self.activated = false
				attacked = true
			end
			
			if not self.attack and not self.attackCustomRecover then
				self.chargeProgress = math.max(0, self.chargeProgress - TimerMan.DeltaTimeSecs * 6.0 * self.chargeSpeed)
				self.Frame = 0
			end
			
			if self.chargeSound ~= nil then
				self.chargeSound:Stop()
				self.chargeSound = nil
			end
			
		end
	end
	
	local delay = 1
	if self.attackStun then
		delay = 2.0
	end
	--if self.charged then
	--	self.attackTime = self.attackTimeDefault * 1.1
	--else
	--self.attackTime = self.attackTimeDefault
	--end
	
	local canHurt = false
	if ((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) or self.attackCustomRecover then
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(20, 40), "custom", true, 0);
		if attacked or self.attack or self.attackCustomRecover then
			self.attackCustom = true
			if not self.attack and not self.attackCustomRecover then
				self.attack = true
				self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackChargedSound, self.AttackChargedSoundVariants > 1 and math.random(1, self.AttackChargedSoundVariants) or "", -5), self.Pos);
				self.attackState = 0
				self.attackTimer:Reset()
				if self.charged then
					self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackChargedSound, self.AttackChargedSoundVariants > 1 and math.random(1, self.AttackChargedSoundVariants) or "", -5), self.Pos);
				else
					self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackSound, self.AttackSoundVariants > 1 and math.random(1, self.AttackSoundVariants) or "", -5), self.Pos);
				end
			end
			if not self.attackTimer:IsPastSimMS(self.attackDuration) then
				if self.attackState == 0 then
					if not self.attackTimer:IsPastSimMS(self.attackPrepareDuration) then
						local fac = math.max(self.attackTimer.ElapsedSimTimeMS / self.attackPrepareDuration, 0)
						self.Frame = 0 + math.floor(self.PrepareFrames * fac + 0.55)
						self.attackOffset = self.attackPrepareOffset
					else
						self.attackState = 1
						if self.attackSound == nil then
							self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackSound, self.AttackSoundVariants > 1 and math.random(1, self.AttackSoundVariants) or "", -5), self.Pos);
						end
					end
					--self.attackDuration = self.attackPrepareDuration + self.attackSwingDuration + self.attackRecoverDuration
				elseif self.attackState == 1 then
					if not self.attackTimer:IsPastSimMS(self.attackPrepareDuration + self.attackSwingDuration) then
						local fac = math.max((self.attackTimer.ElapsedSimTimeMS - self.attackPrepareDuration) / self.attackSwingDuration, 0)
						self.Frame = self.PrepareFrames + math.floor(self.SwingFrames * fac + 0.55)
						self.attackOffset = self.attackSwingOffset
						
						if self:NumberValueExists("AttackFreeze") and self:GetNumberValue("AttackFreeze") == 1 and actor then
							actor:GetController():SetState(Controller.MOVE_LEFT,false);
							actor:GetController():SetState(Controller.MOVE_RIGHT,false);
						end
						canHurt = true
					else
						self.attackState = 2
					end
				elseif self.attackState == 2 then
					if not self.attackTimer:IsPastSimMS(self.attackPrepareDuration + self.attackSwingDuration + self.attackRecoverDuration) then
						local fac = math.max((self.attackTimer.ElapsedSimTimeMS - self.attackPrepareDuration - self.attackSwingDuration) / self.attackRecoverDuration, 0)
						self.Frame = (self.PrepareFrames + self.SwingFrames) + math.floor(self.RecoverFrames * fac + 0.55)
						self.attackOffset = self.attackRecoverOffset
					else
						self.attackState = 0
						self.Frame = 0
						self.attackOffset = Vector(0, 0)
						self.charged = false
						self.attackCustomRecover = false
						self.attackCustom = false
					end
				end
				
				self.chargeProgress = math.max(0, self.chargeProgress - TimerMan.DeltaTimeSecs * 5.0 * self.chargeSpeed)
			else
				if self.attackSound ~= nil then
					self.attackSound:Stop()
					self.attackSound = nil
				end
				self.attackStun = false
				self.attack = false
				self.attackDelayTimer:Reset()
				
				self.charged = false
				self.attack = false
				self.attackOffset = Vector(0, 0)
				self.attackCustomRecover = false
				self.attackCustom = false
			end
		end
		--[[
		elseif self.attackTimer:IsPastSimMS(self.attackTime) then
			if self.attack then
				self.attackStun = false
				self.attack = false
				self.attackDelayTimer:Reset()
				
				self.attackState = 0
				self.Frame = 0
				self.attackOffset = self.defaultAttackOffset
				self.charged = false
				self.attackCustomRecover = false
			end
			
			if not self:IsActivated() then
				self.charged = false
			end
		end
		]]
	else
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(20, 40), "regular", true, 0);
		if ((attacked or (not player and self.FiredFrame)) or (not self.attackTimer:IsPastSimMS(self.attackTime) and self.attack)) and self.attackDelayTimer:IsPastSimMS(self.attackDelay * delay) then
			-- Start Animation
			if not self.attack then
				self.attackTimer:Reset()
				self.attack = true
				--self.switchAnimations and not self.charged or self.charged
				
				if self.charged then
					self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackChargedSound, self.AttackChargedSoundVariants > 1 and math.random(1, self.AttackChargedSoundVariants) or "", -5), self.Pos);
				else
					self.attackSound = AudioMan:PlaySound(stringInsert(self.AttackSound, self.AttackSoundVariants > 1 and math.random(1, self.AttackSoundVariants) or "", -5), self.Pos);
				end
				AudioMan:PlaySound(stringInsert(self.ChargeEndSound, self.ChargeEndSoundVariants > 1 and math.random(1, self.ChargeEndSoundVariants) or "", -5), self.Pos);
			end
			self.attackOffset = self.defaultAttackOffset --!!!
			
			if self.charged then
				self.anim = self.anim + TimerMan.DeltaTimeSecs * 6;
				animTarget = 1.2;
			else
				self.anim = self.anim + TimerMan.DeltaTimeSecs * 5.5;
				animTarget = 0.9;
			end
			
			if self:NumberValueExists("AttackFreeze") and self:GetNumberValue("AttackFreeze") == 1 and actor then
				actor:GetController():SetState(Controller.MOVE_LEFT,false);
				actor:GetController():SetState(Controller.MOVE_RIGHT,false);
			end
			
			self:Deactivate()
			self.attackStun = false
			canHurt = true
			self.chargeProgress = math.max(0, self.chargeProgress - TimerMan.DeltaTimeSecs * 9.0 * self.chargeSpeed)
			--self.anim = self.anim + TimerMan.DeltaTimeSecs * 6;
			--animTarget = 1;
		elseif self.attackTimer:IsPastSimMS(self.attackTime) then
			if self.attack then
				self.attackStun = false
				self.attack = false
				self.attackDelayTimer:Reset()
				
				self.attackState = 0
				self.Frame = 0
				self.attackOffset = self.defaultAttackOffset
				self.charged = false
				self.attackCustomRecover = false
			end
			
			if not self:IsActivated() then
				self.charged = false
			end
		end
	end
	
	local speed = 25
	if self:IsActivated() then
		speed = 10 * self.chargeSpeed
	end
	
	-- NUMBER AND BOOLEAN DEBUG SYSTEM
	--local at = self.attack and 1 or 0
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "attack = ".. at, true, 0);
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "animTarget = ".. animTarget, true, 0);
	
	self.anim = (self.anim + animTarget * TimerMan.DeltaTimeSecs * speed * self.animSpeed * 1.3) / (1 + TimerMan.DeltaTimeSecs * speed * self.animSpeed * 1.3);
	local chargeFactor = math.max(math.min(self.chargeProgress, 1), 0)
	local attackFactor = (((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) and self.attack) and 1 or math.max(self.anim, 0)
	
	local stanceAttack = self.attackOffset --self.charged and self.chargedAttackOffset or self.attackOffset
	local stanceCharge = self.chargeOffset
	
	local rotAttack = self.attackAngle
	local rotCharge = self.chargeAngle
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "chargeFactor = ".. math.floor(chargeFactor * 100), true, 0);
	
	local rotTarget = self.FlipFactor * (rotCharge * chargeFactor)
	
	local stanceCharge = self.chargeOffset * self.chargeProgress + self.attackOffset * attackFactor
	local stance = stanceCharge
	local animType = self:NumberValueExists("AttackAnimType") and self:GetNumberValue("AttackAnimType") or 0
	if (not ((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) and not self.attackCustomRecover) or (self.switchAnimations and (self.charged or not self.attackCustom) and not self.attackCustomRecover) then
		if animType == 0 then
			stanceAttack = (stanceAttack + Vector(0,2) * math.sin(attackFactor * math.pi) + Vector(0,-2) * (1 - math.sin(attackFactor * math.pi)))* attackFactor
			stanceCharge = stanceCharge * chargeFactor
			
			stance = stanceAttack * 1.7 + stanceCharge
			
			rotAttack = rotAttack * (math.sin(attackFactor * math.pi) + attackFactor * 2.0) / 3.0
			rotCharge = rotCharge * chargeFactor
			
			rotTarget = self.FlipFactor * (rotAttack + rotCharge)
		elseif animType == 1 then
			stanceAttack = stanceAttack * attackFactor + Vector(0,7) * attackFactor + Vector(0,-4) * math.sin(attackFactor * math.pi)
			stanceCharge = stanceCharge * chargeFactor
			
			stance = stanceAttack * 1.7 + stanceCharge
			
			rotAttack = rotAttack * (math.sin(attackFactor * math.pi) + attackFactor * 2.0) / 3.0
			rotCharge = rotCharge * chargeFactor
			
			rotTarget = self.FlipFactor * (rotAttack + rotCharge)
		end
	--	PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "yes", true, 0);
	--else
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "no", true, 0);
	end
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "stanceX = ".. math.floor(stance.X), true, 0);
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "stanceY = ".. math.floor(stance.Y), true, 0);
	local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
	local attacVec = Vector(math.min(math.max(self.IndividualRadius, 18), 30) * 1.6 * self.FlipFactor,0):RadRotate(self.RotAngle);
	
	self.rot = (self.rot + rotTarget * TimerMan.DeltaTimeSecs * 16) / (1 + TimerMan.DeltaTimeSecs * 16);
	self.StanceOffset = self.originalStanceOffset + stance * 1.1
	self.RotAngle = self.RotAngle + self.rot
	
	local attackOffset = Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
	local attackSideOffset = Vector(self:GetNumberValue("CustomAttackOffsetX") * self.FlipFactor, self:GetNumberValue("CustomAttackOffsetY")):RadRotate(self.RotAngle);
	
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rot);
	
	local vel = SceneMan:ShortestDistance(self.attackLastPos, Vector(self.Pos.X, self.Pos.Y) + attackOffset, SceneMan.SceneWrapsX) / (GetPPM() * TimerMan.DeltaTimeSecs)
	self.attackVel = (self.attackVel + vel * TimerMan.DeltaTimeSecs * 20) / (1 + TimerMan.DeltaTimeSecs * 20);
	self.attackLastPos = Vector(self.Pos.X, self.Pos.Y) + attackOffset
	
	if canHurt then -- Detect collision
		--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
		local hit = false
		local hitType = 0
		local team = 0
		if actor then team = actor.Team end
		local m = self.charged and (self:NumberValueExists("ChargedRangeMultiplier") and self:GetNumberValue("ChargedRangeMultiplier") or 1) or (self:NumberValueExists("RangeMultiplier") and self:GetNumberValue("RangeMultiplier") or 1)
		local rayVec = (self.attackVel:SetMagnitude(math.max((self.attackVel.Magnitude + self.IndividualRadius) / 2.0, self.attackVel.Magnitude) * 1.1) + attacVec) / 3.0 * m
		local rayOrigin = self.Pos + attackOffset
		if ((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) then
			rayVec = Vector((self.IndividualRadius * 0.5) * self.FlipFactor, 0):RadRotate(self.RotAngle);
			rayOrigin = self.Pos + attackSideOffset
		end
		if self:NumberValueExists("DebugRange") and self:GetNumberValue("DebugRange") ~= 0 then
			PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
		end
		
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck and moCheck ~= rte.NoMOID then
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			hit = true
			if IsMOSRotating(MO) then
				MO = ToMOSRotating(MO)
				--MO.Vel = MO.Vel + self.attackVel / MO.Mass * 15 * (self:GetNumberValue("PushMultiplier") or 1.0)
				MO.Vel = MO.Vel + (self.Vel + pushVector) / MO.Mass * 15 * (self:GetNumberValue("PushMultiplier") or 1.0)
				local crit = RangeRand(0,1) < (self:GetNumberValue("ChargedDamageStunChance")) -- Stun
				local woundName = MO:GetEntryWoundPresetName()
				local woundNameExit = MO:GetExitWoundPresetName()
				local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
				local damageType = self:NumberValueExists("DamageType") and self:GetNumberValue("DamageType") or 0
				
				local material = MO.Material.PresetName
				if crit then
					woundName = woundNameExit
				end
				
				if damageType == 0 then
					if woundName == "Wound Flesh Entry" then woundName = "Wound Dry Flesh Entry"
					elseif woundName == "Wound Flesh Exit" then woundName = "Wound Dry Flesh Exit"
					elseif woundName == "Wound Flesh Body" then woundName = "Wound Dry Flesh Body" end
				elseif damageType == 1 then
					--Wound Flesh Body
					if self.charged then
						if math.random(1,3) < 2 then
							if woundName == "Wound Flesh Entry" then woundName = "Wound Flesh Entry Deadly"
							elseif woundName == "Wound Flesh Exit" then woundName = "Wound Flesh Exit Deadly"
							elseif woundName == "Wound Flesh Body" then woundName = "Wound Flesh Body Deadly" end
						else
							if woundName == "Wound Flesh Entry" then woundName = "Wound Flesh Entry Strong"
							elseif woundName == "Wound Flesh Exit" then woundName = "Wound Flesh Exit Strong"
							elseif woundName == "Wound Flesh Body" then woundName = "Wound Flesh Body Strong" end
						end
					end
				end
				
				if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") or string.find(material,"Bone") or string.find(woundName,"Bone") or string.find(woundNameExit,"Bone") then
					hitType = 1

				else
					hitType = 2
				end
				if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") then
					if self:StringValueExists("GFXHitFlesh") then
						local effect = CreateMOSRotating(self:GetStringValue("GFXHitFlesh"));
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
				elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
					if self:StringValueExists("GFXHitMetal") then
						local effect = CreateMOSRotating(self:GetStringValue("GFXHitMetal"));
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
				end
				
				if MO:IsDevice() and math.random(1,3) >= 2 then
					if self:StringValueExists("GFXHitMetal") then
						local effect = CreateMOSRotating(self:GetStringValue("GFXHitMetal"));
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					--AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/Deflect"..math.random(1,2)..".ogg", self.Pos);
					AudioMan:PlaySound(stringInsert(self.AttackDeflectSound, self.AttackDeflectSoundVariants > 1 and math.random(1, self.AttackDeflectSoundVariants) or "", -5), self.Pos);
					
					self.anim = self.anim - 3
					self.attackStun = true
				end
				
				if self:NumberValueExists("Damage") and self:GetNumberValue("Damage") and self:NumberValueExists("ChargedDamage") and self:GetNumberValue("ChargedDamage") and not (MO:IsDevice() and damageType == 0 and math.random(1,2) < 2) then
					if self.charged then
						for i = 1, math.floor((self:GetNumberValue("ChargedDamage") or 1) + RangeRand(0,0.9)) do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					else
						for i = 1, math.floor((self:GetNumberValue("Damage") or 1) + RangeRand(0,0.9)) do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				end
				
				-- Hurt the actor, add extra damage
				local actorHit = MovableMan:GetMOFromID(MO.RootID)
				if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
					actorHit = ToActor(actorHit)
					actorHit.Vel = actorHit.Vel + (self.Vel + pushVector) / actorHit.Mass * ((50 + self.Mass) * (actor.Mass / 100)) * (self:NumberValueExists("PushMultiplier") and self:GetNumberValue("PushMultiplier") or 1.0) * 0.8
					--print(actorHit.Material.StructuralIntegrity)
					--actor.Health = actor.Health - 8 * damageMulti;
					if self.charged then
						if crit then
							actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
							actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
							actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
							actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
							actorHit:GetController():SetState(Controller.AIM_SHARP,false);
							actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
							actorHit:GetController():SetState(Controller.WEAPON_DROP,true);
							actorHit:GetController():SetState(Controller.BODY_JUMP,false);
							actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
							actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
							actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
							actorHit:FlashWhite(150);
						end
					else
						if crit then
							actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
							actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
							actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
							actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
							actorHit:GetController():SetState(Controller.AIM_SHARP,false);
							actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
							actorHit:GetController():SetState(Controller.WEAPON_DROP,false);
							actorHit:GetController():SetState(Controller.BODY_JUMP,false);
							actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
							actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
							actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
							actorHit:FlashWhite(50);
						end
					end
				end
			end
			
			self.attack = false
			if ((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) then
				self.charged = false
				self.attackCustomRecover = true
				if self.attackState < 2 then
					self.attackState = 2
				end
			end
			self.anim = self.anim + 1.0
		else
			--local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
			--local terrCheck = SceneMan:CastStrengthRay(rayOrigin, rayVec, 5, Vector(), 2, 0, SceneMan.SceneWrapsX); -- Raycast
			local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
			if terrCheck > 5 then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				hit = true
				self.attack = false
				if ((self.switchAnimations and not self.charged) or (not self.switchAnimations and self.charged)) then
					self.charged = false
					self.attackCustomRecover = true
					if self.attackState < 2 then
						self.attackState = 2
					end
				end
				
				if terrCheck >= 100 then
					if self:StringValueExists("GFXHitTerrainHard") then
						local effect = CreateMOSRotating(self:GetStringValue("GFXHitTerrainHard"));
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					hitType = 4 -- Hard
				else
					if self:StringValueExists("GFXHitTerrainSoft") then
						local effect = CreateMOSRotating(self:GetStringValue("GFXHitTerrainSoft"));
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					hitType = 3 -- Soft
				end
				self.anim = self.anim + 1.0
			end
		end
		
		if hit then
			if hitType == 0 then -- Default
				AudioMan:PlaySound(stringInsert(self.HitDefaultSound, self.HitDefaultSoundVariants > 1 and math.random(1, self.HitDefaultSoundVariants) or "", -5), self.Pos);
			elseif hitType == 1 then -- Flesh
				if self.charged and self.UseChargedHits == 1 then
					AudioMan:PlaySound(stringInsert(self.ChargedHitFleshSound, self.ChargedHitFleshSoundVariants > 1 and math.random(1, self.ChargedHitFleshSoundVariants) or "", -5), self.Pos);
				else
					AudioMan:PlaySound(stringInsert(self.HitFleshSound, self.HitFleshSoundVariants > 1 and math.random(1, self.HitFleshSoundVariants) or "", -5), self.Pos);
				end
			elseif hitType == 2 then -- Metal
				if self.charged and self.UseChargedHits == 1 then
					AudioMan:PlaySound(stringInsert(self.ChargedHitMetalSound, self.ChargedHitMetalSoundVariants > 1 and math.random(1, self.ChargedHitMetalSoundVariants) or "", -5), self.Pos);
				else
					AudioMan:PlaySound(stringInsert(self.HitMetalSound, self.HitMetalSoundVariants > 1 and math.random(1, self.HitMetalSoundVariants) or "", -5), self.Pos);
				end
			elseif hitType == 3 then -- Terrain Soft
				if self.charged and self.UseChargedHits == 1 then
					AudioMan:PlaySound(stringInsert(self.ChargedHitTerrainSoftSound, self.ChargedHitTerrainSoftSoundVariants > 1 and math.random(1, self.ChargedHitTerrainSoftSoundVariants) or "", -5), self.Pos);
				else
					AudioMan:PlaySound(stringInsert(self.HitTerrainSoftSound, self.HitTerrainSoftSoundVariants > 1 and math.random(1, self.HitTerrainSoftSoundVariants) or "", -5), self.Pos);
				end
			elseif hitType == 4 then -- Terrain Hard
				if self.charged and self.UseChargedHits == 1 then
					AudioMan:PlaySound(stringInsert(self.ChargedHitTerrainHardSound, self.ChargedHitTerrainHardSoundVariants > 1 and math.random(1, self.ChargedHitTerrainHardSoundVariants) or "", -5), self.Pos);
				else
					AudioMan:PlaySound(stringInsert(self.HitTerrainHardSound, self.HitTerrainHardSoundVariants > 1 and math.random(1, self.HitTerrainHardSoundVariants) or "", -5), self.Pos);
				end
			else
				AudioMan:PlaySound(stringInsert(self.HitDefaultSound, self.HitDefaultSoundVariants > 1 and math.random(1, self.HitDefaultSoundVariants) or "", -5), self.Pos);
			end
			
			
			if self.attackSound ~= nil then
				self.attackSound:Stop()
				self.attackSound = nil
			end
			self.attackOffset = Vector(0, 0)
			
			self.attackDelayTimer:Reset()
		end
	end
end