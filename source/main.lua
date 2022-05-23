import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "Clock.lua"
import "ClockHand.lua"

local gfx <const> = playdate.graphics

-- settings

local MilitaryTimeEnabled = false

-- timers

local mainTimer = nil

-- patterns

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

-- objects

local hourHandImageTable = gfx.imagetable.new("Images/hourHands")
assert(hourHandImageTable)
local minuteHandImageTable = gfx.imagetable.new("Images/minuteHands")
assert(minuteHandImageTable)

local clocks = {}

local groups = {{},{},{},{}}

-- functions

function setTime()
	local current_time = playdate.getTime()

	-- get hour
	local current_hour = current_time.hour
	if MilitaryTimeEnabled == false then
		if current_hour > 12 then
			current_hour = current_hour - 12
		elseif current_hour == 0 then
			current_hour = 12
		end
	end

	local string_hour = tostring(current_hour)
	if #string_hour == 1 then
		string_hour = "0" .. string_hour
	end

	-- get minute
	local string_minute = tostring(current_time.minute)
	if #string_minute == 1 then
		string_minute = "0" .. string_minute
	end

	-- split out digits
	local hour_first_digit = tonumber(string.sub(string_hour, 1, 1))
	local hour_second_digit = tonumber(string.sub(string_hour, 2, 2))
	local minute_first_digit = tonumber(string.sub(string_minute, 1, 1))
	local minute_second_digit = tonumber(string.sub(string_minute, 2, 2))

	-- get pattern for each digit
	local hour_first_digit_pattern = numberPatterns[hour_first_digit]
	local hour_second_digit_pattern = numberPatterns[hour_second_digit]
	local minute_first_digit_pattern = numberPatterns[minute_first_digit]
	local minute_second_digit_pattern = numberPatterns[minute_second_digit]

	-- apply patterns
	for index, pattern in ipairs({
		hour_first_digit_pattern,
		hour_second_digit_pattern,
		minute_first_digit_pattern,
		minute_second_digit_pattern
	}) do
		local clock_group = groups[index]
		for i=1,6,1 do
			local positions = pattern[i]
			local clock = clock_group[i]
			clock:addDestinations(positions[1], positions[2])
		end
	end
end

function updateClock()
	setTime()
	mainTimer = playdate.timer.performAfterDelay(3000, updateClock)
end

-- setup

function setup()

	-- add menu options
	local menu = playdate.getSystemMenu()
	local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("24 hour", MilitaryTimeEnabled, function(value)
		MilitaryTimeEnabled = value
	end)

	-- create clocks
	for n=0,2,1 do
		for i=0,7,1 do
			-- create hour hands
			local hourHandSprite = ClockHand.new(hourHandImageTable)
			hourHandSprite:moveTo(25+(i*50),70+(n*50))

			-- create minute hands
			local minuteHandSprite = ClockHand.new(minuteHandImageTable)
			minuteHandSprite:moveTo(25+(i*50),70+(n*50))

			local clock = Clock.new(hourHandSprite, minuteHandSprite)
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

	updateClock()

end

setup()

-- update

function playdate.update()

	if not playdate.isCrankDocked() then
		local ticks = playdate.getCrankTicks(32)
		if  ticks ~= 0 then
			for index, clock in ipairs(clocks) do
				clock:advanceFrames(ticks)
			end
		end
	end

	if playdate.buttonJustPressed( playdate.kButtonUp ) then
		for index, clock in ipairs(clocks) do
			clock:addDestinations(math.random(0, 359), math.random(0, 359))
		end
	elseif playdate.buttonJustPressed(playdate.kButtonDown) then
		for index, clock in ipairs(clocks) do
			clock:advanceFrames(1)
		end
	elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
		setTime()
	elseif playdate.buttonJustPressed(playdate.kButtonRight) then

	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

end
