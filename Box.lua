local Box = {x = 0,
  y = 0,
  width = 0,
  height = 0,
}

function Box:new(o)
  local b = o or {}
  self.__index = self
  setmetatable(b, self)
  
  return b
end

return Box