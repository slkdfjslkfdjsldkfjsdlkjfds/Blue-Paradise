local searchstring = ""
local englishes = {
	"?",
	"-",
	".",
	",",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	";"
}
local frameX = 300
local frameY = 300
local active = false
local whee
local searchtitle = ""
local searchdesc = ""
local searchingame = true
local searchpassword = true
local searchopen = true
local inputchar = ""
local backspace = false
local changed = false
local inputting = 0
local CtrlPressed = false

local offsetX = -10
local offsetY = 20
local frameWidth = 400
local frameHeight = 350

local function searchInput(event)
	if event.type ~= "InputEventType_Release" and active then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			inputting = 0
			MESSAGEMAN:Broadcast("UpdateString")
		elseif event.DeviceInput.button == "DeviceButton_right mouse button" then
			inputting = 0
			MESSAGEMAN:Broadcast("UpdateString")
		end
	end
	if event.type ~= "InputEventType_Release" and active == true and inputting ~= 0 then
		if event.button == "Back" then
			searchtitle = ""
			searchdesc = ""
			searchingame = true
			searchpassword = true
			searchopen = true
			whee:Search(searchtitle, searchdesc, searchingame, searchpassword, searchopen)
			whee:StopSearch()
			local tind = getTabIndex()
			resetTabIndex(0)
			MESSAGEMAN:Broadcast("TabChanged", {from = tind, to = 0})
			MESSAGEMAN:Broadcast("EndingSearch")
		elseif event.button == "Start" then
			inputting = 0
			MESSAGEMAN:Broadcast("UpdateString")
		elseif event.DeviceInput.button == "DeviceButton_space" then -- add space to the string
			inputchar = " " -- remove the last element of the string
		elseif event.DeviceInput.button == "DeviceButton_delete" then
			inputchar = ""
		elseif event.DeviceInput.button == "DeviceButton_=" then
			inputchar = "="
		elseif event.DeviceInput.button == "DeviceButton_backspace" then
			backspace = true
			inputchar = searchstring:sub(1, -2)
		elseif event.DeviceInput.button == "DeviceButton_v" and CtrlPressed then
			inputchar = Arch.getClipboard()
		else
			for i = 1, #englishes do -- add standard characters to string
				if event.DeviceInput.button == "DeviceButton_" .. englishes[i] then
					inputchar = englishes[i]
				end
			end
		end
		if inputting == 1 then
			if backspace then
				backspace = false
				searchtitle = searchtitle:sub(1, -2)
			else
				searchtitle = searchtitle .. inputchar
				inputchar = ""
			end
			changed = true
		elseif inputting == 2 then
			if backspace then
				backspace = false
				searchdesc = searchdesc:sub(1, -2)
			else
				searchdesc = searchdesc .. inputchar
				inputchar = ""
			end
			changed = true
		end
		if changed == true then
			changed = false
			MESSAGEMAN:Broadcast("UpdateString")
			whee:Search(searchtitle, searchdesc, searchingame, searchpassword, searchopen)
		end
	end
	if event.DeviceInput.button == "DeviceButton_right ctrl" or event.DeviceInput.button == "DeviceButton_left ctrl" then
		if event.type == "InputEventType_Release" then
			CtrlPressed = false
		else
			CtrlPressed = true
		end
	end
end

local translated_info = {
	Title = THEME:GetString("TabSearch", "RoomTitle"),
	Subtitle = THEME:GetString("TabSearch", "RoomSubtitle"),
	Opened = THEME:GetString("TabSearch", "RoomOpened"),
	Passworded = THEME:GetString("TabSearch", "RoomPassworded"),
	InGameplay = THEME:GetString("TabSearch", "RoomInGameplay"),
	TabTitle = THEME:GetString("TabSearch", "Title"),
	Explanation = THEME:GetString("TabSearch", "ExplainLimitation")
}

local function ButtonActive(self)
	return isOver(self) and update
end

