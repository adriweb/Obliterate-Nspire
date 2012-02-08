----------------------
---Obliterate Nspire--
-----Adriweb 2012-----
----------------------------------------------------------
-- "Obliterate" name from Kerm Martian (Cemetech.net)
-- TI-Planet.org and Inspired-Lua.org
-- BetterLuaAPI by Adriweb
-- Screen Manager by Levak
-- Screen Manager Additions 
--             with Widgets by Jim Bauwens
----------------------------------------------------------


------------------------------------------------------------------
--                  Overall Global Variables                    --
------------------------------------------------------------------

platform.apilevel = "1.0"

Tanks = {}
CurrentPlayer = 1


--
-- Uses BetterLuaAPI : https://github.com/adriweb/BetterLuaAPI-for-TI-Nspire
--

a_acute = string.uchar(225)
a_circ  = string.uchar(226)
a_tilde = string.uchar(227)
a_diaer = string.uchar(228)
a_ring  = string.uchar(229)
e_acute = string.uchar(233)
e_grave = string.uchar(232)
o_acute = string.uchar(243) 
o_circ  = string.uchar(244)
l_alpha = string.uchar(945)
l_beta = string.uchar(946)
l_omega = string.uchar(2126)
sup_plus = string.uchar(8314)
sup_minus = string.uchar(8315)
right_arrow = string.uchar(8594)


Color = {
	["black"] = {0, 0, 0},
	["red"] = {255, 0, 0},
	["green"] = {0, 255, 0},
	["blue "] = {0, 0, 255},
	["white"] = {255, 255, 255},
	["brown"] = {165,42,42},
	["cyan"] = {0,255,255},
	["darkblue"] = {0,0,139},
	["darkred"] = {139,0,0},
	["fuchsia"] = {255,0,255},
	["gold"] = {255,215,0},
	["gray"] = {127,127,127},
	["grey"] = {127,127,127},
	["lightblue"] = {173,216,230},
	["lightgreen"] = {144,238,144},
	["magenta"] = {255,0,255},
	["maroon"] = {128,0,0},
	["navyblue"] = {159,175,223},
	["orange"] = {255,165,0},
	["palegreen"] = {152,251,152},
	["pink"] = {255,192,203},
	["purple"] = {128,0,128},
	["royalblue"] = {65,105,225},
	["salmon"] = {250,128,114},
	["seagreen"] = {46,139,87},
	["silver"] = {192,192,192},
	["turquoise"] = {64,224,208},
	["violet"] = {238,130,238},
	["yellow"] = {255,255,0}
}
Color.mt = {__index = function () return {0,0,0} end}
setmetatable(Color,Color.mt)

