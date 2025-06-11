import 'CoreLibs/object'
import 'CoreLibs/sprites'

local gfx <const> = playdate.graphics

class("ClockHand").extends(gfx.sprite)

function ClockHand.new(imagetable, animationCallback)
	return ClockHand(imagetable, animationCallback)
end

function ClockHand:init(imagetable, animationCallback)
	ClockHand.super.init(self)

	self.imagetable = imagetable
	self.animationCallback = animationCallback

	self.clockwise = true

	self.tick = 0
	self.current_frame = 1

	self.current_degrees = 0
	self.destination_degrees = {}

	self:setImage(self.imagetable[1])

	self:add()
end

function ClockHand:changeImagetable(imagetable)
	self.imagetable = imagetable
	self:setImage(self.imagetable:getImage(self.current_frame))
end

function ClockHand:getNextDegrees()
	local current_degrees = 0
	if #self.destination_degrees == 0 then
		return self.current_degrees
	else
		return self.destination_degrees[#self.destination_degrees]
	end
end

-- animating

function ClockHand:convertDegreesToFrames(degrees)
	local conversion_ratio = 360 / #self.imagetable
	local frames = math.floor(1 + degrees / conversion_ratio)
	while frames > #self.imagetable do
		frames -= #self.imagetable
	end
	return frames
end

function ClockHand:convertFrameToDegrees(frame)
	local conversion_ratio = 360 / #self.imagetable
	return conversion_ratio * (frame - 1)
end

function ClockHand:addDestination(destination_degrees)
	table.insert(self.destination_degrees, destination_degrees)
end

function ClockHand:setDirectPosition(degrees)
	-- Clear any pending animations for direct control
	self.destination_degrees = {}
	
	-- Normalize degrees to 0-359
	while degrees < 0 do
		degrees += 360
	end
	while degrees >= 360 do
		degrees -= 360
	end
	
	-- Set position directly
	self.current_degrees = degrees
	self.current_frame = self:convertDegreesToFrames(degrees)
	self:setImage(self.imagetable:getImage(self.current_frame))
end

function ClockHand:advance(frames)
	print(frames)

	if #self.destination_degrees > 0 then
		self:addDestination(self.destination_degrees[#self.destination_degrees] + frames)
	else
		self:addDestination(self.current_degrees + frames)
	end
end

function ClockHand:isMoving()
	return #self.destination_degrees > 0
end

function ClockHand:update()
	ClockHand.super.update()

	self.tick += 1
	if #self.destination_degrees > 0 and self.tick % 2 == 0 then
		local destination_degrees = self.destination_degrees[1]
		local destination_frame = self:convertDegreesToFrames(destination_degrees)
		if self.current_frame ~= destination_frame then
			-- it would be cool if destination degrees could have direction baked into them
			if self.clockwise then
				self.current_frame += 1
			else
				self.current_frame -= 1
			end

			if self.current_frame > #self.imagetable then
				self.current_frame = 1
			elseif self.current_frame < 1 then
				self.current_frame = #self.imagetable
			end
			self:setImage(self.imagetable:getImage(self.current_frame))
			self.current_degrees = self:convertFrameToDegrees(self.current_frame)
		end

		if self.current_frame == destination_frame then
			self.current_degrees = destination_degrees
			table.remove(self.destination_degrees, 1)
		end

		-- if we exhaust all destination frames, turn off reverse
		if #self.destination_degrees == 0 then
			self.clockwise = true
			self.animationCallback()
		end
	end

	-- reset ticks now and then just to avoid max ints
	if self.tick >= 300 then
		self.tick = 0
	end

end
