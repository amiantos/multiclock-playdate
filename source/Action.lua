import 'CoreLibs/object'

class("Action").extends()

function Action.sequence(functions)
	return Action(functions)
end

function Action.wait(delay)
	return Action({}, delay)
end

function Action:init(functions, delay)
	Action.super.init(self)

	-- functions is array of functions to run
	self.functions = functions
	-- delay is seconds, convert to ticks
	self.delay = (delay or 0) * 30
	self.initial_delay = self.delay

	self.finished = false
end

function Action:reset()
	-- reset animation so the objects can be reused
	self.finished = false
	self.delay = self.initial_delay
end


function Action:update()
	if self.finished == false then
		if self.delay == 0 then
			for index, func in ipairs(self.functions) do
				if func.func then
					func.func(func.attribute)
				end
			end
			self.finished = true
		end
		self.delay -= 1
	end
end