function copyTable(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function deepcopy(t) -- This function recursively copies a table's contents, and ensures that metatables are preserved. That is, it will correctly clone a pure Lua object.
	if type(t) ~= 'table' then return t end
	local mt = getmetatable(t)
	local res = {}
	for k,v in pairs(t) do
		if type(v) == 'table' then
		v = deepcopy(v)
		end
	res[k] = v
	end
	setmetatable(res,mt)
	return res
end -- from http://snippets.luacode.org/snippets/Deep_copy_of_a_Lua_Table_2

function utf8(nbr)
	return string.uchar(nbr)
end

function test(arg)
	return arg and 1 or 0
end

function screenRefresh()
	return platform.window:invalidate()
end

function pww()
	return platform.window:width()
end

function pwh()
	return platform.window:height()
end

function drawPoint(gc, x, y)
	gc:fillRect(x, y, 1, 1)
end

function drawCircle(gc, x, y, diameter)
	gc:drawArc(x - diameter/2, y - diameter/2, diameter,diameter,0,360)
end

function drawCenteredString(gc, str)
	gc:drawString(str, .5*(pww() - gc:getStringWidth(str)), .5*pwh(), "middle")
end

function drawXCenteredString(gc, str, y)
	gc:drawString(str, .5*(pww() - gc:getStringWidth(str)), y, "top")
end

function setColor(gc,theColor)
	if type(theColor) == "string" then
		theColor = string.lower(theColor)
		if type(Color[theColor]) == "table" then gc:setColorRGB(unpack(Color[theColor])) end
	elseif type(theColor) == "table" then
		gc:setColorRGB(unpack(theColor))
	end
end

function verticalBar(gc,x)
	gc:fillRect(gc,x,0,1,pwh())
end

function horizontalBar(gc,y)
	gc:fillRect(gc,0,y,pww(),1)
end

function drawSquare(gc,x,y,l)
	gc:drawPolyLine(gc,{(x-l/2),(y-l/2), (x+l/2),(y-l/2), (x+l/2),(y+l/2), (x-l/2),(y+l/2), (x-l/2),(y-l/2)})
end

function drawRoundRect(gc,x,y,wd,ht,rd)  -- wd = width, ht = height, rd = radius of the rounded corner
	x = x-wd/2  -- let the center of the square be the origin (x coord)
	y = y-ht/2 -- same for y coord
	if rd > ht/2 then rd = ht/2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max rd)
	gc:drawLine(x + rd, y, x + wd - (rd), y);
	gc:drawArc(x + wd - (rd*2), y + ht - (rd*2), rd*2, rd*2, 270, 90);
	gc:drawLine(x + wd, y + rd, x + wd, y + ht - (rd));
	gc:drawArc(x + wd - (rd*2), y, rd*2, rd*2,0,90);
	gc:drawLine(x + wd - (rd), y + ht, x + rd, y + ht);
	gc:drawArc(x, y, rd*2, rd*2, 90, 90);
	gc:drawLine(x, y + ht - (rd), x, y + rd);
	gc:drawArc(x, y + ht - (rd*2), rd*2, rd*2, 180, 90);
end

function fillRoundRect(gc,x,y,wd,ht,radius)  -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
	if radius > ht/2 then radius = ht/2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    gc:fillPolygon({(x-wd/2),(y-ht/2+radius), (x+wd/2),(y-ht/2+radius), (x+wd/2),(y+ht/2-radius), (x-wd/2),(y+ht/2-radius), (x-wd/2),(y-ht/2+radius)})
    gc:fillPolygon({(x-wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y+ht/2), (x-wd/2+radius),(y+ht/2), (x-wd/2+radius),(y-ht/2)})
    x = x-wd/2  -- let the center of the square be the origin (x coord)
	y = y-ht/2 -- same
	gc:fillArc(x + wd - (radius*2), y + ht - (radius*2), radius*2, radius*2, 1, -91);
    gc:fillArc(x + wd - (radius*2), y, radius*2, radius*2,-2,91);
    gc:fillArc(x, y, radius*2, radius*2, 85, 95);
    gc:fillArc(x, y + ht - (radius*2), radius*2, radius*2, 180, 95);
end

function drawLinearGradient(color1,color2)
	-- syntax would be : color1 and color2 as {r,g,b}.
 	-- don't really know how to do that. probably converting to hue/saturation/light mode and change the hue.
 	-- todo with unpack(color1) and unpack(color2)
end

function bigText(gc)
	gc:setFont("serif","b",18)
end

function normalText(gc)
	gc:setFont("sansserif","r",12)
end

------------------------------------------------------------------
--                        Widget  Class                         --
------------------------------------------------------------------

Widget	=	class()

function Widget:init()
	self.dw	=	10
	self.dh	=	10
end


function Widget:size()
	self.rx	=	math.floor(Pr(self.xx, 0, self.parent.w)+.5)
	self.ry	=	math.floor(Pr(self.yy, 0, self.parent.h)+.5)
	self.x	=	self.parent.x + self.rx
	self.y	=	self.parent.y + self.ry
	
	self.w	=	math.floor(Pr(self.ww, self.dw, self.parent.w)+.5)
	self.h	=	math.floor(Pr(self.hh, self.dh, self.parent.h)+.5)
