require("player")
require("enemies")
require("game")

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
    setupEnemies()
    createParticle()
    onScreenPowerups = {}
    onScreenPowerupRotationSpeed = 0.1
    Scene = "title"
end

function love.update(dt)
    updateMainGame(dt)
end

function love.keyreleased(key)
    if key =="space" then
        if Scene == "title" then
            Scene = "game"
        elseif Scene == "gameover" then
            love.load()
        else
            playerFirePressed()
        end
    end
 end

-- function pressAKey()
--     if love.keyreleased("space") then
--         if Scene == "title" then
--             Scene = "game"
--         elseif Scene == "gameover" then
--             love.load()
--         end
--     end
-- end

function updateMainGame(dt)
    updateEmemies(dt)
    collisionDetection()
    updateStars(dt)
    updatePowerups(dt)
    updatePlayerBullets(dt)
    handlePlayerInput(dt)
    screenPosition = screenPosition + gameSettings.scrollSpeed
end

function love.draw()
    if Scene == "title" then
        drawTitle()
    elseif Scene == "gameover" then
        drawGameOver()
    else
        drawMainGame()
    end
end

function drawTitle()
    love.graphics.print("Space Shooter", 0, 0)
end
function drawGameOver()
    love.graphics.print("u ded", 0, 0)
end
function drawMainGame()
    beWhite()
    love.graphics.draw(particleSystem)
    love.graphics.print(score .. " | " .. player.lives, 0, 0)

    for k, v in pairs(visibleEnemies) do
        love.graphics.draw(img, v.enemyType.graphics, v.x, v.y, math.pi / 2)
    end
    for k, v in pairs(onScreenPowerups) do
        love.graphics.draw(img, powerup, v.x, v.y, v.rotation, 1, 1, 8, 8)
    end

    for k, v in pairs(player.bullets) do
        love.graphics.draw(img, bullet, v[1], v[2], math.pi / 2)
    end
    love.graphics.points(stars)
    love.graphics.draw(img, ship, player.x, player.y, math.pi / 2)
    love.graphics.setFont(gameFont)
end
