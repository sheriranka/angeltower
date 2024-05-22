pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
//constants
//d stairs down
//u stairs up
//w = wall
//a = empty(can be replaced later)
//s = shop
//b = bossfight
//c = chest(item)
//q = chest(equip)
//x = chest(wpn)
//y = chest(spell)
//e = empty chest



//first floor pal


stagemap = {"wwwwwwwwwywuwawwwawawaawwaabwwawwwaaawawwwaaaaawwaaaaaawwwwwwwww",
"wwwwwwwwwdaaqaawwaaaaaawwaaaxaawwaaaaaawwaasaaawwaaaaaawwwwwwwww"
}

pix,spd,tick = 0.125,2,0

//sprites for walls
flrs = split"0,1,16,17"


//colors for combat spells

elem_cols = {
f=8,
i=12,
t=10,
n=7,
h=11
}
 
 
flrcols = split"7,9,13,0"

flrfills= split"…,●,░,█"

 
bossspr = split"229,198,200,231"

//threshold when stop gaining
//stats
stat_thrs = {}
keys = split"mx,p,m,s"
sts_thrs = split("50,15,15,15|120,30,30,30|200,60,60,60|350,99,99,99","|")
for s=1,#sts_thrs do
	statss = split(sts_thrs[s])
	new_stat = {}
	for k=1,#keys do
		new_stat[keys[k]] = tonum(statss[k])
	end
	add(stat_thrs,new_stat)
end

//add up and down locations
//so the place u go to when u go
//downstairs and upstairs is dif
stagexup,stageyup = {2,3},{4,2}

stagexdown,stageydown = {4,3},{3,5}

w,h = 8,8

up,face = true,false
	//m = main
	//s = stats
	//e = equip
	//w = wpn
	//p = spells
	//d = dialogue
	//t = toss item menu, options are
	//use/equip or discard


menucontents = {
m=split"equip,magic,weapn,stats",
s=split"hp,power,magic,defns,speed",
i={},
w={},
p={},
e={},
t=split"use,pass,toss",
chars=split"char1,char2,char3",
selected=0,
g = 1000
}



//define character


chara = {}
charnames = split"char1,char2,char3"

for j=1,3 do
	add(chara,
	{
	mx=30,
	h=30,
	p=5,
	m=5,
	s=5,
	wpn=nil,
	arm=nil,
	equip={},
	wpns={},
	spells={}
	})
	chara[j].n = charnames[j]
end

//t os type
//t = 2 spell
//t = 1 armor
//t = 3 wpn


//spell ids, 1 and above
//n = name
//oc = can be used outside combat
//d = string description
//e = element
//x = durability
//t = type, type 1 = spell, type 0 = equipabble
//c = color

//add more spells later
spells = {
{n="fire",oc=false,d="flame spell",e="f",x=10,t=1,p=300},
{n="ice",oc=false,d="frost spell",e="i",x=10,t=1,p=300},
{n="thunder",oc=false,d="electric spell",e="t",x=10,t=1,p=300},
{n="heal",oc=true,d="healing spell",e="h",x=10,t=1,p=300}
}


//equipment ids
//n = name
//s = strength
//w = weakness
//d = description
//t = type
//e = equipped 

equip = {
{n="red",str="f",wk="i",t=0,eqp=false,p=500},
{n="blue",str="i",wk="t",t=0,eqp=false,p=500},
{n="green",str="t",wk="f",t=0,eqp=false,p=500},
{n="silver",str="n",wk="no",t=0,eqp=false}
}

//weapon ids

//n = name
//e = element
//a = atk
//x = durability
//d = description
//t = type
//e = equipped



weapon = {
{n="blade",e="n",a=2,p=50},
{n="firesword",e="f",a=5,p=200},
{n="icepick",e="i",a=3,p=100},
{n="iceblade",e="i",a=6,p=400},
{n="thdraxe",e="t",a=10,p=1000},
{n="ironswd",e="n",a=5,p=500},
{n="greatswd",e="n",a=15,p=2000},
{n="ultswd",e="n",a=20,p=9999}
}

for wpn_ in all(weapon) do
	wpn_.t = 2
	wpn_.eqp = false
end


items = {equip,spells,weapon}

//main menu options
mainmenu = split'e,p,w,s'
subsel = 0

//shop stuff
shopinv = {
split"1,2,3",
split"1,2,3,4",
split"2,4,5,6"
}

shoppage = 1
nms = split"armor,spellbooks,weapons"

//transition screen ticks

trans_tick = 0


function _init()

	stage,up,state,moving,movex,
	movey,movetick,menutime,menutimeset,
	steps,windowtxt,windowcount,window,
	subsel,subwin,prev,selection=
	1,true,0,false,0,0,0,0,true,0,
	"",1,nil,nil,nil,nil,1
	
	stageset()
	//spell test
	add(chara[1].spells, getit(2,1))
	add(chara[1].spells, getit(2,2))
	add(chara[2].spells, getit(2,3))
 add(chara[3].spells, getit(2,4))
	
	
end


function _update()

	if moving then
	 tick = (tick+1)%8
	end
	menutime = (menutime+1)%8
	if(menutime == 0) then
		menutimeset = true
	end

//move on map
	if state == 0 then
		updatemap()
//combat
	elseif state == 1 then
		updatecombat()
//transition screen
	elseif state == 2 then
		trans_tick += 1
		if trans_tick == 30 then
			trans_tick = 0
			state = 1
		end
	elseif state == 3 then
		update_start()
	end
		
end


function _draw()

--0 is map
--1 is combat
--2 is transition screen

	if state == 0 then
		drawmaps()
	elseif state == 1 then
		drawcombat()
	elseif state == 2 then
		draw_trans()
	elseif state == 3 then
		draw_start()
	end
	
end



//big changing functions stuff

function stageset()

	if up then
		centerx = stagexup[stage]
		centery = stageyup[stage]
	else
		centerx = stagexdown[stage]
		centery = stageydown[stage]
	end
		
	x,y = centerx,centery
	
	offsetx = 63
	offsety = 63
	
end
-->8
function drawmaps()

	cls(0)
	drawmap(h,w,stagemap[stage])
	drawsprite(tick)
	
	//menu window
	
	if window then
		drawmenu(window)
	end
	
	
	//fix collission
	
	print("x:"..x..",y:"..y,12)
	print("offsetx:"..offsetx..",offsety:"..offsety,0,8,12)

end



function draw_wall(x,y)

	local sp = flrs[ceil(stage/5)]
	spr(sp,x,y)
	spr(sp,x+8,y)
	spr(sp,x,y+8)
	spr(sp,x+8,y+8)
	
end


function drawsprite(tick)

	if moving then
		spr(43,55,55,2,1,face)
		if tick < 4  then
			spr(61,55,63,2,1,face)	
		else
		 spr(45,55,63,2,1,face)
		end
	else
			spr(43,55,55,2,2,face)
	end
	
end

spr_ss = {a=32,q=2,x=2,y=2,e=34,d=6,u=4,s=38}

function drawmap(h,w,grid)

	for i=1,h do
		for j=1,w do
			local s = grid[j+((i-1)*w)]
			local x = ((j-1)*16)+offsetx-((centerx-.5)*16)
			local y = ((i-1)*16)+offsety-((centery-.5)*16)
		
			if s == "w" then
				draw_wall(x,y)
			elseif s == "b" then
				spr(bossspr[ceil(stage/5)],x,y,2,2)
			elseif s == "a" then
				local stage_elems = ceil(stage/5)
				fillp(…)
				rectfill(x,y,x+16,y+16,flrcols[stage_elems])
				fillp(█)
			else
				spr(spr_ss[s],x,y,2,2)
			end
			
		end
	end
	
