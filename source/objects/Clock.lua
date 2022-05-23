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
