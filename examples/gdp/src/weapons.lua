
-- @WEAPONS GROUPING
-- As for enemies, this group will contain all the weapons shooted. (player and enemies)
wp = {
	all = {}, l=0,																						-- weapons array and length.
	typ = { },																							-- source data for weapons.
	rshot = 0;
	c = { 
		{ { }, { }, { }, { }, { }, { }, { }, { }, { }, { } },											-- double buffer weapons.
		{ { }, { }, { }, { }, { }, { }, { }, { }, { }, { } }											-- double buffer weapons.
	},
	cm = 1,
	
	sht = function(x,y,z,rz,tgt,t,rx,ry) 																	-- shoot that weapon.
		if (wp.rshot > 0) then return; end
		if (tgt == 1) and (t == 1) then
			local a = {x=x,y=-y,z=z,rz=rz,type=t,tgt=tgt}; wp.typ[t].s:play(5); 							-- .. store data and play
			table.insert(wp.all,a); wp.l = wp.l + 1; 														-- queue weapon.
			wp.rshot = 9;
			return;
		end
		if ( tgt == 2) and (t == 1) then
			local a = {x=x,y=-y,z=z,rx=rx,ry=ry,rz=0,type=t,tgt=tgt}; wp.typ[t].s:play(5);
			table.insert(wp.all,a); wp.l = wp.l + 1; 														-- queue weapon.
		end
	end,
	refresh = function() wp.rshot = math.max(wp.rshot-1,-1); end,
	update = function(i)																				-- update every weapon shot
		if not i or not wp.all[i] then return end;														-- ... if not shot return.
		local cw = wp.all[i];																			-- current shot:
		local pepth = math.clamp(math.ceil(math.abs(cw.z - stages.z) / 100),1,9);						-- weapon depth relative to scenario.
		if stages.nearcol and stages.nearcol[pepth] then 
			if math.poly.testxy(cw.x,cw.y,stages.nearcol[pepth]) then wp.all[i].z = -800; end
		end
		
		if (cw.type == 1) then																			-- type laser:
			if cw.tgt == 1 then																			-- from player to enemies.
				local depth = math.clamp(math.ceil(math.abs(cw.z) / 100),1,9);							-- real depth.
				if cw.z < -700 then table.remove(wp.all,i); wp.l = wp.l - 1; return; end				-- go out-range. disappear.
				table.insert(wp.c[wp.cm][depth],{cw.x,cw.y});											-- buffer the shot.
				wp.typ[cw.type].m:position(cw.x,cw.y,cw.z);												-- position the shot.
				wp.typ[cw.type].m:rotation(0,0,cw.rz); wp.typ[cw.type].m:blit(); 						-- and blit the shot.
				wp.all[i].z = cw.z - wp.typ[cw.type].speed;												-- move the shot.
			end
			if cw.tgt == 2 then																			-- from enemies to player
				local depth = math.clamp(math.ceil(math.abs(cw.z) / 100),1,9);
				if cw.z > 0 then table.remove(wp.all,i); wp.l = wp.l - 1; return; end					-- go out-range. disappear.
				wp.typ[cw.type].em:position(cw.x,cw.y,cw.z);												-- position the shot.
				wp.typ[cw.type].em:rotation(math.rad(cw.ry),math.rad(cw.rx),cw.rz); wp.typ[cw.type].em:blit(); 				-- and blit the shot.
				wp.all[i].z = cw.z + (wp.typ[cw.type].speed);
				wp.all[i].x = cw.x + cw.rx;
				wp.all[i].y = cw.y + cw.ry;
				local y = -cw.y-80;
				if (depth == 1) and controls.select() then draw.fillrect(240+cw.x,272+y,5,5,color.new(0,0,0)); end
				if (depth == 1) and math.poly.testxy(cw.x,y,pla.rbbox) then
					wp.all[i].z = 100;
					pla.coli();
				end
			end
		end
		
		if (cw.type == 2) then																			-- type guided missile:
			if ( cw.tgt == 1 ) then																		-- from player to enemies.
				if (cw.stgt) then																		-- target acquired?
				
				else																					-- locate target...
				
				end
			end
		end
		
	end,
	loadall = function()																				-- load all weapons:
		table.insert(wp.typ,{ 																			-- first type, laser.
			m=model.load("obj/weapons/laser.obj"), 														-- model,
			em=model.load("obj/weapons/slaser.obj"),
			s=sound.load("snd/laser.wav"), 																-- sound,
			speed = 10 });																				-- and speed.
			
	end,
	
};
