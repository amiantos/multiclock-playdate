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

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local hourHandImageTable = gfx.imagetable.new("Images/HourHand")
assert(hourHandImageTable)


-- A function to set up our game environment.

function myGameSetUp()
	
	for n=0,4,1 do
		for i=0,7,1 do
			hourHandSprite = AnimatedSprite.new(hourHandImageTable)
			hourHandSprite:moveTo(25+(i*50),45+(n*50))
			hourHandSprite:add()
			hourHandSprite:addState("slow spin", 1, 8, {tickStep=2})
			hourHandSprite:changeState("slow spin", true)
		end
	end

	local backgroundImage = gfx.image.new( "Images/main-screen" )
	assert( backgroundImage )
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
			backgroundImage:draw( 0, 0 )
			gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
		end
	)
	

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

	
	
	gfx.sprite.update()
	playdate.timer.updateTimers()

end