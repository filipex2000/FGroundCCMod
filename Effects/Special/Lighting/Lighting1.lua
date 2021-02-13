
function DrawCircleDir(pos, radius, dir)
    PrimitiveMan:DrawCirclePrimitive(pos, radius, 5);
	PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):RadRotate(dir),  13);
end

function Create(self)
	local glow = CreateMOPixel("Lighting Spark 2");
	glow.Pos = self.Pos;
	MovableMan:AddParticle(glow);
	
	local startPos = Vector(self.Pos.X, self.Pos.Y)
	self.Pos = startPos
	
	local maxi = math.random(90,110)
	local mini = 0
	for i = mini, maxi do
		local fac = i / maxi
		
		local travel = Vector(RangeRand(2,4), RangeRand(-1,1)):RadRotate(self.RotAngle)
		local newPos = Vector(self.Pos.X, self.Pos.Y) + travel
		
		local terrCheck = SceneMan:GetTerrMatter(newPos.X, newPos.Y)
		local MOIDCheck = SceneMan:GetMOIDPixel(newPos.X, newPos.Y)
		if (MOIDCheck and MOIDCheck ~= rte.NoMOID and MovableMan:GetMOFromID(MOIDCheck).Team ~= self.Team) or terrCheck ~= 0 then
			AudioMan:PlaySound("FGround.rte/Devices/Weapons/SERIOUS/LightingGuns/Sounds/Lightning.wav", self.Pos);
			for i = 1, 4 do
				local glowHit = CreateMOPixel("Lighting Spark "..math.random(1,5));
				glowHit.Pos = newPos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 4;
				MovableMan:AddParticle(glowHit);
				
				local pixel = CreateMOPixel("Lighting Damage 1");
				pixel.Vel = Vector(60, 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 2.0);
				pixel.Pos = self.Pos - Vector(2, 0):RadRotate(self.RotAngle);
				pixel.Team = self.Team -- It doesn't work, somehow
				pixel.IgnoresTeamHits = true;
				MovableMan:AddParticle(pixel);
				
				if (MOIDCheck and MOIDCheck ~= rte.NoMOID and MovableMan:GetMOFromID(MOIDCheck).Team ~= self.Team) then
					local MO = MovableMan:GetMOFromID(MOIDCheck)
					if MO and IsMOSRotating(MO) then
						local actor = MovableMan:GetMOFromID(MO.RootID)
						if (actor and IsActor(actor)) and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO.PresetName,"Leg") or string.find(MO.PresetName,"Head"))) then
							actor = ToActor(actor)
							actor:FlashWhite(150)
							actor.Status = 1
							actor.Vel = actor.Vel * 0.5 + Vector(RangeRand(-1,1), RangeRand(-0.5,-1.0))
						end
					end
				end
			end
			break
		else
			self.Pos = newPos
		end
		
		local glowA = CreateMOPixel("Lighting Spark "..math.random(2,3));
		glowA.Pos = self.Pos;
		MovableMan:AddParticle(glowA);
		
		if RangeRand(0,1) >= fac then
			local glowB = CreateMOPixel("Lighting Spark "..math.random(4,5));
			glowB.Pos = self.Pos - travel * RangeRand(0.3,0.6);
			MovableMan:AddParticle(glowB);
		end
		
		self.RotAngle = self.RotAngle + RangeRand(-1,1) * 0.035 + RangeRand(-1,1) * 0.075 * fac
		--DrawCircleDir(self.Pos, 2, self.RotAngle)
		
		local g = math.random(1,2)
		if math.random(1, 100) <= 15 / g then
			local maxj = math.random(2,8) * g
			local minj = 0
			local branchPos = self.Pos
			local branchRotAngle = self.RotAngle + math.pi * 0.3 * (math.random(0,1) * 2 - 1) + RangeRand(-1,1) * 0.5
			for j = minj, maxj do
				local facj = j / maxj
				
				local newBranchPos = Vector(branchPos.X, branchPos.Y) + Vector(RangeRand(1,5), RangeRand(-1,1)):RadRotate(branchRotAngle)
				local terrCheck = SceneMan:GetTerrMatter(newBranchPos.X, newBranchPos.Y)
				if terrCheck ~= 0 then
					break
				else
					local glowA = CreateMOPixel("Lighting Spark "..math.random(1,2));
					glowA.Pos = newBranchPos;
					MovableMan:AddParticle(glowA);
					
					if RangeRand(0,1) >= facj then
						local glowB = CreateMOPixel("Lighting Spark "..math.random(3,5));
						glowB.Pos = newBranchPos;
						MovableMan:AddParticle(glowB);
					end
					
					branchPos = newBranchPos
					branchRotAngle = branchRotAngle + RangeRand(-1,1) * 0.3
				end
				
			end
		end
	end
end

function Update(self)
	self.ToDelete = true
end