end

function Widget:prePaint()

end

function Widget:paint(gc) 
	--gc:drawRect(self.x, self.y, self.w, self.h)
end

function Widget:focus()
	if self.parent.focus~=0 then
		self.parent:getWidget().hasFocus	=	false
		self.parent:getWidget():loseFocus()
	end
	self.hasFocus	=	true
	self.parent.focus	=	self.pid
	self:getFocus()
end

function Widget:getFocus() end
function Widget:loseFocus() end
function Widget:arrowKey(key)end
function Widget:mouseDown(x, y) end
function Widget:mouseUp(x, y) end
function Widget:mouseMove(x, y) end
function Widget:enterKey() 	self.parent:switchFocus(1) end
function Widget:charIn() end
function Widget:escapeKey() end
function Widget:backspaceKey() end




------------------------------------------------------------------
--                          Box Widget                          --
------------------------------------------------------------------


box	=	class(Widget)

function box:init(ww,hh,t)
	self.dy	=	10
	self.dx	=	10
	self.ww	=	ww
	self.hh	=	hh
	self.t	=	t
end

function box:paint(gc)
	gc:setColorRGB(0,0,0)
	if self.hasFocus then
		gc:fillRect(self.x, self.y, self.w, self.h)
	else
		gc:drawRect(self.x, self.y, self.w, self.h)
	end
	gc:setColorRGB(128,128,128)
	if self.t then
		gc:drawString(self.t,self.x+2,self.y+2,"top")
	end
end


------------------------------------------------------------------
--                         List Widget                          --
------------------------------------------------------------------

sList	=	class(Widget)

function sList:init()
	self.dw	=	100
	self.dh	=	10
	
	self.items	=	{}
	self.sel	=	1
	self.font	=	{"sansserif", "r", 11}
	self.itemh	=	18
	self.hitems	=	4
	
	self.dh	=	4 * self.itemh + 1
	
	self.color1	=	{160,160,160} 
	self.color2	=	{200,200,200}
	self.scolor	=	{40,40,40}
	self.bgcolor	=	{240,240,245}
	self.textc	=	{0,0,0}
	self.texts	=	{220,220,220}
	
	self.shrink	=	false
	self.offset	=	0
end

function sList:prePaint(gc)
	self.hitems	=	math.floor((self.h-1)/self.itemh)
	local height	=	self.hitems*self.itemh+1
	self.he	=	self.h-height
	if self.shrink then
		self.h	=	height
	end
end

function sList:paint(gc)
	local x	=	self.x
	local y = 	self.y
	local n	=	#self.items
	
	gc:setColorRGB(unpack(self.bgcolor))
	gc:setFont(unpack(self.font))
	gc:fillRect(self.x, self.y, self.w, self.h)
	gc:setColorRGB(0,0,0)
	gc:drawRect(x, y, self.w, self.h)
	
	for i=1, math.min(n, self.hitems) do
		local color	= ((i+self.offset)%2==0) and self.color1 or self.color2
		
		if i + self.offset	==	self.sel and self.hasFocus then color = self.scolor end
		gc:setColorRGB(unpack(color))
		gc:fillRect(x+1, y + 1 + i*self.itemh-self.itemh , self.w-1, self.itemh)
		
		local tcolor	=	self.textc
		if i + self.offset	==	self.sel and self.hasFocus then tcolor = self.texts end		
		gc:setColorRGB(unpack(tcolor))
		gc:drawString(self.items[i+self.offset], x+1, y+1 + i*self.itemh-self.itemh*1.15, "top")
	end
	local i	=	math.min(n, self.hitems)+1
	local color	= ((i+self.offset)%2==0) and self.color1 or self.color2
	if n>self.hitems and not self.shrink then
		gc:setColorRGB(unpack(color))
		gc:fillRect(x+1, y + 1 + i*self.itemh-self.itemh , self.w-1, self.he)
	end
	
	gc:setColorRGB(0,0,0)
	local selp	=	math.max(n/self.hitems,1)
	gc:fillRect(x+self.w+2, 2 + y + (self.offset*self.itemh)/selp, 3, (self.hitems*18)/selp)
