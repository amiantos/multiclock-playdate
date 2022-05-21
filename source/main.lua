import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

-- settings

local MilitaryTimeEnabled = false

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

-- functions

function setTime()
	local current_time = playdate.getTime()
	local string_hour = tostring(current_time.hour)
	if MilitaryTimeEnabled == false and current_time.hour > 12 then
		string_hour = tostring(current_time.hour - 12)
	end
	if #string_hour == 1 then
		string_hour = "0" .. string_hour
	end
	local string_minute = tostring(current_time.minute)
	if #string_minute == 1 then
		string_minute = "0" .. string_minute
	end

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

function updateClock()
	print("Clock updated")
	setTime()
	local timer = playdate.timer.performAfterDelay(3000, updateClock)
end

function startClock()
	print("Start clock")
	setTime()
	local timer = playdate.timer.performAfterDelay(3000, updateClock)
end

-- setup

function myGameSetUp()
	
	-- add menu options
	local menu = playdate.getSystemMenu()
	local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("24 hour", MilitaryTimeEnabled, function(value)
		print("Checkmark menu item value changed to: ", value)
		MilitaryTimeEnabled = value
	end)
	
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
	
	startClock()

end

myGameSetUp()

-- update

function playdate.update()
	
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
			if hand.tick >= 300 then
				hand.tick = 0
			end
		end
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

end