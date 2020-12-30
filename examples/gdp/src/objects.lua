
-- @SCENARIO OBJECTS / DECORATIONS
-- Group for scenario objects / doors, rocks, decoration things, trees... houses...
-- Exactly same behavior as enemies and weapons. Enqueue all... update one by one...
-- Cache colisions...
--
-- With a little code, we can have destroyable objects... but not done at this point. (possible update?)

--
-- Every object is filled in ob.typ[ numberofobject ], with properties and methods:
--		m (property) = basic model of the object.
--		b = function (blit) = do the animation movement process here, use as many vars as every object need.
--		i = function (init) = initiate a copy of the object.
--		p (property) [optional] = a penalty spawning effect. How many other objects will need to spawn before this model can re-spawn.

ob = {
	all = {}, typ = {}, alw={}, al=0, w=10, l=0,m=0,
	fna = function() if ob.al > 0 then return math.floor(math.random(ob.al)); end end,
	allow = function(n) local r = false; for i=1, ob.al do if ob.alw[i] == r then r = true; end end if not r then table.insert(ob.alw,n); ob.al = ob.al + 1; end end,
	deny = function(n) local r = false; for i,v in ipairs(ob.alw) do if n == v then table.remove(ob.alw,i); ob.al = ob.al - 1; end end end,
	create = function() 
		local e,r = { x = math.random() * 250 - 130, y = -70, z = 0, d = false }, ob.fna(); 
		if r and ob.alw[r] then 
			if ob.typ[ob.alw[r]].penalty then
				if ob.typ[ob.alw[r]].penalty > 0 then ob.typ[ob.alw[r]].penalty = ob.typ[ob.alw[r]].penalty - 1; end					-- ... dec penalty time
				if ob.typ[ob.alw[r]].penalty < 2 then ob.typ[ob.alw[r]].penalty = nil; end
				if ob.typ[ob.alw[r]].penalty then return nil; end										-- ... object with penalty, skip.
			end
			return ob.typ[ob.alw[r]].i(e);
		end 
	end,
	blit = function(x,y,z,rx,ry,rz,t) ob.typ[t].m:position(x,y,z); ob.typ[t].m:rotation(rx,ry,rz); ob.typ[t].m:blit(); end,
	update = function(i)
		if not i then return end															-- if not object not update..
		if ob.all[i] then																	-- if object exists in queue
			local e = ob.all[i];
			if (e.d) then table.remove(ob.all,i); ob.l = ob.l - 1; return ob.update(i); end	-- destroyed? removed
			if not e.d then 																-- not destroyed?
				local depth = math.clamp(math.ceil(math.abs(ob.all[i].z-1000) / 100),1,9);	-- what depth range?
				ob.all[i] = ob.typ[e.type].b(e);											-- blit!
				if ob.all[i].col and depth == 1 then 										-- if has collision...
					table.insert(stages.fuck,ob.all[i].col);								-- cache collision.
				end
			end							
		end
		if ob.l < ob.m then																	-- if object limit unreached...
			if ob.w > 0 then ob.w = ob.w -1; return end										-- object spawning time...
			local abcd = ob.create(); 														-- spawn one...
			if abcd then 																	-- ... spawned oK!
				table.insert(ob.all,abcd);													-- queue deco / object.
				ob.l = ob.l + 1; 															-- queue increased.
				ob.w = math.random(5,45); 													-- re-spawning time for next object.
				if abcd.w then ob.w = abcd.w; end											-- object respawn modifier.
			end
		end
	end,
		
	loadall = function() 
	
		ob.typ[1] = {																						-- OBJECT 1 : DECO Tree group.
			m=model.load("obj/stagedata/obstacles/deco00.obj");												-- model file
			b=function(e)																					-- blit:
				e.z = e.z + ((stages.speed + pla.B ));														-- - move.
				if (e.z > 1000) then e.d = true; end														-- - out of screen. destroy.
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;																					-- - apply changes.
			end,
			i=function(e) e.type = 1; return e; end,														-- init: random pos.
		};
		
		ob.typ[2] = {																						-- OBJECT 2 : DECO House.
			m=model.load("obj/stagedata/obstacles/deco01.obj",2.5,color.new(0,0,0));						-- model file
			b=function(e)																					-- blit:
				e.z = e.z + (stages.speed + pla.B);															-- - move.
				if (e.z > 1000) then e.d = true; end														-- - out, destroy.
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;																					-- - apply changes.
			end,
			i=function(e) e.y = e.y + 10; e.type = 2; return e; end,										-- init: elevate 10points.
		};
		
		ob.typ[3] = {																						-- OBJECT 2: rock brige
			m=model.load("obj/stagedata/obstacles/obs00.obj",2.5,color.new(0,0,0));							-- model file
			b=function(e)																					-- blit:
				e.z = e.z + (stages.speed + pla.B);															-- - move along scenario
				if (e.z > 1000) then e.d = true; end														-- - out of scenario.
				ob.blit(e.x,e.y,e.z-1000,0,e.rz,0,e.type);
				return e;																					-- - apply changes.
			end,
			i=function(e)																					-- init:
				e.y = -80; e.x = 0; e.type = 3; e.penalty = 4;												-- fixed pos + penalty
				e.rz = iif(math.random(1,100) > 50,0,math.pi);
				e.col = { {-300,-300}, {300,-300}, {300,-110}, {-300,-110} };								-- collision shape.
				ob.typ[e.type].penalty = ob.typ[e.type].p;
				return e;																					-- apply changes.
			end,																							-- end init.
			p=5,
		};
		
		ob.typ[4] = {
			m=model.load("obj/stagedata/obstacles/obs01.obj",2.5,color.new(0,0,0));							-- OBJECT 4: Double rock bridge
			b=function(e)
				e.z = e.z + (stages.speed + pla.B);
				if (e.z > 1000) then e.d = true; end
				ob.blit(e.x,e.y,e.z-1000,0,e.rz,0,e.type);
				return e;
			end,
			i=function(e)
				e.y = -80; e.x = 0; 
				e.type = 4; 
				if (math.random(1,100) > 50) then 
					e.rz = 0;
					e.col = { {-300,-300}, {300,-300}, {300,300}, { 72, 0 }, { 65, -60 }, { -12,-110}, {-75,-106}, {-148,-98} };
				else 
					e.rz = math.pi;
					e.col = { {300,-300}, {-300,-300}, {-300,300}, { -72, 0 }, { -65, -60 }, { 12,-110}, {75,-106}, {148,-98} };
				end
				ob.typ[e.type].penalty = ob.typ[e.type].p;
				return e; 
			end,
			p=15,
		};
		
		ob.typ[5] = {
			m=model.load("obj/stagedata/obstacles/obs02.obj",2.5,color.new(0,0,0));							-- Object 5: Da Big Rock
			b=function(e)
				e.z = e.z + (stages.speed + pla.B);
				if (e.z > 1000) then e.d = true; end
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;
			end,
			i=function(e) 
				local j = math.random(1,5)*10;
				e.y = -90-j;
				e.x = 0; e.type = 5; 
				local k = math.random(1,100);
				if (k<33) then e.x = 145 elseif (k>80) then e.x = -20; e.y = -120; else e.x = -145; end
				e.col = t2(e.x,e.y+100+j,{{-109,0 }, { -77,-42}, {-62,-74},{-46,-105},{-31,-128}, {0, -105},{16, -75},{31,-66},{62, -76},{78, -80},{94, -60},{110, -25},{123,0}, {-109,0 } });
				ob.typ[e.type].penalty = ob.typ[e.type].p; 
				return e; end,
			p=14,
		};
		
		ob.typ[6] = {																						-- OBJECT 6 : DECO Sheeps.
			m=model.load("obj/stagedata/obstacles/deco02.obj",2.5,color.new(0,0,0));						-- model file
			b=function(e)																					-- blit:
				e.z = e.z + (stages.speed + pla.B);															-- - move.
				if (e.z > 1000) then e.d = true; end														-- - out, destroy.
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;																					-- - apply changes.
			end,
			i=function(e) e.y = e.y + 1; e.type = 6; return e; end,											-- init: elevate 1point.
		};
		
		ob.typ[7] = {
			m=model.load("obj/stagedata/obstacles/obs03.obj",2.5,color.new(0,0,0));							-- Object 7: Dragon Ball Style Building
			b=function(e)
				e.z = e.z + (stages.speed + pla.B);
				if (e.z > 1000) then e.d = true; end
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;
			end,
			i=function(e) 
				e.y = -80; e.type = 7; ob.typ[e.type].penalty = ob.typ[e.type].p;
				if (math.random(1,100)>50) then e.x = 125 else e.x = -125; end
				e.col = w3(e.x,(e.y)-67+80,20,67);
				return e; end,
			p=10,
		};
		
		ob.typ[8] = {
			m=model.load("obj/stagedata/obstacles/obs04.obj",2.5,color.new(0,0,0));							-- Object 8: Dragon Ball Style Building small
			b=function(e)
				e.z = e.z + (stages.speed + pla.B);
				if (e.z > 1000) then e.d = true; end
				ob.blit(e.x,e.y,e.z-1000,0,e.rz,0,e.type);
				return e;
			end,
			i=function(e) e.y = -80; e.type = 8;
				local k = math.random(1,100);
				local j = math.random(1,100);
				if (j<33) then e.rz = pim; elseif (j>66) then e.rz = pi2; else e.rz = 0; end
				if (k<33) then e.x = 145 elseif (k>66) then e.x = -12 else e.x = -145; end
				e.col = w3(e.x,(e.y)+80,20,67);
				ob.typ[e.type].penalty = ob.typ[e.type].p; return e; end,
			p=8,
		};
		
		ob.typ[9] = {
			m=model.load("obj/stagedata/obstacles/obs05.obj",2.5,color.new(0,0,0));							-- Object 9: Dragon Ball Style Building
			b=function(e)
				e.z = e.z + (stages.speed + pla.B);
				if (e.z > 1000) then e.d = true; end
				ob.blit(e.x,e.y,e.z-1000,0,0,0,e.type);
				return e;
			end,
			i=function(e) 
				e.y = -80; 
				e.type = 9; 
				if (math.random(1,100)>50) then 
					e.x = 125 
				else 
					e.x = -125;
				end 
				e.col = w3(e.x,(e.y)-67+80,20,67);
				ob.typ[e.type].penalty = ob.typ[e.type].p; 
				return e;
			end,
			p=10,
		};
		

		
	end
};
