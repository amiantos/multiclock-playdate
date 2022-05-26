import 'CoreLibs/object'

class("Animation").extends()

function Animation.new(functions)
	return Animation(functions)
end

function Animation.wait(delay)
	return Animation({}, delay)
end

function Animation:init(functions, delay)
	Animation.super.init(self)

	-- functions is array of functions to run
	self.functions = functions
	-- delay is seconds, convert to ticks
	self.delay = (delay or 0) * 30

	self.fired = false
end

function Animation:update()
	if self.fired == false then
		if self.delay == 0 then
			for index, func in ipairs(self.functions) do
				if func.func then
					func.func(func.attribute)
				end
			end
			self.fired = true
		end
		self.delay -= 1
	end
end