end

function sList:arrowKey(arrow)
	if #self.items==0 then return end
	
	if arrow	==	"up" and self.sel>1 then
		self.sel	=	self.sel - 1
		if self.offset==self.sel then
			self.offset	=	self.offset - 1
		end
		
	elseif arrow	==	"down" and self.sel<#self.items then
		self.sel	=	self.sel + 1
		if self.offset + self.hitems < self.sel then
			self.offset	=	self.offset + 1
		end
	end
	
end

function sList:mouseUp(xx, yy)
	if xx>=self.x and yy>=self.y and xx<self.x+self.w and yy<self.y+self.h then
		self.sel	=	self.offset + math.ceil((yy-self.y)/self.itemh)
		if self.sel>#self.items then self.sel=#self.items end
	end
end




------------------------------------------------------------------
--                         Input Widget                         --
------------------------------------------------------------------


sInput	=	class(Widget)

function sInput:init()
	self.dw	=	100
	self.dh	=	20
	
	self.value	=	""	
	self.bgcolor	=	{255,255,255}
end

function sInput:paint(gc)
	self.gc	=	gc
	local x	=	self.x
	local y = 	self.y
	
	gc:setColorRGB(unpack(self.bgcolor))
	gc:fillRect(x, y, self.w, self.h)

	gc:setColorRGB(0,0,0)
	gc:drawRect(x, y, self.w, self.h)
	if self.hasFocus then
		gc:drawRect(x-1, y-1, self.w+2, self.h+2)
	end
		
	local text	=	""
	local	p	=	0
	
	while true do
		if p==#self.value then break end
		p	=	p + 1
		text	=	self.value:sub(-p, -p) .. text
		if gc:getStringWidth(text) > (self.w - 8) then
			text	=	text:sub(2,-1)
			break 
		end
	end
	
	if text==self.value then
		gc:drawString(text, x+2, y-2, "top")
	else
		gc:drawString(text, x-4+self.w-gc:getStringWidth(text), y-2, "top")
	end
	if self.hasFocus then
		gc:fillRect(self.x+(text==self.value and gc:getStringWidth(text)+2 or self.w-4), self.y, 1, self.h)
	end
	
end

function sInput:charIn(char)
	if self.number and not tonumber(self.value .. char) then
		return
	end
	self.value	=	self.value .. char
end

function sInput:backspaceKey()
	self.value	=	self.value:usub(1,-2)
end

--Label

sLabel	=	class(Widget)

function sLabel:init(text, widget)
	self.widget	=	widget
	self.text	=	text
	self.dw		=	30
	self.dh		=	20
	self.lim	=	false
	self.color	=	{0,0,0}
	self.font	=	{"sansserif", "r", 11}
	self.p		=	"top"
	
end

function sLabel:paint(gc)
	local text	=	""
	local ttext
	if self.lim then
		if gc:getStringWidth(self.text)<self.w then
			self.dw	= gc:getStringWidth(self.text)
			text = self.text
		else
			for i=1, #self.text do
				ttext	=	self.text:sub(1,i)
				if gc:getStringWidth(ttext .. "..")>self.w then
					break
				end
				text = ttext
			end
			text = text .. ".."
		end
	else
		text = self.text
	end
	
	gc:setFont(unpack(self.font))
	gc:setColorRGB(unpack(self.color))
	gc:drawString(text, self.x, self.y-2, self.p)
end

function sLabel:getFocus()
	if self.widget then
		self.widget:focus()
	end
end


--Button widget

sButton	=	class(Widget)

