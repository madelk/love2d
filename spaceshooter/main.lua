require("player")

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
    setupPlayer()
    ship = love.graphics.newQuad(0, 0, player.shipsize, player.shipsize, img:getDimensions())
    bullet = love.graphics.newQuad(16, 0, 16, 16, img:getDimensions())
    alien = love.graphics.newQuad(32, 0, 16, 16, img:getDimensions())
    powerup = love.graphics.newQuad(48, 0, 16, 16, img:getDimensions())
    enemyPaths = {
        default = {{400, 20}, {20, 20}, {20, 200}, {500, 200}}
    }
    standardEnemy = {
        graphics = alien,
        speed = 100
    }
    enemies = {{
        x = 400,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default
    }, {
        x = 430,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default
    }, {
        x = 460,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default,
        powerup = true
    }, {
        x = 490,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default
    }, {
        x = 520,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default
    }, {
        x = 550,
        y = 20,
        enemyType = standardEnemy,
        path = enemyPaths.default
    }}
    enemiesSpeed = 10;
    visibleEnemies = {}
    createParticle()
    onScreenPowerups = {}
end

function createParticle()
    -- Create a simple image with a single white pixel to use for the particles.
    -- We could load an image from the hard drive but this is just an example.
    local imageData = love.image.newImageData(1, 1)
    imageData:setPixel(0, 0, 1, 1, 1, 1)

    local image = love.graphics.newImage(imageData)

    -- Create and initialize the particle system object.
    particleSystem = love.graphics.newParticleSystem(image, 1000)
    particleSystem:setEmissionRate(50)
    particleSystem:setLinearAcceleration(-500, 0, -1000, 0)
    particleSystem:setParticleLifetime(.2, .5)
    particleSystem:setDirection(1 * math.pi)
    particleSystem:setSizes(1)
    particleSystem:setSpread(.5 * math.pi)
    particleSystem:setSpeed(50, 80)
    particleSystem:setColors(1, 1, 1, 1)
end

function addStarMaybe(x)
    if love.math.random(0, 100) < gameSettings.chanceOfStar then
        local y = love.math.random(0, window.y)
        table.insert(stars, {x, y})
    end
end

function updatePowerups(dt)
    for k, v in pairs(onScreenPowerups) do
        local newx = v[1] - gameSettings.scrollSpeed * dt
        onScreenPowerups[k] = {newx, v[2]}
        if newx < 0 then
            table.remove(onScreenPowerups, k)
        end
    end
    addStarMaybe(window.x)
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
-- a is the initial value, b is the destination value, t is a value between 0 and 1 indicating the progress of the "path" between a and b.
function lerp(a, b, t)
    return a + (b - a) * t -- for t==0 you get a, for t==1 you get b, for t==0.5 you get the middle of the two and so on...
end

function moveto(agent, target, dt)
    -- find the agent's "step" distance for this frame
    local step = agent.enemyType.speed * dt

    -- find the distance to target
    local distx, disty = target.x - agent.x, target.y - agent.y
    local dist = math.sqrt(distx * distx + disty * disty)

    if dist <= step then
        -- we have arrived
        agent.x = target.x
        agent.y = target.y
        return true
    end

    -- get the normalized vector between the target and agent
    local nx, ny = distx / dist, disty / dist

    -- find the movement vector for this frame
    local dx, dy = nx * step, ny * step

    -- keep moving
    agent.x = agent.x + dx
    agent.y = agent.y + dy
    return false
end

function updateEmemies(dt)
    for k, v in pairs(visibleEnemies) do
        if not v.pathSegmentNumber then v.pathSegmentNumber = 1 end
        if v.path[v.pathSegmentNumber] then
            local arrived = moveto(v, {
                x = v.path[v.pathSegmentNumber][1],
                y = v.path[v.pathSegmentNumber][2]
            }, dt)
            print(arrived)
            if arrived then
                v.pathSegmentNumber = v.pathSegmentNumber + 1
            end
        end
        -- https://love2d.org/forums/viewtopic.php?t=79168
        -- local newx = v.startX - (gameSettings.scrollSpeed + enemiesSpeed) * dt
        -- local newy = v.startY
        -- local newx = lerp(v.path[1][1], v.startX, -1)
        -- -- score = obj_vx
        -- -- local obj_vx = (v.path[1][1] - v.startX) * v.enemyType.speed
        -- local obj_vy = (v.path[1][2] - v.startY) * v.enemyType.speed
        -- -- score = obj_vx
        -- visibleEnemies[k].startX = newx
        -- visibleEnemies[k].startY = newy
        -- if newx < 0 then
        --     table.remove(visibleEnemies, k)
        -- end
    end
    for k, v in pairs(enemies) do
        if screenPosition > v.x then
            table.insert(visibleEnemies, v)
            table.remove(enemies, k)
        end
    end
end

function collisionDetection()
    for bk, bv in pairs(player.bullets) do
        for ek, ev in pairs(visibleEnemies) do
            if CheckCollision(bv[1], bv[2], 16, 16, ev.x, ev.y, 16, 16) then
                if ev.powerup then table.insert(onScreenPowerups, {ev.x, ev.y}) end
                table.remove(visibleEnemies, ek)
                table.remove(player.bullets, bk)
                score = score + 1
            end
        end
    end
end

function love.update(dt)
    updateEmemies(dt)
    collisionDetection()
    updateStars(dt)
    updatePowerups(dt)
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
        love.graphics.draw(img, v.enemyType.graphics, v.x, v.y, math.pi / 2)
    end
    for k, v in pairs(onScreenPowerups) do
        love.graphics.draw(img, powerup, v[1], v[2], math.pi / 2)
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
