
function Create(self)
	-- Sounds
	self.soundHitSuccessful = CreateSoundContainer("Beat Blaster Hit Success", "FGround.rte");
	self.soundHitFail = CreateSoundContainer("Beat Blaster Hit Fail", "FGround.rte");
	
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
	
	--[[
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
			false, -- Sec
		}
	}
	]]
	self.beatMusic["Choco"] = {
		Length = 240,
		Kick = "A",
		Snare = "A",
		Hihat = "A",
		None = {
			-- 10
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 20
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 30
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 40
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 50
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 60
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 70
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 80
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 90
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 100
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 110
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 120
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 130
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 140
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 150
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 160
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 170
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 180
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 190
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 200
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 210
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 220
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 230
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 240
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Basic = {
			-- 10
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 20
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 30
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 40
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 50
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 60
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 70
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 80
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 90
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 100
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 110
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 120
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 130
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 140
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 150
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 160
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 170
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 180
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 190
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 200
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 210
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 220
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 230
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 240
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Funky = {
			-- 10
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 20
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 30
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 40
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 50
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 60
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 70
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 80
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 90
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 100
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 110
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 120
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 130
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 140
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 150
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 160
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 170
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 180
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 190
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 200
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 210
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 220
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 230
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 240
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Funkalicious = {
			-- 10
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 20
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 30
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 40
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 50
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 60
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 70
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 80
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 90
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 100
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 110
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 120
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 130
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 140
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 150
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 160
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 170
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 180
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 190
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 200
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 210
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 220
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 230
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			-- 240
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{}, -- Sec
			{}, -- Pri
			{} -- Sec
		},
		Beat = {
			-- 1
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 2
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 3
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 4
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 5
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 6
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 7
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 8
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 9
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 10
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 11
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 12
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 13
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 14
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 15
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 16
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 17
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 18
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 19
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 20
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 21
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 22
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 23
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			-- 24
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false,-- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			true, -- Pri
			false, -- Sec
			--
		}
	}
	
	self.beatCurrentMusic = self.beatMusicList[1]
	self.beatCurrentMusicBeat = 1
	self.beatCurrentMusicStage = 1
	self.beatCurrentMusicScore = 0
	
	self.beatTimer = Timer()
	self.BPM = 240
	
	self.beatHitDetectionTimer = Timer()
	
	self.beatScoreDecayTimer = Timer()
	
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
				self.beatScoreDecayTimer:Reset()
				
				if canHit then
					if not self.fired then
						self.soundHitSuccessful:Play(self.Pos)
						
						for i = 1, math.random(2,3) do
							local spread = math.pi * RangeRand(-1, 1) * 0.15
							local velocity = 45 * RangeRand(0.1, 0.9);
							
							local particle = CreateMOSParticle("Beat Blaster Note "..math.random(1,3), "FGround.rte")
							particle.Pos = self.MuzzlePos
							particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
							particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6)
							MovableMan:AddParticle(particle);
							
							self.fired = false
							self.beatCurrentMusicScore = self.beatCurrentMusicScore + 1
						end
					end
				else
					self.beatCurrentMusicScore = self.beatCurrentMusicScore - 10
					self.soundHitFail:Play(self.Pos)
				end
				
				self.activated = true
			end
		else
			self.activated = false
		end
		
		if self.beatScoreDecayTimer:IsPastSimMS(800) then
			self.beatScoreDecayTimer:Reset()
			self.beatCurrentMusicScore = self.beatCurrentMusicScore - math.random(2,3)
		end
		
		self.beatCurrentMusicScore = math.min(math.max(self.beatCurrentMusicScore, 0), 25)
		self.beatCurrentMusicStage = math.min(math.ceil(math.max(self.beatCurrentMusicScore / 10 + 0.5, 0)), 4)
		
		
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
		
		self.beatCurrentMusicScore = 0
		
		self.Frame = 0
		self.Scale = 1.0
	end
end 