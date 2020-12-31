-- Chipmunk 2D Functions (WIP)
white = color.new(255, 255, 255);
black = color.new(0, 0, 0);

-- Initialize the physics engine
chipmunk.init();

-- Create a new body with mass 10 and moment 20
b = chipmunk.body.new(10, 20);
chipmunk.body.position(b, 5, 10);
vx,vy = chipmunk.body.position(b);

-- Print body's mass and position
screen.print(10, 20, "Mass: "..tostring(chipmunk.body.mass(b)) , 0.5, white, black);
screen.print(10, 35, "Position:"..vx..","..vy, 0.5, white, black);

-- Change body position
chipmunk.body.position(b, 10.5, 20.6);
vx,vy=chipmunk.body.position(b);

-- Print new position
screen.print(10, 50, "New position:"..vx..","..vy, 0.5, white, black);

screen.flip();

while true do
    screen.waitvblankstart()
end