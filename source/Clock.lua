import 'CoreLibs/object'

class("Clock").extends()

function Clock.new(hourClockHand, minuteClockHand)
	return Clock(hourClockHand, minuteClockHand)
end

function Clock:init(hourClockHand, minuteClockHand)
	Clock.super.init(self)

	self.hourClockHand = hourClockHand
	self.minuteClockHand = minuteClockHand
end

-- move hands

function Clock:advanceFrames(frames)
	self.hourClockHand:advance(frames)
	self.minuteClockHand:advance(frames)
end

function Clock:addDestinations(hourHandDestination, minuteHandDestination)
	self.hourClockHand:addDestination(hourHandDestination)
	self.minuteClockHand:addDestination(minuteHandDestination)
end
