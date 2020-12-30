
--- Music module.
music = {
	channel = 1,
	current = 0,
	maxvol = 50,
	songs = { },
	loadall = function()
		sound.fastload(true);
		if files.exists("bgm/intro.mp3") then
			table.insert(music.songs,{ bgm=sound.load("bgm/intro.mp3"), playing=false, vol=0, rvol=0, loopf=66000 });
			table.insert(music.songs,{ bgm=sound.load("bgm/opt.mp3"), playing=false, vol=0, rvol=0, loopf=39500 });
			table.insert(music.songs,{ bgm=sound.load("bgm/sw.mp3"), playing=false, vol=0, rvol=0, loopf=63000 });
			table.insert(music.songs,{ bgm=sound.load("bgm/devian.mp3"), playing=false, vol=0, rvol=0, loopf=92560 });
			--table.insert(music.songs,{ bgm=sound.load("bgm/theme.mp3"), playing=false, vol=0, rvol=0, loopf=17900 });
			--table.insert(music.songs,{ bgm=sound.load("bgm/boss.mp3"), playing=false, vol=0, rvol=0, loopf=62800 });
			--table.insert(music.songs,{ bgm=sound.load("bgm/bonus.mp3"), playing=false, vol=0, rvol=0, loopf=36720 });
			
		else
			music.fadeout = function() end;
			music.fadein = function() end;
			music.switch = function() end;
			music.step = function() end;
		end
		sound.fastload(false);
		music.oldf = screen.flip;
		screen.flip = function()
			--screen.print(10,10,screen.fps());
			skip = not skip;
			--local s = "";
			--if wlan.connected() and coop.connected and coop.ping and coop.ping > 0 then s = " NLN "..coop.ping; end
			--screen.print(10,30,"::"..coop.status.."/"..coop.lastcmd.."/"..iif(coop.pingtime,coop.pingtime,0)..s.." SENDQ "..#coop.queue.." RECVQ "..#coop.rqueue);
			
			music.step(); coop.exec(); music.oldf(); climate.update(); wp.refresh(); world.perspective(75,16/9,20,1000);

		end
		topdialogcallback = function()
			music.step();
		end;
	end,
	fadeout = function(n) music.songs[n].vol = 0; end,
	fadein = function(n) music.songs[n].vol = 99; end,
	switch = function(n) if (music.songs[music.current]) then music.fadeout(music.current) end music.fadein(n); music.current = n; end,
	step = function ()
		if skip then return end;
		for i=1,4 do
			if music.songs[i].vol > music.songs[i].rvol then music.songs[i].rvol = math.clamp(music.songs[i].rvol + 0.5,0,music.maxvol); end
			if music.songs[i].vol < music.songs[i].rvol then music.songs[i].rvol = math.clamp(music.songs[i].rvol - 0.5,0,music.maxvol); end
			if music.songs[i].rvol == 0 and music.songs[i].playing == true then music.songs[i].bgm:stop(); music.songs[i].playing = false; end
			if music.songs[i].rvol > 0 and music.songs[i].playing == false then music.songs[i].bgm:play(music.channel); music.songs[i].playing = true; music.channel = 1 - music.channel; end
			if music.songs[i].bgm:playing() then music.songs[i].bgm:volume( math.min(music.songs[i].rvol,music.maxvol), math.min(music.songs[i].rvol,music.maxvol) ); else music.songs[i].playing = false; end
			
			if music.songs[i].playing == true then
				if music.songs[i].bgm:position() > music.songs[i].loopf then
					music.songs[i].bgm:stop();
					music.songs[i].bgm:play(music.channel);
					music.songs[i].bgm:volume(music.songs[i].rvol,music.songs[i].rvol);
					music.channel = 1 - music.channel;
				end
			end
		end
	end,
};