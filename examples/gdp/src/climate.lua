
-- @CLIMATE GROUP
-- The amazing and wonderful climate machine! With this machine, we could change the current
-- lightning conditions! From sunny, to fade-ins/fade-outs, night type, sunsets...
-- Beautify our game!
climate = {
	-- fog subrange:
	--    fog has near, far, and color. other vars are for smoothing animations between changes.
	--    f() = function that does a fog step.
	--	  u(color) = smooth changes fog color.
	--    set(near,far) = instantly sets fog distances.
	--	  update([near,far]) = does a step in distances, and if arguments, smooth modify distances.
	speed = 5,
	
	fog = {
		near=0, far=0, neari=5, fari=10, nearf=0, farf=0, color = color.new(0,0,0), rcolor = color.new(0,0,0),
		set = function(n,f) climate.fog.nearf = n; climate.fog.near = n; climate.fog.farf = f; climate.fog.far = f; end,
		f = function() climate.fog.color = cgt(climate.fog.color,climate.fog.rcolor); end,
		u = function(c) climate.fog.rcolor = c; end,
		update = function(n,f)
			if n and f then climate.fog.nearf = n; climate.fog.farf = f; end
			climate.fog.near = vgt(climate.fog.near,climate.fog.nearf,climate.fog.neari);
			climate.fog.far = vgt(climate.fog.far,climate.fog.farf,climate.fog.fari);
		end
	},
	
	-- bg subrange (background gradient goes from BG to FOG color)
	-- smooth change the color. (same as fog color)
	bg = {
		color = color.new(0,0,0),
		rcolor = color.new(0,0,0),
		f = function() climate.bg.color = cgt(climate.bg.color,climate.bg.rcolor); end,
		u = function(a) climate.bg.rcolor = a; end
	},
	-- am subrange (global ambient light) (same as bg)
	am = {
		color = color.new(0,0,0),
		rcolor = color.new(0,0,0),
		f = function() climate.am.color = cgt(climate.am.color,climate.am.rcolor); end,
		u = function(a) climate.am.rcolor = a; end		
	},
	-- sn subrange (global directional light (sun)) (same as others...)
	sn = {
		color = color.new(0,0,0),
		rcolor = color.new(0,0,0),
		f = function() climate.sn.color = cgt(climate.sn.color,climate.sn.rcolor); end,
		u = function(a) climate.sn.rcolor = a; end		
	},
	-- sp subrange (ship spotlight, for obscure caves and dark scenarios)
	-- lf, (linear light exponent), cutoff angle and global exponent of ray-light.
	-- color dont modified, cause is yellow light.
	sp = { 
		lf = 0.5, rlf = 0.5, ilf = 0.04,
		cutoff = math.rad(30), exponent = 0.8,
		f = function() climate.sp.lf = vgt(climate.sp.lf,climate.sp.rlf,climate.sp.ilf); end,
		u = function(a) climate.sp.rlf = a; end		
	},
	
	-- global climate update function:
	update = function()
		
		climate.am.f();														-- do a step in ambient light.
		climate.fog.f();													-- do a step in fog color
		climate.bg.f();														-- do a step in background color.
		climate.sn.f();														-- do a step in sun color.
		climate.sp.f();														-- do a step in spotlight
		climate.fog.update();												-- update fog distances.

		world.ambient(climate.am.color);									-- set ambient light.
		-- enable sun, if any light comes from it:
		world.lightenabled(2, (color.R(climate.sn.color) > 0 or color.G(climate.sn.color) > 0 or color.B(climate.sn.color) > 0) );
		world.lightambient(2,climate.sn.color);								-- set sun color.
		
		if (color.R(climate.am.color) < 255) then 										-- ¿spotlight on?
			world.lightenabled(4,true);										-- enable light.
			world.lightambient(4,color.new(255,255,120));					-- ambient color yellow
			world.lightdiffuse(4,color.new(255,255,120));					-- diffuse color yellow
			world.lighttype(4,3); 											-- type: spotlight.
			world.lightattenuation(4,0,climate.sp.lf,0); 					-- light attenuations.
			world.lightspotlight(4,climate.sp.exponent,climate.sp.cutoff);	-- spotlight exponent and cutoff.
			world.lightdirection(4,0,0,1); 									-- direction of spotlight.
			world.lightposition(4,pla.x,-pla.y,pla.z+pla.incz+pla.oz-5); 	-- position of spotlight.
		else world.lightenabled(4,false); end								-- spotlight off!
		
		world.fog(climate.fog.near,climate.fog.far,climate.fog.color);		-- set fog.
		world.update();														-- update light / fog changes!
		draw.fillrect(0,0,480,272,climate.fog.color);						-- fill background with fog color. and gradient from bg to fog.
		draw.gradrect(0,0,480,136,climate.bg.color,climate.bg.color,climate.fog.color,climate.fog.color);
	end,
	
	change = function(fx)													-- Change climate effect! (predefined ones)
		if (fx == "100vis") then 											-- all view, (option window)
			climate.fog.set(1000,1010); climate.fog.update(1000,1010);
			climate.fog.u(color.new(255,255,255));
			climate.am.u(color.new(255,255,255));
			climate.sn.u(color.new(0,0,0));
			climate.bg.u(color.new(255,255,255));
			climate.sp.u(0.1);
			return; 
		end
		
		if (fx == "sunset") then 											-- sunset effect (reddish sky, reddish sun!)
			climate.fog.update(500,1000);
			climate.fog.u(color.new(255,255,200));
			climate.am.u(color.new(255,255,255));
			climate.sn.u(color.new(90,0,0));
			climate.bg.u(color.new(255,200,200));
			climate.sp.u(0.1);
			return; 
		end
		
		if (fx == "night") then 											-- dark blue ambient, no sun, spotlights on!
			climate.fog.update(500,1000);
			climate.fog.u(color.new(10,10,40));
			climate.am.u(color.new(10,10,20));
			climate.sn.u(color.new(0,0,0));
			climate.bg.u(color.new(40,40,80));
			climate.sp.u(0.006);
			return; 
		end
		
		if (fx == "nightvision") then 										-- ¿?
			climate.fog.update(500,1000);
			climate.fog.u(color.new(0,0,0));
			climate.am.u(color.new(0,255,0));
			climate.sn.u(color.new(0,0,0));
			climate.bg.u(color.new(0,0,0));
			climate.sp.u(0.1);
			return; 
		end
		
		
		if (fx == "daily") then 											-- Blue sky, in the morning!
			climate.fog.update(500,1000);
			climate.fog.u(color.new(255,255,255));
			climate.am.u(color.new(255,255,255));
			climate.sn.u(color.new(0,0,0));
			climate.bg.u(color.new(100,100,160));
			climate.sp.u(0.001);
			return; 
		end
		
		if (fx == "fadein") then 											-- fade-in effect.
			climate.fog.set(1,2);-- cerca
			climate.fog.color = color.new(0,0,0); climate.change("daily");
			return; 
		end
		if (fx == "fadeout") then 											-- fade-out effect.
			climate.fog.update(1,2);
			climate.fog.u(color.new(0,0,0));
			climate.am.u(color.new(255,255,255));
			climate.sn.u(color.new(0,0,0));
			climate.bg.u(color.new(0,0,0));
			climate.sp.u(0.1);
			return; 
		end
		if (fx == "") then return; end										-- to add more...
	end,
}
