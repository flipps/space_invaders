enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemy_space_between = 80

function enemies_controller:spawnEnemy(x, y)
  enemy = {}
  enemy.x = x + enemy_space_between
  enemy.y = y
  enemy.width = 16 * 3 -- increasing enemy image size by 3 in Draw function
  enemy.height = 13 * 3 -- increasing enemy image size by 3 in Draw function
  enemy.speed = 0.5
  enemy.cooldown = 20
  enemy.resistance = 1
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

-- function spawnEnemyWaves(spawn_waves_time)
--   print(spawn_waves_time)
--   if spawn_waves_time <= 0 and game_over == false then
--       spawn_waves_time = 200
--       for i=0, 6 do
--           enemies_controller:spawnEnemy(i * 100, 0)
--       end
--   end
-- end