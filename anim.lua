local a = Object:extend()

function a:new(frames, fps, loop, pause)
	pause = pause or 0
	--self.frames = {}
	self.frames = frames
	self.fps = fps
	self.loop = loop
	self.pause = pause
	self.len = #frames + pause
	self.clock = 0
	self.frame = 1
end

function a:update(dt)
	self.clock = self.clock + dt
	if self.clock > 1 / self.fps then
		if self.loop then
			if type(self.loop) == "function" then
				self.frame = self.frame + 1
				if self.frame > #self.frames then
					self.loop()
					self.frame = self.frame - 1
				end
			else
				self.frame = self.frame % self.len + 1
			end
		else
			self.frame = min(self.frame + 1, #self.frames)
		end
		self.clock = 0
	end
end

function a:get()
	return self.frames[self:getFrame()]
end

function a:getFrame()
	if self.frame <= self.pause then
		return 1
	else
		return self.frame - self.pause
	end
end

function a:reset()
	self.frame = 1
	self.clock = 0
end

return a
