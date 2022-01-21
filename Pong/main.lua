-- Author: Colton Ogden
-- cogden@cs50.harvard.edu
-- Modified by Meet Patel

-- Originally programmed by Atari in 1972. Features two
-- paddles, controlled by players, with the goal of getting
-- the ball past your opponent's edge. First to 10 points wins.

-- This version is built to more closely resemble the NES than
-- the original Pong machines or the Atari 2600 in terms of
-- resolution, though in widescreen (16:9) so it looks nicer on 
-- modern systems.


-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- Implements Paddle class and it's properties
require 'Paddle'

-- Implements Ball class and it's properties
require 'Ball'


WINDOWS_WIDTH = 1280  -- Constant variable to set the width of the windows
WINDOWS_HEIGHT = 720  -- Constant variable to set the height of the windows


VIRTUAL_WIDTH = 432   -- Constant variable to set the width of the game so it will look similar to retro 
VIRTUAL_HEIGHT = 243  -- Constant variable to set the height of the game so it will look similar to retro

PADDLE_SPEED = 200 	  -- Constant variable to set the paddle speed 

--[[
 	Loads the function once the program is initialized
]]--
function love.load()

	-- Sets the texture of the fonts to look more retro type (default is linear which causes bluriness)
	love.graphics.setDefaultFilter('nearest','nearest')

	-- Generates a random number based on current time
	math.randomseed(os.time())

	-- Loads a font file from a specified path with font size
	titleFont = love.graphics.newFont('font.ttf', 8)

	-- Loads a font file from a specified path with font size
	scoreFont = love.graphics.newFont('font.ttf', 16)

	-- Loads a font file from a specified path with font size
	winningFont = love.graphics.newFont('font.ttf', 32)

	-- set the font as current font which can be only one at a time
	love.graphics.setFont(titleFont)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
		--['win'] = love.audio.newSource('sounds/win.wav', 'static')
	}

	-- Initialize the virtual window inside the actual window 
	-- Replaces the love.Window.setMode 
	push:setupScreen(VIRTUAL_WIDTH,	VIRTUAL_HEIGHT, WINDOWS_WIDTH, WINDOWS_HEIGHT, {
			fullscreen = false, -- Fullscreen is allowed or not
			resizable = true,   -- Set the window to resizable
			vsync = true,		-- Set the vsync to on
			canvas = false
	})

	-- Sets the tile of the window
	love.window.setTitle("Pong")

	-- Initialize the paddle
	player1 = Paddle(10, 25, 5, 23) 								    -- Player 1 is Left side paddle
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 48, 5, 23)    -- Player 2 is Right side paddle
 
	-- Places the ball in the middle of the window
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4)

	-- Intital state to start the game with player1
	ServingPlayer = 1

    -- Sets the state of the game to start to determine the behaviour of the game
	gameState = 'start'
end

--[[
	Called whenever the dimensions are changed while resizing the window
]]--
function love.resize(w ,h) 
	push:resize(w, h)
end

--[[
	Function will executed based on specified time
]]
function love.update(dt)

	-- Decide the direction of the ball based on last serve
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if ServingPlayer == 1 then
			ball.dx = - math.random(140, 200)
		else
			ball.dx = math.random(140, 200)
		end

	elseif gameState == 'play' then
		-- Detects the collision with player 1 based on that it revers the position of the ball
		if ball:collides(player1) then
			ball.dx = - ball.dx * 1.03
			ball.x = player1.x + 5

			-- Keep velocity going in same direction but randomize that
			if ball.dy < 0 then
				ball.dy = - math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		-- Detects the collision with player 2 based on that it revers the position of the ball
		if ball:collides(player2) then
			ball.dx = - ball.dx * 1.03
			ball.x = player2.x - 5

			-- Keep velocity going in same direction but randomize that
			if ball.dy < 0 then
				ball.dy = - math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
			sounds['paddle_hit']:play()
		end
	

		-- Detects the boundry on the top and bottom side
		if ball.y <= 2 then
			ball.y = 2
			ball.dy = - ball.dy
			sounds['wall_hit']:play()

		-- Virtual height minus 4 (Size of the ball)
		elseif ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = - ball.dy
			sounds['wall_hit']:play()
		end

		-- Calculate the score based on the x-axis
		if ball.x < 0 then
			ServingPlayer = 2
			player2.score = player2.score + 1
			sounds['score']:play()

			if player2.score == 10 then
				--sound['win']:play()
				winningPlayer = 2
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			ServingPlayer = 1
			player1.score = player1.score + 1
			sounds['score']:play()
			
			if player1.score == 10 then
			--	sound['win']:play()
				winningPlayer = 1
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end
	end

	-- Player 1 movement
	if love.keyboard.isDown('w') then
		player1.dy = - PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- Player 2 movement
	if love.keyboard.isDown('up') then
		player2.dy = - PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	-- Update ball movement based on its DX and DY if it's play state
	if gameState == 'play' then
		ball:update(dt)
	end 

	player1:update(dt)
	player2:update(dt)
end

--[[
	Execute when specific key is pressed and perform the operation based on that
]]
function love.keypressed(key)
	-- If the condition is true then it will go into this loop
	if key == 'escape' then
		love.event.quit() -- Quit the window
	-- When the enter button is pressed it changes the state of the game
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'

			ball:reset() -- Reset the ball position

			-- Resets the score
			player1.score = 0
			player2.score = 0

			-- Decides the serving player based on the winning
			if winningPlayer == 1 then
				ServingPlayer = 2
			else
				ServingPlayer = 1
			end
		end
	end
end

--[[
	Function Used to draw something on the screen
]]--
function love.draw()
	-- Begin rendering at virtual resolution
	push:apply('start')

	-- Shows the FPS of the system
	displayFPS()
	

	-- Clear the screen with specified colours and using the RGBA format
	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	-- Sets the font size to the score font
	love.graphics.setFont(scoreFont)

	if gameState ~= 'done' then
		-- Print the score of player 1
		love.graphics.print(tostring(player1.score), VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 4)

		-- Print the score of player 2
		love.graphics.print(tostring(player2.score), (VIRTUAL_WIDTH * 2) / 3, VIRTUAL_HEIGHT / 4)
	end

	-- Print the messgae on the top center of the virtual Window
	-- When the game state is start it prints the message
	if gameState == 'start' then
		love.graphics.setFont(titleFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')

	-- When one player scores then it prints which player is serving 
	elseif gameState == 'serve' then
		love.graphics.setFont(titleFont)
		love.graphics.printf('Player ' .. tostring(ServingPlayer) .. "'s Serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')

	-- When the game is already going n so no message at that time
	elseif gameState == 'play' then

	-- Whent the game is done it asks the use of they want to restart the game and then decides the serve base on the previous game's winning
	elseif gameState == 'done' then
		love.graphics.setFont(winningFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' Wins !', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(titleFont)
		love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')
		ball:reset() -- Reset the ball position
	end

	
	-- Render paddles on left and right side
	player1:render()
	player2:render()

	-- Render ball in the middle of the window
	ball:render()

	-- End rendering at virtual resolution
	push:apply('end')
end

--[[
	Prints the FPS of the system
]]--
function displayFPS()
	love.graphics.setFont(titleFont)
	love.graphics.setColor(0, 255/255, 0, 255/255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 16, 10)
end