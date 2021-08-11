function setupPlayer()
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
    player.lives = 3
    player.boundary.xmin = player.shipsize + 1
    player.boundary.xmax = window.x / 3
    player.boundary.ymin = 1
    player.boundary.ymax = window.y - player.shipsize
end

function playerLoseLife()
    if player.lives == 0 then
        Scene = "gameover"
    else
        player.lives = player.lives - 1
        player.x = window.x / 4
        player.y = window.y / 2
    end
end

function gameOver()

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
    if love.keyboard.isDown("space") then
        playerFirePressed()
    end
end

function playerFirePressed()
    if player.bulletCooldownTimer == 0 then
        table.insert(player.bullets, {player.x, player.y})
        player.bulletCooldownTimer = player.bulletCooldown
    end
end

function updatePlayerParticle(dt)
    particleSystem:moveTo(player.x - 16, player.y + 8)
    particleSystem:update(dt) -- This performs the simulation of the particles.
end
