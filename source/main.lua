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

local inwardPointPattern = {
	[1] = {
		{105, 105}, {115, 115},
		{90, 90}, {90, 90},
		{75, 75}, {65, 65},
	},
	[2] = {
		{125, 125}, {150, 150},
		{90, 90}, {90, 90},
		{55, 55}, {30, 30},
	},
	[3] = {
		{210, 210}, {235, 235},
		{270, 270}, {270, 270},
		{330, 330}, {305, 305},
	},
	[4] = {
		{245, 245}, {255, 255},
		{270, 270}, {270, 270},
		{295, 295}, {285, 285},
	},
}

local halfDownHalfUp = {
	[1] = {
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
	},
	[2] = {
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
		{180, 180}, {180, 180},
	},
	[3] = {
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
	},
	[4] = {
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
		{0, 0}, {0, 0},
	},
}

local horizontalLinesPattern = {
	[1] = {
		{90, 90}, {270, 90},
		{90, 90}, {270, 90},
		{90, 90}, {270, 90},
	},
	[2] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[3] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[4] = {
		{270, 90}, {270, 270},
		{270, 90}, {270, 270},
		{270, 90}, {270, 270},
	},
}

local boxPattern = {
	[1] = {
		{90, 180}, {270, 90},
		{0, 180}, {90, 90},
		{0, 90}, {270, 90},
	},
	[2] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[3] = {
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
		{270, 90}, {270, 90},
	},
	[4] = {
		{270, 90}, {270, 180},
		{270, 270}, {0, 180},
		{270, 90}, {0, 270},
	},
}

-- objects

local defaultHourHandImageTable = gfx.imagetable.new("images/defaults/hourHands")
assert(defaultHourHandImageTable)
local defaultMinuteHandImageTable = gfx.imagetable.new("images/defaults/minuteHands")
assert(defaultMinuteHandImageTable)
local defaultFaceImage = gfx.image.new("images/defaults/face")
assert(defaultFaceImage)

local clocks = {}

local groups = {{},{},{},{}}

-- animations

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
	displayPattern({
		hour_first_digit_pattern,
		hour_second_digit_pattern,
		minute_first_digit_pattern,
		minute_second_digit_pattern
	})
end

function displayPattern(pattern)
	-- apply patterns
	for index, pattern in ipairs(pattern) do
		local clock_group = groups[index]
		for i=1,6,1 do
			local positions = pattern[i]
			local clock = clock_group[i]
			clock:addDestinations(positions[1], positions[2])
		end
	end
end

function spinClocks(degrees)
	for i, clock in ipairs(clocks) do
		for n, hand in ipairs({clock.hourClockHand, clock.minuteClockHand}) do
			local move_degrees = degrees
			while move_degrees >= 360 do
				local next_degrees = hand:getNextDegrees()
				move_degrees -= 180
				next_degrees += 180
				hand:addDestination(next_degrees)
			end
			local next_degrees = hand:getNextDegrees()
			next_degrees += move_degrees
			hand:addDestination(next_degrees)
		end
	end
end

-- lifecycle

function updateClock()
	setTime()
	mainTimer = playdate.timer.performAfterDelay(3000, updateClock)
end

local animationsCompleted = 0
local timeSinceLastAnimation = 0
local isAnimating = false

function animationComplete()
	animationsCompleted += 1
	if animationsCompleted == 48 then
		print("All hands have stopped moving...")
		animationsCompleted = 0
	end
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
			-- create face
			local faceSprite = gfx.sprite.new(defaultFaceImage)
			faceSprite:add()
			faceSprite:moveTo(25+(i*50),70+(n*50))

			-- create hour hands
			local hourHandSprite = ClockHand.new(defaultHourHandImageTable, animationComplete)
			hourHandSprite:moveTo(25+(i*50),70+(n*50))

			-- create minute hands
			local minuteHandSprite = ClockHand.new(defaultMinuteHandImageTable, animationComplete)
			minuteHandSprite:moveTo(25+(i*50),70+(n*50))

			local clock = Clock.new(faceSprite, hourHandSprite, minuteHandSprite)
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

	local backgroundImage = gfx.image.new( "Images/black-background" )
	assert( backgroundImage )

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
			backgroundImage:draw( 0, 0 )
			gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
		end
	)

	-- updateClock()

end

setup()

-- update

function playdate.update()

	if not playdate.isCrankDocked() then
		local ticks = playdate.getCrankTicks(#defaultHourHandImageTable)
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
		displayPattern(inwardPointPattern)
	elseif playdate.buttonJustPressed(playdate.kButtonRight) then
		for index, clock in ipairs(clocks) do
			clock:addDestinations(0, 0)
		end
	elseif playdate.buttonJustPressed(playdate.kButtonA) then
		setTime()
	elseif playdate.buttonJustPressed(playdate.kButtonB) then
		spinClocks(720)
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

end
