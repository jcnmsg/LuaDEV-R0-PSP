
-- @SOCKETS MULTIPLAYER  
-- PROTOCOL:
--   Transfer between 'packets' of data, each packed separated by '/'.
--   Each packet, also, starts with '(' and ends with ')'. These are arbitrarily
--   selected at design time, and will let us know if a packed arrived entirely.
--   If arrived entirely, process it, else, discard, unless it is the last received,
--   cause the last received probably been cutted, and receive the next part in the next
--   read. If this happens, should be executed correctly, else, discard.

coop = {
	status 		= 0,
	connect 	= false,
	socket 		= nil,
	host 		= "www.gcrew.es",
	port 		= 8080,
	queue		= { },																		-- Write queue.
	lastcmd 	= os.clock(),
	linked 		= false,
	linkmode	= 0,
	playing		= false,
	delay		= 1;
	send 		= function(t)																-- Enqueue data to send.
				if t then local s = coop.queue; table.insert(s,"("..t..")");
				coop.queue = s;
				end end,
	read		= function()																-- Get data from socket.
				if coop.socket then local a,b = coop.socket:recv();			 				--    Read data
				if a != "" then coop.lastcmd = os.clock(); return a, b; end 				--    Data and length if data found.
				return false, 0; end return false, 0;										--    false and 0 if error.
				end,
	flush 		= function() coop.queue = { }; coop.playing = false; 	-- Flush connection.
				coop.delay = 1;
				coop.linked = false; if coop.socket then 									--    Clear vars, disconnect...
				coop.socket:send("QUIT\n"); coop.socket:free(); coop.socket = nil; end 		--    ... prepare all for next
				coop.status = 0; 														 	--    connection.
				coop.lastcmd = os.clock(); end;												--    ....
	checkconn	= function()																-- Check connection sanity.
	if not coop.connect then return true; end;												-- If no need of connection. get back.
	
	if coop.connect and not wlan.connected() then 											-- If required connection and not wlan..
		coop.flush(); 																		-- ... init wlan. retry.
		local c = wlan.init(0); 
		if not c or c == 0 then coop.connect = false; end 
		return true; 											
	end	
	if coop.linked and not coop.connect then 												-- If linked, but not asked to..
		coop.flush(); wlan.term(); return true; 											-- flush(). retry
	end
	if not coop.socket then 																-- If no socket...
		local a,b = socket.udp(coop.host,coop.port);	 									-- create socket...
		if a and b then coop.socket = a; return true; end									-- ... and return if ok.
	end
	if wlan.strength() < 40 then return true; end											-- Houston... signal... too weak...
	if not coop.socket then return true; end												-- If no socket. retry.
	coop.status = math.max(coop.status,1);
	return false;
	end,	
	getall		= function() 																-- Get all avaiable data.
	local data, len = coop.read();															-- Read from socket...
	if len > 0 then
		for cmd in data:gmatch("%b()") do
			coop.cmd(cmd:sub(2,-2));
		end
	end
	end,
	write		= function()																-- Send queued data.
	if coop.queue[1] then																	-- If pending data...
		local len;
		len = coop.socket:send(coop.queue[1].."\n",coop.host,coop.port);
		if (len > 0) then																	-- If sent...
			table.remove(coop.queue,1);														--    Remove from queue.
			return true;
		end
		return false;
	end
	return false; end,
	cmd			= function(rcvd)															-- Process one command:
		local cmd = rcvd:explode(" ");														-- Split by words.
		if (cmd[1] == "FLY") then
			local r = cmd[2]:explode(",");
			pla.x2, pla.y2, pla.z2, pla.RZ2 = tonumber(r[1]), tonumber(r[2]), tonumber(r[3]), tonumber(r[4]);
			coop.linked = true;
			coop.status = 2;
		end
	end,
	exec		= function() 																	-- For every cycle:
	if coop.checkconn() then return; end														-- Check connection / connect.
	if os.clock() - coop.lastcmd > 10 and coop.linked then coop.connect = false; coop.flush(); end
	if os.clock() - coop.lastcmd > 60 and not coop.linked then coop.connect = false; coop.flush(); end
	coop.getall();																				-- Check for avail. data.
	local written = coop.write();																-- Send avail. data.
	if (os.clock() - coop.lastcmd) > coop.delay then													-- While foreva' and waiting a bit...
		if coop.status == 0 then return end;
		if coop.status == 1 then coop.send("WPLAY"); return; end;
		if coop.status == 2 then
			coop.send(string.format("FLY %.2f,%.2f,%.2f,%.4f",pla.x,pla.y,pla.z,pla.RZ));		--   Refresh my position...
			return;
		end
	end
	screen.print(10,50,"Status: "..coop.status);
	end,
};
	
	