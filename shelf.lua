local posPort = 3233
local ourPort = 3234
local modemSide = "back"
local shelfNumber = nil

local modem = peripheral.wrap(modemSide)
modem.open(ourPort)

function tellPos(message)
	modem.transmit(posPort, ourPort, message)
end

function scanShelf()
	local items = {}
	for row = 1, 3 do
		for col = 1, 3 do
			turtle.turnLeft()
			local success, item = turtle.inspect()
			if success and item then
				table.insert(items, {name = item.name, count = item.count, side = "left", slot = (row-1)*3 + col})
			end
			turtle.turnRight()
			turtle.turnRight()
			success, item = turtle.inspect()
			if success and item then
				table.insert(items, {name = item.name, count = item.count, side = "right", slot = (row-1)*3 + col})
			end
			turtle.turnLeft()
			if col < 3 then
				turtle.forward()
			end
		end
		if row < 3 then
			turtle.back()
			turtle.back()
			turtle.down()
		end
	end
	turtle.back()
	turtle.up()
	turtle.up()
	turtle.forward()
	return items
end

function saveShelfData(items)
	local file = fs.open("shelf_" .. shelfNumber .. ".txt", "w")
	for _, item in ipairs(items) do
		file.writeLine(item.name .. "," .. item.count .. "," .. item.side .. "," .. item.slot)
	end
	file.close()
end

function initializeShelf()
	print("Enter shelf number:")
	shelfNumber = tonumber(read())
	local items = scanShelf()
	saveShelfData(items)
	print("Shelf initialized with " .. #items .. " items.")
end

function handlePurchase(itemName, amount)
	local items = scanShelf()
	for _, item in ipairs(items) do
		if item.name == itemName and item.count >= amount then
			peripheral.call(item.side, "drop", item.slot, amount)
			return "purchase_success"
		end
	end
	return "purchase_fail"
end

initializeShelf()

while true do
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
	if senderChannel == posPort then
		local command, itemName, amount = string.match(message, "(%w+),(%w+),(%d+)")
		if command == "stockLevels" then
			tellPos(scanShelf())
		elseif command == "purchase" then
			tellPos(handlePurchase(itemName, tonumber(amount)))
		end
	end
end
