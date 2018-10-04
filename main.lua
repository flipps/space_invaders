enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemy_space_between = 80
distance = 0
spawn_waves_time = 100

-- assets
love.graphics.setDefaultFilter('nearest', 'nearest') -- Filter to scale image with no distortion.
enemies_controller.image = love.graphics.newImage('enemy.png')
ambienceSound = love.audio.newSource('ambience.mp3', 'stream')
laserShotSound = love.audio.newSource('laser_shot.wav', 'static')
enemyDestroyedSound = love.audio.newSource('enemy_down.mp3', 'static')

function love.load()
    game_over = false
    ambienceSound:play()

    player = {
        width = 80,
        height = 20,
        bullets = {},
        speed = 5,
        fireCooldown = 20,
        x = 0,
        y = 550,
        points = 0,
        image = love.graphics.newImage('ship.png')
    }

    player.fire = function()
        if player.fireCooldown <= 0 then
            playSound(laserShotSound)
            player.fireCooldown = 20
            bullet = {}
            bullet.size = 5
            bullet.x = player.x + ((player.width / 2) - (bullet.size / 2))
            bullet.y = player.y
            bullet.speed = 10
            table.insert(player.bullets, bullet)
        end
    end
end

function playSound(sound)
    if sound:isPlaying() then
        sound:stop()
        sound:play()
    else
        sound:play()
    end
end

function enemies_controller:spawnEnemy(x, y)
    enemy = {}
    enemy.x = x + enemy_space_between
    enemy.y = y
    enemy.width = 16 * 3 -- increasing enemy image size by 3 in Draw function
    enemy.height = 13 * 3 -- increasing enemy image size by 3 in Draw function
    enemy.speed = 0.5
    enemy.cooldown = 20
    enemy.resistance = 2
    enemy.value = 20
    table.insert(self.enemies, enemy)
end

function enemy:fire() -- enemy:fire is short for enemy.fire(self) which is a reference to the table we created at the load function.
    if self.cooldown <= 0 then
        self.cooldown = 20
        bullet = {}
        bullet.x = self.x - (self.size / 2)
        bullet.y = self.y
        table.insert(enemies, bullet)
    end
end

function spawnEnemyWaves()
    spawn_waves_time = spawn_waves_time - 1

    if spawn_waves_time <= 0 and game_over == false then
        spawn_waves_time = 100
        for i=0, 5 do
            enemies_controller:spawnEnemy(i * 100, 0)
        end
    end
end

function movePlayer()
    if love.keyboard.isDown('right') then
        player.x = player.x + player.speed
    elseif love.keyboard.isDown('left') then
        player.x = player.x - player.speed
    end
    
    --Lock player to the screen width (Love game window size default is 800x600)
    if player.x >= (800 - player.width) then
        player.x = 800 - player.width
    elseif player.x < 0 then
        player.x = 0
    end
end

function checkBulletEnemyCollision(ax, ay, bx, by, ar, br)
	local dx = bx - ax
    local dy = by - ay
    local testRadii = (ar + br)^2
    distance = math.sqrt(dx * dx + dy * dy)
    -- print(testRadii, distance)
    return dx * dx + dy * dy < (ar + br) * (ar + br)
end

function boundBoxCollision(ax, ay, w1, h1, bx, by, w2, h2)
    return ax < bx + w2 and
    bx < ax + w1 and
    ay < by + h2 and
    by < ay + h1
end

function love.update(dt)

    player.fireCooldown = player.fireCooldown - 1

    movePlayer()
    spawnEnemyWaves()

    -- Fire!
    if love.keyboard.isDown('space') then
        player.fire()
    end
    
    -- If the bullet moves out of the screen remove it from the table(performance issue).
    for i,b in ipairs(player.bullets) do
        if b.y < -5 then
            table.remove(player.bullets, i)
        end

        b.y = b.y - b.speed
    end

    -- Enemies positioning
    for i,e in ipairs(enemies_controller.enemies) do
        if e.y >= love.graphics.getHeight() then
            game_over = true
            table.remove(enemies_controller.enemies, i)
        end
        
        e.y = e.y + e.speed
    end

    -- Check enemies and bullets collision
    for i,b in ipairs(player.bullets) do
        for j,e in ipairs(enemies_controller.enemies) do
            if boundBoxCollision(b.x, b.y, b.size, b.size, e.x, e.y, e.width, e.height - 15) then
                e.resistance = e.resistance - 1

                if e.resistance <= 0 then
                    e.resistance = 2
                    player.points = player.points + e.value
                    table.remove(enemies_controller.enemies, j)
                    playSound(enemyDestroyedSound)
                end

                table.remove(player.bullets, i)
            end
        end
    end
end

function displayPlayerPoints(points)
    if game_over == false then
        love.graphics.print('Points:', 20, 20)
        love.graphics.print(points, 20, 40)
    end
end

function love.draw()
    displayPlayerPoints(player.points)

    -- If an enemy reaches the bottom of the screen, game over!
    if game_over then
        love.graphics.print('Game Over!')
        love.audio.stop(ambienceSound, laserShotSound, enemyDestroyedSound)
        return
    end

    -- Draw player
    -- love.graphics.setColor(255, 255, 0)
    love.graphics.draw(player.image, player.x, player.y)
    
    -- Draw enemies
    for _,e in pairs(enemies_controller.enemies) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 3) -- first value before x and y is rotation, then the size.
    end

    -- Draw bullets
    for _,b in pairs(player.bullets) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', b.x, b.y, b.size, b.size)
    end
end
