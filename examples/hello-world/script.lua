blue = color.new(0,0,255) 
white = color.new(255, 255, 255)
black = color.new(0, 0, 0)

screen.print(10, 10, "Hello world!" , 0.6, blue, blue)
screen.print(10, 26, "This is my first program and it runs on the PSP!" , 0.4, white, black)

screen.flip()

while true do
    screen.waitvblankstart()
end