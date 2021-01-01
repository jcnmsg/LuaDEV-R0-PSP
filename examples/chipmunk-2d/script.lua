-- Load ball image
ball = image.load("ball.png")

-- Chipmunk 2D Functions (WIP)
white = color.new(255, 255, 255);
black = color.new(0, 0, 0);

-- Initialize the physics engine
chipmunk.init();

-- Create a new body with mass 10 and moment 20
b = chipmunk.body.new(10, 20);
chipmunk.body.position(b, 240, 10);

-- Chimpunk space
sp = chipmunk.space.new();
chipmunk.space.gravity(sp, 0, 9.8);
chipmunk.space.damping(sp, 5, true);

-- Idle speed threshold
chipmunk.space.idlespeedthreshold(sp, 10);

-- Add body to space
chipmunk.space.addbody(sp, b);

gx, gy = chipmunk.space.gravity(sp);
d = chipmunk.space.damping(sp);

while true do
    -- Get vx, vy
    vx, vy = chipmunk.body.position(b);

    if vy < (272 - ball:height()) then
        -- Run the physics while ball is on screen
        chipmunk.space.step(sp, 1/60); 
    end

    -- Draw the ball image
    ball:blit(vx, vy);

    -- Debug
    screen.print(10, 20, "Body mass: "..chipmunk.body.mass(b) , 0.5, white, black);
    screen.print(10, 35, "Body position:"..vx..","..vy, 0.5, white, black);
    screen.print(10, 50, "Space gravity:"..gx..","..gy, 0.5, white, black);
    screen.print(10, 65, "Space damping:"..d, 0.5, white, black);

    screen.flip();

    screen.waitvblankstart()
end