
-- @ENEMIES GROUPING.
-- This "group" enqueues and spawn's enemies. For spawning one enemy, first we must to "allow" it to spawn,
-- and after is "allowed", we need to set the maximum of enemies at once in the screen.
-- The spawning, and movement, and all related enemy things are coded per type.
-- When destroyed, the burst animation is enqueued, and blitted from far to front, sorted by z distance.
en = { 
	spritequeue = { },																					-- Burst animation
	all = {}, l=0, m=0,																					-- Enemy data, lenght and maximum.
	typ = {}, 																							-- Enemy source data.
	alw={}, al=0,  																						-- Currently allowed
	w=10,																								-- Spawn time gap.
	
	fna = function() if en.al > 0 then return math.floor(math.random(en.al)); end end,					-- find next allowed.
	
	allow = function(n) local r = false; 																-- Allow new type...
		for i=1, en.al do if en.alw[i] == r then r = true; end end										-- ...search in allowed...
		if not r then table.insert(en.alw,n); en.al = en.al + 1; end									-- ... is new, allow!
	end,
	
	deny = function(n) local r = false; 																-- Deny a type...
		for i,v in ipairs(en.alw) do 																	-- ... search in allowed...
			if n == v then table.remove(en.alw,i); en.al = en.al - 1; end 								-- ... found! remove.
		end	
	end,										
	
	create = function()																					-- Create enemy.
		local e,r = {																					-- enemy data.
			x = math.random() * 230 - 115, y = math.random() * 70 - 45, z = 0, 							-- randomize spawn spot.
			u = false, d = false, f = 1 }, en.fna();													-- randomize it's type.
		if r and en.alw[r] then return en.typ[en.alw[r]].i(e); end end,									-- if allowed init.
	
	spriteburst = function()																			-- Blit burst animations
		table.sort(en.spritequeue,function(a,b) return a[4] < b[4]; end);								-- sort by z pos.
		while (en.spritequeue[1]) do																	-- for every one
			local k = en.spritequeue[1];																-- short name access.
			pla.exp[k[1]]:zblit(k[2],k[3],k[4],0,0,0);													-- blit frame.
			pla.exp[k[1]]:zblit(k[2],k[3],k[4],0,0,pim);												-- blit 90º rotated in z.
			table.remove(en.spritequeue,1);																-- remove this entry.
		end
	end,
	
	update = function(i)																				-- update enemy ...
		if not i then return end																		-- ... if avaiable.
		if en.all[i] then																				-- if exists...
			local e = en.all[i];																		-- short name..
			if (e.d and e.f <= 20) then																	-- destroyed! burst!
				if e.f and pla.exp[e.f] then table.insert(en.spritequeue,{e.f,e.x,e.y,e.z-1000}); end	-- enqueue!
				en.all[i].z = e.z + ((stages.speed + pla.B ) / 2);										-- and move.
				en.all[i].f = e.f + 1;																	-- inc frame.
			end
			if (e.d and e.f > 20) then table.remove(en.all,i); en.l = en.l -1; return en.update(i); end	-- after destroy.
			if not e.d then en.all[i] = en.typ[e.type].b(e); return; end								-- enemy alive, blit.
		end
		if skip then return end;
		if en.l < en.m then																				-- if enemy limit unreached
			if en.w > 0 then en.w = en.w -1; return end													-- ... wating time ...
			local abcd = en.create(); 																	-- ... new one ...
			if abcd then table.insert(en.all,abcd); en.l = en.l + 1; en.w = math.random(15,35) end		-- enqueue enemy.
		end
	end,
	
	weapontest = function(p)
		local e = p;
		if not e.d and not skip then															-- if not destroyed:
			local depth = math.clamp(math.ceil(math.abs(e.z-1000) / 100),1,9);					-- find depth
			if ( math.poly.testlist( w3(e.x,e.y,e.w,e.h) , wp.c[1-wp.cm][depth]) ) then			-- test with guns in his layer.
				pla.exps:play(6); 																-- explode!
				if enemycallback then enemycallback(e.type); end e.d = true; e.f = 0; return e; -- call the callback.
			end
		end
		return e;
	end,
	
	playertest = function(p)
		local e = p;
		if not e.d and not skip then															-- if not destroyed:
			local depth = math.clamp(math.ceil(math.abs(e.z-1000) / 100),1,9);					-- find depth
			if ( depth == 1 ) then draw.poly(240,272,w3(e.x,e.y-80,e.w,e.h),color.new(0,0,0)) end
			if ( depth == 1 ) and ( math.poly.testlist( pla.rbbox , w3(e.x,(-e.y-80),e.w,e.h) ) ) then	-- test collision with player
				pla.exps:play(6); e.d = true; e.f = 0; pla.coli(); return e;								-- explode!
			end
		end
		return e;
	end,
	
	blit = function(p)
		local e = p;
		if (e.z > 1000) then e.d = true; e.f = 21; return e;
		else
			local m = en.typ[e.type].m;
			m:position(e.x,e.y,e.z-1000);
			m:rotation(iif(e.rx,e.rx,0),iif(e.ry,e.ry,0),iif(e.rz,e.rz,0));
			m:scale(iif(e.sx,e.sx,1),iif(e.sy,e.sy,1),iif(e.sz,e.sz,1));
			m:blit();
		end
		return e;
	end,
	
	loadall = function() 																				-- load all enemies!
		
		en.typ[1] = {																					-- Type 1: Tutorial target.
			m=model.load("obj/enemies/tutotarget.obj",0.4,color.new(0,0,0)),							-- [-] model data.
			b=function(e)																				-- Enemy movement:
				e.time = e.time + 1;																	----------------------
				if ( e.time < 50 ) then e.z = math.min(e.z + (stages.speed + pla.B ),700); 				-- Come... and wait.
				e.x = e.x; e.y = e.y; end																-- .................
				if ( e.time == 50 ) then e.Rx = math.random() * 250 - 130; 								-- select random pos.
				e.Ry = math.random() * 70 - 45 end														-- .................
				if ( e.time > 90 and e.time < 120 ) then e.x = vgt(e.x,e.Rx,2); 						-- move to that pos
				e.y = vgt(e.y,e.Ry,2); end																-- .................
				if ( e.time > 160 ) then e.z = e.z + stages.speed + pla.B; end							-- Leave world...
				e.ang = e.ang + (math.pi / 180 * 5);													-- ... rotate all time.
				e.rz = e.ang;
				e.sx, e.sy, e.sz = 0.3,0.3,0.3;
				e = en.weapontest(e);
				e = en.blit(e);																			
				return e;
			end,
			i=function(e) e.w = 25; e.h = 25; e.Rx = e.x; e.Ry = e.y; e.time = 0; e.ang = 0; e.type = 1; return e; end,			-- init enemy type.
		};																								-- END enemy type 1.
		en.typ[2] = {																					-- Type 2: Air mines
			m=model.load("obj/enemies/omnishoot.obj",0.4,color.new(0,0,0)),	
			b=function(e)
				e.z = e.z + stages.speed + pla.B;
				e = en.weapontest(e);
				e = en.playertest(e);
				e = en.blit(e);
				return e;
			end,
			i=function(e) 
				e.w = 6; e.h = 6;
				e.type = 2;
				return e;
			end,
		};
		en.typ[3] = {																					-- Type 3: Minigunner
			m=model.load("obj/enemies/minigunner.obj",0.4,color.new(0,0,0)),							-- aims to the player
			b=function(e)																				-- shoots at random freq.
				en.typ[3].m:scale(2,2,2);
				e.z = math.min(e.z + stages.speed + pla.B,700);
				e.x = math.cos(e.ang)*100;
				local psx = ((e.x-pla.x)/-30);
				local psy = ((e.y-(pla.y+5))/30);
				e.ry = math.rad(psx*10);
				e.rx = math.rad(psy*10);
				if (e.z == 700) then
					e.time = e.time + 1;
					if e.time > e.freq or not e.s then e.time = 0;
						wp.sht(e.x,-e.y,-e.z,0,2,1,psx,psy);
						e.s = true;
					end
				end
				e = en.weapontest(e);
				e = en.blit(e);
				return e;
			end,
			i=function(e) e.w = 20; en.sx = 1.2; en.sy = 1.2; en.sz = 1.2; e.freq = math.random(30,140); e.s = false; e.h = 20; e.ang = math.rad(math.random(1,360)); e.time = 0; e.type = 3; return e; end,
		};
		en.typ[4] = {																					-- Type 3: Minigunner
			m=model.load("obj/enemies/minigunner2.obj",0.4,color.new(0,0,0)),
			b=function(e)
				e.z = e.z + stages.speed + pla.B;
				e.x = math.cos(e.ang)*200;
				e.ang = e.ang + math.rad(4);
				if ( e.ang > pi2 ) then e.ang = e.ang - pi2; e.time = e.time +1; end
				if not e.d and not skip then															-- if not destroyed:
					local depth = math.clamp(math.ceil(math.abs(e.z-1000) / 100),1,9);					-- find depth
					if ( math.poly.testlist( w3(e.x,e.y,20,20) , wp.c[1-wp.cm][depth]) ) then			-- test with guns in his layer.
						pla.exps:play(6); 																-- explode!
						if enemycallback then enemycallback(e.type); end e.d = true; e.f = 0; return e; -- call the callback.
					end
				end	
				if (e.z > 1000) then e.d = true; e.f = 21;
				else local m = en.typ[e.type].m; m:position(e.x,e.y,e.z-1000);
				m:rotation(0,e.ang,0); m:blit(); end
				return e;
			end,
			i=function(e) e.w = 45; e.h = 45; e.x = 0; e.time = 0; e.s = 0; e.ang = iif(math.random(1,100)>50,math.pi,0); e.type = 4; return e; end,
		};
		en.typ[5] = {																					-- Type 6: Mega boss
			m=model.load("obj/enemies/boss00_a.obj",0.4,color.new(0,0,0)),
			m2=model.load("obj/enemies/boss00_b.obj",0.4,color.new(0,0,0)),
			b=function(e)
				e.z = e.z + stages.speed + pla.B;
				e.x = math.cos(e.ang)*200;
				e.ang = e.ang + math.rad(4);
				if ( e.ang > pi2 ) then e.ang = e.ang - pi2; e.time = e.time +1; end
				if not e.d and not skip then															-- if not destroyed:
					local depth = math.clamp(math.ceil(math.abs(e.z-1000) / 100),1,9);					-- find depth
					if ( math.poly.testlist( w3(e.x,e.y,20,20) , wp.c[1-wp.cm][depth]) ) then			-- test with guns in his layer.
						pla.exps:play(6); 																-- explode!
						if enemycallback then enemycallback(e.type); end e.d = true; e.f = 0; return e; -- call the callback.
					end
				end	
				if (e.z > 1000) then e.d = true; e.f = 21;
				else local m = en.typ[e.type].m; m:position(e.x,e.y,e.z-1000);
				m:rotation(0,e.ang,0); m:blit(); end
				return e;
			end,
			i=function(e) e.w = 45; e.h = 45; e.x = 0; e.time = 0; e.s = 0; e.ang = iif(math.random(1,100)>50,math.pi,0); e.type = 5; return e; end,
		};
		en.typ[6] = {																					-- Type 6: Turret
			m=model.load("obj/enemies/turret.obj",0.4,color.new(0,0,0)),
			b=function(e)
				e.z = e.z + stages.speed + pla.B;
				e.y = 70;
				if not e.d and not skip then															-- if not destroyed:
					local depth = math.clamp(math.ceil(math.abs(e.z-1000) / 100),1,9);					-- find depth
					if ( math.poly.testlist( w3(e.x,e.y,20,30) , wp.c[1-wp.cm][depth]) ) then			-- test with guns in his layer.
						pla.exps:play(6); 																-- explode!
						if enemycallback then enemycallback(e.type); end e.d = true; e.f = 0; return e; -- call the callback.
					end
				end	
				if (e.z > 1000) then e.d = true; e.f = 21;
				else local m = en.typ[e.type].m; m:position(e.x,e.y,e.z-1000);
				m:rotation(0,0,0); m:blit(); end
				return e;
			end,
			i=function(e) e.w = 45; e.h = 45; e.x = 0; e.time = 0; e.s = 0; e.type = 6; return e; end,
		};
	end
};
