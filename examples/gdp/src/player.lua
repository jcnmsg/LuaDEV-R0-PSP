-- @PLAYER :: Ship controls and vars
-- Wooooohoooo, a little big array storing all player-related vars / functions.
pla = {
	life=0, rlife=125, lives=3, 														-- life and lives
	boost=0, rboost=125, b=0,B=0,														-- booster machine
	boostsnd = sound.load("snd/boost.wav"), boostoff = sound.load("snd/boostoff.wav"),	-- booster sounds
	boosting = false, boostaccel = 1, boostdecel = 0.5,									-- booster accelerations
	
																						-- Player pos = 
	x=-35, y=10, z=-90,																	-- Player real position +
	incx=0,incy=0,incz=0,																-- incremented by effects +
	ox = 0, oy = 0, oz = 0,																-- overrided offset.
	
	p=0, P=0, rearview= false,															-- Perspective effect (rear view)
	RZ=math.pi-(0.01), rz=0,															-- Player rotation.
	---RX=0, RY=0, rx=0, ry=0,
	
	cx=0,cy=0,ix=0,iy=0, colx=0, coly=0,												-- centered, increment and colision.
	ang=0,																				-- 360º var.
	viring=false,																		-- player turning 90º (L or R)
	
	overridecontrols = false,															-- override controls and position.
	tilt = 0.4, tiltinc = 0.4,															-- max tilt / tilt speed.
	invertyaxis = false, useanalog = true,												-- options of controls.
	bbox = { w=25, h=8, d=math.vector.magnitude(30,9) },								-- bounding box of ship.
	rbbox = { {1,1}, {1,1}, {1,1}, {1,1} },												-- real bounding box (after rotation).
	model = { ship = nil, motor = nil, shield = nil },									-- 3d objects
	
	exp = { 																			-- duh, need other var to store this
		image.load("img/exp/exp_01.png"),												-- but... whatever... the explosion
		image.load("img/exp/exp_02.png"),												-- animation frames.
		image.load("img/exp/exp_03.png"),												-- ... k
		image.load("img/exp/exp_04.png"),												-- ... a
		image.load("img/exp/exp_05.png"),												-- ... a
		image.load("img/exp/exp_06.png"),												-- ... a
		image.load("img/exp/exp_07.png"),												-- ... b
		image.load("img/exp/exp_08.png"),												-- ... b
		image.load("img/exp/exp_09.png"),												-- ... o
		image.load("img/exp/exp_10.png"),												-- ... o
		image.load("img/exp/exp_11.png"),												-- ... o
		image.load("img/exp/exp_12.png"),												-- ... o
		image.load("img/exp/exp_13.png"),												-- ... m
		image.load("img/exp/exp_14.png"),												-- ... m
		image.load("img/exp/exp_15.png"),												-- ... m
		image.load("img/exp/exp_16.png"),												-- ... .
		image.load("img/exp/exp_17.png"),												-- ... .
		image.load("img/exp/exp_18.png"),												-- ... .
		image.load("img/exp/exp_19.png"),												-- ...  
		image.load("img/exp/exp_20.png")												-- ... !
	},
	exps = sound.load("snd/exp.wav"),													-- explosion sound.
	
	weapon = 1,																			-- current weapon
	weapons = { { 1, -1 } }, 															-- weapon's ammunition
	
	crossh = image.load("res/roti.png"),
	imangle = 0, impch = 1, impacting = false, imptime = os.clock(),					-- collided with something. it hurts...
	impact = { 																			-- collision sounds.
		sound.load("snd/impact_l.wav"), 
		sound.load("snd/impact_m.wav"), 
		sound.load("snd/impact_h.wav") 
	},
	
	-- Functions related to PLAYER
	
	coli=function()
		if (os.clock() - pla.imptime) > 0.2 then
			pla.imptime = os.clock(); 
			pla.impact[pla.impch]:play(4); pla.impch = pla.impch + 1; if pla.impch > 3 then pla.impch = 1; end
			local k = math.random(1,10);
			pla.colx = iif(pla.x > 0,-k,k);
			pla.coly = iif(pla.y < 0,k,-k);
			pla.rlife = pla.rlife - 3;
		end
		draw.fillrect(0,0,480,272,color.new(255,0,0,20));
	end,
	-- bc (stands for bounding box create and collision test (yay))
	--  * if overriding controls... i'm a ghost. Don't test. xD
	--  * Recreates bounding box
	
	bc=function() 
		if skip then return end
		if pla.overridecontrols then return end 
		pla.rbbox = w2(pla.x+pla.incx,pla.y+pla.incy-80,pla.bbox.w,pla.bbox.h,-pla.RZ); 
		if coop.playing and pla.rx2 then pla.rbbox2 = w2(pla.rx2,pla.ry2-80,pla.bbox.w,pla.bbox.h,-pla.RRZ2); end
		if coop.playing and pla.rbbox2 and math.poly.testlist(pla.rbbox,pla.rbbox2) then pla.coli(); end
		if stages.fuck then
			for i=1, #stages.fuck do
				draw.fillrect(0,0,10,10,color.new(255,0,0,100));
				--screen.print(10,80,pla.y+pla.incy.." - size: "..#stages.fuck);
				if math.poly.testlist(stages.fuck[i],pla.rbbox) then pla.coli(); end
				if controls.select() then draw.poly(240,272,stages.fuck[i],color.new(255,0,0)); end
			end
		end
		
		if controls.select() then draw.poly(240,272,pla.rbbox,color.new(255,255,0)); end
		if controls.select() and pla.rx2 then draw.poly(240,272,pla.rbbox2,color.new(0,255,0)); end
	end,
	
	-- hudstep: make things happen in the hud.
	hudstep=function() 
		if skip then return end;
		hud.ra = vgt(hud.ra,hud.a,10);																-- Opacity gradually.
		if pla.rlife > pla.life then pla.life = pla.rlife; end 										-- Life inc instantly.
		if pla.rlife < pla.life then pla.life = vgt(pla.life,pla.rlife,0.15); end					-- Life dec gradually.
		if pla.rboost > pla.boost then pla.boost = pla.rboost; end 									-- Boost inc instantly
		if pla.rboost < pla.boost then pla.boost = pla.boost - 0.15; end							-- Boost dec gradually.
	end,
	
	-- hudblit: blits the hud in screen.
	hudblit=function() 
		local f,x; f = math.floor; x = math.clamp;													-- some links to functions.
		pla.hudstep(); 																				-- make a step.
		hud.hud:blend(0,0,hud.ra); 																	-- blend the base
		screen.clip(12,6,f(pla.life),50); 															-- limit area to life bar
		hud.lifeb:blend(12,6,hud.ra); 																-- blend bg image of life
		screen.clip(12,6,x(f(pla.rlife),1,125),50); 												-- limit area to real life
		hud.lifea:blend(12,6,hud.ra); 																-- blend front life.
		screen.clip(467 - x(f(pla.boost),1,125),6,x(f(pla.boost),1,125),50); 						-- limit area to boost bar
		hud.boostb:blend(342,6,hud.ra); 															-- blend boost bar
		screen.clip(469 - x(f(pla.rboost),1,125),6,x(f(pla.rboost),1,125),50); 						-- limit real boost
		hud.boosta:blend(342,6,hud.ra); 															-- blend real boost
		screen.clip(); 																				-- unlimit draw.
		if ( pla.P > 0 ) then 																		-- cabin view...
			pla.crossh:center();																	-- crosshair center
			pla.crossh:blend(240,136,(pla.P*12.5));													-- blend image.
		end
	end,
	
	-- blit: blits the player models.
	blit=function()
		local k = 0.5+(math.random()/2);															-- A little bit of randomness..
		
		pla.model.ship:rotation(0,0,pla.RZ);														-- give rotation
		pla.model.ship:position(pla.x+pla.incx,(-pla.y)+pla.incy,pla.z+pla.incz+pla.oz);			-- give position
		pla.model.ship:blit();																		-- no words. blit!
		
		pla.model.motor:rotation(0,0,math.rad(pla.ang*2));											-- Add the flaming motor...
		pla.model.motor:position(pla.x+pla.incx,((-pla.y)+pla.incy)+2.2,pla.z+pla.incz+k+pla.oz); 	-- ... with a little...
		pla.model.motor:scale(1,k-0.5,k+(pla.B*0.01)); 												-- ... randomness ...
		pla.model.motor:blit();																		-- ... and blit it.
		pla.bc();																					-- re-gen the bounding box.
		
		-- PLAYER 2:
		if coop.playing then
			if not pla.RZ2 or not pla.x2 then return end
			if not pla.RRZ2 then pla.rx2 = pla.x2; pla.ry2 = pla.y2; pla.rz2 = pla.z2; pla.RRZ2 = pla.RZ2; end
			pla.rx2 = pla.rx2+(pla.x2-pla.rx2)*0.6;
			pla.ry2 = pla.ry2+(pla.y2-pla.ry2)*0.6;
			pla.rz2 = pla.rz2+(pla.z2-pla.rz2)*0.6;
			pla.RRZ2 = pla.RRZ2+(pla.RZ2-pla.RRZ2)*0.6;
			pla.model.ship:rotation(0,0,pla.RZ2);														-- give rotation
			pla.model.ship:position(pla.rx2+pla.incx,(-pla.ry2)+pla.incy,pla.rz2+pla.incz+pla.oz);		-- give position
			pla.model.ship:blit();																		-- no words. blit!
			pla.model.motor:rotation(0,0,math.rad(pla.ang*2));											-- Add the flaming motor...
			pla.model.motor:position(pla.rx2,(-pla.ry2)+2.2,pla.rz2); 									-- ... with a little...
			pla.model.motor:scale(1,k-0.5,k+(pla.B*0.01)); 												-- ... randomness ...
			pla.model.motor:blit();																		-- ... and blit it.	
		end
	end,
	
	-- preload("shipname"): load the ship model
	preload = function(s)
		local s = s or "ship0";																		-- ship or default one.
		if pla.model.ship then pla.model.ship:free(); pla.model.ship = nil; end						-- if found, free
		if pla.model.motor then pla.model.motor:free(); pla.model.motor = nil; end					-- if found, free
		if pla.model.shield then pla.model.shield:free(); pla.model.shield = nil; end				-- if found, free
		pla.model.ship = model.load("obj/ship/"..s.."/ship.obj",0.4,color.new(0,0,0));				-- load new
		pla.model.motor = model.load("obj/ship/"..s.."/motor.obj",0.4,color.new(0,0,0));			-- load new
		--pla.model.shield = model.load("obj/ship/"..s.."/shield.obj");								-- load new
	end,
	
	-- make the airship fly.. :')
	fly=function()
		local spx, spy, angx, angy, tx, ty;															-- many locals to start with...
		pla.P = vgt(pla.P,pla.p,1);
		pla.ang = pla.ang + 5; if pla.ang >= 360 then pla.ang = 0; end								-- rotative 360º var.
		-- spx, spy are random booster increments in x and y position. (wind turbulence?)
		spx, spy = math.round(math.random()*(pla.B/12) ,4)+0.001, math.round(math.random()*(pla.B/12),4)+0.001;
		
		if not pla.overridecontrols then
			--move: inc movement by 0.1 + 20%, limit range -7 to 7
			if controls.left() then if pla.ix < 0 then pla.ix = math.max( pla.ix - 0.1 + (pla.ix * 0.2) ,-7); else pla.ix = (pla.ix / 8) - 0.5; end end
			if controls.right() then if pla.ix > 0 then pla.ix = math.min( pla.ix + 0.1 + (pla.ix * 0.2) ,7); else pla.ix = (pla.ix / 8) + 0.5; end end
			if controls.down() then if pla.iy > 0 then pla.iy = math.min( pla.iy + 0.1 + (pla.iy * 0.2) ,7); else pla.iy = (pla.iy / 2) + 0.5; end end
			if controls.up() then if pla.iy < 0 then pla.iy =  math.max( pla.iy - 0.1 + (pla.iy * 0.2) ,-7); else pla.iy = (pla.iy / 2) - 0.5; end end
			
			--move: if not moving, deccel 50%.
			if not controls.up() and not controls.down() then pla.iy =  pla.iy / 2; end
			if not controls.left() and not controls.right() then pla.ix =  pla.ix / 2; end
			
			-- turn 
			pla.viring = (controls.l() or controls.r()) and (controls.l() != controls.r());			-- are we turning?
			if controls.l() then pla.rz = pim elseif controls.r() then pla.rz = -pim end			-- .. where?
			
			-- @boost
			if controls.circle() then																-- are we boosting?
				if pla.rboost > 2 then pla.b = 20; pla.rboost = math.max(pla.rboost - 0.5,0); 		-- .. can boost, turbo!
				else pla.b = 0; pla.rboost = 0; end													-- .. we cant boost..
			else 
				pla.b = 0; pla.rboost = math.min(pla.rboost + 0.25,125);							-- nope, not boosting.
			end
			
			-- @shoot
			if controls.cross() then
				if ( pla.weapons[pla.weapon][1] == 1 ) then wp.sht(pla.x,pla.y,pla.z,pla.RZ,1,1); end
			end
		else																						-- overriding controls...
			pla.b = 0; 																				-- no boost
			pla.rboost = math.min(pla.rboost + 0.25,125);	 										-- boost charge
			pla.iy =  pla.iy / 2; 																	-- no move
			pla.ix =  pla.ix / 2;																	-- no move
			pla.viring = false;																		-- no turning
		end

		-- colx, and coly are collisions offsets, sum that to real movement (not position):
		if math.abs(pla.colx) > 0.3 then pla.colx = math.round(pla.colx / 2,5); pla.ix = pla.ix + pla.colx; end
		if math.abs(pla.coly) > 0.3 then pla.coly = math.round(pla.coly / 2,5); pla.iy = pla.iy + pla.coly; end
		
		-- center ship position, and range the movement:
		pla.cx = math.ceil(math.clamp(pla.cx + pla.ix,-110,110));
		pla.cy = math.ceil(math.clamp(pla.cy + pla.iy,-45,45));	

		-- BOOSTER!
		if pla.B > pla.b then pla.B = math.round(math.clamp(pla.B - pla.boostdecel,0,20),2); 			--boost decceleration
		elseif pla.b > pla.B then pla.B = math.round(math.clamp(pla.B + pla.boostaccel,0,20),2); end	--boost aceleration
		-- booster sounds
		if pla.b == 20 and pla.boosting == false then pla.boosting = true; pla.boostoff:stop(); pla.boostsnd:play(6); end
		if pla.b == 0 and pla.boosting == true then pla.boostsnd:stop(); pla.boostoff:play(6); pla.boosting = false; end
	
		-- final positions!
		pla.incx, pla.incy, pla.incz = spx, spy + math.round((math.sin(math.rad(pla.ang)*4)*0.5),3), -pla.B;
		tx, ty = (pla.cx-(pla.x+spx)), (pla.cy-(pla.y+spy));											-- distance from center of the screen
		if not pla.viring then pla.rz = -1 * math.rad( tx / 2 ); end									-- if viring override rotation
		pla.RZ = pla.RZ - (pla.RZ-pla.rz)/6;															-- smooth rotation.
		local k1 = math.abs(tx/3);																		-- constantize...
		local k2 = math.abs(ty/3);																		-- ... or cache... whatever...
		
		-- Move ship by...
		if k1>0 then pla.x = math.clamp(pla.x + (tx*0.05),-260,260);									-- ... small inc
		elseif k1>10 then pla.x = math.clamp(pla.x + (tx*0.2),-260,260);								-- ... medium inc
		elseif k1>20 then pla.x = math.clamp(pla.x + (tx*0.3),-260,-260);								-- ... full inc
		end
		
		if k2>0 then pla.y = math.clamp(pla.y + (ty*0.05),-70,70);										-- small inc
		elseif k2>10 then pla.y = math.clamp(pla.y + (ty*0.2),-70,70);									-- medium inc
		elseif k2>20 then pla.y = math.clamp(pla.y + (ty*0.3),-70,70);									-- full inc
		end
	end
};
