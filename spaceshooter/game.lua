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
        if not v.rotation then v.rotation = 0 end
        v.rotation = v.rotation + onScreenPowerupRotationSpeed
        local newx = v.x - gameSettings.scrollSpeed * dt
        v.x = newx
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

function collisionDetection()
    collisionDetectionEnemies()
    collisionDetectionPowerUp()
end

function collisionDetectionEnemies()
    for ek, ev in pairs(visibleEnemies) do
        for bk, bv in pairs(player.bullets) do
            if CheckCollision(bv[1], bv[2], 16, 16, ev.x, ev.y, 16, 16) then
                if ev.powerup then
                    table.insert(onScreenPowerups, {
                        x = ev.x+8,
                        y = ev.y+8,
                        rotation = 0
                    })
                end
                table.remove(visibleEnemies, ek)
                table.remove(player.bullets, bk)
                score = score + 1
            end
        end
        if CheckCollision(ev.x, ev.y, 16, 16, player.x, player.y, 16,16) then
            playerLoseLife()
        end
    end
end
function collisionDetectionPowerUp()
    for k, v in pairs(onScreenPowerups) do
        if CheckCollision(v.x, v.y, 16, 16, player.x, player.y, 16, 16) then
            table.remove(onScreenPowerups, k)
            player.speed = player.speed + 30
        end
    end
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

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
