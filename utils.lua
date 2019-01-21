function playSound(sound)
  if sound:isPlaying() then
      sound:stop()
      sound:play()
  else
      sound:play()
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