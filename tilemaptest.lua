import "CoreLibs/sprites"
import 'CoreLibs/graphics'

gfx = playdate.graphics

local TILE_WIDTH = 50 -- 3 rows
local TILES_ON_SCREEN = 15 -- Screen Width
local BUFFER_TILES = 20 -- Ensure this is the actual height of your tilemap. Adjust if necessary.
local SCROLL_SPEED = 3

local COLLISION_SPRITE_1_Y = 160
local COLLISION_SPRITE_2_Y = 176
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

local tileSprite = gfx.sprite.new()

local something

-- map:setZIndex(1000)
local star = gfx.sprite.new(gfx.image.new('assets/link/s1'))

local function createEmptyCollision()
    local y = COLLISION_SPRITE_1_Y
    for r = 0, 1 do
        if r == 1 then
            y = COLLISION_SPRITE_2_Y
        end
        for i = 0, 14 do
            local x = 16 * i
            gfx.sprite.addEmptyCollisionSprite(x, y, 16, 16):setTag(5)
        end
    end

    something = gfx.sprite.addEmptyCollisionSprite(300,100,16,16):setTag(42)
end

function initializeTiles()
    for row = 1, BUFFER_TILES do
        for column = 1, TILES_ON_SCREEN do

            local block = math.random(1,2)

            if row == 6 then
                block = 6
            end

            -- setting up rocks
            map:setTileAtPosition(column, row, block)

        end
    end

    -- Simple hitbox
    createEmptyCollision()

    tileSprite:setTilemap(map)
    tileSprite:setZIndex(1000)
    tileSprite:add()
    tileSprite:setCenter(0, 0)
    tileSprite:moveTo(0, 0)

    -- Creating the star which acts like the rig
    star:moveTo(300,50)
    star:setTag(1)
    star:setCollideRect(0,0,37,34)
    star:setZIndex(2000)
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

        print("tileSprite y", tileSprite.y, -TILE_WIDTH)
        


        if tileSprite.y <= -TILE_WIDTH then
            print("returning to start")

            local topTiles = getTopTiles()

            shiftAllTilesUp()
            placeTopTilesAtBottom(topTiles)

            local returnY = TILE_WIDTH + tileSprite.y
            print("return to ", -2)

            tileSprite:moveTo(0, -2)
        end

        tileSprite:moveBy(0,-1)
    end

    
end

local STARSPEED = 2
local function moveStar()
    local x, y = 0, 0

    if updown then
        y = -STARSPEED
    elseif downdown then
        y = STARSPEED
    elseif leftdown then
        x = -STARSPEED
    elseif rightdown then
        x = STARSPEED
    end

    star:moveBy(x, y)
end

local function checkCollisions()
    local collisions =  gfx.sprite:allOverlappingSprites()

    if #collisions > 0 then
        for c = 1, #collisions do
            print("collision", #collisions, collisions[c])
            
            local collisionPairs = collisions[1]
            
            for pair=1, #collisionPairs do
                local sprite = collisionPairs[pair]

                if sprite:getTag() ~= 1 then
                    print("sprite tag: ", sprite:getTag())
                    sprite:remove()
                end
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
