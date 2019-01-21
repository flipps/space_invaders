player = {}

player.width = 80
player.height = 20
player.bullets = {}
player.speed = 5
player.fireCooldown = 20
player.x = 0
player.y = 550
player.points = 0

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

movePlayer = function()
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