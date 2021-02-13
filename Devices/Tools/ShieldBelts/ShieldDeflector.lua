function Create(self)
	self.magnetDistance = 50
	
	self.deflectedParticles = {}
	self.deflectedParticlesReset = Timer()
end

function Update(self)
	if self.shieldState == 1 and self.parent then
		local team = self.parent.Team
		
		if self.deflectedParticlesReset:IsPastSimMS(200) then
			self.deflectedParticles = {}
		end
		
		local repelSound = false
		for mo in MovableMan.Particles do
			if mo and mo.HitsMOs == true and mo.Team ~= team and (mo.ClassName == "MOPixel" or mo.ClassName == "MOParticle") then
				local kilohurts = (mo.Mass * mo.Sharpness * math.pow(mo.Vel.Magnitude, 2)) * 0.001
				
				local deflected = false
				if #self.deflectedParticles > 0 then
					for i, d in ipairs(self.deflectedParticles) do
						if d == mo.UniqueID then
							deflected = true
							break
						end
					end
				end
				if kilohurts > 4 and not deflected then
					local distance = SceneMan:ShortestDistance(self.Pos, mo.Pos + mo.Vel * GetPPM() * TimerMan.DeltaTimeSecs, SceneMan.SceneWrapsX).Magnitude
					
					if distance < (self.magnetDistance + math.random(-15,15)) then
						if mo.UniqueID % 3 == 0 then
							mo.Team = team
						end
						local originalVel = Vector(mo.Vel.X, mo.Vel.Y)
						
						mo.Sharpness = mo.Sharpness * 0.75
						mo.WoundDamageMultiplier = mo.WoundDamageMultiplier * 0.5
						mo.Vel = mo.Vel + Vector(-120 * RangeRand(0.9,1.1), 90 * (math.random(0,1) - 0.5) * RangeRand(0.9,1.1)):RadRotate(mo.Vel.AbsRadAngle) / mo.Mass * 0.06
						
						
						
						AudioMan:PlaySound("FGround.rte/Devices/Tools/ShieldBelts/Sounds/Spark"..math.random(1,2)..".ogg", mo.Pos, -1, 0, 30, RangeRand(0.95,1.15), 350, false)
						
						if kilohurts > 6.4 then
							if not repelSound then
								AudioMan:PlaySound("FGround.rte/Devices/Tools/ShieldBelts/Sounds/Repel"..math.random(1,3)..".ogg", mo.Pos, -1, 0, 30, RangeRand(0.95,1.15), 350, false)
								
								local glow = CreateMOPixel("Shieldbelt Deflect Arch Glow");
								glow.Pos = mo.Pos + Vector(originalVel.X, originalVel.Y):SetMagnitude(8);
								glow.EffectRotAngle = originalVel.AbsRadAngle + math.pi
								MovableMan:AddParticle(glow)
								repelSound = true
							end
						else
							local glow = CreateMOPixel("Shieldbelt Deflect Glow");
							glow.Pos = mo.Pos;
							MovableMan:AddParticle(glow)
						end
						
						self.battery.Charge = self.battery.Charge - kilohurts * 0.1--0.15
						
						self.deflectedParticlesReset:Reset()
						--print(mo.UniqueID)
						table.insert(self.deflectedParticles, mo.UniqueID)
						--PrimitiveMan:DrawCirclePrimitive(mo.Pos, 2, 5)
					end
				end
				
			end
		end
		--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.magnetDistance, 13)
	end
end