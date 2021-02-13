

function Create(self)
end

function Update(self)
	--[[ -- No need for it, in here
	local act = MovableMan:GetMOFromID(self.RootID);
	local actor = act and act.ID ~= rte.NoMOID and MovableMan:IsActor(act) and ToActor(act) or nil;
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		--actor:GetController():SetState(Controller.AIM_SHARP,false);
	end]]
	
	if self.FiredFrame then
		local lastChainID = 0
		local v = "B" -- Variant
		for i = 1, 16 do -- Chain Count
			local chain = CreateMOSParticle("Particle Chainshot "..v); -- Instead of "A", "B" variants, TODO replace with "1", "2" variants
			chain.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle); -- TODO: replace with muzzle offset
			chain.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle + RangeRand(-1, 1) * 0.3) * RangeRand(50, 70); -- Randomize velocity for cooler effect
			chain.PinStrength = 5000 -- Prevent any movement in the first frame when sharpness is broken!!!
			chain:SetWhichMOToNotHit(MovableMan:GetMOFromID(self.RootID),-1);
			
			local actor = MovableMan:GetMOFromID(self.RootID); -- Prevent F.F.
			if actor and IsAHuman(actor) then
				chain.Team = actor.Team;
				chain.Frame = self.Frame;
				chain.IgnoresTeamHits = true;
			end
			MovableMan:AddParticle(chain);
			
			if lastChainID then -- Create a Link/Joint connection
				--chain:SetNumberValue("LinkID", lastChainID)
				chain.Sharpness = lastChainID
			end
			lastChainID = chain.UniqueID 
			
			-- Simple hack for chain variation
			if v == "B" then
				v = "A"
			else
				v = "B"
			end
			
		end
	end
end