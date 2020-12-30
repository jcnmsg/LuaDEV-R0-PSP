--  ##################################
--  ####  Gcrew's Defense Patrol  ####
--  ##################################
--  ####  By: DeViaNTe @ GCREW    ####
--  ####   2011 - www.gcrew.es    ####
--  ##################################
-----------------------------------------------------------------------------------------------
-- Released under the license:
-- CC : Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
-- http://creativecommons.org/licenses/by-nc-sa/3.0/
-- http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode
--
-- You are free:
-- to Share — to copy, distribute and transmit the work
-- to Remix — to adapt the work
--
-- Under the following conditions:
-- 	Attribution — You must attribute the work in the manner specified by the author 
--	or licensor (but not in any way that suggests that they endorse you or your use
--	of the work).
--
--	Noncommercial — You may not use this work for commercial purposes.
--
--	Share Alike — If you alter, transform, or build upon this work, you may
--	distribute the resulting work only under the same or similar license to this one.
-----------------------------------------------------------------------------------------------
-- @tester
os.cpu(333);

do
 local a = image.load("img/genesis.png");
 for i=1,255,10 do a:blend(0,0,i); screen.flip(); end
 os.sleep(3.5);
 for i=255,0,-10 do a:blend(0,0,i); screen.flip(); end
 a:free(); a = nil; collectgarbage("collect");
end
os.luasplash();
os.luadevsplash();

-- @import things...
dofile("language.lua");
dofile("modeling.lua");

world.perspective(75,16/9,20,1000);

--@mainconfig
loadconfig();
world.lights(1); world.update();

controlswrapped = controls.read;
function fuckcontrols() controls.read = function() end; end
function restorecontrols() controls.read = controlswrapped; end
cdown = controls.down;
cup = controls.up;

function unflipcontrols() controls.up = cup; controls.down = cdown; end
function flipcontrols() if pla.invertaxis then controls.up = cdown; controls.down = cup; else unflipcontrols(); end end

-- @first splash
--os.luadevsplash();
--os.luasplash();

-- @game splash + loadinga
do
	-- @logo image
	im.load("upgrade","res/midwin.png",false);		im.setalpha("upgrade",0);
	im.load("complete","res/miscomp.png",true);		im.setalpha("complete",0);
	im.load("cc","res/cc.png",false);				im.setpos("cc",390,2); im.setalpha("cc",0);
	im.load("logo","img/logo.png",true);			im.setpos("logo",240,136);	im.setalpha("logo",0);
	im.load("wisfi","img/loader.png",true); 		im.setpos("wisfi",40,186);	im.setalpha("wisfi",0);	im.makerot("wisfi");
	-- this last one breaks load from here to further calls. (need to modify the name...)
	im.load("load","img/loader.png",true); 			im.setpos("load",20,262);	im.setalpha("load",0);	im.makerot("load"); im.speed("wisfi",10);
	im.text("pstart",240,195,text.pstart,255,255,255,0,true,"blinking");
	im.text("tuto",240,10,"TUTORIAL",255,255,255,0,true,"blinking"); im.setalpha("tuto",0);
	im.text("xtocont",430,260,text.xtocont,255,255,255,0,true,"blinking"); im.setalpha("xtocont",255);

	__loading_text = "";
	loadcallback = function()
		im.fadeto("logo",255);
		im.fadeto("load",255);
		im.blit("logo");
		im.blit("load");
		local t = im.getalpha("load");
		screen.print(40,259,text.cargando,color.new(255,255,255,t));
		screen.print(40+screen.textwidth(text.cargando.." "),259,__loading_text,color.new(200,200,255,t));
		screen.flip();
	end;
	
	-- @load resources
	__loading_text = text.cargandomusica; 		music.loadall(); music.switch(4);
	__loading_text = text.cargandoarwing; 		pla.preload();
	__loading_text = text.cargandomenuprin;		stages.init();
	__loading_text = text.cargandomusica; 		en.loadall(); wp.loadall(); stages.preload(1);
	__loading_text = text.cargandoobstacles;	ob.loadall();
	
	-- @disappear on finished
	im.speed("load",5); im.fadeto("load",0);
	while im.getalpha("load") > 0 do
		im.blit("logo"); im.blit("load");
		screen.print(40,259,text.cargado,color.new(255,255,255,im.getalpha("load")));
		screen.print(40+screen.textwidth(text.cargado.." "),259,text.cargandofin,color.new(200,255,200,im.getalpha("load")));
		screen.flip();
	end
	collectgarbage("collect");
