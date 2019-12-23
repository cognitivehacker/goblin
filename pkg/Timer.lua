local Timer = {}

function Timer:new(o)
  local t = o or {}
  self.__index = self
  setmetatable(t, self)
  
  if not t.seconds then
    error("The object Timer must have \"seconds\" parameter")
  end
  
  t.timer = t.seconds
  
  t.dead = false

  return t
end

function Timer:onDead(g)
end

function Timer:run(g, dt)
  if self.timer <= 0 then 
    self.exec(g)
    
    if self.times then
      self.times = self.times - 1

      if self.times <= 0 then
        self.dead = true
      end
   end

    self.timer = self.seconds
    
    return
  end
  
  self.timer = self.timer - dt
end

function Timer:isDead()
    return self.dead
end

return Timer