function sButton:init(text, action)
	self.text	=	text
	self.action	=	action
	
	self.dh	=	27
	self.dw	=	48
	
	self.bordercolor	=	{136,136,136}
	
end

function sButton:paint(gc)
	
	self.w	=	gc:getStringWidth(self.text)+8
	gc:setColorRGB(248,252,248)
	gc:fillRect(self.x+2, self.y+2, self.w-4, self.h-4)
	gc:setColorRGB(0,0,0)
	
	gc:drawString(self.text, self.x+4, self.y+2, "top")
		
	gc:setColorRGB(unpack(self.bordercolor))
	gc:fillRect(self.x + 2, self.y, self.w-4, 2)
	gc:fillRect(self.x + 2, self.y+self.h-2, self.w-4, 2)
	
	gc:fillRect(self.x, self.y+2, 1, self.h-4)
	gc:fillRect(self.x+1, self.y+1, 1, self.h-2)
	gc:fillRect(self.x+self.w-1, self.y+2, 1, self.h-4)
	gc:fillRect(self.x+self.w-2, self.y+1, 1, self.h-2)
	
	if self.hasFocus then
		gc:setColorRGB(40, 148, 184)
		gc:drawRect(self.x-2, self.y-2, self.w+3, self.h+3)
		gc:drawRect(self.x-3, self.y-3, self.w+5, self.h+5)
	end
end

function sButton:enterKey()
	if self.action then self.action() end
end

sButton.mouseUp	=	sButton.enterKey




--------------------
---Screen Manager---
----- By Levak -----
--- with changes ---
--------------------

function Pr(n, d, s)
	return (type(n)=="number" and n or (type(n)=="string" and .01*s*n or d))
end


Screen	=	class()

Screens	=	{}

function push_screen(screen)
	table.insert(Screens, screen)
	platform.window:invalidate()
	current_screen():pushed()
end

function remove_screen(screen)
	platform.window:invalidate()
	return table.remove(Screens)
end

