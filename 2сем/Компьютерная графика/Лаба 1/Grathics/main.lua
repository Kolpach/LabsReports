local Grid = display.newGroup()--Несколько переменных
local _X = display.contentCenterX
local _Y = display.contentCenterY
local x0 = display.contentCenterX - (display.actualContentWidth/2)
local y0 = display.contentCenterY - (display.actualContentHeight/2)
local W = display.contentCenterX + (display.actualContentWidth/2)
local H = display.contentCenterY + (display.actualContentHeight/2)
local draw = display.newGroup()

local oX = display.newLine(Grid, x0 + 40 , _Y, W - 40 , _Y)--Оси
local oY = display.newLine(Grid, _X, y0 + 40, _X, H - 40)
oX.text = display.newText( "X", W - 40 , _Y + 20)
oX.text = display.newText( "Y",  _X + 20, y0 + 45)
oX.strokeWidth = 4
oY.strokeWidth = 4
for i=1, 5, 1 do--Сетка по Х
  local lineX = display.newLine( Grid, x0 + 60, _Y + 60*i, W -60, _Y + 60*i )
  local lineX2 = display.newLine( Grid, x0 + 60, _Y - 60*i, W -60, _Y - 60*i )
  lineX.strokeWidth = 2
  lineX2.strokeWidth = 2
end

for i=1, 9, 1 do--Сетка по У
  local lineY = display.newLine( Grid, _X + 60*i, y0 + 60, _X + 60*i, H - 60 )
  local lineY2 = display.newLine( Grid, _X - 60*i, y0 + 60, _X - 60*i, H - 60 )
  lineY.strokeWidth = 2
  lineY2.strokeWidth = 2
end


local function getGreedCordinate(x, y)--Функция вычисления координат нажатия с их округлением к ближайшему
  local rX, rY
  rX = x - _X
  rY = y - _Y
  rX = rX % 60--Вычисление нужного остатка
  rY = rY % 60

  if(math.abs(rX) > 30) then
    if(rX > 0 ) then
      rX = 60 - rX
    else
      rX = math.abs(rX) - 60
    end
  else
    if(rX > 0 ) then
      rX = -1*rX
    else
      rX = math.abs(rX)
    end
  end

  if(math.abs(rY) > 30) then
    if(rY > 0 ) then
      rY = 60 - rY
    else
      rY = math.abs(rY) - 60
    end
  else
    if(rY > 0 ) then
      rY = -1*rY
    else
      rY = math.abs(rY)
    end
  end

  local result = {}
  result.x = x + rX
  result.y = y + rY
  return result
end
local function getOneCordinate( x )--Функция округления вниз
  rX = x % 1.0--Вычисление нужного остатка
  if(rX < 0) then
    rX = rX + 1
  end
  if(rX > 0.99999) then
    rX = 0
  end
  return x -rX
end

local touchArea = display.newRect( _X, _Y, display.actualContentWidth-120, display.actualContentHeight-120 )--Зона нажатия
touchArea.isVisible = false
touchArea.isHitTestable = true

local touches = {}
local drawingMode = "1"

local function chooseMode( event )
  local key = event.keyName
  if( key == "1") or ( key == "2" ) or ( key == "3" ) then
    drawingMode = key
  end
end

local function CDA( Px, Py )
  local x1, y1 = touches[1].x, touches[1].y
  local x, y = 0, 0

  local nX, nY = 1, -1
  if(Px < 0) then--Для случая Px или Py <0
    nX = -1
  end
  if(Py > 0) then
    nY = 1
  end

  local dX, dY = getOneCordinate(Px/math.abs(Px)*0.5)*60,  -1*getOneCordinate(-1*Py/math.abs(Py)*0.5)*60--отображаем первый квадрат
  if( Px == 0) then--Проверка деления на ноль
    dX = 0
  end
  if( Py == 0) then
    dY = 0
  end
  local dot1 = display.newRect(draw, x1 + dX , y1 + dY , 60, 60 )
  dot1.anchorX , dot1.anchorY = 0, 1
  dot1:setFillColor(0.5 , 0.25, 0.84, 1)

  Px = math.abs(Px)
  Py = math.abs(Py)
  local a = nil --Не изменять нужна дальше
  if(Px < Py) then--Для случая, когда 45 < угол < 135
    a = Px
    Px = Py
    Py = a
  end

  for x=1, Px - 1, 1 do
    y = y + Py/Px --Сам алгоритм
    local dot
    if(a~=Py) then--Сложная проверка на -45 < угол < 45
      dot = display.newRect(draw, x1 + 60*x*nX + dX, y1 + (60*getOneCordinate( y )*nY + dY), 60, 60 )--Для случая угол < 45
    else
      dot = display.newRect(draw, x1 + (60*getOneCordinate( y )*nX + dX), y1 + 60*x*nY + dY, 60, 60 )--угол > 45
    end
    dot.anchorX , dot.anchorY = 0, 1
    dot:setFillColor(0.5, 0.25, 0.84, 1)

  end
