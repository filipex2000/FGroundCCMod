
function Create(self)
	-- Sounds
	self.soundHitSuccessful = CreateSoundContainer("Beat Blaster Hit Successful", "FGround.rte");
	
	self.beatSounds = {}
	
	-- Drum Kick
	self.beatSounds["Drum Kick A"] = CreateSoundContainer("Beat Blaster Drum Kick A", "FGround.rte");
	self.beatSounds["Drum Kick Basic A"] = CreateSoundContainer("Beat Blaster Drum Kick Basic A", "FGround.rte");
	self.beatSounds["Drum Kick Funky A"] = CreateSoundContainer("Beat Blaster Drum Kick Funky A", "FGround.rte");
	self.beatSounds["Drum Kick Funkalicious A"] = CreateSoundContainer("Beat Blaster Drum Kick Funkalicious A", "FGround.rte");
	-- Drum Snare
	self.beatSounds["Drum Snare A"] = CreateSoundContainer("Beat Blaster Drum Snare A", "FGround.rte");
	self.beatSounds["Drum Snare Basic A"] = CreateSoundContainer("Beat Blaster Drum Snare Basic A", "FGround.rte");
	self.beatSounds["Drum Snare Funky A"] = CreateSoundContainer("Beat Blaster Drum Snare Funky A", "FGround.rte");
	self.beatSounds["Drum Snare Funkalicious A"] = CreateSoundContainer("Beat Blaster Drum Snare Funkalicious A", "FGround.rte");
	-- Drum Hihat
	self.beatSounds["Drum Hihat A"] = CreateSoundContainer("Beat Blaster Drum Hihat A", "FGround.rte");
	self.beatSounds["Drum Hihat Basic A"] = CreateSoundContainer("Beat Blaster Drum Hihat Basic A", "FGround.rte");
	self.beatSounds["Drum Hihat Funky A"] = CreateSoundContainer("Beat Blaster Drum Hihat Funky A", "FGround.rte");
	self.beatSounds["Drum Hihat Funkalicious A"] = CreateSoundContainer("Beat Blaster Drum Hihat Funkalicious A", "FGround.rte");
	
	self.beatDrumKick = self.beatSounds["Drum Kick A"]
	self.beatDrumSnare = self.beatSounds["Drum Snare A"]
	self.beatDrumHihat = self.beatSounds["Drum Hihat A"]
	
	self.beatMusic = {}
	self.beatMusicList = {"Choco"}
	self.beatMusicStages = {"None", "Basic", "Funky", "Funkalicious"}
	
	self.beatMusic["Choco"] = {
		Length = 6,
		Kick = "A",
		Snare = "A",
		Hihat = "A",
		None = {
			{"Drum Kick", "Drum Hihat"}, -- Primary
			{"Drum Snare", ""}, -- Secondary
			{"Drum Kick", ""}, -- Pri
			{"Drum Snare", ""}, -- Sec
			{"Drum Kick", ""}, -- Pri
			{"Drum Snare", "Drum Hihat"} -- Sec
		},
		Basic = {
			{}, -- Primary
			{}, -- Secondary
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Funky = {
			{}, -- Primary
			{}, -- Secondary
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Funkalicious = {
			{}, -- Primary
			{}, -- Secondary
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Beat = {
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false -- Sec
		}
	}
	
	self.beatCurrentMusic = self.beatMusicList[1]
	self.beatCurrentMusicBeat = 1
	self.beatCurrentMusicStage = 1
	self.beatCurrentMusicScore = 0
	
	self.beatTimer = Timer()
	self.BPM = 240
	
	self.beatHitDetectionTimer = Timer()
	
	self.activated = false
	self.fired = false
end

function Update(self)
	local actor = self:GetRootParent();
	local parent = nil
	local parentIsPlayer = nil
	local parentController = nil
	if actor and IsActor(actor)  then
		parent = ToActor(actor)
		parentIsPlayer = parent:IsPlayerControlled()
		parentController = parent:GetController()
	end
	
	if parent then
	
		local msPerBeat = 1 / (self.BPM / 60) * 1000
		local music = self.beatMusic[self.beatCurrentMusic]
		local beat = self.beatCurrentMusicBeat
		local beatPrevious = beat - 1
		if beatPrevious < 1 then
			beatPrevious = music.Length
		end
		
		local beatIsSecondary = (beat % 2 == 1)
		local beatCanHit = false -- can fire to the rythm this beat?
		if (music.Beat[beat] and music.Beat[beat] == true) then
			beatCanHit = true
			if self.beatTimer.ElapsedSimTimeMS > msPerBeat * 0.8 then
				self.beatHitDetectionTimer:Reset()
			end
		end
		canHit = not self.beatHitDetectionTimer:IsPastSimMS(150)
		
		if not beatIsSecondary or (self.beatTimer.ElapsedSimTimeMS > msPerBeat * 0.8) then
			-- Head bop
			parent.ViewPoint = parent.ViewPoint + Vector(0, (self.beatTimer.ElapsedSimTimeMS / msPerBeat) * 25 - 12.5)
			
			-- Scale
			self.Scale = 1.0 + 0.2 * (1 - (self.beatTimer.ElapsedSimTimeMS / msPerBeat))
			
			-- Animation
			if self.beatTimer.ElapsedSimTimeMS < msPerBeat * 0.1 then
				self.Frame = 2
			elseif self.beatTimer.ElapsedSimTimeMS < msPerBeat * 0.2 then
				self.Frame = 3
			elseif self.beatTimer.ElapsedSimTimeMS > msPerBeat * 0.8 then
				self.Frame = 1
			else
				self.Frame = 0
			end
		else
			self.Frame = 0
			self.Scale = 1.0
		end
		
		-- Firing
		if parentController then
			-- Debug
			local barOffset = Vector(0, 17)
			local barLength = 10
			-- Stamina
			for i = 0, 1 do
				PrimitiveMan:DrawLinePrimitive(parent.Pos + barOffset + Vector(-barLength, i), parent.Pos + barOffset + Vector(barLength, i), (canHit and 116 or 26));
			end
		end
		
		if self:IsActivated() then
			if not self.activated then
				
				if canHit then
					if not self.fired then
						self.soundHitSuccessful:Play(self.Pos)
						self.fired = false
						self.beatCurrentMusicScore = self.beatCurrentMusicScore + 1
					end
				else
					self.beatCurrentMusicScore = - 5
				end
				
				self.activated = true
			end
		else
			self.activated = false
		end
		self.beatCurrentMusicScore = math.max(self.beatCurrentMusicScore, 0)
		self.beatCurrentMusicStage = math.min(math.ceil(math.max(self.beatCurrentMusicScore / 5 + 0.5, 0)), 4)
		
		
		if self.beatTimer:IsPastSimMS(msPerBeat) then
			local stage = self.beatCurrentMusicStage
			local stages = {"", " Basic", " Funky", " Funkalicious"}
			
			self.beatDrumKick = self.beatSounds["Drum Kick"..stages[stage].." "..music.Kick]
			self.beatDrumSnare = self.beatSounds["Drum Snare"..stages[stage].." "..music.Snare]
			self.beatDrumHihat = self.beatSounds["Drum Hihat"..stages[stage].." "..music.Hihat]
			
			
			for i = 1, self.beatCurrentMusicStage do
				local notes = music[self.beatMusicStages[i]][beat]
				for i, note in ipairs(notes) do
					if note and note ~= "" then
						local soundContainer = nil
						if note == "Drum Kick" then
							soundContainer = self.beatDrumKick
						elseif note == "Drum Snare" then
							soundContainer = self.beatDrumSnare
						elseif note == "Drum Hihat" then
							soundContainer = self.beatDrumHihat
						else
							soundContainer = self.beatSounds[note]
						end
						
						if beatCanHit then
							soundContainer.Volume = 2.0
						else
							soundContainer.Volume = 1.0
						end
						soundContainer:Play(self.Pos)
						
					end
				end
			end
			
			self.fired = false
			self.beatTimer:Reset()
			self.beatCurrentMusicBeat = ((self.beatCurrentMusicBeat) % music.Length) + 1
		end
	
	else
		self.beatTimer:Reset()
		self.Frame = 0
		self.Scale = 1.0
	end
end 