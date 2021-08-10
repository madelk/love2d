function setupEnemies()
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
        if not v.pathSegmentNumber then
            v.pathSegmentNumber = 1
        end
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
    end
    for k, v in pairs(enemies) do
        if screenPosition > v.x then
            table.insert(visibleEnemies, v)
            table.remove(enemies, k)
        end
    end
end