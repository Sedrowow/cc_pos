local posPort = 3233
local ourPort = 3234
local modemSide = "back"

local modem = peripheral.wrap(modemSide)
modem.open(ourPort)

function tellPos(message)
	modem.transmit(posPort, ourPort, message)
end

function stockLevels()
	turtle.select(1)

	count = 0
	while turtle.suckDown() do
	  count = count + 1
	end
	 
	for i=1,count do
	  turtle.select(i)
	  turtle.dropDown()
	end
	
	return count
end

function sendArmour()

	function dropArmour()
		turtle.select(1)
		turtle.drop()
		turtle.select(2)
		turtle.drop()
		turtle.select(3)
		turtle.drop()
		turtle.select(4)
		turtle.drop()
	end

	function retrieveArmour()
		turtle.suckUp(1)
		turtle.suckDown(1)
		turtle.turnLeft()
		turtle.suck(1)
		turtle.turnRight()
		turtle.turnRight()
		turtle.suck(1)
		turtle.turnLeft()
	end

	function checkArmour()
		return turtle.getItemCount(1) > 0  and
			turtle.getItemCount(2) > 0 and
			turtle.getItemCount(3) > 0 and
			turtle.getItemCount(4) > 0
	end

	retrieveArmour()
	if checkArmour() then
		dropArmour()
		return "armour_success"
	else
		return "armour_fail"
	end
end

while true do
	local event, modemSide, senderChannel, replyChannel, 
		message, senderDistance = os.pullEvent("modem_message")
	if senderChannel == posPort then
		tellPos(message())
	end
end
