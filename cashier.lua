local modemSide = "back"
local modem = peripheral.wrap(modemSide)
local posPort = 3233
local cashierPort = 3238

modem.open(cashierPort)

function handlePayment(itemName, amount, payment)
	-- Check if stock is available
	modem.transmit(posPort, cashierPort, "checkStock," .. itemName .. "," .. amount)
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
	if message == "stock_available" then
		-- Check if payment is correct
		if checkPayment(payment) then
			-- Deliver item
			modem.transmit(posPort, cashierPort, "deliverItem," .. itemName .. "," .. amount)
			return "payment_success"
		else
			return "payment_fail"
		end
	else
		return "stock_unavailable"
	end
end

function checkPayment(payment)
	-- Implement logic to check if the payment is correct
	return true
end

while true do
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
	local command, itemName, amount, payment = string.match(message, "(%w+),(%w+),(%d+),(%w+)")
	if command == "payment" then
		local result = handlePayment(itemName, tonumber(amount), payment)
		modem.transmit(posPort, cashierPort, result)
	end
end