end


-- @main menu
function mainmenu()
	-- @first impressions...
	world.lights(1); world.update();
	im.fadeto("pstart",255);
	im.speed("logo",2); im.moveto("logo",240,90); im.fadeto("logo",255);
	im.speed("cc",2); im.fadeto("cc",255);
	menushown = false;
	music.switch(1);
	pla.overridecontrols = true;
	pla.oz = 200;
	local quitin = false;
	local selecti = "";
	restorecontrols();
	climate.change("fadein");
	
	while true do		
		if quitin and os.clock() > quitin then return selecti; end
		controls.read();
		stages.blit();
		pla.fly(); pla.blit(); im.blit("logo"); im.blit("cc");
		draw.fillrect(0,189,480,20,color.new(0,0,0,math.min(im.getalpha("pstart"),60)));
		im.blit("pstart");
		screen.print(240,260,"(CC) Creative Commons - 2011 - DeViaNTe @ Gcrew - www.gcrew.es",0.7,climate.fog.color,0x0,"center",480);
		if menushown then
			stages.rrz = (math.pi / 32) * menu.opc;
			local sel = menu.exec();
			if ( sel ) then
				climate.change("fadeout"); menushown = false;
				im.speed("logo",10); im.fadeto("logo",0); im.fadeto("cc",0);
				fuckcontrols(); quitin = os.clock() + 2.2;
				selecti = sel;
			end
		end
		screen.flip();
		if menushown == false then
			-- @Controls not menu
			if controls.press("start") then
				menushown = true; menu.sxoffset = 0;
				menu.rxoffset = 600; menu.malpha = 0;
				menu.malphad = 10; menu.opc = 0;
				im.speed("pstart",10); im.fadeto("pstart",0);
			end
		else
			-- @controls on menu
			if controls.press("circle") then
				menushown = false; stages.rrz = math.pi / 16;
				im.speed("pstart",10); im.fadeto("pstart",255);
			end
		end
	end
end

