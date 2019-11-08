local physics = require "physics"
physics.start()
local W = display.actualContentWidth
local H = display.actualContentHeight
local _X = display.contentCenterX
local _Y = display.contentCenterY
local x0 = _X - W/2
local y0 = _Y - H/2

local fontColor = {0.8, 0.8, 0.7 , 1}
local lineColor = {0.1, 0.1, 0.1, 1}

local dots ={}
local points = {}
local lines = {}
local collisionCordinate = {}
local stack = {}
local DX

local draw = display.newGroup()
local font = display.newRect( _X, _Y, W, H )
font:setFillColor(unpack(fontColor))
font:toBack()

local function clearEverything()
  display.remove( draw )
  draw = display.newGroup()
  while( #lines ~= 0 ) do
    display.remove(lines[1])
    physics.removeBody( lines[1] )
    table.remove( lines, 1 )
  end
  while( #points ~= 0 ) do
    table.insert( dots, points[1] )
    table.remove( points, 1 )
  end
end

local function setPoint( event )
  if( event.phase == "began") then
    local dot = display.newCircle( draw, event.x, event.y, 5 )
    table.insert( points, {x = event.x, y = event.y})
  end
end

local function setLine(first, second)
  local length = math.sqrt(math.pow(second.x - first.x, 2)+math.pow(second.y - first.y, 2)) --длина прямой
  local line = display.newRect( first.x, first.y, length , 10) -- рисуем прямую вдоль оХ
  line:setFillColor(unpack(lineColor))
  line.anchorX = 0--Вращать будем вокруг начальной точки
  line.x = first.x--Устанавливаем начальную точку
  line.y = first.y
  line.rotation = math.deg(math.atan2(second.y - first.y, second.x - first.x)) -- вращаем
  physics.addBody( line, "static" )
  table.insert( lines, line )
end

local function drawContor()
  local iter
  for iter=1, #points-1, 1 do
    setLine(points[iter], points[iter+1])
  end
  setLine(points[1], points[#points])
  while( #points ~= 0 ) do
    table.insert( dots, points[1] )
    table.remove( points, 1 )
  end
end

local function putInStack( loX, loY )
  table.insert( collisionCordinate, {x = loX, y = loY} )
  local collision = physics.rayCast( loX, loY, loX + DX+30, loY, "sorted" )
  if(collision) then
    for i,v in ipairs( collision ) do
        table.insert( collisionCordinate, {x=v.position.x, y=v.position.y} )--[[
        local circle = display.newCircle( v.position.x, v.position.y, 5 )
        circle:setFillColor(0,1,0,1)--]]
    end
  end
  local pair = {}
  for k=1,#collisionCordinate,1 do
    table.insert( pair, collisionCordinate[k] )
    if(#pair == 2)then
      if( math.abs(pair[1].x - pair[2].x) > 10 ) then
        local collisionCorrection = physics.rayCast( pair[2].x, loY, pair[1].x-W, loY, "closest" )
        local lol = collisionCorrection[1]
        pair[1].x , pair[1].y = lol.position.x, lol.position.y
      end
      display.colorSample( pair[1].x + 1 , pair[1].y, function( event )

          local R = math.round(event.r*10)
          local G = math.round(event.g*10)
          local B = math.round(event.b*10)
          if(R == 8)and(G == 8)and(B == 7) then
            table.insert(stack, pair[1])
            table.remove( pair, 2 )
            table.remove( pair, 1 )
          end
      end )
    end

    --[[for i=1,#points,1 do
      if(collisionCordinate[k] == points[i]) then
        if(i~=#points)and(math.abs(points[i+1].y-points[i].y)/(points[i+1].y-points[i].y)==math.abs(points[i-1].y-points[i].y)/(points[i-1].y-points[i].y)) or (i==#points)and(math.abs(points[1].y-points[i].y)/(points[1].y-points[i].y)==math.abs(points[i-1].y-points[i].y)/(points[i-1].y-points[i].y)) then
          k=k-1
        end
      end
    end]]
  end

  while(#collisionCordinate ~= 0) do
    table.remove(collisionCordinate, 1)
  end
end


local function fillLine( cords )
  local x = cords.x
  local y = cords.y
  local collision = physics.rayCast( x, y, x+W, y, "closest" )
  if(collision) then
    local collisionPoint = collision[1]
    DX = collisionPoint.position.x
    local collisionCorrection = physics.rayCast( DX, y, DX - W, y, "closest" )
    local lol = collisionCorrection[1]
    x, y = lol.position.x, lol.position.y

    DX = DX - x
    local line = display.newLine( draw, x, y, x+DX, y )
    line:setStrokeColor(1,0,0,1)
    line.strokeWidth = 1
  end
end

local function keysActions(event)
  if(event.phase == "down") then
    if(event.keyName == "f") or (event.keyName == "F") or (event.keyName == "а") or (event.keyName == "А") then
      display.remove( draw )
      draw = display.newGroup()
      drawContor()
    elseif(event.keyName == "r") or (event.keyName == "R") or (event.keyName == "к") or (event.keyName == "К") then
      clearEverything()
    elseif(event.keyName == "c") or (event.keyName == "C") or (event.keyName == "с") or (event.keyName == "С") then
      display.remove( draw )
      draw = display.newGroup()
      while(#stack > 0) do
        table.remove(stack, 1)
      end
      table.insert( stack, points[#points] )
      local collisionCorrection = physics.rayCast( stack[1].x, stack[1].y, stack[1].x-W, stack[1].y, "closest" )
      local lol = collisionCorrection[1]
      stack[1].x , stack[1].y = lol.position.x, lol.position.y


      local t = {}
      function t:timer( event )
        fillLine( stack[#stack] )
        local locX, locY = stack[#stack].x, stack[#stack].y
        table.remove( stack, #stack )
        putInStack( locX, locY+1 )
        putInStack( locX, locY-1 )
        if(#stack == 0) then
          print("lox")
          timer.cancel( event.source )
        end
      end

      local time = timer.performWithDelay( 30, t , 0)
    end
  end
end

Runtime:addEventListener("key", keysActions)
font:addEventListener("tap", setPoint)
font:addEventListener("touch", setPoint)
