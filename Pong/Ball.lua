--[[
	-- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
	Modified by Meet Patel
	
    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]

Ball = Class{}


-- Parameterized constructor
function Ball:init(x, y, radius)
	self.x = x
	self.y = y
	self.radius = radius

	self.dy = math.random(2) == 1 and 100 or -100 										-- Go either on upper diretion or lower direction
	self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)    -- Generate random number inclusive -50 and 50
end

--[[
	Upates the Ball positon based on the current time
]]--
function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

--[[
	Places the ball in the middle of the windows with random values
]]--
function Ball:reset(dt)
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2
	self.dy = math.random(2) == 1 and 100 or -100 
	self.dx = math.random(-50, 50) 
end

--[[
	Detects the collision between walls and paddles
]]--
function Ball:collides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.radius then
		return false
	end
	
	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.radius then
		return false
	end

	return true
end

--[[
	Draws the ball based on the dimensions provided
]]--
function Ball:render()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end
