
-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "AnimatedSprite.lua"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

local numberPatterns = { 
	[0] = {
		{90, 180},
		{270, 180},
		{180, 0},
		{180, 0},
		{90, 0},
		{270, 0}
	},
	[1] = {
		{225, 225},
		{180, 180},
		{225, 225},
		{180, 0},
		{225, 225},
		{0, 0}
	},
	[2] = {
		{90, 90},
		{270, 180},
		{180, 90},
		{270, 0},
		{0, 90},
		{270, 270}
	},
	[3] = {
		{90, 90},
		{270, 180},
		{90, 90},
		{0, 270},
		{90, 90},
		{270, 0}
	},
	[4] = {
		{180, 180},
		{180, 180},
		{0, 90},
		{0, 180},
		{225, 225},
		{0, 0}
	},
	[5] = {
		{180, 90},
		{270, 270},
		{0, 90},
		{270, 180},
		{90, 90},
		{270, 0}
	},
	[6] = {
		{180, 90},
		{270, 270},
		{0, 180},
		{270, 180},
		{0, 90},
		{0, 270}
	},
	[7] = {
		{90, 90},
		{270, 180},
		{225, 225},
		{180, 0},
		{225, 225},
		{0, 0}
	},
	[8] = {
		{90, 180},
		{270, 180},
		{90, 0},
		{270, 0},
		{0, 90},
		{270, 0}
	},
	[9] = {
		{90, 180},
		{270, 180},
		{90, 0},
		{0, 180},
		{90, 90},
		{270, 0}
	}
	
}

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local hourHandImageTable = gfx.imagetable.new("Images/HourHand")
assert(hourHandImageTable)

local clocks = {}

local groups = {{},{},{},{}}

local degreesToFrames = {
	[0] = 1,
	[45] = 3,
	[90] = 5,
	[135] = 7,
	[180] = 9,
	[225] = 11,
	[270] = 13,
	[315] = 15,
}

-- set time function

function setTime()
	local current_time = playdate.getTime()
	local string_hour = tostring(current_time.hour)
	if string_hour.len == 1 then
		string_hour = "0" .. string_hour
	end
	local string_minute = tostring(current_time.minute)
	if string_minute.len == 1 then
		string_minute = "0" .. string_minute
	end
	
	print(string_hour .. string_minute)

	local hour_first = tonumber(string.sub(string_hour, 1, 1))
	local hour_second = tonumber(string.sub(string_hour, 2, 2))
	local minute_first = tonumber(string.sub(string_minute, 1, 1))
	local minute_second = tonumber(string.sub(string_minute, 2, 2))
	
	local hour_first_pattern = numberPatterns[hour_first]
	local hour_second_pattern = numberPatterns[hour_second]
	local minute_first_pattern = numberPatterns[minute_first]
	local minute_second_pattern = numberPatterns[minute_second]
	
	for index, pattern in ipairs({
		hour_first_pattern, hour_second_pattern, minute_first_pattern, minute_second_pattern
	}) do
		local clock_group = groups[index]
		for i=1,6,1 do
			local positions = pattern[i]
			local clock = clock_group[i]
			clock.hourHands.destination_frame = degreesToFrames[positions[1]]
			clock.minuteHands.destination_frame = degreesToFrames[positions[2]]
		end
	end
end

-- A function to set up our game environment.

function myGameSetUp()
	
	-- create clocks
	for n=0,2,1 do
		for i=0,7,1 do
			-- create hour hands
			hourHandSprite = gfx.sprite.new(hourHandImageTable:getImage(1))
			hourHandSprite.tick = 0
			hourHandSprite.current_frame = 1
			hourHandSprite.destination_frame = 1
			hourHandSprite:moveTo(25+(i*50),70+(n*50))
			hourHandSprite:add()
			-- create minute hands
			minuteHandSprite = gfx.sprite.new(hourHandImageTable:getImage(1))
			minuteHandSprite.tick = 0
			minuteHandSprite.current_frame = 1
			minuteHandSprite.destination_frame = 1
			minuteHandSprite:moveTo(25+(i*50),70+(n*50))
			minuteHandSprite:add()
			
			local clock = {hourHands=hourHandSprite, minuteHands=minuteHandSprite}
			table.insert(clocks, clock)
			
			if i == 0 or i == 1 then
				table.insert(groups[1], clock)
			elseif i == 2 or i == 3 then
				table.insert(groups[2], clock)
			elseif i == 4 or i == 5 then
				table.insert(groups[3], clock)
			elseif i == 6 or i == 7 then
				table.insert(groups[4], clock)
			end
			
		end
	end
	
	-- set background

	local backgroundImage = gfx.image.new( "Images/main-screen" )
	assert( backgroundImage )
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
			backgroundImage:draw( 0, 0 )
			gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
		end
	)
	
	-- create timer

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()
	
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		setTime()
	end
	
	for index, clock in ipairs(clocks) do
		for key, hand in pairs(clock) do
			hand.tick += 1
			if hand.tick % 3 == 0 then
				if hand.current_frame ~= hand.destination_frame then
					hand.current_frame += 1
					if hand.current_frame > 16 then
						hand.current_frame = 1
					end
					hand:setImage(hourHandImageTable:getImage(hand.current_frame))
				end
			end
		end
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

end