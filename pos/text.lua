local TextApi = {}
local mon = {}
local lineCursor = 0
local screenTop = 0

function TextApi.init(monitor, line)
   mon = monitor
   screenTop = line
   lineCursor = line
end

function TextApi.newLine()
   lineCursor = lineCursor + 1
end

function TextApi.resetLine()
   lineCursor = screenTop
end

function TextApi.customText(text, line, left)
   mon.setCursorPos(left, line)
   mon.write(text)
end

function TextApi.leftText(text)
   TextApi.customText(text, lineCursor, 2)
   TextApi.newline()
end

function TextApi.centerText(text)
   TextApi.customText(text, lineCursor, getCenter())
   TextApi.newline()
end

function TextApi.heading(text)
   TextApi.centerText(text)
   TextApi.newline()
end

function TextApi.getLineNumber()
   return lineCursor
end

local function getCenter(text)
   w, h = mon.getSize()
   return (w-string.len(text))/2+1
end

return TextApi