--@options menu
function options()
	world.lights(1); world.update();
	local curcallback = loadcallback;
	unflipcontrols();
	loadcallback = nil;
	music.switch(2);
	local option = 0;
	local bg = image.load("img/opt.png");
	local w = color.new(255,255,255);
	local r = color.new(0,128,200);
	local b = color.new(0,0,0);
	local ry = 0;
	local fs = 1;
	climate.change("100vis");
	for i = 0, 255, 10 do
		ry = ry + 1; if ( ry > 360 ) then ry = ry - 360; end
		bg:blend(0,0,i);
		screen.print(240,30,text.actujuego,1,color.new(255,255,255,i),color.new(0,0,0,i),"center");
		pla.model.ship:rotation(math.rad(15),math.rad(ry),0);
		pla.model.ship:position(0,7,-80);
		pla.model.ship:blit();
		screen.flip();
	end
	restorecontrols();
	local oldmusicvol = music.maxvol;
	local oldinvert = pla.invertyaxis;
	local oldanalog = pla.useanalog;
	while true do
		controls.read();
		ry = ry + 1; if ( ry > 360 ) then ry = ry - 360; end
		bg:blit(0,0);
		screen.print(240,30,text.actujuego,1,w,b,"center");
		
		screen.print(240,160,text.optanalog.." "..iif(pla.useanalog,text.si,text.no),fs,iif(option==0,r,w),b,"center"); 
		screen.print(240,190,text.optinvert.." "..iif(pla.invertyaxis,text.si,text.no),fs,iif(option==1,r,w),b,"center"); 
		screen.print(240,220,text.optbgmvol.." "..music.maxvol.."%",fs,iif(option==2,r,w),b,"center");
		screen.print(240,250,text.optvolver,fs,iif(option==3,r,w),b,"center");
		pla.model.ship:rotation(math.rad(15),math.rad(ry),0);
		pla.model.ship:position(0,7,-80);
		pla.model.ship:blit();
		screen.flip();
		if controls.press("down") then option = math.min(option + 1,3); end
		if controls.press("up") then option = math.max(option - 1,0); end
		if (controls.press("left") or controls.press("right")) and option == 0 then pla.useanalog = not pla.useanalog; end
		if (controls.press("left") or controls.press("right")) and option == 1 then pla.invertyaxis = not pla.invertyaxis; end
		if (controls.left()) and option == 2 then music.maxvol = math.max(music.maxvol - 1,0) end
		if (controls.right()) and option == 2 then music.maxvol = math.min(music.maxvol + 1,100) end
		if controls.press("cross") and option == 3 then break; end
		if controls.press("circle") then music.maxvol = oldmusicvol; pla.invert = oldinvert; pla.useanalog = oldanalog; break; end
	end
		optionswindowry = ry;
	function bottomdialogcallback()
		optionswindowry = optionswindowry + 1; if ( optionswindowry > 360 ) then optionswindowry = optionswindowry - 360; end
		bg:blit(0,0);
		screen.print(240,30,text.actujuego,1,color.new(255,255,255),color.new(0,0,0),"center");
		pla.model.ship:rotation(math.rad(15),math.rad(optionswindowry),0);
		pla.model.ship:position(0,7,-80);
		pla.model.ship:blit();
	end
	saveconfig();
	bottomdialogcallback = nil;
	optionswindowry = nil;
	
	if pla.useanalog then controls.analogtodigital(40); else controls.analogtodigital(0); end
	
	for i = 0, 255, 10 do
		ry = ry + 1; if ( ry > 360 ) then ry = ry - 360; end
		bg:blit(0,0);
		screen.print(240,30,text.actujuego,1,color.new(255,255,255),color.new(0,0,0),"center");
		pla.model.ship:rotation(math.rad(15),math.rad(ry),0);
		pla.model.ship:position(0,7,-80);
		pla.model.ship:blit();
		draw.fillrect(0,0,480,272,color.new(0,0,0,i));
		screen.flip();
	end

	bg:free();
	loadcallback = curcallback;
	climate.change("fadeout");
	flipcontrols();
	return;
end

function starwarsparody()
	local cv = music.maxvol;
	for i=0,255,3 do screen.print(240,136,text.alongtime,1,color.new(0,math.floor(i/4),i,i),0x0,"center");  screen.flip(); end
	while music.maxvol > 0 do screen.print(240,136,text.alongtime,1,color.new(0,math.floor(255/4),255,255),0x0,"center"); music.maxvol = music.maxvol - 1; screen.flip(); end
	os.sleep(1); music.maxvol = cv; music.switch(3);
	for i=255,0,-1 do starfield.update(); draw.fillrect(0,0,480,272,color.new(0,0,0,i)); screen.print(240,136,text.alongtime,1,color.new(0,math.floor(i/4),i,i),0x0,"center");  screen.flip(); end
	for i=272,-232,-0.5 do starfield.update(); screen.print(120,i,text.introtext,0.66,color.new(255,255,0),0x0,"full",240); screen.flip(); end
	for i=272,-232,-0.5 do starfield.update(); screen.print(120,i,text.introtext2,0.66,color.new(255,255,0),0x0,"full",240); screen.flip(); end
	for i=272,-232,-0.5 do starfield.update(); screen.print(120,i,text.introtext3,0.66,color.new(255,255,0),0x0,"full",240); screen.flip(); end
	for i=0,255,10 do starfield.update(); draw.fillrect(0,0,480,272,color.new(0,0,0,i)); screen.flip(); end
end