end
		
//true = change in x
//false = change in y
function position(d,xy)

	if xy then
		x += d*pix
	else
		y += d*pix
	end

end


//moddifying this
//test later

windows = {}

function windows.m()

	rectfill(16,16,56,54,0)
	rect(16,16,56,54,7)
		
	for i=1,#menucontents.m do
			
		if i == selection then
				print("★"	,18,i*8+12)
		end
			print(menucontents.m[i],28,i*8+12)
	end
		
	rectfill(92,16,112,24,0)
	rect(92,16,112,24,7)
	print(menucontents.g.."g",94,18)
		
end


function windows.c()


 rectfill(16,16,56,64,0)
	rect(16,16,56,64,7)
		
	for i=1,#menucontents.m do
			
		if i == subsel then
			print("★"	,18,i*8+12)
		end
		print(menucontents.m[i],28,i*8+12)
	end

	rectfill(47,16,90,48,0)
	rect(47,16,90,48,7)
		
	for i=1,#menucontents.chars do
			
		if i == selection then
			print("★"	,52,i*8+12)
		end
		print(menucontents.chars[i],62,i*8+12)
	end

end

function windows.y()

 rectfill(47,16,90,48,0)
	rect(47,16,90,48,7)
		
	for i=1,#menucontents.chars do
			
		if i-1 == selection then
			print("★"	,52,i*8+12)
		end
		print(menucontents.chars[i],62,i*8+12)
	end
	
end

function windows.h()

	windows['y']()
	
end

function windows.k()

	windows['y']()
	
end

function windows.e()

	rectfill(32,16,96,56,0)
	rect(32,16,96,56,7)
	
	for i=1,#chara[menucontents.selected].equip do
			if i == selection then
				print("★"	,35,i*8+12)
			end
			print(chara[menucontents.selected].equip[i].n,44,i*8+12)
	 	if chara[menucontents.selected].equip[i].eqp	then
				print("e",90,i*8+12)
			end
		end

end

function windows.p()

	rectfill(32,16,96,52,0)
	rect(32,16,96,52,7)
		
	for i=1,#chara[menucontents.selected].spells do
		if i == selection then
				print("★"	,35,i*8+12)
		end
		print(chara[menucontents.selected].spells[i].n,44,i*8+12)
		print(chara[menucontents.selected].spells[i].x,80,i*8+12)
	end

end

function windows.w()

	rectfill(32,16,104,52,0)
	rect(32,16,104,52,7)
		
	for i=1,#chara[menucontents.selected].wpns do
		if i == selection then
				print("★"	,35,i*8+12)
		end
		print(chara[menucontents.selected].wpns[i].n,44,i*8+12)
		if chara[menucontents.selected].wpns[i].eqp	then
			print("e",90,i*8+12)
		end
	end
	
end

function windows.s()
	
	rectfill(32,16,96,60,0)
	rect(32,16,96,60,7)
		
	print("hp", 40, 20)
	print("atk\nmag\nspd\nwpn\neqp")
		
	print(chara[menucontents.selected].h.."/"..chara[menucontents.selected].mx, 64, 20)
	print(chara[menucontents.selected].p)
	print(chara[menucontents.selected].m)
	print(chara[menucontents.selected].s)
	if not chara[menucontents.selected].wpn == nil then
		print(chara[menucontents.selected].wpn.n)
	else
		print("none")
	end
		
	if not chara[menucontents.selected].arm == nil then
		print(chara[menucontents.selected].arm.n)
	else
		print("none")
	end

end

function windows.t()

 rectfill(32,32,90,64,0)
	rect(32,32,90,64,7)
		
	print(subwin[subsel].n, 35,34)
	for i=1,#menucontents.t do
			if i == selection then
					print("★"	,35,i*8+34)
			end
			print(menucontents.t[i],44,i*8+34)
	end
	
end

function windows.d()

	rectfill(7,91,120,120,0)
	rect(7,91,120,120,7)
		
	print(windowtxt[windowcount],9,93)

end

function windows.b()
 rectfill(32,16,104,52,0)
	rect(32,16,104,52,7)
		
				
	rectfill(32,16,80,15,0)
	rect(32,8,80,15,7)
	print(nms[shoppage],34,10)
		
		
	for i=1,#shopinv[shoppage] do
		if i == selection then
		 print("★"	,35,i*8+12)
	 end
	 print(getit(shoppage, shopinv[shoppage][i]).n,44,i*8+12)
		print(getit(shoppage, shopinv[shoppage][i]).p,80,i*8+12)
	end
		
	rectfill(92,54,118,62,0)
	rect(92,54,118,62,7)
	print(menucontents.g.."g",94,56)
		
end

function drawmenu(window)


	windows[window]()
	
end


-->8
//map collissions
//and map logic


function col(grid)

	for i=1,h do
		for j=1,w do
		
			local s = grid[j+((i-1)*w)]
			if s == "w" or s == "x" or s == "e" or s == "q" or s == "y" or s == "s" or s == "b" then
						
				if abs(x - j) < 1 and abs(y-i) < 1 then
					//print("i:"..i..",j:"..j,0,32,10)
					return true
				end
				
			end
			
		end
	end

	return false
	
end


function stairs(grid)


	for i=1,h do
		for j=1,w do
		
			local s = grid[j+((i-1)*w)]
			if s == "d" then
						
				if abs(x - j) < .5 and abs(y-i) < .5 then
					//print("i:"..i..",j:"..j,0,32,10)
					stage -= 1
					up = false
					stageset()
				end
			
			elseif s == "u" then
				if abs(x - j) < .5 and abs(y-i) < .5 then
					//print("i:"..i..",j:"..j,0,32,10)
					stage += 1
					up = true
					stageset()
				end
			end
			
		end
	end

	return false


end



function getitem(c)

	get = true
	
	if c == "q" then
		local n = flr(rnd())%#equip+1
	
		local stored = false
	
		for i=1,3 do
			if #chara[i].equip < 4 then
				add(chara[i].equip, getit(1,n))
				windowtxt = {"you found "..equip[n].n..".", "stored in bag."}
				stored = true
				break
			end
		end
			
		if not stored then
			windowtxt = {"you found "..equip[n].n..".","but your equip inventory\nis full."}
			get = false
		end

	elseif c == "x" then
		local n = flr(rnd())%#weapon+1
	 
	 stored = false
	 
	 for i=1,3 do
			if #chara[i].wpns < 4 then
				add(chara[i].wpns, getit(3,n))
				windowtxt = {"you found "..weapon[n].n..".", "stored in bag."}
				stored = true
				break
			end
		end
			
		if not stored then
			windowtxt = {"you found "..weapon[n].n..".","but your equip inventory\nis full."}
			get = false
		end

	elseif c == "y" then
		local n = flr(rnd())%#spells+1
	
	 local stored = false
	 
	 for i=1,3 do
			if #chara[i].spells < 4 then
				add(chara[i].spells, getit(2,n))
				windowtxt = {"you found "..spells[n].n..".", "stored in bag."}
				stored = true
				break
			end
		end
			
		if not stored then
			windowtxt = {"you found "..spells[n].n..".","but your equip inventory\nis full."}
			get = false
		end
		
	end
	
	window = "d"
	resetmenu()
	return get