function current_screen()
	return Screens[#Screens]
end

function Screen:init(xx,yy,ww,hh)
	self.yy	=	yy
	self.xx	=	xx
	self.hh	=	hh
	self.ww	=	ww
	
	self:size()
	
	self.widgets	=	{}
	self.focus	=	0
end

function Screen:size()
	local screenH	=	platform.window:height()
	local screenW	=	platform.window:width()

	self.x	=	math.floor(Pr(self.xx, 0, screenW)+.5)
	self.y	=	math.floor(Pr(self.yy, 0, screenH)+.5)
	self.w	=	math.floor(Pr(self.ww, screenW, screenW)+.5)
	self.h	=	math.floor(Pr(self.hh, screenH, screenH)+.5)
end

function Screen:drawWidgets(gc) 
	for _, widget in pairs(self.widgets) do
		widget:size()
		widget:prePaint()
		widget:paint(gc)
		
		gc:setColorRGB(0,0,0)
	end
end

function Screen:pushed() end

function Screen:appendWidget(widget, xx, yy) 
	widget.xx	=	xx
	widget.yy	=	yy
	widget.parent	=	self
	widget:size()
	
	table.insert(self.widgets, widget)
	widget.pid	=	#self.widgets
end

function Screen:getWidget()
	return self.widgets[self.focus]
end

function Screen:draw(gc)
	self:size()
	self:paint(gc)
	self:drawWidgets(gc)
end

function Screen:switchFocus(n)
	if n~=0 or #self.widgets>0 then
		if self.focus~=0 then
			self:getWidget().hasFocus	=	false
			self:getWidget():loseFocus()
		end
		
		self.focus	=	self.focus + n
		if self.focus>#self.widgets then
			self.focus	=	1
		elseif self.focus<1 then
			self.focus	=	#self.widgets
		end	
		self:getWidget().hasFocus	=	true	
		self:getWidget():getFocus()
	end
end

function Screen:paint(gc)
	-- will be overriden
end

function Screen:invalidate()
	platform.window:invalidate(self.x ,self.y , self.w, self.h)
end

function Screen:timer()		end

function Screen:arrowKey(arrow)	
	if self.focus~=0 then
		self:getWidget():arrowKey(arrow)
	end
	self:invalidate()
end
function Screen:arrowUp()	
	if self.focus~=0 then
		self:getWidget():arrowKey("up")
	end
	self:invalidate()
end

function Screen:arrowDown()	
	if self.focus~=0 then
		self:getWidget():arrowKey("down")
	end
	self:invalidate()
end

function Screen:arrowLeft()	
	self:invalidate()
end

function Screen:arrowRight()	
	self:invalidate()
end

function Screen:enterKey()	
	if self.focus~=0 then
		self:getWidget():enterKey()
	end
	self:invalidate()
end

function Screen:backspaceKey()
	if self.focus~=0 then
		self:getWidget():backspaceKey()
	end
	self:invalidate()
end

function Screen:escapeKey()	
	if self.focus~=0 then
		self:getWidget():escapeKey()
	end
	self:invalidate()
end

function Screen:tabKey()	
	self:switchFocus(1)
	self:invalidate()
end

function Screen:backtabKey()	
	self:switchFocus(-1)
	self:invalidate()
end

function Screen:charIn(char)
	if self.focus~=0 then
		self:getWidget():charIn(char)
	end
	self:invalidate()
end

function Screen:getWidgetIn(x, y)
	for n, widget in pairs(self.widgets) do
		if x>=widget.x and y>=widget.y and x<widget.x+widget.w and y<widget.y+widget.h then
			return n, widget
		end
	end 
end

function Screen:mouseDown(x, y) 
	local n, widget	=	self:getWidgetIn(x, y)
	if n then
		if self.focus~=0 then self:getWidget().hasFocus = false self:getWidget():loseFocus()  end
		self.focus	=	n
		
		widget.hasFocus	=	true
		widget:getFocus()

		widget:mouseDown(x, y)
	else
		if self.focus~=0 then self:getWidget().hasFocus = false self:getWidget():loseFocus()  end
		self.focus	=	0
	end
end
function Screen:mouseUp(x, y)
	if self.focus~=0 then
		self:getWidget():mouseUp(x, y)
	end
	self:invalidate()
end
function Screen:mouseMove(x, y)
	if self.focus~=0 then
		self:getWidget():mouseMove(x, y)
	end
end


--Dialog screen

Dialog	=	class(Screen)

function Dialog:init(title,xx,yy,ww,hh)
	self.yy	=	yy
	self.xx	=	xx
	self.hh	=	hh
	self.ww	=	ww
	self.title	=	title
	self:size()
	
	self.widgets	=	{}
	self.focus	=	0
end

function Dialog:paint(gc)
	gc:setColorRGB(224,224,224)
	gc:fillRect(self.x, self.y, self.w, self.h)

	for i=1, 14,2 do
		gc:setColorRGB(32+i*3, 32+i*4, 32+i*3)
		gc:fillRect(self.x, self.y+i, self.w,2)
	end
	gc:setColorRGB(32+16*3, 32+16*4, 32+16*3)
	gc:fillRect(self.x, self.y+15, self.w, 10)
	
	gc:setColorRGB(128,128,128)
	gc:drawRect(self.x, self.y, self.w, self.h)
	gc:drawRect(self.x-1, self.y-1, self.w+2, self.h+2)
	
	gc:setColorRGB(96,100,96)
	gc:fillRect(self.x+self.w+1, self.y, 1, self.h+2)
	gc:fillRect(self.x, self.y+self.h+2, self.w+3, 1)
	
	gc:setColorRGB(104,108,104)
	gc:fillRect(self.x+self.w+2, self.y+1, 1, self.h+2)
	gc:fillRect(self.x+1, self.y+self.h+3, self.w+3, 1)
	gc:fillRect(self.x+self.w+3, self.y+2, 1, self.h+2)
	gc:fillRect(self.x+2, self.y+self.h+4, self.w+2, 1)
			
	gc:setColorRGB(255,255,255)
	gc:drawString(self.title, self.x + 4, self.y+2, "top")
end


function on.timer()			current_screen():timer()		 end
function on.arrowRight()	current_screen():arrowRight()	 end
function on.arrowUp()		current_screen():arrowUp() 		 end
function on.arrowDown()		current_screen():arrowDown()	 end
function on.arrowLeft()		current_screen():arrowLeft() 	 end
function on.arrowKey(arrw)	current_screen():arrowKey(arrw)  end
function on.enterKey()		current_screen():enterKey()		 end
function on.escapeKey()		current_screen():escapeKey()	 end
function on.tabKey()		current_screen():tabKey()		 end
function on.backtabKey()	current_screen():backtabKey()	 end
function on.charIn(ch)		current_screen():charIn(ch)		 end
function on.backspaceKey()	current_screen():backspaceKey()  end
function on.mouseDown(x,y)	pcall(function() current_screen():mouseDown(x,y) end)	 end
function on.mouseUp(x,y)	pcall(function() current_screen():mouseUp(x,y) end)	 end
function on.mouseMove(x,y)	pcall(function() current_screen():mouseMove(x,y) end)  end


-----------------
-----GLOBALS:----
-----------------

Ground = class()
Tank = class()
Weapon = class()


-----------------
-----GROUND:-----
-----------------

function Ground:init(groundType)
	self.groundType = groundType
end

function Ground:paint(gc)
    gc:setColorRGB(180,180,180)
	gc:fillRect(0,.5*pwh(),pww(),.5*pwh()) --debug, todo depending on groundType.
	gc:setColorRGB(0,0,0)
end

-----------------
------TANK:------
-----------------

function Tank:init(x, y, team)
	self.x = x
	self.y = y
	self.w = 12
	self.h = 8
	self.id = #Tanks
	self.team = team
	self.playing = false -- will get changed
	self.cannonAngle = 360-45 -- from 0 to 359
	self.cannonPower = 50 -- from 0 to 100
end

function Tank:paint(gc)
	gc:fillRect(self.x, self.y, self.w, self.h)
	gc:setColorRGB(255,0,0)
	gc:drawLine(self.x+.5*self.w, self.y+.5*self.h, self.x+.5*self.w+14*math.cos(self.cannonAngle*3.14159/180), self.y+.5*self.h+14*math.sin(self.cannonAngle*3.14159/180))
	gc:setColorRGB(0,0,0)
	if self.playing then
		gc:drawString("*", self.x, self.y-20, "top")
	end
end

-----------------
-----WEAPON:-----
-----------------

function Weapon:init(fromTank)
	self.fromTank = fromTank
	self.initX = fromTank.x
	self.initY = fromTank.y
end

function Weapon:paint(gc)
	
end




-----------------------
------GameScreen:------
-----------------------

GameScreen = Screen()

function GameScreen:paint(gc)
    Ground:paint(gc)
	for _, tank in pairs(Tanks) do
	    tank:paint(gc)
	end	
	gc:setColorRGB(255,255,255)
	gc:drawString(Tanks[CurrentPlayer].team .. "'s turn", 1, pwh()-21, "top")
	tmpStr = "Power : " .. Tanks[CurrentPlayer].cannonPower .. " / Angle : " .. Tanks[CurrentPlayer].cannonAngle
	gc:drawString(tmpStr, pww()-gc:getStringWidth(tmpStr)-2, pwh()-21, "top")
	gc:setColorRGB(0,0,0)
end

function GameScreen:arrowUp()
    print("arrowUp : Power+")
    Tanks[CurrentPlayer].cannonPower = Tanks[CurrentPlayer].cannonPower < 100 and Tanks[CurrentPlayer].cannonPower + 1 or Tanks[CurrentPlayer].cannonPower
end

function GameScreen:arrowDown()
    print("arrowDown : Power-")
    Tanks[CurrentPlayer].cannonPower = Tanks[CurrentPlayer].cannonPower > 1 and Tanks[CurrentPlayer].cannonPower - 1 or Tanks[CurrentPlayer].cannonPower
end

function GameScreen:arrowRight()
    print("arrowRight : Angle+")
    Tanks[CurrentPlayer].cannonAngle = Tanks[CurrentPlayer].cannonAngle <= 360 and Tanks[CurrentPlayer].cannonAngle + 5 or 0
    if Tanks[CurrentPlayer].cannonAngle >= 360 then Tanks[CurrentPlayer].cannonAngle = 0 end 
end

function GameScreen:arrowLeft()
    print("arrowLeft : Angle-")
    Tanks[CurrentPlayer].cannonAngle = Tanks[CurrentPlayer].cannonAngle >= 0 and Tanks[CurrentPlayer].cannonAngle - 5 or 360
	if Tanks[CurrentPlayer].cannonAngle < 0 then Tanks[CurrentPlayer].cannonAngle = 355 end 
end

function GameScreen:charIn(ch)
	if ch == "7" then
		Tanks[CurrentPlayer].x = Tanks[CurrentPlayer].x > 0 and Tanks[CurrentPlayer].x - 10 or Tanks[CurrentPlayer].x
	elseif ch == "9" then
		Tanks[CurrentPlayer].x = Tanks[CurrentPlayer].x < pww() and Tanks[CurrentPlayer].x + 10 or Tanks[CurrentPlayer].x
	end
    print(ch)
    platform.window:invalidate()
end

function GameScreen:escapeKey()
    remove_screen(current_screen())
    push_screen(Menu)
end

function GameScreen:enterKey()
	print("enterKey pressed while in game : shooooooot ! then call next_turn() ")
	next_turn()
end

function next_turn()
    Tanks[CurrentPlayer].playing = false
    CurrentPlayer = CurrentPlayer==2 and 1 or 2
    print("Current player is now " .. CurrentPlayer)
    Tanks[CurrentPlayer].playing = true
    return Tanks[CurrentPlayer]
end

-----------------
------MENU:------
-----------------

Menu = Screen()

function Menu:paint(gc)
	bigText(gc)
	drawXCenteredString(gc,"Obliterate Nspire",8)
	normalText(gc)
end

function Menu:arrowUp() Menu:backtabKey() end
function Menu:arrowDown() Menu:tabKey() end


playButton	=	sButton(" Play ! ", function () print("User wanna play the game") startGame() end)
Menu:appendWidget(playButton, "41.5", "30")
playButton:focus()

statsButton	=	sButton(" Stats ", function () print("User wanna see the stats") end)
Menu:appendWidget(statsButton, "42", "50")

helpButton	=	sButton(" Help ", function () print("User wanna get help") end)
Menu:appendWidget(helpButton, "42.5", "70")

------------------------------------------------------------------
--                   Bindings to the on events                  --
------------------------------------------------------------------

function on.paint(gc)
	for k, screen in pairs(Screens) do
	    screen:draw(gc)
	end	
end

function on.resize(x, y)
	-- Global Ratio Constants for On-Calc (shouldn't be used often though...)
	kXRatio = x/318
	kYRatio = y/212
	platform.window:invalidate()  -- redraw everything
end


-----------------
----FUNCTIONS----
-----------------

function startGame()
    print("Starting game...")
    remove_screen(Menu)

    tank1 = Tank(.1*pww(),98*kYRatio,"Team 1") -- hardcoded coords
    tank1.playing = true
    tank2 = Tank(.9*pww(),98*kYRatio,"Team 2")
    table.insert(Tanks,1,tank1)
    table.insert(Tanks,2,tank2)
    
	push_screen(GameScreen)
end


-----------------
-----Start !-----
-----------------

push_screen(Menu)
