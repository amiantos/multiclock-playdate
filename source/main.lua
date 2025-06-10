import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "Clock.lua"
import "ClockHand.lua"
import "Action.lua"
import "Patterns.lua"

local gfx <const> = playdate.graphics

-- object storage

local clocks = {}

local groups = {{},{},{},{}}

-- timers

local mainTimer = nil

-- themes

local themes = {
	default = {
		hourHand = gfx.imagetable.new("images/themes/default/hourHands"),
		minuteHand = gfx.imagetable.new("images/themes/default/minuteHands"),
		face = gfx.image.new("images/themes/default/face"),
		background = gfx.image.new("images/black-background")
	},
	defaultReversed = {
		hourHand = gfx.imagetable.new("images/themes/defaultReversed/hourHands"),
		minuteHand = gfx.imagetable.new("images/themes/defaultReversed/minuteHands"),
		face = gfx.image.new("images/themes/defaultReversed/face"),
		background = gfx.image.new("images/white-background")
	}
}

-- settings

local MilitaryTimeEnabled = false

local current_theme = themes.default
local current_theme_string = "default"

-- core animation functions

function displayPattern(pattern)
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

-- animation helpers

function spinWithDelay(params)
	local params = params or {degrees=180, delay=10}
	local current_pattern = getCurrentDisplayAsPattern()
	printTable(getCurrentDisplayAsPattern())
end

function displayTime()
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

function displayRandomPattern()
	displayPattern(createRandomPattern())
end

function getCurrentDisplayAsPattern()
	local pattern = {}
	for n, cluster in ipairs(groups) do
		local group = {}
		for i, clock in ipairs(cluster) do
			group[i] = {
				clock.hourClockHand.current_degrees,
				clock.minuteClockHand.current_degrees
			}
		end
		pattern[n] = group
	end
	return pattern
end

-- lifecycle

function updateClock()
	displayTime()
	mainTimer = playdate.timer.performAfterDelay(3000, updateClock)
end

local animationsCompleted = 0
local ticksSinceLastAnimation = 0
local isAnimating = false

function animationComplete()
	animationsCompleted += 1
	if animationsCompleted == 48 then
		print("All hands have stopped moving...")
		animationsCompleted = 0
		ticksSinceLastAnimation = 0
	end
end

function changeTheme(theme_string)
	if theme_string ~= current_theme_string then
		current_theme_string = theme_string
		if current_theme_string == "default" then
			current_theme = themes.default
		else
			current_theme = themes.defaultReversed
		end
		setBackground()
		setClockTheme()
		print("Changed theme to", current_theme_string)
	end
end

function setBackground()
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
			current_theme.background:draw( 0, 0 )
			gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
		end
	)
end

function setClockTheme()
	for i, clock in ipairs(clocks) do
		clock:setTheme(current_theme)
	end
end

-- action stuff


local actionQueue = {
	Action.sequence({
		{func=displayTime},
	})
}

local actionArrays = {
	{
		Action.sequence({
			{func=displayTime},
			{func=spinClocks, attribute=180}
		}),
		Action.wait(5),
		Action.sequence({
			{func=displayTime}
		})
	},
	{
		Action.sequence({
			{func=spinClocks, attribute=90},
			{func=displayPattern, attribute=boxPattern},
			{func=spinClocks, attribute=90}
		}),
		Action.wait(5),
		Action.sequence({
			{func=displayPattern, attribute=boxPattern}
		})

	},
	{
		Action.sequence({
			{func=displayPattern, attribute=inwardPointPattern},
		}),
		Action.wait(5),
		Action.sequence({
			{func=spinClocks, attribute=720}
		}),
		Action.sequence({
			{func=displayPattern, attribute=halfDownHalfUp},
		}),
	},
	{
		Action.sequence({
			{func=displayPattern, attribute=horizontalLinesPattern},
		})
	},
	{
		Action.sequence({
			{func=displayRandomPattern},
		})
	}
}

-- local displayTimeAnimationCombinations = {
-- 	{
-- 		{func=displayTime},
-- 		{func=spinClocks, attribute=180}
-- 	}
-- }


-- update

function playdate.update()

	if playdate.isCrankDocked() then
		if #actionQueue > 0 then
			local currentAction = actionQueue[1]
			currentAction:update()
			if currentAction.finished == true then
				table.remove(actionQueue, 1)
				if #actionQueue == 0 then
					print("All actions exhausted...")
				end
			end
		else
			ticksSinceLastAnimation += 1
			if ticksSinceLastAnimation >= 150 then
				print("Picking random action...")
				local randomActionArray = actionArrays[math.random(1, #actionArrays)]
				for i, action in ipairs(randomActionArray) do
					action:reset()
					table.insert(actionQueue, action)
				end
			end
		end
	else
		local ticks = playdate.getCrankTicks(360)
		if  ticks > 0 then
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
		displayPattern(boxPattern)
	elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
		displayPattern(inwardPointPattern)
	elseif playdate.buttonJustPressed(playdate.kButtonRight) then
		for index, clock in ipairs(clocks) do
			clock:addDestinations(0, 0)
		end
	elseif playdate.buttonJustPressed(playdate.kButtonA) then
		displayTime()
	elseif playdate.buttonJustPressed(playdate.kButtonB) then
		spinClocks(180)
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

end

-- setup

function playdate.gameWillPause()
	local pauseImage = gfx.image.new(400, 240, gfx.kColorWhite)
	gfx.pushContext(pauseImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
	gfx.drawTextAligned("MultiClock", 100, 20, kTextAlignment.center)
	
	gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
	gfx.drawTextAligned("Controls:", 100, 60, kTextAlignment.center)
	gfx.drawText("Ⓐ: Show time", 10, 90)
	gfx.drawText("Ⓑ: Spin clocks", 10, 110)
	gfx.drawText("⬆: Random", 10, 130)
	gfx.drawText("⬇: Box pattern", 10, 150)
	gfx.drawText("⬅: Points", 10, 170)
	gfx.drawText("➡: Reset", 10, 190)
	gfx.drawText("Crank: Manual", 10, 210)
	
	gfx.popContext()
	playdate.setMenuImage(pauseImage)
end

function setup()

	-- add menu options
	local menu = playdate.getSystemMenu()
	local timeFormatMenu, error = menu:addCheckmarkMenuItem("24 hour", MilitaryTimeEnabled, function(value)
		MilitaryTimeEnabled = value
		table.insert(actionQueue, Action.sequence({
			{func=displayTime},
		}))
	end)

	local themeOptionMenu, error = menu:addOptionsMenuItem(
		"theme",
		{"default", "reversed"},
		"default",
		function(value)
			changeTheme(value)
		end
	)


	-- create clocks
	for n=0,2,1 do
		for i=0,7,1 do
			-- create face
			local faceSprite = gfx.sprite.new(current_theme.face)
			faceSprite:add()
			faceSprite:moveTo(25+(i*50),70+(n*50))

			-- create hour hands
			local hourHandSprite = ClockHand.new(current_theme.hourHand, animationComplete)
			hourHandSprite:moveTo(25+(i*50),70+(n*50))

			-- create minute hands
			local minuteHandSprite = ClockHand.new(current_theme.minuteHand, animationComplete)
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

	setBackground()

	-- updateClock()

end

setup()
