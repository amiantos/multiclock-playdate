import 'CoreLibs/object'
import 'CoreLibs/sprites'

local gfx <const> = playdate.graphics

class("ClockHand").extends(gfx.sprite)

function ClockHand.new(imagetable)
	return ClockHand(imagetable)
end

function ClockHand:init(imagetable)
	ClockHand.super.init(self)

	self.imagetable = imagetable

	self.clockwise = true

	self.tick = 0
	self.current_frame = 1
	self.destination_frames = {}

	self:setImage(self.imagetable[1])

	self:add()

end

-- animating

function ClockHand:addDestination(destination_frame)
	table.insert(self.destination_frames, destination_frame)
end

function ClockHand:advance(frames)
	if #self.destination_frames == 0 then
		if frames < 0 then
			self.clockwise = false
		end
		local destination_frame = self.current_frame + frames
		if destination_frame > #self.imagetable then
			destination_frame = destination_frame - #self.imagetable
		elseif destination_frame < 1 then
			destination_frame = destination_frame + #self.imagetable
		end
		table.insert(self.destination_frames, 1, destination_frame)
	end
end

function ClockHand:update()
	ClockHand.super.update()

	self.tick += 1
	if #self.destination_frames > 0 then
		if self.tick % 3 == 0 then
			local destination_frame = self.destination_frames[1]
			if self.current_frame ~= destination_frame then
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
			end

			if self.current_frame == destination_frame then
				table.remove(self.destination_frames, 1)
			end

			-- if we exhaust all destination frames, turn off reverse
			if #self.destination_frames == 0 then
				self.clockwise = true
			end
		end
	end

	-- reset ticks now and then just to avoid max ints
	if self.tick >= 300 then
		self.tick = 0
	end

end
