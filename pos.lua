local textApi = require "text"
local buttonApi = require "button"
local shop = require "shop"

local modemSide = "back"
local modem = peripheral.wrap(modemSide)

local monitorSide = "top"
local mon = peripheral.wrap(monitorSide)

mon.setTextScale(1)
mon.setTextColor(colors.white)
mon.setBackgroundColor(colors.black)

local shelves = {
   "wood" = 3234,
   "iron" = 3235,
   "gold" = 3236,
   "diamond" = 3237
}
local posPort = 3233
local cashier = 3238
shop.init(posPort, cashier, shelves, modem)

textApi.init(mon, 2)
buttonApi.init(mon)

function setupStock()
  shop.addStock("wood", "Wooden Armour", 3, 2) 
  shop.addStock("iron", "Iron Armour", 1, 7)
  shop.addStock("gold", "Golden Armour", 1, 25)
  shop.addStock("diamond", "Diamond Armour", 1, 200)
end

function renderStock()
   for name, data in pairs(shop.getStock()) do
      renderItem(data)
      textApi.newline()
   end
end

local function renderItem(data)
   if data["number"] > 0 then
      purchaseButton(textApi.getLineNumber(), data)
   end
   textApi.leftText(data["name"])
   textApi.customText("$"..data["price"], textApi.getLineNumber()-1, 24)
   textApi.leftText("In stock: " .. data["number"])
end

local function purchaseButton(line, data)
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
   shop.addToBasket(buttonApi.getLastPressed()["name"])
   basketPage()
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
   return 0
end

function storeHomePage()
   clearScreen()
   textApi.heading("XEpps' Armour Store")
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

setupStock()
storeHomePage()
while true do
   event = {os.pullEvent()}
   if(event[1] == "monitor_touch") then
      local e,side,x,y = unpack(event)
      buttonApi.checkxy(x,y)
   end
end