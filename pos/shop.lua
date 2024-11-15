Shop = {}

stock = {}
basket = {}

posPort = {}
shelves = {}
cashier = {}

function Shop.init(_posPort, _cashier, _shelves, _modem)
	posPort = _posPort
	cashier = _cashier
	shelves = _shelves
	modem = _modem
	modem.open(posPort)
end

function Shop.addStock(id, name, number, price)
   stock[id] = {}
   stock[id]["id"] = id
   stock[id]["name"] = name
   stock[id]["number"] = number
   stock[id]["price"] = price
end 

function Shop.getStock()
	return stock
end

function Shop.getStockLevel(item)
	modem.transmit(shelves[item], posPort, "stockLevels")
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		if senderChannel == shelves[item] then
			stock[item]["number"] = message
			return stock[item]["number"]
		end
	end
end

function Shop.addToBasket(item)
	basket = stock[item]
end

function getStockLevel(item)
	modem.transmit(shelves[item], posPort, "stockLevels")
	while true do
		local event, modemSide, senderChannel, replyChannel,
			message, senderDistance = os.pullEvent("modem_message")
		if senderChannel == shelves[item] then
			return message
		end
	end
end

function Shop.purchaseItem(item)
	modem.transmit(shelves[item], posPort, "purchase")
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		if senderChannel == shelves[item] then
			return message
		end
	end
end

return Shop