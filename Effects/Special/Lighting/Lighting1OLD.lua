
function DrawCircleDir(pos, radius, dir)
    PrimitiveMan:DrawCirclePrimitive(pos, radius, 5);
	PrimitiveMan:DrawLinePrimitive(pos, pos + Vector(radius, 0):RadRotate(dir),  13);
end

function Create(self)
	local glow = CreateMOPixel("Lighting Spark 2");
	glow.Pos = self.Pos;
	MovableMan:AddParticle(glow);
	
	self.start = true
	
	self.forks = 0; --DO NOT CHANGE THIS
	self.forkPosX = {}
	self.forkPosY = {}
	self.forkDirection = {}
	self.forkIteration = {}
	self.forkForks = {}
	--[[
	for i = 1, self.projectiles do
		table.insert(self.projectilePosX, i, 0)
		table.insert(self.projectilePosY, i, 0)
		table.insert(self.projectileVelX, i, v.X)
		table.insert(self.projectileVelY, i, v.Y)
		table.insert(self.projectileStuck, i, false)
	end]]
end

function Update(self)
	self.Vel = Vector(0, 0);
	
	if self.start then
		self.forks = self.forks + 1
		local i = self.forks
		local newForkPos = Vector(self.Pos.X, self.Pos.Y) + Vector(20 * RangeRand(0.8,1.2), 0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.2)
		
		table.insert(self.forkPosX, i, newForkPos.X)
		table.insert(self.forkPosY, i, newForkPos.Y)
		table.insert(self.forkDirection, i, self.RotAngle + RangeRand(-1,1) * 0.2)
		table.insert(self.forkIteration, i, 1)
		table.insert(self.forkForks, i, 0)
		self.start = false
		
		local vec = SceneMan:ShortestDistance(Vector(self.Pos.X, self.Pos.Y),newForkPos,SceneMan.SceneWrapsX);
		local maxi = vec.Magnitude/ GetPPM() * 7
		for g = 0, maxi do
			local glow = CreateMOPixel("Lighting Spark "..math.max(6 - self.forkIteration[i], 1));
			glow.Pos = Vector(self.Pos.X, self.Pos.Y) + vec / maxi * g * RangeRand(1.1,0.9) + Vector(RangeRand(-1,1), RangeRand(-1,1));
			MovableMan:AddParticle(glow);
		end
	else
		for j = 1, 2 do -- double sim
			local newForks = self.forks
			for i = 1, self.forks do
				local pos = Vector(self.forkPosX[i], self.forkPosY[i])
				
				if self.forkIteration[i] < 4 and self.forkForks[i] < 2 then
					self.forkForks[i] = self.forkForks[i] + math.random(1,2)
					
					newForks = newForks + 1
					local newIndex = newForks
					local newRotation = RangeRand(-1,1) * self.forkIteration[i] * math.random(1,3) * 0.1 * self.forkForks[i]
					local newForkPosA = pos + Vector(40 * RangeRand(0.8,1.2), 0):RadRotate(self.forkDirection[i] + newRotation)
					
					--PrimitiveMan:DrawLinePrimitive(pos, newForkPosA,  97);
					
					table.insert(self.forkPosX, newIndex, newForkPosA.X)
					table.insert(self.forkPosY, newIndex, newForkPosA.Y)
					table.insert(self.forkDirection, newIndex, self.forkDirection[i] + RangeRand(-1,1) * 0.2)
					table.insert(self.forkIteration, newIndex, self.forkIteration[i] + math.random(1,2))
					table.insert(self.forkForks, newIndex, 0)
					
					if self.forkIteration[i] < 3 and math.random(1,2) < 2 then
						--self.forkForks[i] = self.forkForks[i] + 1
						
						newForks = newForks + 1
						local newIndex = newForks
						local newRotation = self.forkIteration[i] * math.random(1,3) * 0.1 * self.forkForks[i] * RangeRand(0.8,1.2) * (math.random(0,1) - 0.5) * 2
						
						local newForkPosB = pos + Vector(20 * RangeRand(0.8,1.2), 0):RadRotate(self.forkDirection[i] + newRotation)
						
						--PrimitiveMan:DrawLinePrimitive(pos, newForkPosB,  97);
						
						table.insert(self.forkPosX, newIndex, newForkPosB.X)
						table.insert(self.forkPosY, newIndex, newForkPosB.Y)
						table.insert(self.forkDirection, newIndex, self.forkDirection[i] + RangeRand(-1,1) * 0.2)
						table.insert(self.forkIteration, newIndex, self.forkIteration[i] + 1)
						table.insert(self.forkForks, newIndex, 0)
						
						local vec = SceneMan:ShortestDistance(pos,newForkPosB,SceneMan.SceneWrapsX);
						local maxg = vec.Magnitude / GetPPM() * 6
						local bend = vec * 0.5 + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 7
						for g = 0, maxg do
							local glow = CreateMOPixel("Lighting Spark "..math.max(6 - self.forkIteration[newIndex], 1));
							glow.Pos = pos + bend * math.sin(1 / maxg * g * math.pi) + vec / maxg * g * RangeRand(1.1,0.9) + Vector(RangeRand(-1,1), RangeRand(-1,1));
							MovableMan:AddParticle(glow);
						end
					end
					--PrimitiveMan:DrawCirclePrimitive(pos, 1, 97);
					--glow.Pos = pos;
					--MovableMan:AddParticle(glow);
					local vec = SceneMan:ShortestDistance(pos,newForkPosA,SceneMan.SceneWrapsX);
					local maxg = vec.Magnitude / GetPPM() * 6
					local bend = vec * 0.5 + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 7
					for g = 0, maxg do
						local glow = CreateMOPixel("Lighting Spark "..math.max(6 - self.forkIteration[i], 1));
						glow.Pos = pos + bend * math.sin(1 / maxg * g * math.pi) + vec / maxg * g * RangeRand(1.1,0.9) + Vector(RangeRand(-1,1), RangeRand(-1,1));
						MovableMan:AddParticle(glow);
					end
				end
				--self.forkIteration[i] = self.forkIteration[i] + 1
				--DrawCircleDir(pos, 7 / self.forkIteration[i], self.forkDirection[i])
			end
			self.forks = newForks
		end
	end
	
	--DrawCircleDir(Vector(self.Pos.X,self.Pos.Y), 8, self.RotAngle)
end