while true do
	if pla.useanalog then controls.analogtodigital(40); else controls.analogtodigital(0); end
	local abc = mainmenu();
	--draw.fillrect(0,0,480,272,color.new(0,0,0)); screen.flip();
	
	if abc == "exit" then  os.exit(); end
	if abc == "opti" then options(); end
	if abc == "multi" then 
		bottomdialogcallback = function() im.blit("logo"); im.blit("cc"); im.blit("wisfi"); screen.print(60,183,text.multiespera,color.new(255,255,255,im.getalpha("wisfi"))); draw.fillrect(0,0,480,272,color.new(0,0,0,200)); coop.extrawait = os.clock() + 20; end;
		im.fadeto("wisfi",255);
		im.fadeto("logo",255);
		coop.flush();
		coop.fallen = false;
		coop.connect = true
		coop.extrawait = os.clock() + 60;
		restorecontrols();
		while coop.connected or os.clock() < coop.extrawait do
			local status = coop.status;
			local texto = "";
			if (status< 2) then texto = text.multiespera; end
			if (status==2) then texto = text.multijoined:format(coop.hallcount); end
			if (coop.linked) then texto = text.multiunion; end
			im.blit("logo");
			im.blit("wisfi");
			controls.read();
			screen.print(60,183,texto,color.new(255,255,255,im.getalpha("wisfi")));
			screen.flip();
			if controls.press("circle") then coop.connect = false; coop.flush(); wlan.term(); break; end
			if coop.linked then break; end
			if coop.fallen then break; end
		end
		if not coop.linked then coop.flush(); wlan.connect = false; wlan.term(); end
		-- timed out, or.. quitted. no matter what.
		im.fadeto("wisfi",0); im.fadeto("cc",0);
		im.fadeto("logo",0);
		bottomdialogcallback = nil;
		while (im.getalpha("wisfi") > 0) do im.blit("logo"); im.blit("cc"); im.blit("wisfi"); screen.print(60,183,text.multiunion,color.new(255,255,255,im.getalpha("wisfi"))); screen.flip(); end
		
		-- what happened?
		-- multiplayer game.
		
		if coop.linked then
			coop.playing = 1;
			flipcontrols(); -- starwarsparody();
			stages.curstage = 1; stages.curpattern = 1; stages.cursubpattern = 1; pla.overridecontrols = false;
			pla.oz = 0; restorecontrols(); climate.change("fadein"); stages.actiondone = true;
			stages.rrz = 0;	-- desinclinar terreno.
			while coop.linked and not coop.fallen do
				local function blitter() 
					local tot = math.max(en.l+3,wp.l+2,ob.l+2);
					wp.cm = 1-wp.cm; -- change buffer;
					wp.c[wp.cm] = { { }, { }, { }, { }, { }, { }, { }, { }, { }, { } }; -- refresh collisions.
					stages.blit();
					pla.fly();
					for i=1, tot do en.update(i); wp.update(i); ob.update(i); end
					en.spriteburst();
					pla.blit();
					pla.hudblit();
				end
				controls.read();
				blitter();
				if controls.press("start") then coop.fallen = true; coop.flush(); break; end
				screen.flip();
			end
		end
		-- @multiplayer game
		
	end
	if abc == "newgam" then
		flipcontrols(); -- starwarsparody();
		stages.curstage = 1; stages.curpattern = 1; stages.cursubpattern = 1; pla.overridecontrols = false;
		pla.oz = 0; restorecontrols(); climate.change("fadein"); stages.actiondone = true;
		while true do
			local function blitter() 
				local tot = math.max(en.l+1,wp.l+1,ob.l+1);
				local a = os.clock();
				wp.cm = 1-wp.cm; -- change buffer;
				wp.c[wp.cm] = { { }, { }, { }, { }, { }, { }, { }, { }, { }, { } }; -- refresh collisions.
				stages.blit();
				pla.fly();
				for i=1, tot do en.update(i); wp.update(i); ob.update(i); end
				en.spriteburst();
				pla.blit();
				pla.hudblit();
				im.blit("tuto");
				talk.blit();
			end
			controls.read();
			blitter();
			--if controls.press("select") then lightstation(blitter) end
			if controls.press("start") then pause(); end
			if controls.press("triangle") then pla.rearview = not pla.rearview; pla.p = iif(pla.rearview,20,0); end
			--if controls.press("l") then climate.change("nightvision"); end
			--if controls.press("circle") then climate.change("daily"); end
			--if controls.press("triangle") then climate.change("night"); end
			--if controls.press("square") then climate.change("sunset"); end
			screen.flip();
		end
	end
	
	
	
end


-- @Valley appear
os.exit();