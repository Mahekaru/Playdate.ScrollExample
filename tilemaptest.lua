import "CoreLibs/sprites"
import 'CoreLibs/graphics'

gfx = playdate.graphics

local TILE_WIDTH = 50 -- 3 rows
local TILES_ON_SCREEN = 15 -- Screen Width
local BUFFER_TILES = 20 -- Ensure this is the actual height of your tilemap. Adjust if necessary.
local SCROLL_SPEED = 3

-- Is down being pressed
local updown = false
local downdown = false
local leftdown = false
local rightdown = false

local totalOffset = 0
local tiles = gfx.imagetable.new('assets/link/rocksprite')
local map = gfx.tilemap.new()
map:setImageTable(tiles)
map:setSize(TILES_ON_SCREEN, BUFFER_TILES)

local star = gfx.sprite.new(gfx.image.new('assets/link/s1'))

function initializeTiles()
    for row = 1, BUFFER_TILES do
        for column = 1, TILES_ON_SCREEN do

            local block = math.random(1,2)

            if row == 6 then
                block = 6
            end

            -- map:setTag("Rock")
            map:setTileAtPosition(column, row, block)

        end
    end

    gfx.sprite.addEmptyCollisionSprite(250,50,16,16)


    star:moveTo(300,50)
    star:setTag(1)
    star:setCollideRect(0,0,16,16)
    star:add()
end

initializeTiles()

-- Grabs the top 3 rows of tiles
local function getTopTiles()
    local topTiles = {}

    local x_topTile = 1

    for row = 1, 3 do
        for column = 1, TILES_ON_SCREEN do
            topTiles[x_topTile] = map:getTileAtPosition(column, row)

            x_topTile+=1
        end
    end

    return topTiles
end

-- Moves whole screen tile down
-- Moves all blocks from 4th row up
local function shiftAllTilesUp()
    for row = 1, BUFFER_TILES-3, 1 do  -- start from one less than the bottom
        for column = 1, TILES_ON_SCREEN do
            local tileBelow = map:getTileAtPosition(column, row + 3)
            map:setTileAtPosition(column, row, tileBelow)
        end
    end
end

-- pastes the 3 rows from the top to last 3 rows at the bottom
local function placeTopTilesAtBottom(topTiles)
    local x_topTile = 1

    for row = BUFFER_TILES - 3, BUFFER_TILES-1, 1 do
        for column = 1, TILES_ON_SCREEN do
            map:setTileAtPosition(column, row, topTiles[x_topTile])
            x_topTile +=1
        end
    end
end


local function handleInputs()
    -- Is down being pressed
    updown = playdate.buttonIsPressed(playdate.kButtonUp)
    downdown = playdate.buttonIsPressed(playdate.kButtonDown)
    leftdown = playdate.buttonIsPressed(playdate.kButtonLeft)
    rightdown = playdate.buttonIsPressed(playdate.kButtonRight)
    
end

local function moveBlocks()
    if downdown then 
        totalOffset = totalOffset + SCROLL_SPEED
        -- print("totaloffset: ", totalOffset)
        if totalOffset >= TILE_WIDTH then
            -- Cache the first top 3 row
            local topTiles = getTopTiles()

            shiftAllTilesUp()
            placeTopTilesAtBottom(topTiles)

            totalOffset = 2
        end
    end
    
    -- print("totaloffset", -totalOffset)
    map:draw(0, -totalOffset)
end

local function moveStar()
    local x, y = 0, 0

    if updown then
        y = -1
    elseif downdown then
        y = 1
    elseif leftdown then
        x = -1
    elseif rightdown then
        x = 1
    end

    star:moveBy(x, y)
end

local function checkCollisions()
    local collisions =  gfx.sprite:allOverlappingSprites()

    if #collisions > 0 then
        for c = 1, #collisions do
            print("collision", #collisions, collisions[c])
            local c = collisions[1]
            
            local sprite1 = c[1]
            local sprite2 = c[2]
            print("sprites",sprite1, sprite2)

            if sprite1:getTag() ~= 1 then
                sprite1:remove()
                map:setTileAtPosition(1, 1, 34)
            end

            if sprite2:getTag() ~= 1 then
                sprite2:remove()
                map:setTileAtPosition(1, 1, 34)
            end
        end
    end
end


function playdate.update()
    gfx.sprite:update()

    handleInputs()
    moveBlocks()
    moveStar()
    checkCollisions()

    star:moveWithCollisions(star.x, star.y)
    
end
