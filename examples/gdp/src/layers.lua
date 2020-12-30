
-- @LAYERS:
-- im stands for "images" or layers. This group of functions will auto-control image positions, and rotations
-- and opacities. Extended with "text" (texts) and "foo" (dummy) to export functionality of auto-controlling
-- to other objects.
-- 	subfunctions:
--		load = inserts the image with a name in the list.
--		foo =  inserts a dummy entry in the list (displays nothing)
--		text = insert a text in the list.
--		blit = if found entry i in list then update position, rotation, etc.. and blit it.
--		speed = set the speed of changes in the entry.
--		makerot = make the entry auto-rotate (as the loading rotating icon)
--		setpos = Instantly sets position to x,y.
--		moveto = Gradually move to x,y.
--		setalpha = Gets opaticy.
--		setalpha = Sets opacity.
--		fadeto = Gradually sets opacity to.
im = {
	load		= function(n,p,c) im[n] = { i = image.load(p), x = 0, rx = 0, y = 0, ry =0, a = 255, ra = 255, ang=0, rspd=10, n=1 ,rotating =false }; if (c) then im[n].i:center(); end end,
	foo			= function(n) im[n] = { i=false,x=0,rx=0,y=0,ry=0,a=0,ra=255 }; end,
	text		= function(n,x,y,txt,r,g,b,a,c,eff) local ef=eff or "none"; local cen = c or false; im[n] = { ang=0, rspd=15, n=1, x=x, y=y, txt=txt, r=r,g=g,b=b,a=a, rx=x,ry=y,ra=a, centered=cen, eff=ef }; end,
	blit		= function(i) if not im[i] then return end im[i].x = vgt(im[i].x,im[i].rx,im[i].n); im[i].y = vgt(im[i].y,im[i].ry,im[i].n); im[i].a = vgt(im[i].a,im[i].ra,im[i].n); if im[i].rotating then im[i].ang = im[i].ang + im[i].rspd; if im[i].ang > 360 then im[i].ang = im[i].ang - 360 end im[i].i:rotate(im[i].ang); end if (im[i].txt) then im[i].ang = im[i].ang + im[i].rspd; if im[i].ang > 360 then im[i].ang = im[i].ang - 360 end if im[i].eff == "none" then screen.print(im[i].x,im[i].y,im[i].txt,0.77,color.new(im[i].r,im[i].g,im[i].b,im[i].a),color.new(0,0,0,math.min(im[i].a,128)),iif(im[i].centered,"center","left")); return; end if im[i].eff == "blinking" and im[i].ang > 180 then screen.print(im[i].x,im[i].y,im[i].txt,0.77,color.new(im[i].r,im[i].g,im[i].b,im[i].a),color.new(0,0,0,math.min(im[i].a,128)),iif(im[i].centered,"center","left")); return; end else if im[i].i then im[i].i:blend(math.floor(im[i].x),math.floor(im[i].y),im[i].a); end end end,
	speed		= function(i,n) im[i].n = n end,
	makerot		= function(i,r) local s = r or 10; im[i].rspd = s; im[i].rotating = true; end,
	setpos		= function(i,x,y) im[i].rx = x; im[i].x = x; im[i].ry = y; im[i].y = y; end,
	moveto		= function(i,x,y) im[i].rx = x; im[i].ry = y; end,
	setalpha	= function(i,a) im[i].ra = a; im[i].a = a; end,
	getalpha	= function(i) return im[i].a; end,
	fadeto		= function(i,a) im[i].ra = a; end,
}
