enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
love.graphics.setDefaultFilter('nearest', 'nearest') -- Filter to scale image with no distortion.
enemies_controller.image = love.graphics.newImage('enemy.png')
enemy_space_between = 80

function love.load()
    player = {
        width = 80,
        height = 20,
        bullets = {},
        speed = 5,
        fireCooldown = 20,
        x = 0,
        y = 550
    }

    player.fire = function()
        if player.fireCooldown <= 0 then
            player.fireCooldown = 20
            bullet = {}
            bullet.size = 5
            bullet.x = player.x + ((player.width / 2) - (bullet.size / 2))
            bullet.y = player.y
            bullet.speed = 10
            table.insert(player.bullets, bullet)
        end
    end

    for i=3, 1, -1 do
        enemies_controller:spawnEnemy(love.math.random(20, 780), 0)
    end
end

function enemies_controller:spawnEnemy(x, y)
    enemy = {}
    enemy.x = x + enemy_space_between
    enemy.y = y
    enemy.size = 16 * 5 -- increasing enemy image size by 5 in Draw function
    enemy.speed = 2
    enemy.cooldown = 20
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
    return dx * dx + dy * dy < (ar + br) * (ar + br)
end

function love.update(dt)

    player.fireCooldown = player.fireCooldown - 1

    movePlayer()

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
        if e.y >= 620 then
            table.remove(enemies_controller.enemies, i)
        end

        e.y = e.y + e.speed
    end

    -- Check enemies and bullets collision
    for i,b in ipairs(player.bullets) do
        for j,e in ipairs(enemies_controller.enemies) do
            if checkBulletEnemyCollision(b.x, b.y, e.x, e.y, b.size, e.size) then
                table.remove(player.bullets, i)
                table.remove(enemies_controller.enemies, j)
            end
        end
    end
end

function love.draw()
    -- Draw player
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)
    
    -- Draw enemies
    for _,e in pairs(enemies_controller.enemies) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 5) -- first value before x and y is rotation, then the size.
    end

    -- Draw bullets
    for _,b in pairs(player.bullets) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', b.x, b.y, b.size, b.size)
    end
end
