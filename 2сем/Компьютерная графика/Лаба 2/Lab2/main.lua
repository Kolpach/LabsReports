local physics = require("physics")
physics.start()
local W = display.actualContentWidth
local H = display.actualContentHeight

local Grid = display.newGroup()--Несколько переменных
local draw = display.newGroup()
local _X = display.contentCenterX
local _Y = display.contentCenterY
local x0 = display.contentCenterX - (display.actualContentWidth/2)
local y0 = display.contentCenterY - (display.actualContentHeight/2)

local dots = {}
local collisionCordinate = {}
local lines = {}
local drawing = false

local font = display.newRect( _X, _Y, W, H )
font:setFillColor(0, 0, 0, 1)
font:toBack()
local oX = display.newLine(Grid, x0 + 40 , _Y, x0 + W - 40 , _Y)--Оси
local oY = display.newLine(Grid, _X, y0 + 40, _X, y0 + H - 40)
oX.text = display.newText( "X", x0 + W - 40 , _Y + 20)
oX.text = display.newText( "Y",  _X + 20, y0 + 45)
oX.strokeWidth = 4
oY.strokeWidth = 4
local i = 1
while _Y - 60*i > y0 + 60 and _Y + 60*i < y0 + H - 60 do--Сетка по Х
  local lineX = display.newLine( Grid, x0 + 60, _Y + 60*i, x0 + W -60, _Y + 60*i )
  local lineX2 = display.newLine( Grid, x0 + 60, _Y - 60*i, x0 + W -60, _Y - 60*i )
  lineX.strokeWidth = 2
  lineX2.strokeWidth = 2
  i = i + 1
end
i = 1
while (_X - 60*i > x0 + 60) and (_X + 60*i < x0 + W - 60)  and (i<25) do--Сетка по У
  local lineY = display.newLine( Grid, _X + 60*i, y0 + 60, _X + 60*i, y0 + H - 60 )
  local lineY2 = display.newLine( Grid, _X - 60*i, y0 + 60, _X - 60*i, y0 + H - 60 )
  lineY.strokeWidth = 2
  lineY2.strokeWidth = 2
  i = i + 1
end

local function clearDisplay()
  table.remove( dots )
  dots = {}
  display.remove( draw )
  draw = display.newGroup()
  drawing = false
  while(#lines > 0) do
    physics.removeBody( lines[1] )
    table.remove( lines, 1 )
  end
end

local function getCoordinate( event )
  if(event.phase == "began") then
    if(drawing == true) then
      clearDisplay()
    end

    local X, Y
    print("its a tap")
    X, Y = event.x - _X, event.y - _Y
    local dX, dY = X%60, Y%60
    if(dX > 30) then
      X = X + 60 - dX
    else
      X = X - dX
    end

    if(dY > 30) then
      Y = Y + 60 - dY
    else
      Y = Y - dY
    end
    local circle = display.newCircle( draw, _X+X, _Y+Y, 10 )
    table.insert( dots, {x=_X+X,y=_Y+Y} )
  end
end

local touchArea = display.newRect( _X, _Y, W, H )
touchArea.isVisible = false
touchArea.isHitTestable = true
touchArea:addEventListener("tap", getCoordinate )
touchArea:addEventListener("touch", getCoordinate )

local function drawLines()
  display.remove( draw )
  draw = display.newGroup()
  local iter
  for iter=1, #dots-1, 1 do
    print("work ",iter)
    local length = math.sqrt(math.pow(dots[iter+1].x - dots[iter].x, 2)+math.pow(dots[iter+1].y - dots[iter].y, 2))
    local line = display.newRect(draw, dots[iter].x, dots[iter].y, length , 2)
    line:setFillColor(1,0,0,1)
    line:setStrokeColor(1,0,0,1)
    line.anchorX = 0
    line.x = dots[iter].x
    line.y = dots[iter].y
    line.rotation = math.deg(math.atan2(dots[iter+1].y - dots[iter].y, dots[iter+1].x - dots[iter].x))
    physics.addBody( line, "static" )
    table.insert( lines, line )
  end
  local length = math.sqrt(math.pow(dots[1].x - dots[#dots].x, 2)+math.pow(dots[1].y - dots[#dots].y, 2))
  local line = display.newRect(draw, dots[#dots].x, dots[#dots].y, length , 2)
  line:setFillColor(1,0,0,1)
  line:setStrokeColor(1,0,0,1)
  line.anchorX = 0
  line.x = dots[#dots].x
  line.y = dots[#dots].y
  line.rotation = math.deg(math.atan2(dots[1].y - dots[#dots].y, dots[1].x - dots[#dots].x))
  physics.addBody( line, "static" )
  table.insert( lines, line )
  print("lines ", #lines)
end

local function Fill( y )
  local collision = physics.rayCast( x0, y, x0+W, y, "sorted" )
  if(collision) then
    for i,v in ipairs( collision ) do
        table.insert( collisionCordinate, {x=v.position.x, y=v.position.y} )--[[
        local circle = display.newCircle( v.position.x, v.position.y, 5 )
        circle:setFillColor(0,1,0,1)]]
    end
  end

  local pair = {}
  for k=1,#collisionCordinate,1 do
    table.insert( pair, collisionCordinate[k] )
    print("pair ", #pair)
    if(#pair == 2)then
      local line = display.newLine( draw, pair[1].x, y, pair[2].x, y )
      line:setStrokeColor(1,0,0,1)
      print("here")
      table.remove( pair, 2 )
      table.remove( pair, 1 )
    end

    for i=1,#dots,1 do
      if(collisionCordinate[k] == dots[i]) then
        if(i~=#dots)and(math.abs(dots[i+1]-dots[i].y)/(dots[i+1]-dots[i].y)==math.abs(dots[i-1]-dots[i].y)/(dots[i-1]-dots[i].y)) or (i==#dots)and(math.abs(dots[1]-dots[i].y)/(dots[1]-dots[i].y)==math.abs(dots[i-1]-dots[i].y)/(dots[i-1]-dots[i].y)) then
          k=k-1
        end
      end
    end
  end


  while(#collisionCordinate ~= 0) do
    table.remove(collisionCordinate, 1)
  end
end

local function mainLoop()
  drawing = true
  drawLines()
  local MaxY, MinY = 0, 6000
  for i=1, #dots, 1 do
    if(dots[i].y > MaxY) then
      MaxY = dots[i].y
    end
    if(MinY > dots[i].y) then
      MinY = dots[i].y
    end
  end
  --for i=MinY+1, MaxY-1, 1 do
  local it = -1
      local tim = timer.performWithDelay( 10, function() Fill(MinY + it) it=it+1 end, MaxY-MinY )
  --end

end

local function keysActions(event)
  if(event.phase == "down") then
    if(event.keyName == "f") or (event.keyName == "F") or (event.keyName == "а") or (event.keyName == "А") then
      mainLoop()
    elseif(event.keyName == "r") or (event.keyName == "R") or (event.keyName == "к") or (event.keyName == "К") then
      clearDisplay()
    end
  end
end

Runtime:addEventListener("key", keysActions)
