function func_a(s)
    for i=1, 10 do
        coroutine.yield("A", i, s+i);
    end
end

function func_b (v)
    for i=1,5 do
        coroutine.yield("B", i, v+i);
    end
end

usb:on(); -- Program starts here:
co1 = coroutine.create( func_a );
fu2 = coroutine.wrap( func_b );
tempfile = io.open( "tempf.txt" , "w" );

while coroutine.status(co1)~="dead" do
    status = xpcall(function() 
        res, co, num, val = coroutine.resume( co1 , 3 );

        if res == true and co ~= nil then
            tempfile:write("true"," ", co, " ", num, " ", val, " " , "\n" );
        end
    
        a, b, c = fu2(5);
    
        if a == nil and b == nil and c == nil then
            tempfile:write( "nil nil nil", "\n" );
        else 
            tempfile:write( a , " ", b, " ", c , "\n" );
        end
    end, function()
        tempfile:write("ERROR! Cannot resume dead couroutine");
    end);

    if status ~= true then
        break;
    end
end

tempfile:flush();
tempfile:close();

-- // Expected output:
-- // true A 1 4
-- // B 1 6
-- // true A 2 5
-- // B 2 7
-- // true A 3 6
-- // B 3 8
-- // true A 4 7
-- // B 4 9
-- // true A 5 8
-- // B 5 10
-- // true A 6 9
-- // nil nil nil
-- // true A 7 10
-- // ERROR! cannot resume dead coroutine