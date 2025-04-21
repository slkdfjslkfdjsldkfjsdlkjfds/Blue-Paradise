local t = Def.ActorFrame {}
local topFrameHeight = 35
local bottomFrameHeight = 50
local borderWidth = 0

--Frames
if SameColor(getMainColor("highlight"),color("#64ddff")) then
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameTop")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 0):valign(0):zoom(1)
			end
		}
else
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameGreyTop")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 0):valign(0):zoom(1)
				self:diffuse(ColorMultiplier(getMainColor("positive"),1.5))
			end
		}
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameGreyTop")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 0):valign(0):zoom(1)
				self:diffuse(ColorMultiplier(getMainColor("positive"),0.75))
				self:diffusealpha(0.2):blend(Blend.Add)
			end
		}
end

if SameColor(getMainColor("highlight"),color("#64ddff")) then
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameBottom")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 430):valign(0):zoom(1)
			end
		}
else
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameGreyBottom")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 430):valign(0):zoom(1)
				self:diffuse(ColorMultiplier(getMainColor("positive"),1.5))
			end
		}
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_FrameGreyBottom")) ..
		{
			OnCommand = function(self)
				self:xy(SCREEN_CENTER_X, 430):valign(0):zoom(1)
				self:diffuse(ColorMultiplier(getMainColor("positive"),0.75))
				self:diffusealpha(0.2):blend(Blend.Add)
			end
		}
end

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