end


local function Brezenhem( Px, Py)
  local x1, y1 = touches[1].x, touches[1].y
  local x, y = 0, 0

  local nX, nY = 1, -1
  if(Px < 0) then--Для случая Px или Py <0
    nX = -1
  end
  if(Py > 0) then
    nY = 1
  end

  local dX, dY = getOneCordinate(Px/math.abs(Px)*0.5)*60 ,  -1*getOneCordinate(-1*Py/math.abs(Py)*0.5)*60--Это смещение зависит от Px и Py, смещает прямую так, чтобы начальные точки совпадали
  if( Px == 0) then--Проверка деления на ноль
    dX = 0
  end
  if( Py == 0) then
    dY = 0
  end
  local dot1 = display.newRect(draw, x1 + dX , y1 + dY , 60, 60 ) -- Ставим первую точку
  dot1.anchorX , dot1.anchorY = 0, 1
  dot1:setFillColor(0, 0.25, 0.84, 1)

  Px = math.abs(Px)
  Py = math.abs(Py)
  local a = nil --Не изменять нужна дальше
  if(Px < Py) then--Для случая, когда 45 < угол < 135
    a = Px
    Px = Py
    Py = a
  end

  local E = 2*Py - Px--Сам алгоритм
  for i=1, Px-1, 1 do
    x = x + 1
    if E >= 0 then
      y = y + 1
      E = E + 2*(Py - Px)
    else
      E = E + 2*Py
    end

    local dot
    if(a~=Py) then--Сложная проверка на -45 < угол < 45
      dot = display.newRect(draw, x1 + 60*x*nX + dX, y1 + 60*y*nY + dY, 60, 60 )--Для случая угол < 45
    else
      dot = display.newRect(draw, x1 + 60*y*nX + dX, y1 + 60*x*nY + dY, 60, 60 )--угол > 45
    end
    dot.anchorX , dot.anchorY = 0, 1
    dot:setFillColor(0, 0.25, 0.84, 1)

  end
end


local function drawL( Px, Py)--Рисует

  print( Px, Py )

  if( drawingMode == "1") then
    Brezenhem( Px, Py)
  elseif ( drawingMode == "2" ) then
    CDA( Px, Py )
  elseif ( drawingMode == "3" ) then
    Brezenhem( Px, Py )
    CDA( Px, Py )
  end

  local line = display.newLine( draw, touches[1].x, touches[1].y, touches[2].x, touches[2].y )
  line:setStrokeColor(1,0,0,1)
  line.strokeWidth = 2
end


local function onTouch( event )--Регистрация нажатий
  if( event.phase == "began" ) then
    print(event.x, event.y, #touches)

    if #touches > 1 then --Нам нужно только первое и второе нажатия, если больше то перезагружаем
      display.remove( draw )--очистка от прошлого задания
      draw = display.newGroup()
      table.remove( touches, 2 )
      table.remove( touches, 1 )
    end

    local result = getGreedCordinate( event.x, event.y )
    table.insert( touches, result )--Регистрируем первое и второе нажатия

    local dot = display.newCircle(draw, result.x, result.y, 10 )--Для наглядности добавляет точки
    --dot.anchorX , dot.anchorY = 0, 1
    dot:setFillColor(0.5, 0.5, 0.5, 1)
    dot.isVisible = true -- Сейчас включено

    if(#touches == 2) then
      local Px, Py = (touches[2].x - touches[1].x)/60, (touches[2].y - touches[1].y)/60
      drawL( Px, Py )--После двух точек рисуем линию
    end

  end
end
touchArea:addEventListener("tap", onTouch)
touchArea:addEventListener("touch", onTouch)
Runtime:addEventListener("key", chooseMode)
