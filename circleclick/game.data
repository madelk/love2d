function love.load()
    target = {}
    target.x = 100
    target.y = 100
    target.radius = 50
    number = 0
    score = 0
    timer = 60
    gameFont = love.graphics.newFont(40)
    love.window.setMode(400, 240, flags)
end

function love.update(dt)
    number = number + 1
end

function love.draw()
    beWhite()
    love.graphics.setFont(gameFont)
    love.graphics.print(score, 0, 0)
    love.graphics.circle("fill", target.x, target.y, target.radius)
end

function beWhite()
    love.graphics.setColor(1, 1, 1)
end

function beBlack()
    love.graphics.setColor(0, 0, 0)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        if mouseToTarget < target.radius then
            score = score + 1
            target.x = math.random(0 + target.radius, love.graphics.getWidth() - target.radius)
            target.y = math.random(0 + target.radius, love.graphics.getHeight() - target.radius)
        end
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
