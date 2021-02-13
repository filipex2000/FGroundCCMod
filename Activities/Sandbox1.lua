--package.loaded.Constants = nil; require("Constants");

----------------------
--- Start Activity ---
----------------------

function Sandbox:StartActivity()
	PresetMan:ReloadAllScripts();	-- reload .lua files
	
	self.actorName = "Scooter"--"Novamech Robot"
	self.actorSpawnPos = Vector(50, 600);
end

function Sandbox:PauseActivity(pause)
end

function Sandbox:EndActivity()
end

function Sandbox:DoBrainSelection()
end

function Sandbox:UpdateActivity()
	if not self.actor or self.actor and self.actor.ID == 255 then
		local actor = CreateActor(self.actorName);
		actor.Pos = self.actorSpawnPos;
		actor.Team = Activity.TEAM_1;
		actor.IgnoresTeamHits = true;
		MovableMan:AddActor(actor);
		self.actor = actor
	end
	PrimitiveMan:DrawCirclePrimitive(self.actorSpawnPos, 3, 13);
	PrimitiveMan:DrawCirclePrimitive(self.actorSpawnPos, 1, 5);
end