end

function interact(grid)

	local index = flr(x) + (flr(y)-1)*w
	local inx = nil
	local get = false
	
	local grid_table = {
	index-1,
	index+1,
	index-w,
	index+w
	}
	
	for x in all(grid_table) do
		if grid[x] == "x" or grid[x] == "q" or grid[x] == "y" then
			inx = x
			get = getitem(grid[x])
			break
		elseif grid[x] == "s" then
			window = "b"
			resetmenu()
			break
		elseif grid[x] == "b" then
			//start boss fight
			state = 2
			gen_battle()
			gen_boss()
			//remove boss from map
			inx = x
			stagemap[stage] = sub(grid, 1, inx-1).."a"..sub(grid, inx+1, #grid)
		end
	end
	//if itemget is true, mod mapstring
	
	if get then
		stagemap[stage] = sub(grid, 1, inx-1).."e"..sub(grid, inx+1, #grid)
	end

end


function updatemenu(window)

	local w = window
	
	if w == "m" then
		len = #menucontents.m
	elseif w == "c" or w == "y" or w == "h" or w == "k" then
		len = #menucontents.chars
	elseif w == "i" then
		len = #chara[menucontents.selected].i
	elseif w == "e" then
	 len = #chara[menucontents.selected].equip
	elseif w == "w" then
		len = #chara[menucontents.selected].wpns
	elseif w == "p" then
		len = #chara[menucontents.selected].spells
	elseif w == "t" then
		len = #menucontents.t
	elseif w == "b" then
		len = #shopinv[shoppage]
	else
		len = 0
	end


	if menutimeset then
		if(btn(3)) then
			selection = (selection + 1)%len
			if selection == 0 then selection = len end
			resetmenu()
		end
		
		if(btn(2)) then
			selection = (selection - 1)%len
			if selection == 0 then selection = len end
			resetmenu()
		end
		
		//pending. one button doesnt work
		if(btn(1)) then
		 shoppage = (shoppage + 1)%3
		 if shoppage == 0 then shoppage = 3 end
			selection = 1
			resetmenu()
		end
	
		if(btn(0)) then
		 shoppage = (shoppage - 1)%3 + 1
	 	if shoppage == 0 then shoppage = 3 end
	 	selection = 1
	 	resetmenu()
	 end
	
		if(btn(4)) then
			nextmenu()
			resetmenu()
		end
		
		if(btn(5)) then
			prevmenu()
			resetmenu()
		end
	end
	
end


function prevmenu()
	
	if state == 0 then
		local v = window
		
		local window_table={
		m=nil,
		s="m",
		e="m",
		p="m",
		w="m",
		t=prev,
		k="b",
		b=nil
		}
		//
		//}
		window = window_table[v]
		selection = 1
	
	end

end


function nextmenu()

		local w = window
		
		if w == "m" then
			window = "c"
			subsel = selection
			selection = 1	
		elseif w == "c" then
			window = mainmenu[subsel]
			menucontents.selected = selection
			selection = 1
		elseif w == "p" and #chara[menucontents.selected].spells > 0 then
			window = "t"
			subwin = chara[menucontents.selected].spells
			subsel = selection
			selection = 1
			prev = mainmenu[2]				
		elseif w == "w" and #chara[menucontents.selected].wpns > 0 then
			window = "t"
			subwin = chara[menucontents.selected].wpns
			subsel = selection
			selection = 1
			prev = mainmenu[3]
		elseif w == "e" and #chara[menucontents.selected].equip > 0 then
			window = "t"
			subwin = chara[menucontents.selected].equip
			subsel = selection
			selection = 1
			prev = mainmenu[1]		
		elseif w == "y" then
			usingitem()
		elseif w == "h" then
			passitem()
		elseif w == "t" then		
			if selection == 1 then
				useitem()
			elseif selection == 2 then
				selection = 1
				window = "h"
				resetmenu()
			else
				del(subwin,subwin[subsel+1])
				prevmenu()
			end
		elseif w == "d" then
			windowcount += 1
			if windowcount > #windowtxt then
			 window = nil
			 windowcount = 1
			end
		elseif w == "b" then
			if menucontents.g >= getit(shoppage,shopinv[shoppage][selection]).p then
				window = "k"
				selected = selection
				selection = 1
				resetmenu()
			end
		elseif w == "k" then
			buyitem()
		end

end


function useitem()

	if subwin[subsel].t == 1 then
		
		if subwin[subsel].oc then
			
			resetmenu()
			window = "y"
			selected = 1
			//new menu
			
		else 
		
			resetmenu()
			window = "d"
			windowtxt = {"this item can't be used\noutside of battle."}
		end
	
		
	else
		//unequip all item and then
		//equip one
		
		if subwin[subsel].eqp == true then
			subwin[subsel].eqp = false
			
			//if wpn change wpn status
			//if arm change arm status
			if subwin[subsel].t == 2 then
				chara[menucontents.selected].wpn = nil
			else
				chara[menucontents.selected].arm = nil
		 end
		 
			prevmenu()
		else
		
			for i in all(subwin) do
				i.eqp = false
			end
			
			subwin[subsel].eqp = true
			
			if subwin[subsel].t == 2 then
				chara[menucontents.selected].wpn = subwin[subsel+1]
			else
				chara[menucontents.selected].arm = subwin[subsel+1]
		 end
			
			prevmenu()
		end
		
	end

end

function usingitem()

	
	subwin[subsel].x -= 1
	chara[selection].h += ceil(chara[selection].mx/2)
	if chara[selection].h > chara[selection].mx then chara[selection].h = chara[selection].mx end
		if subwin[subsel].x == 0 then
			del(subwin,subwin[subsel])
		end
	selection = 1
	resetmenu()
	window = "m"


end

function passitem()

	local ob = subwin[subsel]
	
	if ob.t == 0 then
		if #chara[selection].equip < 4 then
		 ob.eqp = false
		 add(chara[selection].equip, ob)
		 del(subwin,subwin[subsel])
		 chara[menucontents.selected].arm = nil
		 resetmenu()
		 window = "m"
		else
			window = "d"
			windowtxt = {chara[selection].n.."'s inventory is full"}
			resetmenu()
		end
	elseif ob.t == 1 then
		if #chara[selection].spells < 4 then
		 add(chara[selection].spells, ob)
		 del(subwin,subwin[subsel])
		 resetmenu()
		 window = "m"
		else
			window = "d"
			windowtxt = {chara[selection].n.."'s inventory is full"}
			resetmenu()
			end
	elseif ob.t == 2 then
	 ob.eqp = false
		if #chara[selection].wpns < 4 then
		 add(chara[selection].wpns, ob)
		 del(subwin,subwin[subsel])
		 chara[menucontents.selected].wpn = nil
		 resetmenu()
		 window = "m"
		else
			window = "d"
			windowtxt = {chara[selection].n.."'s inventory is full"}
			resetmenu()
		end
	end

end


//change buy item later
function buyitem()

	if shoppage == 2 and #chara[selection].spells < 4 then
	 add(chara[selection].spells, getit(shoppage, shopinv[shoppage][selected+1]))
		menucontents.g -= getit(shoppage, shopinv[shoppage][selected]).p
		prevmenu()
		
	elseif shoppage == 3 and #chara[selection].wpns < 4 then
	 add(chara[selection].wpns, getit(shoppage, shopinv[shoppage][selected+1]))
	 menucontents.g -= getit(shoppage, shopinv[shoppage][selected]).p
		prevmenu()
	elseif shoppage == 1 and #chara[selection].equip < 4 then
  add(chara[selection].equip, getit(shoppage, shopinv[shoppage][selected+1]))
	 menucontents.g -= getit(shoppage, shopinv[shoppage][selected]).p
		prevmenu()
	else
		window = "d"
		windowcount = 1
		windowtxt = {"not enough space"}
	end
	
	resetmenu()
	
end


function resetmenu()

	menutime = 1
	menutimeset = false
	
end


function updatemap()

if not window then



		//do moving
		if moving == true then
		
			offsetx += 2*movex
			offsety += 2*movey
			movetick += 1
			
			if movetick%8 == 0 then		
				moving = false
				movex = 0
				movey = 0
				
				//at end of move
				//check if standing on stairs
				//or if speed goes up
				dosteps()	
				stairs(stagemap[stage])
			end
		
		
		//only do the following if
		//not moving
		//do not press menu open while
		//walking
		else
		

			if(btn(0)) then
	
				x -= 1
				
				if col(stagemap[stage]) then
					x += 1
					movex = 0
					moving = false
				else
				 movex = 1
				 moving = true
				end
				
				face = false
				
			elseif(btn(1)) then
				
				x += 1
				face = true
				
				if col(stagemap[stage]) then
					x -= 1
					movex = 0
					moving = false
				else
				 movex = -1
				 moving = true
				end
				
			
			elseif(btn(2)) then
			
			
			 y -= 1
			 
				if col(stagemap[stage]) then
					y += 1
					movey = 0
					moving = false
				else
					movey = 1
					moving = true
				end
				
			
			elseif(btn(3)) then
			
			 y += 1
		
				if col(stagemap[stage]) then
					y -= 1
					movey = 0
					moving = false
				else
				 movey = -1
				 moving = true
				end
				
			end
			
			
			if menutimeset then
			//interact w items
				if(btn(4)) then
					interact(stagemap[stage])	
				end
		
			//open menu
				if(btn(5)) then
					window = "m"
					resetmenu()
				end
			
		 end	
	end

else

 updatemenu(window)
 
end


end


function dosteps()

	steps = (steps + 1)%16
	
	if(steps == 0) then
	
	
		windowtxt = {}
		for i=1, #chara do
			if(rnd(3) > 2) then 
			add(windowtxt, chara[i].n.." speed increased by 1.")
			window = "d"
			chara[i].s += 1
			resetmenu()
			end
		end
	elseif steps == 4 or steps == 12 then
		
		//screen transition state
			if rnd(3) > 2 then
			state = 2
			gen_battle()
			enemies_gen()
			end
		
	end
	
end
-->8

c_menus = {}
//sort actions by speed
//bubble sort because
//at most 6 actionds
function sort_actions()

	local swapped = true
	while swapped do
	
		swapped = false
		for i=1,#actions-1 do
		
			if actions[i].s < actions[i+1].s then
				actions[i], actions[i+1] = actions[i+1],actions[i]
				swapped = true
			end	
		end	
	end
end

//speed, target, power or magic, atk type, element


function enemy_action(en)

//select ability type
	if #en.spells > 0 then
		actt = ceil(rnd(2)) //1 is attack 2 is spell
	else
		actt = 1
	end
	
	local t = rnd(alivechars)
	local tarn = encount + 3
	local tarn = encount + 3
	if actt == 1 then
		action = {s=en.s,p=en.p,e="n",t=t,y='phys',trn=tarn}
	else
		local spell = en.spells[ceil(rnd(#en.spells))]
		action={s=en.s,p=en.m,e=en.spells.e,t=t,y='mag',trn=tarn}
	end	
	encount += 1
		
	return action

end


//1
function c_menus.st1()

	local s = chara[turn] 
	
	newaction = {s=s.s,p=s.p,y='phys'}
	//used to be isnil
	if s.wpn then
		newaction.e = s.wpn.e
		newaction.p += s.wpn.a
	else
		newaction.e = "n"
	end
	
	add(actions,newaction)
	
	
	curmen,commen = enemies,'st5'

end


function c_menus.st2()

	curmen,commen,selection=chara[turn].spells,'st4',1

end

function c_menus.st4()


	local s = chara[turn]
	
	newaction = {s=s.s,p=s.m,e=s.spells[selection].e,y='mag'}

	add(spellsel,chara[turn].spells[selection])
	
	curmen = enemies
	
	//if healing spell select characters
	if newaction.e == "h" then
		commen='st9'
		newaction.y='heal'
	else
		commen = 'st5'
	end
	
	selection = 1
	add(actions,newaction)
end


function c_menus.st5()

	actions[turn].t = selection+3
	actions[turn].trn = alivechars[turn]
	
	if turn < #alivechars then
		curmen = m
		commen = 'st1'
		turn += 1
	else
		commen = 'st7'
		selection = 1
		c_next()
	end

end

function c_menus.st3()

//defend option
	defending[turn] = true
 turn += 1
 if turn > #alivechars then
  commen = 'st7'
  c_next()
 else
	 commen = 'st1'
	 curmen = m
	end

end

function c_menus.st7()


	encount = 1
	//calculate enemy actions
	foreach(enemies, function(en) add(actions,enemy_action(en)) end) 
		
	commen = 'st8'
	//sort by speed
	sort_actions()
	foreach(spellsel, function(spl) spl.x-=1 end)
	c_next()
	//enemy move calculation

end

//select from party members
//for healing spell

function c_menus.st9()

	//add target
	actions[turn].t = selection
	
	//same as st5 here
	if turn < #alivechars then
		curmen = m
		commen = 'st1'
		turn += 1
		selection = 1
	else
		commen = 'st7'
		selection = 1
		c_next()
	end

end


dmgcalc = {}

function dmgcalc.phys(a)

	local enm_ = enemies[a.t-3]
	
	if a.t > 3 then
		d = a.p - enm_.s/4
		if a.e == enm_.wk then
		 d *= 1.5
		elseif a.e == enm_.str then
			d *= 0.5
		end
		
	else
		d = a.p - chara[a.t].s/4
		if defending[a.t] then d = d/2 end
		if chara[a.t].arm then
			if a.e == chara[a.t].arm.wk then
			 d *= 1.5
			elseif a.e == chara[a.t].arm.str then
				d *= 0.5
			end
		end
	end
	
	d += (rnd(d)/2)/(d/4)
	d = ceil(d)
	
	return d
	
end


function dmgcalc.mag(a)

	local enm_ = enemies[a.t-3]
	if a.t > 3 then
		d = 2 * a.p - (enm_.m/8)
		if a.e == enm_.wk then
		 d *= 1.5
		elseif a.e == enm_.str then
			d *= 0.5
		end
		
	else
		d = 2 * a.p - (chara[a.t].m/8)	
		if defending[a.p] then d = (d/2) end
		if chara[a.t].arm then
			if a.e == chara[a.t].arm.wk then
			 d *= 1.5
			elseif a.e == chara[a.t].arm.str then
				d *= 0.5
			end
		end
	end
	
	d += (rnd(d)/2)/(d/4)
	d = ceil(d)
	return d

end

function dmgcalc.heal(a)
	
	
	d += flr(rnd(d))
	return d

end

//game over fight lost
function c_menus.st0()

	if menutimeset then
		if(btn(4)) then
			reset()
		end
	end

end

//battle won. calculate results
function c_menus.sta()

	stss = split"mx,p,m,s"
	st_nms = split"hp,power,magic,speed"
	//all alive chars
	add(txt_bx,"earned "..gld.." gold.")
	menucontents.g += gld
	for j in all(alivechars) do
		//all stats
		for s=1,#stss do
			rnd_nm = ceil(rnd(3))
			the_stat = stss[s]
			//make sure its lower than threshold
			if rnd_nm == 1 and chara[j][the_stat] < stat_thrs[ceil(stage/5)][the_stat] then
				if the_stat == "mx" then
					inc = ceil(rnd(5))
					chara[j].mx += inc
					add(txt_bx,chara[j].n.." "..st_nms[s].." increased by "..inc..".")
				else
					chara[j][stss[s]] += 1
					add(txt_bx,chara[j].n.." "..st_nms[s].." increased by 1.")
				end
			end
		end
	end
	
	commen = "sts"
end

function c_menus.sts()

	if menutimeset then
		if(btn(4)) then
				deli(txt_bx,1)
				resetmenu()
				if #txt_bx < 1 then
					//revive dead characters on battle end
					for c in all(chara) do
						if c.h < 1 then c.h = 1 end
					end
					
					state = 0
				end
				
		end
	end
end


function c_menus.st8()

//calculate if fight won or lost

	if #alivechars < 1 then
		//game over
		commen = 'st0'		
		pal()
		resetmenu()
	elseif #enemies < 1 then
		pal()
		commen = 'sta'
	else
		if not comani and #actions > 0 then
			//rt animation
			comani = true
			curframe = 1
			//take first act and remove from queue
			curact = deli(actions,1)
			pal(15,elem_cols[curact.e])
			//calculate dmg
			dmg = dmgcalc[curact.y](curact)
			if dmg < 0 then 
				dmg = 1
			end
			if curact.y == "heal" then
				dmg *= -1
			end
			
			
		elseif comani then
			
			//update sprite every 3 ticks
			comtick += 1
			if comtick%5 == 0 then
				curframe += 1
				comtick = 0
			end
			
			if curframe > frames then
				comani = false
				//if enemy or character dies. remove from list
				local act = curact
				local t = 3
				
				
				if act.t > t then
					enemies[act.t-t].h -= dmg
				 if enemies[act.t-t].h < 1 then
				 	local curen = deli(enemies,act.t-t)
				 	gld += curen.g
				 	//delete moves targeting dead
				 	//enemy
				 	
				 	//and delete moves from
				 	//dead enemy
				 	for dl in all(actions) do
				 		if dl.t == act.t or dl.trn == act.t then
				 			del(actions,dl)
				 		end
				 	end
				 	
					end
					
				//pending
				else
					chara[act.t].h -= dmg
					if chara[act.t].h < 1 then
						deli(alivechars,act.t)
						
						for dl in all(actions) do
				 		if dl.t == act.t or dl.trn == act.t then
				 			del(actions,dl)
				 		end
				 	end
					elseif chara[act.t].h > chara[act.t].mx then
						chara[act.t].h = chara[act.t].mx
					end
				end
				
			end
		
		else
		//start new turn
			commen = "st1"
			curmen = m
			pal()
		//reset turn and defending status
			turn = 1
			defending = {false,false,false}
		//update spells
			spellsel = {}
			for ac in all(alivechars) do
				for sl in all(chara[ac].spells) do
					if sl.x < 1 then del(chara[ac].spells,sl) end
				end
			end
		end
		
	end

end


function c_next()

	if commen == 'st1' then
		local f = {c_menus.st1,c_menus.st2,c_menus.st3}
		//call func of turn
		f[selection]()
	else
	
		//call func
		c_menus[commen]()
	
	end

end

//player menu
function player_select()

	
	local len = #curmen
	if menutimeset then
		if btn(0) then
			selection -= 1
			resetmenu()
		end
		
		if btn(1) then
			selection += 1
			resetmenu()
		end
	
		if(btn(3)) then
			selection += 1
			resetmenu()
		end
		
		if(btn(2)) then
			selection -= 1
			resetmenu()
		end
		
		if(btn(4)) then
			c_next()
			resetmenu()
		end
		
		if(btn(5)) then
			c_back()
			resetmenu()
		end
		
		if selection == 0 then
			selection = len
		elseif selection > len then
			selection = 1
		end
	end
 //btwn 4 is confirm 5 is back

end


//back button go back a menu
function c_back()

	local l = commen
	if l == 'st1' and turn > 1 then
		turn -= 1
		//delete last action
		deli(actions)
	elseif l == 'st5' or l == 'st4' or l == 'st9' then
		commen = 'st1'
		curmen = m
		//remove spell from spelllist
		if l == 'st5' or l == 'st9' then
			deli(spellsel)
			deli(actions)
		end
	end
	
end


c_draw = {}


function c_draw.st1()

	rectfill(7,7,55,39,0)
	rect(7,7,55,39,7)
		
	for i=1,#m do
		
		print(m[i], 23, 4+(i*8))
		if selection == i then
			print("★", 12, 4+(i*8))
		end
		
	end
	
	rect(56,7,73,24)	
	spr(sprites[turn],57,8,2,2)

end 


function c_draw.st4()

 rectfill(7,7,55,39,0)
	rect(7,7,55,39,7)
		
	local s = chara[turn]
	for i=1,#s.spells do
		
		print(s.spells[i].n, 23, 4+(i*8))
		print(s.spells[i].x, 47, 4+(i*8))
		if selection == i then
			print("★", 12, 4+(i*8))
		end
		
	end
	
	rect(56,7,73,24)	
	spr(sprites[turn],57,8,2,2)

end 

function c_draw.st7()

end


function c_draw.st5()

	for i=1,#enemies do
		if selection == i then
			print("♥",enemies[i].x+enemies[i].w*8-4,40)
		end
	end

end

atk_anim = {
phys=split"224,225,226,226,227",
mag=split"240,241,242,241,242"
}

//animations
function c_draw.st8()

	local act = curact
	local t = 3
	//if target is enemy
	if act.t > t and #enemies > 0 then
		local loc = enemies[act.t-t].x + enemies[act.t-t].w*8-4
		if curframe > 5 then
			//display damage
			print(dmg,loc,74,7)
		else
			spr(atk_anim[act.y][curframe],loc,74)
		end
	else
	//if target is player	
		if curframe < 5 then
			if not (curact.y == "heal") then camera(ceil(rnd(3))-6,ceil(rnd(3))-6)	end
			
			if curact.y == 'mag' and curframe%2 then
				for n=1,5 do
					circ(rnd(128),rnd(128),5,15)
				end	
			elseif curact.y == 'phys' and curframe%2 then
				for n=1,3 do
					line(rnd(128), rnd(128), rnd(128), rnd(128),15)
				end
			end
		else
		//adjust this
			camera()
			local i = act.t
			print(dmg,i*24+16,92,7)
			rect(i*24+8,96,i*24+24+8,127)
			local c = chara[alivechars[i]]
			if c then
				print(c.n,i*24+10,99)
				print(c.h.."/"..c.mx,i*24+10,106)
			end
		end
	
	end
	
end


//make boxes wider later
function c_draw.st9()

	local c = alivechars
	for i=1,#c do
		
		rect(i*24+8,96,i*24+24+8,127)
		print(chara[c[i]].n,i*24+10,99)
		print(chara[c[i]].h.."/"..chara[c[i]].mx,i*24+10,106)
		
		
		if selection == i then
			print("♥",i*24+17,90)
			end
	end


end


function c_draw.sts()

	rect(0,118,127,127)
	print(txt_bx[1],2,120)

end

function c_draw.sta()

	print("enemies routed! 🅾️",2,120,7)

end

function c_draw.st0()

	print("your party was wiped out...",2,120,7)

end

function drawcombat()

	cls(0)

	foreach(enemies, function(en) spr(en.sp,en.x,en.y,en.w*2,en.w*2) end)
	
	c_draw[commen]()

end


//references nextmenu and prevmenu from
//prev window
function updatecombat()
	
	if commen == 'st8' then
		c_menus.st8()
	elseif commmen == 'sta' then
		c_menus.sta()
	elseif commmen == 'sts' then
		c_menus.sts()
	elseif commen == 'st0' then
		c_menus.st0()
	else
		player_select()
	end

end

-->8
//adding objects to inventories

function getit(typ,id)

	local item = {}
	
	//clone item
	for k, v in pairs(items[typ][id]) do
	 item[k] = v
	end
	
	return item

end

keys = split"sp,h,p,m,s,wk,str,g,id"
//small enems
sm_enms = split("64,15,6,4,9,f,i,40,1|96,20,4,6,7,i,t,40,2|70,21,5,5,9,i,f,40,3|102,25,5,2,4,t,n,55,4","|")
sm_enms_sp = split"2,3,1,"
//enemy list
enm_sm = {}
for i=1,#sm_enms do

	local spl = split(sm_enms[i])
	newems = {}
	for j=1,#keys do
		if tonum(spl[j]) == nil then
			newems[keys[j]] = spl[j]
		else
			newems[keys[j]] = tonum(spl[j])
		end
	end
	add(enm_sm,newems)

end


//large enems
lg_enms = split("76,40,5,9,8,f,i,55,1|72,60,8,5,7,n,t,120,2|66,80,3,4,6,i,f,100,3","|")
lg_enms_sp = ",3,1"
//enemy list
enm_lg = {}
for i=1,#lg_enms do

	local spl = split(lg_enms[i])
	newems = {}
	for j=1,#keys do
		if tonum(spl[j]) == nil then
			newems[keys[j]] = spl[j]
		else
			newems[keys[j]] = tonum(spl[j])
		end
	end
	add(enm_lg,newems)

end

enms = {enm_sm,enm_lg}
enms_sp = {sm_enms_sp,lg_enms_sp}
//add spell to enemy
//add(enm[1].spells,spells[1])

//enemy groups
//1 = small, 2 = large, 3 = boss
en_grp = {{1,1,1},{2,1},{1,2},{2}}

//generate enemies
function enemies_gen()

	grp = rnd(en_grp)	
	local cnt = 1
	local lvl = ceil(stage/5)
	
	for e in all(grp) do
		local en = rnd(enms[e])
		newem = {}
		for k, v in pairs(en) do
			if isnum(v) then
				local s = v*(((lvl-1)*3)+1)
				newem[k] = s
		 else
		 	newem[k] = v
		 end
		end
		newem.x = 32*cnt
		newem.y = 86-e*16	
		newem.w = e	
		newem.spells = {}
		if enms_sp[e][newem.id] then
			add(newem.spells,spells[enms_sp[e][newem.id]])
		end
		add(enemies, newem)
		cnt += 1
	end
	
end


bosses_st = split("132,231,18,15,15,t,i,600,1|136,475,25,20,27,i,f,900,2|140,699,35,32,34,f,t,1200,3|204,1200,50,50,50,n,x,2000,4","|")
boss_stats = {}
for i=1,#bosses_st do
	a_boss = {}
	a_boss_st = split(bosses_st[i])
	for k=1,#keys do
		a_boss[keys[k]] = a_boss_st[k]
	end
	add(boss_stats,a_boss)
end


bosses_sp = {{2,3},{1,3},{2,1},split"1,2,3"}


function gen_boss()


	boss_num = ceil(stage/5)
	the_boss = boss_stats[boss_num]
	boss_spells = bosses_sp[boss_num]
	new_boss = {}
	for k, v in pairs(the_boss) do
			if isnum(v) then
				new_boss[k] = tonum(v)
		else
		 	new_boss[k] = v
		end
	end
	
	new_boss.x = 48
	new_boss.y = 48
	new_boss.w = 2
	new_boss.spells = {}
	for spl in all(boss_spells) do
		add(new_boss.spells,spells[spl])
	end 
	add(enemies, new_boss)
	
end
-->8
//tools

//big sprites and stuff

-- convert a hexadecimal string into a table of numbers.
--
-- arguments:
-- s = the hexadecimal string to decode
-- n = the size (in number of digits) of each item stored in the string
-- (eg. 2 digits gives 00..ff = 1 unsigned byte,
-- 4 digits = 0000..ffff = 16-bit unsigned integer, etc)
function unhex(s,n)
 n = n or 2
 local t = {}
 for i = 1, #s, n do
  add(t, ('0x' .. sub(s, i, i+n-1)) + 0)
 end
 return t
end

function isnum(v)
	return type(v) == "num"
end

function gen_battle()

//combat vars
	m,enemies,turn,
sprites,commen,comani,frames,
curframe,comtick,actions,curact,
alivechars,dmg,defending=
split"attack,magic,defend",
{},1,{192,194,196},'st1',false,
7,1,0,{},nil,{1,2,3},0,
{false,false,false}

txt_bx = {}
spellsel = {}
encount = 1
gld = 0

curmen = m

end

function draw_trans()
	
	for i=1,(trans_tick+1)*2 do
		circfill(rnd(128),rnd(128),6,0)
	end

end
-->8
//start screen


function draw_start()

	cls(9)
	
	fillp(█)
	rectfill(0,0,127,30,2)
	rectfill(0,31,127,60,14)
	rectfill(0,99,127,127,0)
	fillp(▒)
	rectfill(0,30,127,40,2)
	rectfill(0,0,127,14,1)
	rectfill(0,98,127,86,8)
	fillp(░)
	rectfill(0,41,127,50,2)
	rectfill(0,25,127,30,14)
	rectfill(0,24,127,15,1)
	rectfill(0,61,127,70,14)
	rectfill(0,50,127,60,9)
	rectfill(0,70,127,85,8)
	fillp(⌂)
	rectfill(0,95,127,105,0)
	
	
	fillp(█)
	rectfill(100,45,120,127)
	rectfill(101,0,119,44)
	
	spr(128,48,30,4,4)
	
	print("press 🅾️ to start",32,100,7)
	

end

function update_start()


	if btn(2) then selection -= 1 end
	if btn(3) then selection += 1 end
	if btn(4) then 
		state = 0
	end


end
__gfx__
07777770055445500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70011007528888250099999999997900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071170758288285099999999a9aa7900000056666500000000001dddd1000000000000000000000000000000000000000000000000000000000000000000000
711001174889988409944a4444944aa0000056666665000000001dddddd100000000000000000000000000000000000000000000000000000000000000000000
71100117488998840944494444944490000567777776500000015151515150000000000000000000000000000000000000000000000000000000000000000000
707117075828828509444944449444900056777777776500005dddd66dddd5000000000000000000000000000000000000000000000000000000000000000000
70011007528888250944494444944490055555555555555005555555555555500000000000000000000000000000000000000000000000000000000000000000
07777770055445500944494444944490556777777777765555666666666666550000000000000000000000000000000000000000000000000000000000000000
0b0b0b0bdd0000dd09999a96799aa770566666777766666556666677776666650000000000000000000000000000000000000000000000000000000000000000
b3333330dfeeeefd099999956999aa90555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
03bbbb3b0eeeeee00444444564444440666666666666666666777777777777660000000000000000000000000000000000000000000000000000000000000000
b3b33b300effffe00444444994444440666777777777666667777777777777760000000000000000000000000000000000000000000000000000000000000000
03b33b3b0effffe004444449a4444440d66666666666666d77777777777777770000000000000000000000000000000000000000000000000000000000000000
b3bbbb300eeeeee00444444994444440dd666666666666dd77777777777777770000000000000000000000000000000000000000000000000000000000000000
0333333bdfeeeefd0444444994444440151515155151515155555555555555550000000000000000000000000000000000000000000000000000000000000000
b0b0b0b0dd0000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000003333000000000000000000000000003bb3b000000000000
070000000000000000000000000000000000000000000000000000033330000000000000000000000f137300000003333330000000000003333b000000000000
0000070000000007000000000000000000000000000000000000003ddddb000000000000000000003fff330000003f3333730000000000b2222bb00000000000
00007000000000000000000000000000000000000000000000000030dd03000000000000000000000011b0000003ffff33330000000000731337700000000000
00000000000000000099999999999900000000000000000000000030dd030000000000000000000000333b00000311ff11333000000007711433700000000000
0000000700000000095111111111159000000000000000000000003d88d300000000000000000000072227000000effffef33000000000711443300000000000
000000000000700009511111111115900000000000000000000000033330000000000000000000000011330000000fffff330000000000055743300000000000
0000000000000700095111111111159000000000000000000000033333300000000000000000000000707000000000011bb00000000000057770000000000000
000000000000000009511111111115700000000000000000000003333330000000000000000000000000000000000003bb3b000000000003bb3b000000000000
000000000000000009999999a999aa9000000000000000000000033b333b000000000000000000000000000000000003333b000000000003333b000000000000
070000000000000004444449a444444000000000000000000000033bb3bb0000000000000000000000000000000000b2222bb000000000b2222bb00000000000
00000000000000000444444994444440000000000000000000000333b3b000000000000000000000000000000000007133377000000000713337700000000000
007000000070000004444449a4444440000000000000000000000333333000000000000000000000000000000000071113337000000007111333700000000000
00000000700000000444444994444440000000000000000000000333333000000000000000000000000000000000001111333000000000411133300000000000
00000000000000000444444994444440000000000000000000033333333000000000000000000000000000000000007400740000000007440005500000000000
00000000000000070000000000000000000000000000000000000990099000000000000000000000000000000000007700770000000007700005500000000000
8888888888888888cccccccccccccccccccccccccccccccc2222222222222222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888888888888888cccccccccccccccccccccccccccccccc2222222222222222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888888888888888cccccccccccccccccccccccccccccccc2222222222222222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8808888888880888cccccccccccccccccccccccccccccccc2222222222222222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8800088888800888cccccccccccccccccccccccccccccccc2222202222022222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888088888008888cccccccccccccccccccccccccccccccc2222202222022222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888008880088888cccccccccccccccccccccccccccccccc2222202222022222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888008880088888cccccccccccccccccccccccccccccccc2222202222022222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
8888888888888888ccccc0000ccccccccccccccccccccccc2222222222222222ddddddd1dddddddddddddddddddddddd99999999999999999999999999999999
8888888888888888cccccccc00cccccccccccccccccccccc2222222222222222dddddd1111dddddddddddddddddddddd99999999999999991199999999999999
8888888888888888ccccccccc00cccccccccccc0cccccccc2222222222222222dddd1111d11ddddddd11111ddddddddd99999111111111111111111111999999
8888888880088888cccccccc0000ccccccc0000ccccccccc2222222222222222ddddddd1dd11ddd111d1ddd1dddddddd99999999999111111991919911199999
8880088800888888cccccccc0cc0cccccccc000ccccccccc2220000000000222ddddddd1ddd11dd1dddd1dd1dddddddd99999999999919199991919999999999
8888800008888888cccccccc00000ccccccc00cccccccccc2222222222222222ddddddd11dd1dddddddd1d11dddddddd99999999999919199991119999999999
8888888888888888cccccccccccccccccccccccccccccccc2222222222222222dddddddd1111dddddddd111ddddddddd99999999999911199999199999999999
8888888888888888cccccccccccccccccccccccccccccccc2222222222222222dddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaeaaaaaaaeaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaeaaaaaaaeaaadddddddddddddddddddddddddddddddd99999999991111111111111111999999
3355555335555533ccccccccccccccccccccccccccccccccaaaaeaaaaaaaeaaadddddddddddddddddddddddddddddddd99999991119999999999999999999999
3335553333555333cccccccccccc000000ccccccccccccccaaaaeaaaaaaaeaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3335553333555333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaeaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddd11111111111111dddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaeeeeeeeeeaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3335555555553333ccccccccccccccccccccccccccccccccaaeeaaaaaaaaeeaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
3333333333333333ccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddd99999999999999999999999999999999
000000000000000000000000000000000000000000000ccc00000000000000000000000000000000000000000000000000000000000000bbb000000000000000
00000000000000000000000000000000000000000000ccccc00000000000000000000000000000000000000000000000000000000000bbbbbaa0000000000000
0000000000000000000000000000000000000000000cccfcc0000000000000000000000000000088880000000000000000000000000bb44bbbaa000000000000
0000000000000000000000000000000000000000000ccffc7cc0000000000000000000000000888889a00000000000000000000000bb344bbbba000000000000
000000000000000000000000000000000000000000cccfff9cccccccccccc000000000000088888888900000000000000000000000b33444bbbb000000000000
0070000000000000000000000a0000000000000000ccffff911ccccccccccc0000000000000888888888000000000000b00000000bb33444443bb00000000b00
00700000aa000000000000000a0007000000070000c1ffffc111111111110c0000000000000454eee888000000000000ba000000bb333344433bbb000000bb00
0770000aaa000000000000000a0007000000707000001ff1c1a111111111100000000000000545eee8880000000000000bb000bbb3333335533bbbab0bab0000
777000aa0a000000000000000a00077000000700000009911a1100011111000000000000004454eeef8800000000000000abbbb3333333c44c43bb0bbb000000
777000aa0a000000a000aaa00a000777000000000000f99fa000a0000110000000000088444545eef88000000000000000000333333334c44c44400000000000
77700aaaaa0aaa0aaa0aa0a00a000777000000000000fffffa0a000000100000000888845444545ef88000000000000000000333333344cccc44490000000000
77700a000a0a0a0a0a0aaaa00a00077700000000009fffffffa000a0001100000008844444544545888000000000000000003333333444cccc9c449000000000
77770a000a0a0a0aaa0aaa000a0077770000000000992dddfa0a0a00000700000088844454445458899000000000000000003333334443ccccc9344990000000
7777700000000000aaaaaaaa0a0077770000000000992dddaf00a0000070700000840000445448889aa0050000000000000333303344439cccccc34449000000
0777700000000000aa00000000077770000000000090222aff00000000070000000000005444580ffaa9f05ee000000000033300349439c9ccccc33444440000
077777000aa000aaaa000000000777700000000009900fffffd0000000000000000000004454880ff9a9fffee50000000033330049433c9cccc8cc3004444400
070770aaaa000aa0aa000000007777700007770009900fffdd7d776000000000000000000488800ffaa9ffffe60000000033300449403ccccc8c8c00b4440444
000aaaaa00000aaaa0000000000707700070007000ffadd27dd777777dd00000000000008800000ef9aa7005670000000033000490403cccccc8ccc0b4904004
0000000a000000000000aaa0a00000000070007000f9072dd7ddccc7777d0000000000008000000efa9a7000007000000330004400433cccccccccc000904004
0000000a00aaa0a000aaa0a0aaa000000070007000a072d2d2dd1d1cccc2d000000000000888880ef9aaa7000007000003300b440043cccccccccccc0090b0bb
0000000a0aa0aaa0a0aaaaa0a0000000000777000a001d272dc7d1d1d12d2000000000008488888efa9aaa00000070003330bb440403ccc8ccccccccc040b400
0000000a0aa0aaaaaaa0a000a000000000000000a00017cd7ddc6d1d1d120000000000004888888ef9aaaa0000000700330004040b33cc8c8cccccccc04b0400
0000000a00aaa0aaaaa0aaa0a00000000000000a000011ccdcddd661212d0000000000008488888efa9aaa0000000000030044040b30ccc8cccccccccc040440
00000000000000000000000000000000000000a00000011cdddcd76dd2d00000000000084888888ef9a9a9000000000030044004040ccccccccccccccc040040
00000000000000000000000000000000000000000000011c6cdddc7ddff0000000000004888888eef99a9a0000000000300400b4b90cc1ccccccccccccc90040
0000000000000000000000000000000000000000000001116ddcddddffff000000000048484888eff99999000000000000490bb0b40c1cc1cccc1ccc1cc40004
0000000000000000000000000000000000000000000011211ddddcdf00ff000000000084888848eff99999000000000000900040b41c1c11cc1ccc1ccc140004
0000000000000000000000000000000000000000000012121cdddddff00f000000000048484888eff9999900000000000490099004c1c11c1cc1111cc1c14b04
0000000000000000000000000000000000000000000121212dddd00ff00000000000048488884efff99999000000000044000400044c1111c11ccc111c1c4bb0
00000000000000000000000000000000000000000001121211000000f00000000000084848488ffff999900000000000400b400111c111cc11c11111c1c11400
00000000000000000000000000000000000000000000000000000000f000000000000000088eef00000000000000000040bb4011111111111c00c1111c000411
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004044011000000c110000000110000440
dddd3333333ddddd22220000000022220000000000000000000000008888880000000000000000000000000000000000000000000000aaaaa000000000000000
dddd33333333b3dd2220000000000222000000cccc00000000000008888888800000000bbbbbb000000000000000000000000000000a00777a00000000000000
ddd333f3b3b333dd222000000606022200000cccccc00000000000888eeef880000000bb44baba000000000000000000000000e88000aaaaa070000000000000
dd333fff3b3373dd22000044000660220000cccccccc0000000008822ee2288800000bbb114babb0000000000000000000000889990000000000000000000000
dd33ffff333773dd22000554455000220000cccccccc00000008884eeeeef88800000bb41744bbb0000000000000000000008999aaa0000f0000700000000000
dd3300ff003733dd22005734437500220000cccccccc000008844444eeeff88000000bb44444bbb00000000000000000000a99abb33a000f0000770000000000
dd3f70ff7003333d22044734437400220000cccccccc00000444444444aa8800bb0bb33344444b000000000000000000000aaab3c11a00fff000070000000000
dddf70ff70f3333d22044444444400220000cccccccc00000044444888faa00000b33333553330030000000000000000000a03c1120a0fffff00070000000000
dddffffffff3333d22004e4444e400220000cccccccc00000000488888f9a00000333333ccc3033000000000000000000000a01220a00fffff00007700000000
ddddffeefff3333d220004400440002200000cccccc000000000880888fa9a00033333334cc30000000000000000000000000aaaaa7000fff000000777000000
ddd33fffff1333332200004444000022000000cccc0000000000008888f9aa00033333344c9c0000000000000000000000000706007000990000000000770000
dd3333fff113333d220003555370002200000011110000000000888889f99a003333333b49c90000000000000000000000000706000750777000000000070000
dddd3331111bb33d22000736677700220000cc1111cccc000008888889f9990033333344cc9c0000000000000000000000007706070000077700000007700000
dddd1bb11bbbb1dd220077776676002200cccc1111ccccc00088888889ff990033033b4c4ccc0000000000000000000000070006900005077770000000000000
ddd113bbbbbb311d22047666773440220cccccccccccccc00000000000fff0003004440cc4ccc0000000000000000000007000f6900707077770007700000000
dd1333bbb333333122443767333344220ccccccccccccccc000000000000000000400041c4c1c1000000000000000000070000fff00075075550000000000000
000000000000000000000000000000000000000000000cccccc0000000000aaaaaaa0000000000000000000000000000700000fff00700776670000000000000
000000f0000000f0000000f000000000000000000000cccc9fc70000000000000000000000000000000000000000000070000076007000777777000000000000
0000000000000f00000000f00000000000000000000cccc9f7fcc000000070000000700000000000000000000000000070000076007050777777000000000000
0000000000000f0000000ff0000000000000000000accc9ff17fc0000089b00ffff0000000000000000000000000000000000006770000777777770000000000
00000000000000000000ff000000ff0000000000a0a0a9ffffee1000009ac011ff11070000000000000000000000000000007006000000777777777000000000
0000000000000000000ff000000ff00000000000a0a0affffff110000abc2aeffffe070000000000000000000000000000077706000000077777777000000000
0000000000000000000000000ff000000ff00000aaaaa1199111100000aaafffffff070000000000000000000000000077700706007700077777777777000000
000000000000000000000000000000000000000000a009ffff921100070600fffff0000000000000000000000000000000000706077700077777777777700000
000000000000000000ffff00000000000000000000a099dddd922100700600057700000000000000000000000000000000000706770070067777777777700000
0000000000ffff000f0000f0000000000000000000ff90dddd922210077600557700000000000000000000000000000000000006700077066777777777770000
000000000f0000f0f000000f000000000000000000ff00d2dd922000600605557770000000000000000000000000000000000006000000066677777777777000
000ff0000f0000f0f000000f000000000000000000a000cd27900000606ff5577770000000000000000000000000000000000006000000066677777777777000
000ff0000f0000f0f000000f000000000000000000a00cdcd2700000060ff5777770000000000000000000000000000000000006000000066667777777770700
000000000f0000f0f000000f000000000000000000a0ddcdcd220000000657777770000000000000000000000000000000000006000000066667777770707000
0000000000ffff000f0000f0000000000000000000a0009009000000000600707077000000000000000000000000000000000006000000060607070707070000
000000000000000000ffff00000000000000000000a00ff00ff00000000607070707000000000000000000000000000000000000000000707070707070700000
__map__
0000008c8d8e8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000009c9d9e9f00000000000091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000acadaeaf008c8d8e9191918e8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8e8f8c8d8e8f8c8d8e8f919c9d9e9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9d9e9f9c9d9e9f8c8d8e8f8c919191af00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
adaeafacadaeaf9c9d9e9f91919191bf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bdbebfbcbdbebfacadaeaf919191910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bcbdbebfbcbdbebf919191910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
