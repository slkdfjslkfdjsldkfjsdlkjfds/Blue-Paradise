local t = Def.ActorFrame {}
local topFrameHeight = 35
local bottomFrameHeight = 50
local borderWidth = 0

--Frames
t[#t + 1] = UIElements.QuadButton(1, 1) .. {
	InitCommand = function(self)
		--self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, topFrameHeight):diffuse(getMainColor("frames"))
		self:Load("/Themes/Blue Paradise/Graphics/border_top.png")
		self:scaletocover(0, 0, SCREEN_WIDTH, topFrameHeight)
		self:valign(1)
		self:xy(SCREEN_CENTER_X, topFrameHeight)
	end
}

t[#t + 1] = UIElements.QuadButton(1, 1) .. {
	InitCommand = function(self)
		--self:xy(0, SCREEN_HEIGHT):halign(0):valign(1):zoomto(SCREEN_WIDTH, bottomFrameHeight):diffuse(getMainColor("frames"))
		self:Load("/Themes/Blue Paradise/Graphics/border_bottom.png")
		self:scaletocover(0, 0, SCREEN_WIDTH, bottomFrameHeight)
		self:valign(0)
		self:xy(SCREEN_CENTER_X, SCREEN_HEIGHT-bottomFrameHeight)
	end
}

t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(0, SCREEN_HEIGHT - bottomFrameHeight):halign(0):valign(0):zoomto(SCREEN_WIDTH, borderWidth):diffuse(
			getMainColor("highlight")
		):diffusealpha(0.5)
	end
}

--[[
if themeConfig:get_data().global.TipType == 2 or themeConfig:get_data().global.TipType == 3 then
	t[#t + 1] =
		LoadFont("Common Normal") ..
		{
			InitCommand = function(self)
				self:xy(SCREEN_CENTER_X, SCREEN_BOTTOM - 7):zoom(0.35):settext(
					getRandomQuotes(themeConfig:get_data().global.TipType)
				):diffuse(getMainColor("highlight")):diffusealpha(0):zoomy(0):maxwidth((SCREEN_WIDTH - 350) / 0.35)
			end,
			BeginCommand = function(self)
				self:sleep(2)
				self:smooth(1)
				self:diffusealpha(1)
				self:zoomy(0.35)
			end
		}
end
]]

return t
