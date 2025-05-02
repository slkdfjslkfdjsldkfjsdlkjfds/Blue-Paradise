if IsSMOnlineLoggedIn() then
	CloseConnection()
end

local t = Def.ActorFrame {}

local frameX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX") - 10
local frameY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")

--Fucking Background
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(1000, 900):diffuse(getTitleColor('BG_Right')):diffusealpha(1)
	end
}

--[[
--Right gray rectangle(not being used rn)
t[#t + 1] =	Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(1000, 900):diffuse(getTitleColor('BG_Right')):diffusealpha(1)
	end
}
--]]

--Dark gray triangle
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(240, 480):halign(0):valign(0):zoomto(170, 900):rotationz(135):diffuse(getTitleColor('Line_Right')):diffusealpha(1)
	end
}

--Light gray triangle
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(capWideScale(420, 650), 0):halign(0.9):valign(0.90):zoomto(capWideScale(170, 700), 900):rotationz(135):diffuse(getTitleColor('Line_Left')):diffusealpha(1)
		
	end
}

--character on screen
t[#t + 1] = Def.Sprite{
		Texture=THEME:GetPathG("","oc");
		InitCommand=function(self)
		self:xy((capWideScale(get43size(500),480)), 230):halign(0):valign(0):zoomto(250, 250):diffusealpha(1)
		end
}

local playingMusic = {}
local playingMusicCounter = 1
--Title text
t[#t + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	InitCommand=function(self)
		--self:xy(125,frameY-82):zoom(0.7):align(0.5,1)
		self:xy(SCREEN_CENTER_X,frameY-182):zoom(0.7)
		self:diffusetopedge(Saturation(getMainColor("highlight"), 0.5))
		self:diffusebottomedge(Saturation(getMainColor("positive"), 0.8))
	end,
	OnCommand=function(self)
		self:settext("Etterna")
	end,
}

--Theme text
t[#t + 1] = LoadFont("Common Large") .. {
	InitCommand=function(self)
		--self:xy(125,frameY-52):zoom(0.325):align(0.5,1)
		self:xy(SCREEN_CENTER_X,frameY-152):zoom(0.325)
		self:diffusetopedge(Saturation(getMainColor("highlight"), 0.5))
		self:diffusebottomedge(Saturation(getMainColor("positive"), 0.8))
	end,
	OnCommand=function(self)
		self:settext(getThemeName())
	end
}

--Version number
t[#t + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	Name = "Version",
	InitCommand=function(self)
		--self:xy(125,frameY-35):zoom(0.25):align(0.5,1)
		self:xy(SCREEN_CENTER_X,frameY-135):zoom(0.25)
		self:diffusetopedge(Saturation(getMainColor("highlight"), 0.5))
		self:diffusebottomedge(Saturation(getMainColor("positive"), 0.8))
	end,
	BeginCommand = function(self)
		self:settext(GAMESTATE:GetEtternaVersion())
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" then
			DLMAN:ShowProjectReleases()
		end
	end
}

--game update button
local gameneedsupdating = false
local buttons = {x = 20, y = 20, width = 142, height = 42, fontScale = 0.35, color = getMainColor("frames")}
t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(buttons.x,buttons.y)
	end,
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:zoomto(buttons.width, buttons.height):halign(0):valign(0):diffuse(buttons.color):diffusealpha(0)
			self:playcommand("LastVersionUpdated")
		end,
		LastVersionUpdatedMessageCommand = function(self)
			local latest = tonumber((DLMAN:GetLastVersion():gsub("[.]", "", 1)))
			local current = tonumber((GAMESTATE:GetEtternaVersion():gsub("[.]", "", 1)))
			if latest and latest > current then
				gameneedsupdating = true
			end
			self:playcommand("On")
		end,
		OnCommand = function(self)
			if gameneedsupdating then
				self:diffusealpha(0.3)
			end
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and gameneedsupdating then
				DLMAN:ShowProjectReleases()
			end
		end
	},
	LoadFont("Common Large") .. {
		OnCommand = function(self)
			self:xy(1.7, 1):align(0,0):zoom(buttons.fontScale):diffuse(getMainColor("positive"))
			if gameneedsupdating then
				self:settext(THEME:GetString("ScreenTitleMenu", "UpdateAvailable"))
			else
				self:settext("")
			end
		end
	}
}

local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

local transformF = THEME:GetMetric("ScreenTitleMenu", "ScrollerTransform")
local scrollerX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX")
local scrollerY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")
local scrollerChoices = THEME:GetMetric("ScreenTitleMenu", "ChoiceNames")
local _, count = string.gsub(scrollerChoices, "%,", "")
local choices = mysplit(scrollerChoices, ",")
local choiceCount = count + 1
local i
for i = 1, choiceCount do
	t[#t + 1] = UIElements.QuadButton(1, 1) .. {
		OnCommand = function(self)
			self:xy(scrollerX, scrollerY):zoomto(260, 16)
			transformF(self, 0, i, choiceCount)
			self:addx(SCREEN_CENTER_X - 20)
			self:addy(SCREEN_CENTER_Y + 18)
			self:diffusealpha(0)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				SCREENMAN:GetTopScreen():playcommand("MadeChoicePlayer_1")
				SCREENMAN:GetTopScreen():playcommand("Choose")
				if choices[i] == "Multi" or choices[i] == "GameStart" then
					GAMESTATE:JoinPlayer()
				end
				GAMESTATE:ApplyGameCommand(THEME:GetMetric("ScreenTitleMenu", "Choice" .. choices[i]))
			end
		end
	}
end

return t
