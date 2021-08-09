function love.load()
    window = {}
    window.x = 400
    window.y = 240
    gameSettings = {}
    gameSettings.chanceOfStar = 2
    stars = {}
    for i = 1, window.x do
        addStarMaybe(i)
    end
    score = 0
    gameFont = love.graphics.newFont(40)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    img = love.graphics.newImage("spritemap.png")
    player = {}
    player.x = window.x / 4
    player.y = window.y / 2
    player.speed = 0.4
    player.bullets = {}
    player.bulletSpeed = 2
    ship = love.graphics.newQuad(0, 0, 16, 16, img:getDimensions())
    bullet = love.graphics.newQuad(16, 0, 16, 16, img:getDimensions())
end

function addStarMaybe(x)
    if love.math.random(0, 100) < gameSettings.chanceOfStar then
        local y = love.math.random(0, window.y)
        table.insert(stars, {x, y})
    end
end

function updateStars()
    for k, v in pairs(stars) do
        local newx = v[1] - player.speed
        stars[k] = {newx, v[2]}
        if newx < 0 then
            table.remove(stars, k)
        end
    end
    addStarMaybe(window.x)
end

function updatePlayerBullets()
    for k, v in pairs(player.bullets) do
        local newx = v[1] + player.bulletSpeed
        player.bullets[k] = {newx, v[2]}
        if newx > window.x then
            table.remove(player.bullets, k)
        end
    end
end

function handlePlayerInput()
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
    if love.keyboard.isDown("space") then
        table.insert(player.bullets, {player.x, player.y})
    end
end

function love.update(dt)
    updateStars()
    updatePlayerBullets()
    handlePlayerInput()

end

function love.draw()
    for k, v in pairs(player.bullets) do
        love.graphics.draw(img, bullet, v[1], v[2], math.pi / 2)
    end
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