local t = Def.ActorFrame {
	InitCommand = function(self)
		self:zoom(0.9)
	end,
	BeginCommand = function(self)
		whee = SCREENMAN:GetTopScreen():GetMusicWheel()
		SCREENMAN:GetTopScreen():AddInputCallback(searchInput)
		self:finishtweening()
		if NSMAN:IsETTP() then
			self:visible(true)
			active = true
			whee:Move(0)
			MESSAGEMAN:Broadcast("BeginningSearch")
			MESSAGEMAN:Broadcast("RefreshSearchResults")
		else
			self:visible(false)
		end
		self:queuecommand("Set")
	end,
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(500, 0):diffusealpha(0)
		self:sleep(0.04):queuecommand("Invis")
	end,
	InvisCommand= function(self)
		self:visible(false)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
	end,
	SetCommand = function(self)
		self:finishtweening()
		if getTabIndex() == (NSMAN:IsETTP() and 0 or 1) then
			MESSAGEMAN:Broadcast("BeginningSearch")
			self:visible(true)
			self:queuecommand("On")
			active = true
			whee:Move(0)
			MESSAGEMAN:Broadcast("RefreshSearchResults")
		else
			self:queuecommand("Off")
			active = false
		end
	end,
	TabChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	Def.Quad {
		SetCommand = function(self)
			self:xy(frameX, 45):zoomto(frameWidth, frameHeight):halign(0):valign(0):diffuse(getMainColor("tabs"))
		end
	},
	Def.Quad {
		SetCommand = function(self)
			self:xy(frameX, 45):zoomto(frameWidth, offsetY):halign(0):valign(0):diffuse(getMainColor("frames")):diffusealpha(0.5)
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 20, frameY - 200):zoom(0.4):halign(0)
			self:settextf("%s: ", translated_info["Title"])
		end
	},
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:xy(frameX + 225, frameY - 200):zoomto(300, 25):diffuse(getMainColor("frames")):diffusealpha(0.55)
		end,
		SetCommand = function(self)
			if 1 == inputting then
				self:diffuse(color("#FFFFFF66"))
			else
				self:diffuse(getMainColor("frames")):diffusealpha(0.55)
			end
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and active then
				inputting = 1
				MESSAGEMAN:Broadcast("UpdateString")
			end
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 20, frameY - 150):zoom(0.4):halign(0)
			self:settextf("%s: ", translated_info["Subtitle"])
		end
	},
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:xy(frameX + 225, frameY - 150):zoomto(300, 25):diffuse(getMainColor("frames")):diffusealpha(0.55)
		end,
		SetCommand = function(self)
			if 2 == inputting then
				self:diffuse(color("#FFFFFF66"))
			else
				self:diffuse(getMainColor("frames")):diffusealpha(0.55)
			end
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and active then
				inputting = 2
				MESSAGEMAN:Broadcast("UpdateString")
			end
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 225, frameY - 202):zoom(0.4):maxwidth(700)
		end,
		SetCommand = function(self)
			self:settext(searchtitle)
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 225, frameY - 152):zoom(0.4):maxwidth(700)
		end,
		SetCommand = function(self)
			self:settext(searchdesc)
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 20, frameY - 50):zoom(0.4):halign(0)
			self:settext(translated_info["Opened"])
		end
	},
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:xy(frameX + 50, frameY):zoomto(25, 25):diffuse(getMainColor("positive")):diffusealpha(0.35)
		end,
		SetCommand = function(self)
			if searchingame then
				self:diffuse(getMainColor("positive"))
			else
				self:diffuse(getMainColor("negative"))
			end
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and active then
				searchingame = not searchingame
				MESSAGEMAN:Broadcast("UpdateString")
				whee:Search(searchtitle, searchdesc, searchingame, searchpassword, searchopen)
			end
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + frameWidth / 2 - 50, frameY - 50):zoom(0.4):halign(0)
			self:settext(translated_info["Passworded"])
		end
	},
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:xy(frameX + frameWidth / 2 - 12, frameY):zoomto(25, 25):diffuse(getMainColor("positive")):diffusealpha(0.35)
		end,
		SetCommand = function(self)
			if searchpassword then
				self:diffuse(getMainColor("positive"))
			else
				self:diffuse(getMainColor("negative"))
			end
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and active then
				searchpassword = not searchpassword
				MESSAGEMAN:Broadcast("UpdateString")
				whee:Search(searchtitle, searchdesc, searchingame, searchpassword, searchopen)
			end
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + frameWidth - 100, frameY - 50):zoom(0.4):halign(0)
			self:settext(translated_info["InGameplay"])
		end
	},
	UIElements.QuadButton(1, 1) .. {
		InitCommand = function(self)
			self:xy(frameX + frameWidth - 80, frameY):zoomto(25, 25):diffuse(getMainColor("positive")):diffusealpha(0.35)
		end,
		SetCommand = function(self)
			if searchopen then
				self:diffuse(getMainColor("positive"))
			else
				self:diffuse(getMainColor("negative"))
			end
		end,
		UpdateStringMessageCommand = function(self)
			self:queuecommand("Set")
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and active then
				searchopen = not searchopen
				MESSAGEMAN:Broadcast("UpdateString")
				whee:Search(searchtitle, searchdesc, searchingame, searchpassword, searchopen)
			end
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 20, frameY + 70):zoom(0.5):halign(0)
			self:settext(translated_info["Explanation"])
		end,
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 5, offsetY + 34):zoom(0.65):halign(0)
			self:settext(translated_info["TabTitle"])
			self:diffuse(Saturation(getMainColor("positive"), 0.1))
		end
	}
}

return t
