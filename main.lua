require 'utils'

require 'player/player'
require 'invaders/enemy'

distance = 0
spawn_waves_time = 200
game_started = false

-- assets
love.graphics.setDefaultFilter('nearest', 'nearest') -- Filter to scale image with no distortion.

enemies_controller.image = love.graphics.newImage('assets/images/enemy.png')
game_title = love.graphics.newImage('assets/images/invadets_title.png')
play_button = love.graphics.newImage('assets/images/play.png')
ambienceSound = love.audio.newSource('assets/audio/ambience.mp3', 'stream')
laserShotSound = love.audio.newSource('assets/audio/laser_shot.wav', 'static')
enemyDestroyedSound = love.audio.newSource('assets/audio/enemy_down.mp3', 'static')
player.image = love.graphics.newImage('assets/images/ship.png')

function love.load()
    game_over = false

    if game_over == false then
        ambienceSound:play()
    end

end

function love.mousepressed(x, y, button)
    local playButtonX = love.graphics.getWidth() / 2 - play_button:getWidth() / 2
    if button == 1 then
        if x >= playButtonX and 
        x <= playButtonX + play_button:getWidth() and 
        y >= love.graphics.getHeight() / 2 and 
        y <= love.graphics.getHeight() / 2 + play_button:getHeight() then
            game_over = false
            game_started = true
        end
    end
end

function love.update(dt)

    player.fireCooldown = player.fireCooldown - 1
    spawn_waves_time = spawn_waves_time - 1

    if game_started then
        movePlayer()
        if spawn_waves_time <= 0 and game_over == false then
            spawn_waves_time = 200
            for i=0, 6 do
                enemies_controller:spawnEnemy(i * 100, 0)
            end
        end
    end

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
            game_started = false
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
                    e.resistance = 1
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

    if game_started == false then
        love.graphics.draw(game_title, love.graphics.getWidth() / 2 - game_title:getWidth() / 2, love.graphics.getHeight() / 3)
        love.graphics.draw(play_button, love.graphics.getWidth() / 2 - play_button:getWidth() / 2, love.graphics.getHeight() / 2)
        love.audio.pause(laserShotSound, enemyDestroyedSound)
    else
        love.graphics.draw(game_title, game_title:getWidth() + 800)
    end

    -- If an enemy reaches the bottom of the screen, game over!
    if game_over then
        love.graphics.draw(game_title, love.graphics.getWidth() / 2 - game_title:getWidth() / 2, love.graphics.getHeight() / 3)
        love.graphics.draw(play_button, love.graphics.getWidth() / 2 - play_button:getWidth() / 2, love.graphics.getHeight() / 2)
        love.graphics.print('Game Over!')
        enemies_controller.enemies = {}
        player.points = 0
        love.audio.pause(laserShotSound, enemyDestroyedSound)
        return
    end

    -- Draw player
    if game_over == false then
        if game_started then
            love.graphics.draw(player.image, player.x, player.y)
        end
        
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
    
end