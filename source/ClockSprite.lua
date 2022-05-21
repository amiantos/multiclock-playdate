import 'CoreLibs/object'
import 'CoreLibs/sprites'
local gfx <const> = playdate.graphics

class("ClockSprite").extends(gfx.sprite)

function ClockSprite.new(hourHandImagetable)
	return ClockSprite(hourHandImagetable)
end

function ClockSprite:init(hourHandImageTable)
	ClockSprite.super.init(self)
	
	-- self.hourHandImageTable =
end

function ClockSprite:update()
	-- TODO: do stuff 
end