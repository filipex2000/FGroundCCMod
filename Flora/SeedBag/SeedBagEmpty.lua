

function Create(self)
	self.Frame = 0
end

function Update(self)
	self.Frame = math.min(math.floor((self.FrameCount - 1) * self.Age / 400 + 0.5), (self.FrameCount - 1))
end