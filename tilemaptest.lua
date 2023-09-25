import "CoreLibs/sprites"
gfx = playdate.graphics

local TILE_WIDTH = 50 -- 3 rows
local TILES_ON_SCREEN = 15 -- Screen Width
local BUFFER_TILES = 20 -- Ensure this is the actual height of your tilemap. Adjust if necessary.
local SCROLL_SPEED = 3

-- Is down being pressed
local downdown = false
local totalOffset = 0
local tiles = gfx.imagetable.new('assets/link/rocksprite')
local map = gfx.tilemap.new()

map:setImageTable(tiles)
map:setSize(TILES_ON_SCREEN, BUFFER_TILES)

function initializeTiles()
    for row = 1, BUFFER_TILES do
        for column = 1, TILES_ON_SCREEN do

            local block = math.random(1,2)

            if row == 6 then
                block = 6
            end

            map:setTileAtPosition(column, row, block)
        end
    end
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
    downdown = playdate.buttonIsPressed(playdate.kButtonDown)
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



function playdate.update()
    handleInputs()
    moveBlocks()
end
