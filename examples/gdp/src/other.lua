
-- @menu group
-- This group does and blits the main menu screen. With an offset and a real offset (leftoffset of the first option).
-- Then, the offset is multiplied by the option number, if go to right, offset inc, real offset "goes to" offset, so
-- our option will change progressively. Options spacing 240px.
menu = { 
	sxoffset = 0, rxoffset = 600, malpha = 0, malphad = 10,
	snd = sound.load("snd/menu.wav",1), AR = image.load("img/arrowr.png"), AL = image.load("img/arrowl.png"),
	x=0,
	texts = { text.nuevojuego, text.cargajuego, text.multijuego, text.actujuego, text.kitajuego },
	responses = { "newgam", "conti", "conti", "opti", "exit"  },
	numopt = 5,
	blit = function(x)
		if menu.rxoffset < menu.sxoffset then menu.rxoffset = menu.rxoffset + iif((((menu.sxoffset - menu.rxoffset) / 3) > 2),math.ceil((menu.sxoffset - menu.rxoffset) / 3),1); end 
		if menu.rxoffset > menu.sxoffset then menu.rxoffset = menu.rxoffset - iif((((menu.rxoffset - menu.sxoffset) / 3) > 2),math.ceil((menu.rxoffset - menu.sxoffset) / 3),1); end 
		menu.malpha = menu.malpha + menu.malphad; if menu.malpha > 255 and menu.malphad > 0 then menu.malpha = 255; menu.malphad = -menu.malphad; end 
		if menu.malpha < 100 and menu.malphad < 0 then menu.malpha = 100; menu.malphad = -menu.malphad; end 
		for i=1,menu.numopt do
			screen.print((240*i) - menu.rxoffset,192,menu.texts[i],1,color.new(255,255,255,iif((x == (i-1)),255,128)),color.new(0,0,0,iif((x == (i-1)),255,128)),"center");
		end		
		if x > 0 then image.blend(130,195,menu.AL,menu.malpha); end 
		if x < menu.numopt-1 then image.blend(350,195,menu.AR,menu.malpha); end 
	end,
	exec = function() if not menu.opc then menu.opc = 0; end if controls.press("left") then if menu.opc > 0 then menu.snd:play(7); end menu.opc = math.max(menu.opc - 1,0); end if controls.press("right") then if menu.opc < menu.numopt-1 then menu.snd:play(7); end menu.opc = math.min(menu.opc + 1,menu.numopt-1); end menu.sxoffset = (240 * menu.opc); screen.clip(11,120,458,159);  menu.blit(menu.opc); screen.clip(); if controls.press("cross") or controls.press("start") then menu.snd:play(7); controls.read(); return menu.responses[menu.opc+1] end return false; end,
}
menu.AR:center(); menu.AR:resize(25,25);
menu.AL:center(); menu.AL:resize(25,25);

-- @starfield
starfield = { 
	stars = {}, num=50, origx=240, origy=136, paused=false, speed=1, rspeed=1, a=255,
	createstar = function() local star, xcoeff, ycoeff; star = { x = math.random() * 480 - starfield.origx, y = math.random() * 272 - starfield.origy, z = 480, width = 2 }; xcoeff, ycoeff = iif(star.x > 0,1,-1), iif(star.y > 0,1,-1); if (math.abs(star.x)>math.abs(star.y)) then star.dx = 1.0; star.dy = math.abs(star.y / star.x); else star.dx = math.abs(star.x / star.y); star.dy = 1.0; end star.dx, star.dy, star.dz = star.dx * xcoeff * starfield.speed, star.dy * ycoeff * starfield.speed, -1; star.ddx, star.ddy = 0.1 * star.dx, 0.1 * star.dy; return star; end,
	move = function(star) if starfield.paused then return star; end star.x, star.y, star.z, star.dx, star.dy, star.width = star.x + star.dx, star.y + star.dy, star.z + star.dz, star.dx + star.ddx, star.dy + star.ddy, math.abs(1 + ((480 - star.z) * 0.05)); return star; end,
	update = function() starfield.speed = vgt(starfield.speed,starfield.rspeed,0.01); for i = 1, #starfield.stars do starfield.stars[i] = starfield.move(starfield.stars[i]); local s = starfield.stars[i]; if (s.x < -starfield.origx or s.x > starfield.origx or s.y < -starfield.origy or s.y > starfield.origy) then starfield.stars[i] = starfield.createstar(); else draw.fillrect(starfield.stars[i].x + 240,starfield.stars[i].y+136,starfield.stars[i].width,starfield.stars[i].width,color.new(255,255,255,starfield.a)); end end for i = #starfield.stars, 50 do table.insert(starfield.stars,starfield.createstar()); end end,
};

