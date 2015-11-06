local shader
local canvas
local time = 0

function love.load(arg)
    shader = love.graphics.newShader('MetaHexaBalls.glsl')
    canvas = love.graphics.newCanvas(800, 600)
end

function love.update(dt)
    time = dt + time;
    shader:send('iResolution', { love.window.getWidth(), love.window.getHeight(), 1 })
    shader:send('iGlobalTime', time)
    shader:send('iMouse', { love.mouse.getX(), love.mouse.getY(), love.mouse.getX(), love.mouse.getY() })
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.setShader(shader)
  love.graphics.draw(canvas)
  love.graphics.setShader()
  love.graphics.setCanvas()
  love.graphics.draw(canvas,0,0,0,1,1,0,0)
end
