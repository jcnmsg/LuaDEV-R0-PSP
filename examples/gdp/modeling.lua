--  ##################################
--  ####  Gcrew's Defense Patrol  ####
--  ##################################
--  ####  By: DeViaNTe @ GCREW    ####
--  #### (c) 2011 - www.gcrew.es  ####
--  ##################################

-- GDP, the rewritten and commented version :P
-- Sure, this code could be optimized, but it was written "on the fly",
-- and later adding and adding extras, so, when finished it could be
-- optimized as well, but not done.

-- Collision testing explanation for the whole game:
-- As 3D collision tesing isn't implemented in LuaDEV (yet... maybe...)
-- we need to "simulate" a depth collision testing. Our screen depth will be 1000 points in depth.
-- So... we will sub-divide this range in 9 ranges of 100 points every one. (further depth ignored)
-- For every depth 100 point range, we will test guns VS enemies.
-- For the first depth, we will test enemy guns and terrain VS player.
-- Pretty simple collision testing, but this will cover our needs.

-- Speed optimization in collision testings:
-- Lua isn't as fast as C, sure, but LuaDEV is pretty fast, compared with other luaplayers.
-- But, for performance, we need to do an approximation, so we will don't need to test every point, with every thing.
-- For example, player ammo vs enemy, for every weapon type, we will make a "point caché". So, we will have
-- 9 cached ranges, filled with the points of every weapon. There are 2 different weapon types, blasters, and missiles.
-- (bombs cover fullrange). This provides us with 18 layers of guns, 2 at every range, and for every frame,
-- we will fill every range with the points of every blaster, and test the enemies only with the subrange they are
-- vs the guns in that sub-range. (Near shoots will never hit further enemies, for example, we don't need to test collision).
-- This approximation gives us a good performance inc, at the cost of a small amount of ram. So.. good enough!
-- Weapons will be "double buffered". As we will blit enemies and weapons at the same time, to make use of only one
-- "for" construction for all objects, we need to "buffer" all the weapons, and test them in the next frame,
-- while buffering the weapons for the next frame again.

-- Things like that one, the tricks on sub-range the depths and pre-cache all the points, are done at design time,
-- so, if you are designing a homebrew, make sure that you detail every detail in the game, so the final coding will
-- be "mechanic", only translating your ideas into code.

currentversion = "0.2";		-- Current version of GDP.
model.buffer(2*1024*1024);	-- LuaDEV inits with 1mb for the display list, mm, better we increase it to 2mb.
pim = math.pi / 2;			-- pi/2
pi2 = math.pi * 2;			-- 2*pi
skip = false;				-- We don't need to re-calc everything every frame... or do we?

-- @FUNCTIONS
-- vgt : "var go to", accepts two vars and a increment step, returns the first var incremented by the step going to the second var.
--     (You will find along all the source vars typed as "var", "rvar". This function is the helper for those constructions).
--     (Cause with this function var will "go to" rvar, gradually, not instantly. Smoothing effects.                       )
-- cgt : "color go to", something similar withs vars, but with colors, at component range.
-- w3 : Given a dot and dimensions, generate box.
-- w2 : Given a dot and dimensions, generate a box and rotate it. (used for collision testing)
function vgt(ra,a,i) if ( ra < a ) then return math.min(ra + i,a); end if ( ra > a ) then return math.max(ra - i,a); end return ra; end
function cgt(c1,c2) return color.goto(c1,c2,climate.speed); end
function w3(cx,cy,w,h) return {{cx-w,cy-h},{cx+w,cy-h},{cx+w,cy+h},{cx-w,cy+h}}; end
function w2(cx,cy,w,h,a) return math.poly.rotate(cx,cy,a,w3(cx,cy,w,h)); end
function t2(cx,cy,f) local t = { }; for i=1, #f do t[i] = { f[i][1]+cx, f[i][2]+cy }; end return t; end

-- @HUD :: ¿Head up display?
-- Array for storing some hud-based variables / images.
hud = { 
	hud = image.load("res/hudbase.png"),		-- base image.
	lifea = image.load("res/lifea.png"),		-- life front bar
	lifeb = image.load("res/lifeb.png"), 		-- life backg. bar
	boosta = image.load("res/boosta.png"), 		-- boost front bar
	boostb = image.load("res/boostb.png"), 		-- boost backg. bar
	a = 0, ra = 0 								-- opacity, real opacity.
};

dofile("src/layers.lua");
dofile("src/player.lua");
dofile("src/enemies.lua");
dofile("src/weapons.lua");
dofile("src/climate.lua");
dofile("src/objects.lua");
dofile("src/stages.lua");
dofile("src/music.lua");
dofile("src/coop.lua");
dofile("src/other.lua");