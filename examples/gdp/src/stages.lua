
-- @stages
stages = {
	curstage = 0,
	curpattern = 1,
	cursubpattern = 1,
	z = 0,
	speed = 10,
	rspeed = 10,
	
	nearmodel = nil,
	farmodel = nil,
	loadmodel = nil,
	
	actiondone = false,
	actiontest = nil, 
	
	tempdata = { },

	rz = math.pi / 16, rrz = math.pi / 16, -- override rotation.
	
	subpatterncallback = nil,
	endstagecallback = nil,
	
	chkmod = function(a) if (type(a) != "userdata") then return stages.loadmodel; end return a or stages.loadmodel; end,
	
	stepper = function(abc)
		stages.speed = vgt(stages.speed,stages.rspeed,1);
		stages.z = stages.z + stages.speed + pla.B;
		local inc = (stages.z > 1000);
		if ( inc ) then stages.z = stages.z - 1000; end
		
		local cs = stages[stages.curstage];
		local np = cs.patterns[stages.curpattern];
		local fp = cs.patterns[stages.curpattern + 1];
		local tnp, tfp;
		
		tnp = type(np); tfp = type(fp);
		if tnp == "nil" then if stages.endstagecallback then stages.endstagecallback() end end -- near pattern = nil.
		if tnp == "number" and inc then stages.curpattern = stages.curpattern + 1; end
		if tnp == "table" then if stages.cursubpattern + 1 <= #np then if inc then stages.cursubpattern = stages.cursubpattern + 1; end else if stages.subpatterncallback and stages.subpatterncallback() then if tfp == "number" then if inc then stages.curpattern = stages.curpattern + 1; stages.cursubpattern = 1; end end else if inc then stages.cursubpattern = 1; end end end end
		
		-- @inched. xD
		np = cs.patterns[stages.curpattern];
		fp = cs.patterns[stages.curpattern + 1];
		tnp = type(np); tfp = type(fp);
		
		stages.nearmodel = stages.chkmod(0);
		stages.farmodel = stages.chkmod(0);
		
		-- @actionner
		if not stages.actiondone then
			if stages.actiontest and stages.actiontest() then 
				table.remove(stages[stages.curstage].timeline,1);
				stages.actiontest = nil;
				stages.actiondone = true;
			end
		end
		
		if stages.actiondone and not stages.actiontest then
			if stages[stages.curstage].timeline[1] and stages[stages.curstage].timeline[1].frame then 
				stages[stages.curstage].timeline[1].frame();
				stages.actiontest = stages[stages.curstage].timeline[1].test;
				stages.actiondone = false;
			end
		end
		
		stages.nearcol = { };	 -- near collisions.
		
		if tnp == "number" and tfp == "number" then 
			stages.nearmodel = stages.chkmod(cs.models[np]);
			stages.farmodel = stages.chkmod(cs.models[fp]); 
			return;
		end

		if tnp == "number" and tfp == "nil" then
			stages.nearmodel = stages.chkmod(cs.models[np]);
			if stages.endstagecallback and stages.endstagecallback() then 
				stages.ns = cs.patterns.tostage;
				stages.farmodel = stages.loadmodel;
			else
				stages.farmodel = stages.chkmod(cs.models[ cs.patterns[1] ] );
			end
			return;
		end
		
		if tnp == "number" and tfp == "table" then 
			stages.nearmodel = stages.chkmod(cs.models[np]);
			stages.farmodel = stages.chkmod(cs.models[ fp[1] ]);
			return;
		end
		if tnp == "table" then
			stages.nearmodel = stages.chkmod( cs.models[ np[stages.cursubpattern] ] );
			if stages.cursubpattern + 1 <= #np then stages.farmodel = stages.chkmod(cs.models[np[stages.cursubpattern + 1] ]); return; 
			else 
				if stages.subpatterncallback and stages.subpatterncallback() then
					if tfp == "number" then stages.farmodel = stages.chkmod(cs.models[fp]); return; end
				else stages.farmodel = stages.chkmod(cs.models[np[1] ]); end
			end
			return;
		end
	end,
	
	preload = function(id)
		stages.unload();
		for i = 1, #stages[id].mpaths do table.insert( stages[id].models , model.load(stages[id].mpaths[i],2.5,color.new(0,0,0))); end
		stages.curstage = id;
		stages.tempdata = { };
	end,
	
	unload = function() 
		if stages.curstage == 0 then return end
		for i = #stages[stages.curstage].models, 1, -1  do stages[stages.curstage].models[i]:free(); table.remove(stages[stages.curstage].models,i); end
		stages.tempdata = { };
	end,
	
	blit = function()
		world.lookat({pla.x*(pla.P/20),-pla.y*(pla.P/20),(pla.z-pla.B)*(pla.P/20)},{pla.x*(pla.P/20),-pla.y*(pla.P/20),-1000},{math.clamp(math.sin(-pla.RZ*pla.tiltinc),-pla.tilt,pla.tilt),math.clamp(math.cos(pla.RZ*pla.tiltinc),-pla.tilt,pla.tilt),0});		
		stages.fuck = { };
		stages.stepper();
		stages.rz = vgt(stages.rz,stages.rrz,math.rad(2));
		stages.nearmodel:rotation(0,0,stages.rz); stages.nearmodel:position(0,-80,stages.z); stages.nearmodel:blit();
		stages.farmodel:rotation(0,0,stages.rz); stages.farmodel:position(0,-80,stages.z-1000); stages.farmodel:blit();
	end,
	
	init = function() stages.loadmodel = model.load("obj/stagedata/00/base00.obj",2.5,color.new(0,0,0)); end
};

dofile('src/stage01.lua');
