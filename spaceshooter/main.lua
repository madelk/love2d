function love.load()
    window = {}
    window.x = 400
    window.y = 240
    gameSettings = {}
    gameSettings.chanceOfStar = 2
    gameSettings.scrollSpeed = 50
    stars = {}
    for i = 1, window.x do
        addStarMaybe(i)
    end
    screenPosition = window.x
    score = 0
    gameFont = love.graphics.newFont(40)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    img = love.graphics.newImage("spritemap.png")
    player = {}
    player.x = window.x / 4
    player.y = window.y / 2
    player.speed = 60
    player.bullets = {}
    player.bulletSpeed = 200
    player.bulletCooldown = 25
    player.bulletCooldownTimer = 0
    player.shipsize = 16
    player.boundary = {}
    player.boundary.xmin = player.shipsize + 1
    player.boundary.xmax = window.x / 3
    player.boundary.ymin = 1
    player.boundary.ymax = window.y - player.shipsize
    ship = love.graphics.newQuad(0, 0, player.shipsize, player.shipsize, img:getDimensions())
    bullet = love.graphics.newQuad(16, 0, 16, 16, img:getDimensions())
    alien = love.graphics.newQuad(32, 0, 16, 16, img:getDimensions())
    enemies = {{410, 20}, {420, 200}}
    enemiesSpeed = 10;
    visibleEnemies = {}
    createParticle()
end

function createParticle()
	-- Create a simple image with a single white pixel to use for the particles.
	-- We could load an image from the hard drive but this is just an example.
	local imageData = love.image.newImageData(1, 1)
	imageData:setPixel(0,0, 1,1,1,1)

	local image = love.graphics.newImage(imageData)

	-- Create and initialize the particle system object.
	particleSystem = love.graphics.newParticleSystem(image, 1000)
	particleSystem:setEmissionRate(50)
    particleSystem:setLinearAcceleration( -500, 0, -1000, 0 )
	particleSystem:setParticleLifetime(.2, .5)
	particleSystem:setDirection(1*math.pi)
	particleSystem:setSizes(1)
	particleSystem:setSpread(.5*math.pi)
	particleSystem:setSpeed(50, 80)
	particleSystem:setColors(1,1,1,1)
end

function addStarMaybe(x)
    if love.math.random(0, 100) < gameSettings.chanceOfStar then
        local y = love.math.random(0, window.y)
        table.insert(stars, {x, y})
    end
end

function updateStars(dt)
    for k, v in pairs(stars) do
        local newx = v[1] - gameSettings.scrollSpeed * dt
        stars[k] = {newx, v[2]}
        if newx < 0 then
            table.remove(stars, k)
        end
    end
    addStarMaybe(window.x)
end

function updatePlayerBullets(dt)
    if player.bulletCooldownTimer > 0 then
        player.bulletCooldownTimer = player.bulletCooldownTimer - 1
    end
    for k, v in pairs(player.bullets) do
        local newx = v[1] + player.bulletSpeed * dt
        player.bullets[k] = {newx, v[2]}
        if newx > window.x then
            table.remove(player.bullets, k)
        end
    end
end

function handlePlayerInput(dt)
    if love.keyboard.isDown("up") and player.y >= player.boundary.ymin then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("down") and player.y <= player.boundary.ymax then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("left") and player.x >= player.boundary.xmin then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("right") and player.x <= player.boundary.xmax then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("space") and player.bulletCooldownTimer == 0 then
        table.insert(player.bullets, {player.x, player.y})
        player.bulletCooldownTimer = player.bulletCooldown
    end
end

function updateEmemies(dt)
    for k, v in pairs(visibleEnemies) do
        local newx = v[1] - (gameSettings.scrollSpeed + enemiesSpeed) * dt
        visibleEnemies[k] = {newx, v[2]}
        if newx < 0 then
            table.remove(visibleEnemies, k)
        end
    end
    for k, v in pairs(enemies) do
        if screenPosition > v[1] then
            table.insert(visibleEnemies, v)
            table.remove(enemies, k)
        end
    end
end

function collisionDetection()
    for bk, bv in pairs(player.bullets) do
        for ek, ev in pairs(visibleEnemies) do
            if CheckCollision(bv[1], bv[2], 16, 16, ev[1], ev[2], 16, 16) then
                table.remove(visibleEnemies, ek)
                table.remove(player.bullets, bk)
                score = score + 1
            end
        end
    end
end

function updatePlayerParticle(dt)
	particleSystem:moveTo(player.x-16, player.y+8)
	particleSystem:update(dt) -- This performs the simulation of the particles.
end

function love.update(dt)
    updateEmemies(dt)
    collisionDetection()
    updateStars(dt)
    updatePlayerBullets(dt)
    handlePlayerInput(dt)
    screenPosition = screenPosition + gameSettings.scrollSpeed
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function love.draw()
    beWhite()
	love.graphics.draw(particleSystem)
    love.graphics.print(score, 0, 0)

    for k, v in pairs(visibleEnemies) do
        love.graphics.draw(img, alien, v[1], v[2], math.pi / 2)
    end

    for k, v in pairs(player.bullets) do
        love.graphics.draw(img, bullet, v[1], v[2], math.pi / 2)
    end
    love.graphics.points(stars)
    love.graphics.draw(img, ship, player.x, player.y, math.pi / 2)
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
