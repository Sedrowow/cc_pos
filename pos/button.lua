local ButtonApi = {}

local lastPressed = {}
local button={}
local mon={}

function ButtonApi.init(monitor)
	mon = monitor
end

function ButtonApi.getLastPressed()
	return lastPressed
end

function ButtonApi.makeButton(name, title, func, xmin, xmax, ymin, ymax)
   button[name] = {}
   button[name]["name"] = name
   button[name]["title"] = title
   button[name]["func"] = func
   button[name]["active"] = false
   button[name]["xmin"] = xmin
   button[name]["ymin"] = ymin
   button[name]["xmax"] = xmax
   button[name]["ymax"] = ymax
end

function ButtonApi.clearButtons()
	button = {}
end

function ButtonApi.screen()
   local currColor
   for name,data in pairs(button) do
      local on = data["active"]
      if on == true then currColor = colors.lime else currColor = colors.red end
      fill(data["title"], currColor, data)
   end
end
     
function ButtonApi.checkxy(x, y)
   for name, data in pairs(button) do
      if y>=data["ymin"] and  y <= data["ymax"] then
         if x>=data["xmin"] and x<= data["xmax"] then
            setLastPressed(name)
            data["func"]()
            data["active"] = not data["active"]
         end
      end
   end
end

local function fill(text, color, bData)
   mon.setBackgroundColor(color)
   local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
   local xspot = math.floor((bData["xmax"] - bData["xmin"] - string.len(text)) /2) +1
   for j = bData["ymin"], bData["ymax"] do
      mon.setCursorPos(bData["xmin"], j)
      if j == yspot then
         for k = 0, bData["xmax"] - bData["xmin"] - string.len(text) +1 do
            if k == xspot then
               mon.write(text)
            else
               mon.write(" ")
            end
         end
      else
         for i = bData["xmin"], bData["xmax"] do
            mon.write(" ")
         end
      end
   end
   mon.setBackgroundColor(colors.black)
end

local function setLastPressed(name)
  lastPressed = button[name]
end

return ButtonApi
