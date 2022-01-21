--[[
	-- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
	Modified by Meet Patel
	
    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}


-- Parameterized constructor
function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0           -- Y positon of the paddle
	self.score = 0;
end

--[[
	Upates the paddle positon when the appropriate button is pressed
]]--
function Paddle:update(dt)
	-- Loop through the y positon 
	-- It cheks that it does not go out of bound in both direction
	if self.dy < 0 then
		self.y = math.max(1, self.y + self.dy * dt) 
	else
		self.y = math.min(VIRTUAL_HEIGHT - self.height + 1, self.y +  self.dy * dt)
	end
end

--[[
	Draws the paddle based on the dimensions provided
]]--
function Paddle:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
