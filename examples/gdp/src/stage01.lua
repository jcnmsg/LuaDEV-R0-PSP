
-- @action wrappers / helpers.
function talkwrap(m,t,z) 
	local x = { 
		frame=function() 
			talk.mood = m;
			if (type(t) == "function") then talk.speech(iif(z,z,1),t()); 
			else talk.speech(iif(z,z,1),t); end
			end, 
		test=function() return not talk.showing; end 
	}; return x; 
end
function waitwrap(t) local x = { frame=function() stages.tempdata.endtime = os.clock() + t; end, test=function() return (os.clock() > stages.tempdata.endtime); end }; return x; end
function otherwrap(m,t) local x; if not t then x = { frame=m, test=function() return true end }; else x = { frame=m, test=t }; end return x; end
function gotopattern(n) local x = { frame = function() stages.subpatterncallback = function() return true end end, test = function() return (stages.curpattern > n); end }; return x; end
function waitpattern(n) local x = { frame=function() end, test = function() return (stages.curpattern == n); end }; return x; end
function clearpattern() local x = { frame=function() stages.subpatterncallback = function() return false; end end, test = function() return true end }; return x; end



-- @stagedata
stagedata = { };
stagedata[1] = {
		id="loading",
		models = { },
		mpaths = { 
			"obj/stagedata/00/base01.obj", 	-- mountain to valley.
			"obj/stagedata/00/base02.obj", 	-- valley
			"obj/stagedata/00/base03.obj", 	-- valley to beach
			"obj/stagedata/00/base04.obj", 	-- beach to sea
			"obj/stagedata/00/base05.obj",	-- sea
			"obj/stagedata/00/base06.obj",	-- sea to beach
			"obj/stagedata/00/base07.obj",	-- beach to valley
			"obj/stagedata/00/base08.obj",	-- valley to mountain
			"obj/stagedata/00/base09.obj",	-- valley to cave
			"obj/stagedata/00/base10.obj",	-- cave
			"obj/stagedata/00/base11.obj",	-- cave to valley
			},
		patterns = { -- this builds the magical world... :D (pattern numbers are the ones in the list above, plus 0, that is stages.loadmodel,
			0,
			{0, 0, 0 },
			0,
			{ 0, 0, 0 },	
			0,
			{ 0, 0, 0 }, -- 6
			0, -- 7
			1, 2, 2, 2, 2, 8, 0, -- 14
			1, 9, 10, 11, 2, 2, 2, 9, 10, -- 23
			{ 10, 10, 10, }, -- 24
			10, 10, -- 26
			{ 10, 10, 10, }, -- 27
			10, 10, 10, 11,  --31
			3, 4, 6, 7, 8, 0, 0,--38
			{ 0, 0, 0 }, --39
			0,0,0,--42
			{ 0, 1, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 7, 9, 10, 11, 8 }, --43
			0, 
			
			0,0
		},
		timeline = { -- action timeline, can program the action in a stage. Allow enemies, allow obstacles... wait for pattern...
			otherwrap(function() music.switch(4); climate.speed=1; en.m = 0; ob.allow(1); ob.allow(6); ob.allow(2); ob.allow(3); ob.m = 6; im.fadeto("tuto",255); end),
			waitwrap(2),
			talkwrap(0,text.tuto1),
			talkwrap(2,text.tuto2),
			talkwrap(1,function() return text.tuto3:format(os.date("%H:%M"),os.nick()) end),
			talkwrap(2,text.tuto4),
			talkwrap(1,text.tuto5),
			waitwrap(4),
			otherwrap(function() hud.a = 255; end),
			gotopattern(2), clearpattern(),
			waitwrap(0.1),
			talkwrap(1,text.tuto6),
			talkwrap(2,text.tuto7),
			otherwrap(function() stages.tempdata.aciertos = 0; en.allow(1); en.m = 2;  enemycallback = function(a) stages.tempdata.aciertos = stages.tempdata.aciertos + 1; end; en.m = 2; end),
			waitwrap(60),
			otherwrap(function() enemycallback = nil; en.m = 0; end),
			talkwrap(1,function() return text.tuto8:format(stages.tempdata.aciertos,iif(stages.tempdata.aciertos > 60,text.tuto9_1,iif(stages.tempdata.aciertos > 40,text.tuto9_2,iif(stages.tempdata.aciertos>20,text.tuto9_3,text.tuto9_4)))) end),
			talkwrap(0,text.tuto10,2);
			talkwrap(3,text.tuto11,2);
			otherwrap(function() ob.deny(2); ob.deny(6); end);
			talkwrap(2,text.tuto12);
			talkwrap(2,text.tuto13,2);
			talkwrap(3,text.tuto14,2);
			talkwrap(0,text.tuto15,2);
			talkwrap(0,text.tuto16,2);
			talkwrap(2,text.tuto17);
			talkwrap(1,text.tuto18);
			talkwrap(0,text.tuto19);
			talkwrap(2,text.tuto20);
			talkwrap(2,text.tuto21);
			otherwrap(function() stages.rspeed = 15; end);
			gotopattern(7); clearpattern(), otherwrap(function() ob.allow(5); ob.allow(4); ob.deny(6); ob.deny(1); ob.m=3; end);
			waitpattern(14); otherwrap(function() ob.m=1; end); 
			waitpattern(17); otherwrap(function() climate.speed = 10; climate.change("night"); end);
			waitpattern(18); otherwrap(function() climate.speed = 5; climate.change("daily"); end);
			waitpattern(23); otherwrap(function() climate.speed = 10; climate.change("night"); end);
			waitwrap(1.5);
			talkwrap(1,text.tuto22);
			talkwrap(0,text.tuto23);
			otherwrap(function() en.allow(2); en.deny(1); en.m = 5; end);
			waitwrap(10);
			otherwrap(function() en.m = 8; end);
			waitwrap(5);
			otherwrap(function() en.m = 22; end);
			waitwrap(10);
			gotopattern(28); clearpattern();
			otherwrap(function() en.m = 0; en.deny(2); end);
			waitpattern(30); 
			otherwrap(function() climate.speed = 2; climate.change("daily"); ob.deny(1); ob.m = 7; end);
			waitpattern(36);
			otherwrap(function() climate.speed = 1; climate.change("sunset"); ob.allow(1); ob.m = 7; end);
			talkwrap(1,text.tuto24);
			otherwrap(function() ob.allow(9); ob.allow(8); ob.allow(7); ob.allow(1); ob.m = 7; end);
			otherwrap(function() en.allow(3); en.m = 5; end);
			waitwrap(60);
			talkwrap(2,text.tuto25);
			otherwrap(function() ob.deny(1); ob.deny(9); ob.deny(8); ob.deny(7); ob.allow(5); en.allow(2); en.allow(1); en.m = 8; ob.allow(4); ob.allow(3); ob.m = 1; end);
			gotopattern(40);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("sunset"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("night"); end);
			waitwrap(10);
			otherwrap(function() climate.sped = 1; climate.change("daily"); end);
			waitwrap(10);
		},
};

table.insert(stages,stagedata[1]);