-- @talkysys
talk = {
	images = { image.loadsprite("res/pnj/00.png",100,100), image.loadsprite("res/pnj/01.png",100,100) },
	showing = false,
	mood = 0,
	now = os.clock(),
	speech = function(i,t) talk.i = i; talk.t = t; talk.showing = true; talk.now = os.clock(); end,
	close = function() talk.showing = false; end,
	blit = function()
		if talk.showing then
			pla.overridecontrols = true;
			talk.images[talk.i]:setframe(talk.mood);
			draw.fillrect(0,170,480,102,color.new(0,0,0,180));
			talk.images[talk.i]:blit(5,272-100);
			screen.print(110,175,talk.t,0.6,color.new(255,255,255),color.new(0,0,0,200),"left",340);
			im.blit("xtocont");
			if controls.press("cross") or (os.clock() - talk.now) > 10 then 
				if ( os.clock() - talk.now > 0.500 ) then menu.snd:play(7); talk.showing = false; pla.overridecontrols = false; end
			end
		end
	end,
}

-- @savegames
mainconfigtable = { gameid="GDEFPATROL", savenames = "PERFIL" };
mainconfigvsh = { title=text.configtitle, subtitle=text.configsubtitle, details=text.configdetails, savetext=text.saveconfig, icon0="res/config_icon0.png", saveicon="res/save_icon0.png" };
historyconfigtable = { gameid="GDEFPATROL", savenames = { "HIST00", "HIST01", "HIST02", "HIST03", "HIST04", "HIST05", "HIST06", "HIST07", "HIST08", "HIST09" } };
historyconfigvsh = { title=text.savetitle, subtitle=os.date(), details=text.savedetails, savetext = text.savetext, icon0="res/save_icon0.png", saveicon="res/save_icon0new.png", snd0="res/snd0.at3" };
function saveconfig()
	local iny = pla.invertaxis and "true" or "false";
	local usa = pla.useanalog and "true" or "false";
	local mxv = music.maxvol or 100;
	local data = "iny="..iny..";usa="..usa..";mxv="..mxv..";";
	local a,b = savedata.save(mainconfigtable,mainconfigvsh,data);
end

function loadconfig()
	local a,b,c = savedata.autoload(mainconfigtable);
	local iny = false;
	local usa = false;
	local mxv = 100;
	if (a) then
		local t = c:explode(";");
		for i=1,#t do
			local f = t[i]:explode("=");
			if ( f[1] == "iny" ) then iny = iif(f[2]=="true",true,false); end
			if ( f[1] == "usa" ) then usa = iif(f[2]=="true",true,false); end
			if ( f[1] == "mxv" ) then mxv = tonumber(f[2]); end
		end
	end
	pla.invertaxis = iny or false;
	pla.useanalog = usa or false;
	music.maxvol = iif(type(mxv)=="number" or type(mxv)=="string",mxv,100) or 100;
end



-- @pause function
function pause()
	local a = screen.toimage();															-- grab a copy
	local ret = false;
	while not ret do
		controls.read();
		a:blit(0,0);
		a:blend(-2,-2,100);
		a:blend(2,2,100);
		a:blend(-2,2,100);
		a:blend(2,-2,100);
		draw.fillrect(0,0,480,272,color.new(0,0,0,50));
		screen.print(240,136,"PAUSE",1,color.new(255,255,255),color.new(0,0,0),"center");
		screen.flip();
		if controls.press("start") then ret = true; end
	end
	a:free();
end
