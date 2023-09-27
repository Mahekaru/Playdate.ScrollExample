import 'tilemaptest'

if playdate.update == nil then
	
	playdate.update = function() end
	playdate.graphics.drawText("Please uncomment one of the import statements.", 15, 100)
end
