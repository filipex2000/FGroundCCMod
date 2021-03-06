
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackSequence = 1
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	self.attackAnimationCanHit = true
	return
end

function Create(self)
	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.attackAnimations = {}
	self.attackAnimationCanHit = false
	self.attackAnimationsSounds = {}
	self.attackAnimationsGFX = {}
	self.attackAnimationTimer = Timer();
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	local attackPhase
	local regularAttackSounds = {}
	local i
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/DeflectSmall.wav"
	regularAttackSounds.hitDeflectSoundVariations = 5
	
	regularAttackSounds.hitFleshSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/BluntSmall/HitFlesh.wav"
	regularAttackSounds.hitFleshSoundVariations = 4
	
	regularAttackSounds.hitMetalSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/BluntSmall/HitMetal.wav"
	regularAttackSounds.hitMetalSoundVariations = 4
	
	regularAttackSounds.hitTerrainSoftSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/BluntSmall/HitTerrainSoft.wav"
	regularAttackSounds.hitTerrainSoftSoundVariations = 3
	
	regularAttackSounds.hitTerrainHardSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/BluntSmall/HitTerrainHard.wav"
	regularAttackSounds.hitTerrainHardSoundVariations = 3
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect"
	
	-- Regular Attack
	attackPhase = {}
	
	-- Prepare
	i = 1
	attackPhase[i] = {}
	attackPhase[i].durationMS = 50
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 0
	attackPhase[i].frameEnd = 0
	attackPhase[i].angleStart = 0
	attackPhase[i].angleEnd = 30
	attackPhase[i].offsetStart = Vector(0, 3)
	attackPhase[i].offsetEnd = Vector(-5, -15)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Attack
	i = 2
	attackPhase[i] = {}
	attackPhase[i].durationMS = 100
	
	attackPhase[i].canDamage = true
	attackPhase[i].attackDamage = 1
	attackPhase[i].attackStunChance = 0.1
	attackPhase[i].attackRange = 10
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 0
	attackPhase[i].frameEnd = 0
	attackPhase[i].angleStart = 30
	attackPhase[i].angleEnd = -120
	attackPhase[i].offsetStart = Vector(20, -10)
	attackPhase[i].offsetEnd = Vector(16, 5)
	
	attackPhase[i].soundStart = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/BluntSmall/Swing.wav"
	attackPhase[i].soundStartVariations = 3
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 3
	attackPhase[i] = {}
	attackPhase[i].durationMS = 100
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 0
	attackPhase[i].frameEnd = 0
	attackPhase[i].angleStart = -170
	attackPhase[i].angleEnd = 15
	attackPhase[i].offsetStart = Vector(16, 15)
	attackPhase[i].offsetEnd = Vector(0, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[1] = regularAttackSounds
	self.attackAnimationsGFX[1] = regularAttackGFX
	self.attackAnimations[1] = attackPhase
	
	-- Charged Attack
	--
	--
	--
	
	-- replace with your own code if you wish
	
	-- default "regular attack and charged attack behaviour"
	
	self.startedCharging = false
	self.isCharging = false
	self.isCharged = false
	
	self.chargeStartTimer = Timer()
	self.chargeStartTime = 50
	self.chargeTimer = Timer()
	self.chargeTime = 300
	
	self.chargeStanceOffset = Vector(-1,-6)
	self.chargeAngle = 15
	
	self.chargeSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/Charge.wav"
	self.chargeSoundVariants = 1
	
	self.chargeEndSound = "FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/ChargeEnd.wav"
	self.chargeEndSoundVariants = 5
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 35
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
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
	
	-- INPUT
	local charge = false
	local attacked = false
	
	if player then -- PLAYER INPUT
		charge = self:IsActivated()
	else -- AI
		
	end
	
	-- replace with your own code if you wish
	-- default "regular attack and charged attack behaviour"
	
	if charge and not self.attackAnimationIsPlaying then
		if not self.startedCharging then
			self.startedCharging = true
		end
		if not self.isCharging and self.chargeStartTimer:IsPastSimMS(self.chargeStartTime) then
			self.isCharging = true
			AudioMan:PlaySound(stringInsert(self.chargeSound, self.chargeSoundVariants > 1 and math.random(1, self.chargeSoundVariants) or "", -5), self.Pos);
		end
		
		if self.isCharging then
			if self.chargeTimer:IsPastSimMS(self.chargeTime) then
				if not self.isCharged then
					self.isCharged = true
				end
			end
		end
	else
		self.chargeStartTimer:Reset()
		self.chargeTimer:Reset()
		if self.isCharging or self.startedCharging then
			self.isCharging = false
			self.startedCharging = false
			AudioMan:PlaySound(stringInsert(self.chargeEndSound, self.chargeEndSoundVariants > 1 and math.random(1, self.chargeEndSoundVariants) or "", -5), self.Pos);
			attacked = true
		end
	end
	
	-- INPUT TO OUTPUT
	
	-- replace with your own code if you wish
	-- default "regular attack and charged attack behaviour"
	if attacked then
		--if self.isCharged then
			self.isCharged = false
		--	playAttackAnimation(self, 2) -- charged attack
		--else
			playAttackAnimation(self, 1) -- regular attack
		--end
	end
	
	-- ANIMATION PLAYER
	local stanceTarget = Vector(0, 0)
	local rotationTarget = 0
	
	local canDamage = false
	local damageVector = Vector(0,0)
	local damageRange = 1
	local damageStun = 0
	local damagePush = 1
	local damage = 0
	
	-- charge animation, remove/replace it if you wish
	local chargeFactor = math.min(self.chargeTimer.ElapsedSimTimeMS / self.chargeTime, 1)
	stanceTarget = stanceTarget + self.chargeStanceOffset * chargeFactor
	rotationTarget = rotationTarget + self.chargeAngle / 180 * math.pi * chargeFactor
	
	
	if self.attackAnimationIsPlaying and currentAttackAnimation ~= 0 then -- play the animation
		local animation = self.currentAttackAnimation
		local attackPhases = self.attackAnimations[animation]
		local currentPhase = attackPhases[self.currentAttackSequence]
		
		local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
		
		if not self.currentAttackStart then -- Start of the sequence
			self.currentAttackStart = true
			if currentPhase.soundStart then
				AudioMan:PlaySound(stringInsert(currentPhase.soundStart, currentPhase.soundStartVariations > 1 and math.random(1, currentPhase.soundStartVariations) or "", -5), self.Pos);
			end
		end
		
		canDamage = currentPhase.canDamage or false
		damage = currentPhase.attackDamage or 0
		damageVector = currentPhase.attackVector or Vector(0,0)
		damageRange = currentPhase.attackRange or 0
		damageStun = currentPhase.attackStun or 0
		damagePush = currentPhase.attackPush or 0
		
		rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
		stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
		local frameChange = currentPhase.frameEnd - currentPhase.frameStart
		self.Frame = math.floor(currentPhase.frameStart + math.floor(frameChange * factor, 0.55))
		
		-- DEBUG
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
		if self.attackAnimationTimer:IsPastSimMS(currentPhase.durationMS) then
			if (self.currentAttackSequence+1) <= #attackPhases then
				self.currentAttackSequence = self.currentAttackSequence + 1
			else
				self.currentAttackAnimation = 0
				self.currentAttackSequence = 0
				self.attackAnimationIsPlaying = false
			end
			
			if currentPhase.soundEnd then
				AudioMan:PlaySound(stringInsert(currentPhase.soundEnd, currentPhase.soundEndVariations > 1 and math.random(1, currentPhase.soundEndVariations) or "", -5), self.Pos);
			end
			
			self.currentAttackStart = false
			self.attackAnimationTimer:Reset()
			self.attackAnimationCanHit = true
			canDamage = false -- if you remove this it hits twice instead of once during one phase
		end
	else -- default behaviour, modify it if you wish
		self.Frame = 0
	end
	
	if self.stanceInterpolation == 0 then
		self.stance = stanceTarget
	elseif self.stanceInterpolation == 1 then
		self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
	end
	
	rotationTarget = rotationTarget * self.FlipFactor
	if self.rotationInterpolation == 0 then
		self.rotation = rotationTarget
	elseif self.rotationInterpolation == 1 then
		self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
	end
	local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
	
	self.StanceOffset = self.originalStanceOffset + self.stance
	self.RotAngle = self.RotAngle + self.rotation
	
	local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
	self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
	
	-- COLLISION DETECTION
	
	--self.attackAnimationsSounds[1]
	if canDamage and self.attackAnimationCanHit then -- Detect collision
		--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
		local hit = false
		local hitType = 0
		local team = 0
		if actor then team = actor.Team end
		--local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(preAngle)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
		--local rayOrigin = self.Pos + damageVector:RadRotate(self.RotAngle)
		local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(self.RotAngle)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
		local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(damageVector.X * self.FlipFactor, damageVector.Y):RadRotate(self.RotAngle)
		
		PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
		
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck and moCheck ~= rte.NoMOID then
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			hit = true
			if IsMOSRotating(MO) then
				MO = ToMOSRotating(MO)
				MO.Vel = MO.Vel + (self.Vel + pushVector) / MO.Mass * 15 * (damagePush)
				local crit = RangeRand(0,1) < damageStun
				local woundName = MO:GetEntryWoundPresetName()
				local woundNameExit = MO:GetExitWoundPresetName()
				local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
				
				local material = MO.Material.PresetName
				if crit then
					woundName = woundNameExit
				end
				
				if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") or string.find(material,"Bone") or string.find(woundName,"Bone") or string.find(woundNameExit,"Bone") then
					hitType = 1
				else
					hitType = 2
				end
				if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") then
					if self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX then
						local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
				elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
					if self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX then
						local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
				end
				
				if MO:IsDevice() and math.random(1,3) >= 2 then
					if self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX then
						local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					--AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/Melee/Sounds/Deflect"..math.random(1,2)..".ogg", self.Pos);
					AudioMan:PlaySound(stringInsert(self.AttackDeflectSound, self.AttackDeflectSoundVariants > 1 and math.random(1, self.AttackDeflectSoundVariants) or "", -5), self.Pos);
					
					--self.anim = self.anim - 3
					--self.attackStun = true
				end
				
				for i = 1, math.floor((damage) + RangeRand(0,0.9)) do
					MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
				end
				
				-- Hurt the actor, add extra damage
				local actorHit = MovableMan:GetMOFromID(MO.RootID)
				if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
					actorHit = ToActor(actorHit)
					actorHit.Vel = actorHit.Vel + (self.Vel + pushVector) / actorHit.Mass * ((50 + self.Mass) * (actor.Mass / 100)) * (damagePush) * 0.8
					--print(actorHit.Material.StructuralIntegrity)
					--actor.Health = actor.Health - 8 * damageMulti;
					if self.isCharged then
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
			self.isCharged = false
		else
			local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
			if terrCheck > 5 then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				hit = true
				self.attack = false
				self.charged = false
				
				if terrCheck >= 100 then
					if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX then
						local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					hitType = 4 -- Hard
				else
					if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainSoftGFX then
						local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					hitType = 3 -- Soft
				end
			end
		end
		
		if hit then
			if hitType == 0 then -- Default
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
					AudioMan:PlaySound(stringInsert(elf.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSoundVariations > 1 and math.random(1, self.attackAnimationsGFX[self.currentAttackAnimation].hitDefaultSoundVariations) or "", -5), self.Pos);
				end
			elseif hitType == 1 then -- Flesh
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound then
					AudioMan:PlaySound(stringInsert(self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSoundVariations > 1 and math.random(1, self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSoundVariations) or "", -5), self.Pos);
				end
			elseif hitType == 2 then -- Metal
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound then
					AudioMan:PlaySound(stringInsert(self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSoundVariations > 1 and math.random(1, self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSoundVariations) or "", -5), self.Pos);
				end
			elseif hitType == 3 then -- Terrain Soft
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainSoftSound then
					AudioMan:PlaySound(stringInsert(self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainSoftSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainSoftSoundVariations > 1 and math.random(1, self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainSoftSoundVariations) or "", -5), self.Pos);
				end
			elseif hitType == 4 then -- Terrain Hard
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainHardSound then
					AudioMan:PlaySound(stringInsert(self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainHardSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainHardSoundVariations > 1 and math.random(1, self.attackAnimationsSounds[self.currentAttackAnimation].hitTerrainHardSoundVariations) or "", -5), self.Pos);
				end
			else
				if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
					AudioMan:PlaySound(stringInsert(self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound, self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSoundVariations > 1 and math.random(1, self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSoundVariations) or "", -5), self.Pos);
				end
			end
			self.attackAnimationCanHit = false
		end
	end
end 