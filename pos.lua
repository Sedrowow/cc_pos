local textApi = require "text"
local buttonApi = require "button"
local shop = require "shop"
local config = {}

local modem = peripheral.wrap("back")
local mon = peripheral.wrap("top")

mon.setTextScale(1)
mon.setTextColor(colors.white)
mon.setBackgroundColor(colors.black)

local shelves = {}
local posPort = 3233
local cashier = 3238
shop.init(posPort, cashier, shelves, modem)

textApi.init(mon, 2)
buttonApi.init(mon)

function scanShelves()
	for i = 1, 4 do
		modem.transmit(3233 + i, posPort, "stockLevels")
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		if senderChannel == 3233 + i then
			local items = textutils.unserialize(message)
			shelves["SHELF_" .. i] = items
		end
	end
end

function setupStock()
	for shelf, items in pairs(shelves) do
		for _, item in ipairs(items) do
			print("Enter price for " .. item.name .. ":")
			local price = tonumber(read())
			shop.addStock(item.name, item.name, item.count, price)
		end
	end
	saveConfig()
end

function saveConfig()
	local file = fs.open("config.lua", "w")
	file.write("MODEM_SIDE = \"back\"\n")
	file.write("MONITOR_SIDE = \"top\"\n")
	file.write("SCREEN_TOP = 2\n")
	file.write("PORTS = {\n")
	for i = 1, 4 do
		file.write("\tSHELF_" .. i .. " = " .. (3233 + i) .. ",\n")
	end
	file.write("\tPOS = 3233,\n")
	file.write("\tCASHIER = 3238\n")
	file.write("}\n")
	file.write("STOCK = {\n")
	for name, data in pairs(shop.getStock()) do
		file.write("\t" .. name .. " = {\n")
		file.write("\t\tid = \"" .. data.id .. "\",\n")
		file.write("\t\tname = \"" .. data.name .. "\",\n")
		file.write("\t\tnumber = " .. data.number .. ",\n")
		file.write("\t\tcost = " .. data.price .. "\n")
		file.write("\t},\n")
	end
	file.write("}\n")
	file.write("EXCHANGE = {\n")
	file.write("\t[17] = {\n")
	file.write("\t\tid = 17,\n")
	file.write("\t\tname = \"Oak Wood\",\n")
	file.write("\t\tvalue = (1/64)\n")
	file.write("\t},\n")
	file.write("\t[264] = {\n")
	file.write("\t\tid = 264,\n")
	file.write("\t\tname = \"Diamond\",\n")
	file.write("\t\tvalue = 8\n")
	file.write("\t},\n")
	file.write("\t[265] = {\n")
	file.write("\t\tid = 265,\n")
	file.write("\t\tname = \"Iron Ingot\",\n")
	file.write("\t\tvalue = (1/4)\n")
	file.write("\t},\n")
	file.write("\t[266] = {\n")
	file.write("\t\tid = 266,\n")
	file.write("\t\tname = \"Gold Ingot\",\n")
	file.write("\t\tvalue = 1\n")
	file.write("\t}\n")
	file.write("}\n")
	file.close()
end

function renderStock()
	for name, data in pairs(shop.getStock()) do
		renderItem(data)
		textApi.newline()
	end
end

function renderItem(data)
	if data["number"] > 0 then
		purchaseButton(textApi.getLineNumber(), data)
	end
	textApi.leftText(data["name"])
	textApi.customText("$"..data["price"], textApi.getLineNumber()-1, 24)
	textApi.leftText("In stock: " .. data["number"])
end

function purchaseButton(line, data)
	buttonApi.makeButton(data["id"], "Buy", purchase, 32, 38, line-1, line+1)       
end

function homePageButton()
	buttonApi.makeButton("store_home", "Store Home", storeHomePage, 24, 38, 16, 18)
end

function exchangePageButton()
	buttonApi.makeButton("exchange_rate", "Exchange Rate", exchangeRatePage, 2, 18, 16, 18)
end

function payButton()
	buttonApi.makeButton("pay_button", "Pay", pay, 15, 25, 8, 12)
end
   
function purchase()
	local item = buttonApi.getLastPressed()["name"]
	shop.addToBasket(item)
	local result = shop.purchaseItem(item)
	if result == "purchase_success" then
		basketPage()
	else
		textApi.centerText("Purchase failed. Please try again.")
	end
end    

function basketPage()
	clearScreen()
	textApi.heading("Pay for "..basket["name"])
	textApi.centerText("Amount left to pay:")
	remainingCost = basket["price"] - amountPaid()
	textApi.customText("$"..remainingCost, textApi.getLineNumber, 30)   
	textApi.newline()
	textApi.newline()
   
	if remainingCost > 0 then
		textApi.centerText("To pay for this item, please")
		textApi.centerText("place the appropriate number of")
		textApi.centerText("items in the chest left.")
		textApi.newline()
		textApi.centerText("Warning: No change given")
	else
		payButton()
	end
	homePageButton()
	exchangePageButton()
	buttonApi.screen()
end                                                             

function amountPaid()
   local totalPaid = 0
   local chest = peripheral.wrap("left")
   local items = chest.list()
   for _, item in pairs(items) do
      if item.name == "minecraft:diamond" then
         totalPaid = totalPaid + (item.count * 8)
      elseif item.name == "minecraft:gold_ingot" then
         totalPaid = totalPaid + (item.count * 1)
      elseif item.name == "minecraft:iron_ingot" then
         totalPaid = totalPaid + math.floor(item.count / 4)
      elseif item.name == "minecraft:oak_log" then
         totalPaid = totalPaid + math.floor(item.count / 64)
      end
   end
   return totalPaid
end

function storeHomePage()
	clearScreen()
	textApi.heading("Sedro's Shopping Store")
	renderStock()
	exchangePageButton()
	buttonApi.screen()
end     

function exchangeRatePage()
	clearScreen()
	textApi.heading("Exchange Rates")
	textApi.centerText("Items => currency ($)")
	textApi.centerText("1 diamond => $8")
	textApi.centerText("1 gold bar => $1")
	textApi.centerText("4 iron bars => $1")
	textApi.centerText("64 oak logs => $1")
	homePageButton()
	buttonApi.screen() 
end

function clearScreen()
	mon.clear()
	buttonApi.clearButtons()
	textApi.resetLine()
end

scanShelves()
setupStock()
storeHomePage()
while true do
	event = {os.pullEvent()}
	if(event[1] == "monitor_touch") then
		local e,side,x,y = unpack(event)
		buttonApi.checkxy(x,y)
	end
end