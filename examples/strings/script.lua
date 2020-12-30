white = color.new(255,255,255);
x = "hi";

-- STRING.GSUB 1
x = string.gsub("Yes No", "(%w+)", "%1 %1 %1");
screen.print(10, 20, x , 0.4, white, black)

-- STRING.GSUB 2
x = string.gsub("hello world", "(%w+)%s*(%w+)", "%2 %1");
screen.print(10, 40, x , 0.4, white, black)

-- STRING.GSUB 3
x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function(s) return loadstring(s)() end);
screen.print(10, 60, x , 0.4, white, black)

-- STRING.GSUB 4
local t = {nombre="lua", versión="5.1"};
x = string.gsub("$nombre-$versión.tar.gz", "%$(%w+)", t);
screen.print(10, 80, x , 0.4, white, black)

screen.flip();

while true do
    screen.waitvblankstart()
end