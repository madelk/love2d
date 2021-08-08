function love.load()
    window = {}
    window.x = 400
    window.y = 240
    gameSettings = {}
    gameSettings.chanceOfStar = 5
    stars = {}
    for i = 1, window.x do
        addStarMaybe(i)
    end
    number = 0
    score = 0
    timer = 60
    gameFont = love.graphics.newFont(40)
    love.window.setMode(window.x, window.y, {})
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    img = love.graphics.newImage("spritemap.png")
    love.graphics.scale(2, 2)
    player = {}
    player.x = window.x / 4
    player.y = window.y / 2
    player.speed = 0.4

    ship = love.graphics.newQuad(0, 0, 16, 16, img:getDimensions())
end

function addStarMaybe(x)
    if love.math.random(0, 100) < gameSettings.chanceOfStar then
        local y = love.math.random(0, window.y) 
        table.insert(stars,{x, y})
    end
end

function love.update(dt)
    if stars[1][1] < 0 then
        table.remove(stars, 1)
    end

    for k, v in pairs(stars) do
        local newx = v[1] - player.speed
        stars[k] = {newx, v[2]}
      end
    addStarMaybe(window.x)

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed
    end
    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
    end
end

function love.draw()
    love.graphics.points(stars)
    love.graphics.draw(img, ship, player.x, player.y, math.pi / 2)
    beWhite()
    love.graphics.setFont(gameFont)
end

function beWhite()
    love.graphics.setColor(1, 1, 1)
end

function beBlack()
    love.graphics.setColor(0, 0, 0)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
