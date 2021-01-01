-- Load assets
floor = image.load("assets/background/floor.png");
cauldron_sprite = image.load("assets/sprite/cauldron.png")
player_sprite = image.load("assets/sprite/player.png");

-- Create 5 boilers and set their coordinates
world_entities = {}
for i=0,4 do
    world_entities[i] = {x = (i*112), y = (i*60), sprite = cauldron_sprite, vel = 0}
end

-- Create the player
player = {x = 200, y = 100, sprite = player_sprite, vel = 3}

function ysort_draw() 
    -- Draw the sprites behind the player
    for i=0, table.getn(world_entities) do
        if world_entities[i]["y"] + world_entities[i]["sprite"]:height() < player["y"] + player["sprite"]:height() then
            world_entities[i]["sprite"]:blit(world_entities[i]["x"], world_entities[i]["y"]);
        end
    end

    -- Draw the player
    player["sprite"]:blit(player["x"], player["y"]);

    -- Draw in front of the player
    for i=0, table.getn(world_entities) do
        if world_entities[i]["y"] + world_entities[i]["sprite"]:height() >= player["y"] + player["sprite"]:height() then
            world_entities[i]["sprite"]:blit(world_entities[i]["x"], world_entities[i]["y"]);
        end
    end
end

while 1 do
    -- Draw the background
    floor:blit(0,0);
    
    -- Read controls and update player position
    controls.read();
    if controls.up() then player["y"] = player["y"] - player["vel"]; end
    if controls.down() then player["y"] = player["y"] + player["vel"]; end
    if controls.left() then player["x"] = player["x"] - player["vel"]; end
    if controls.right() then player["x"] = player["x"] + player["vel"]; end

    -- Draw world entities and player sprites with y-sort
    ysort_draw();

    screen.flip();
    screen.waitvblankstart();
end