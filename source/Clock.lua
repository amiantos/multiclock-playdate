import 'CoreLibs/object'

class("Clock").extends()

function Clock.new(face, hourClockHand, minuteClockHand)
	return Clock(face, hourClockHand, minuteClockHand)
end

function Clock:init(face, hourClockHand, minuteClockHand)
	Clock.super.init(self)

	self.face = face
	self.hourClockHand = hourClockHand
	self.minuteClockHand = minuteClockHand
end

function Clock:setTheme(theme)
	self.face:setImage(theme.face)
	self.hourClockHand:changeImagetable(theme.hourHand)
	self.minuteClockHand:changeImagetable(theme.minuteHand)
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

function Clock:setDirectPositions(hourHandDegrees, minuteHandDegrees)
	self.hourClockHand:setDirectPosition(hourHandDegrees)
	self.minuteClockHand:setDirectPosition(minuteHandDegrees)
end

function Clock:isMoving()
	return self.hourClockHand:isMoving() or self.minuteClockHand:isMoving()
end
