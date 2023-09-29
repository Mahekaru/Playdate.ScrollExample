import "CoreLibs/sprites"
import 'CoreLibs/graphics'

gfx = playdate.graphics

local TILE_WIDTH = 50 -- 3 rows
local TILES_ON_SCREEN = 15 -- Screen Width
local BUFFER_TILES = 20 -- Ensure this is the actual height of your tilemap. Adjust if necessary.
local SCROLL_SPEED = 3
local TILE_SIZE = 16
local COLLISION_TAGS={
    Player = 1,
    Rocks = 2,
    Reset_Bar = 3
}
-- Inputs
--------------------------
local updown = false    --
local downdown = false  --
local leftdown = false  --
local rightdown = false --
--------------------------

-- local totalOffset = 0
local tiles = gfx.imagetable.new('assets/link/rocksprite')
local map = gfx.tilemap.new()

-- local RESET_COLLISION = 152
-- local COLLISION_ROW_3 = 184

local TILE_SPRITE_X = 0
local TILE_SPRITE_Y = 0

local COLLISION_RESET_Y = TILE_SPRITE_Y + (TILE_SIZE * 8)
local COLLISION_SPRITE_1_Y = TILE_SPRITE_Y + (TILE_SIZE * 10)
local COLLISION_SPRITE_2_Y = TILE_SPRITE_Y + (TILE_SIZE * 11)


map:setImageTable(tiles)
map:setSize(TILES_ON_SCREEN, BUFFER_TILES)

local tileSprite = gfx.sprite.new()

local collisionOverlay = {}
local resetBar

local star = gfx.sprite.new(gfx.image.new('assets/link/s1'))

local function createEmptyCollision()
    local y = COLLISION_SPRITE_1_Y
    local created = 1
    
    for r = 0, 1 do
        if r == 1 then
            y = COLLISION_SPRITE_2_Y
        end

        for i = 0, 14 do
            local x = 16 * i
            collisionOverlay[created] = gfx.sprite.addEmptyCollisionSprite(x, y, TILE_SIZE, TILE_SIZE)
            collisionOverlay[created]:setTag(COLLISION_TAGS.Rocks)
            collisionOverlay[created]:setGroups(2)
            
            collisionOverlay[created]:setCollidesWithGroups({1,3})
            -- print("so...",#collisionOverlay, collisionOverlay[created])
            created += 1
        end
    end

    resetBar = gfx.sprite.addEmptyCollisionSprite(0,COLLISION_RESET_Y,16 * 15, 16)
    resetBar:setTag(COLLISION_TAGS.Reset_Bar)
    resetBar:setGroups(3)
    resetBar:setCollidesWithGroups(2)

    
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
    print("COLLISION_RESET_Y", COLLISION_RESET_Y)
    print("COLLISION_SPRITE_1_Y", COLLISION_SPRITE_1_Y)
    print("Collision Sprite 2 Y", COLLISION_SPRITE_2_Y)
    createEmptyCollision()

    tileSprite:setTilemap(map)
    tileSprite:setZIndex(1000)
    tileSprite:add()
    tileSprite:setCenter(0, 0)
    tileSprite:moveTo(TILE_SPRITE_X, TILE_SPRITE_Y)

    -- Creating the star which acts like the rig
    star:moveTo(300,155)
    star:setTag(1)
    star:setCollideRect(0,0,37,34)
    star:setZIndex(2000)
    star:setGroups(1)
    star:setCollidesWithGroups(2)
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
    for row = 1, BUFFER_TILES-SCROLL_SPEED, 1 do  -- start from one less than the bottom
        for column = 1, TILES_ON_SCREEN do
            local tileBelow = map:getTileAtPosition(column, row + 3)
            map:setTileAtPosition(column, row, tileBelow)
        end
    end
end

-- pastes the 3 rows from the top to last 3 rows at the bottom
local function placeTopTilesAtBottom(topTiles)
    local x_topTile = 1

    for row = BUFFER_TILES - SCROLL_SPEED, BUFFER_TILES-1, 1 do
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

        if tileSprite.y <= -TILE_WIDTH then

            local topTiles = getTopTiles()

            shiftAllTilesUp()
            placeTopTilesAtBottom(topTiles)

            tileSprite:moveTo(0, -SCROLL_SPEED)
        end

        -- print("COLLISION_ROW_3", COLLISION_RESET_Y)
        -- if tileSprite.y <= COLLISION_RESET_Y then
            
        -- end

        --first row has reached the top
        --print("index 1", collisionOverlay[1].y, collisionOverlay[16].y)
        for c = 1, #collisionOverlay do
            -- print("Collision y",collisionOverlay[c].y)
             --print("index location",c, collisionOverlay[c].y)
            -- if collisionOverlay[c].y == 150 then
            --     -- print("Inside",collisionOverlay)
            --     collisionOverlay[c]:moveTo(collisionOverlay[c].x, 180)
            -- end

            collisionOverlay[c]:moveBy(0, -SCROLL_SPEED)
        end

        tileSprite:moveBy(0,-SCROLL_SPEED)
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

    -- print("star y ", star.y)
    star:moveBy(x, y)
end

local function checkCollisions()
    local collisions =  gfx.sprite:allOverlappingSprites()

    if #collisions > 0 then
        for c = 1, #collisions do
            --print("collision", #collisions, collisions[c])
            
            local collisionPairs = collisions[c]
            
            local sprite1 = collisionPairs[1]
            local sprite2 = collisionPairs[2]
            
            if (sprite1:getTag() == COLLISION_TAGS.Player and sprite2:getTag() == COLLISION_TAGS.Rocks) or 
               (sprite2:getTag() == COLLISION_TAGS.Player and sprite1:getTag() == COLLISION_TAGS.Rocks) then
                for pair=1, #collisionPairs do
                        local sprite = collisionPairs[pair]--what was collided into

                        if sprite:getTag() == COLLISION_TAGS.Rocks then
                            -- print("PLAYER HAS HIT A ROCK")
                            sprite:remove()
                        end
                end
            elseif (sprite1:getTag() == COLLISION_TAGS.Rocks and sprite2:getTag() == COLLISION_TAGS.Reset_Bar) or 
                    (sprite2:getTag() == COLLISION_TAGS.Rocks and sprite1:getTag() == COLLISION_TAGS.Reset_Bar) then
                    
                    

                    for pair=1, #collisionPairs do
                        local sprite = collisionPairs[pair]--what was collided into
        
                        if sprite:getTag() == COLLISION_TAGS.Rocks then
                            sprite:moveTo(sprite.x, sprite.y + (TILE_SIZE * 2))
                        end
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
    COLLISION_SPRITE_2_Y = (tileSprite.y) + (TILE_SIZE * 11)
end
