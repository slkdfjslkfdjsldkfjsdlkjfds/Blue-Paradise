local hoverAlpha = 0.6

local update = false
local clickedForSinglePlaylist = false
local t = Def.ActorFrame {
	BeginCommand = function(self)
		self:queuecommand("Set"):visible(false)
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
		if getTabIndex() == 7 then
			self:queuecommand("On")
			self:visible(true)
			update = true
		else
			self:queuecommand("Off")
			update = false
		end
		MESSAGEMAN:Broadcast("DisplayAllPlaylists")
	end,
	TabChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end
}

local frameX = 270
local frameY = 45
local frameWidth = capWideScale(360, 400)
local frameHeight = 350
local fontScale = 0.25

local scoreYspacing = 13
local distY = 15
local offsetX = -10
local offsetY = 20
local rankingPage = 1
local rankingWidth = frameWidth - capWideScale(15, 50)
local rankingX = capWideScale(30, 50)
local rankingY = capWideScale(40, 40)
local rankingTitleSpacing = (rankingWidth / (#ms.SkillSets))
local whee

local singleplaylistactive = false
local allplaylistsactive = true

local PlaylistYspacing = 30
local row2Yoffset = 12

local pl
local keylist
local songlist = {}
local stepslist = {}
local chartlist = {}

local currentchartpage = 1
local numchartpages
local chartsperplaylist = 20

local allplaylists
local currentplaylistpage = 1
local numplaylistpages = 1
local playlistsperpage = 10

local translated_info = {
	Delete = THEME:GetString("TabPlaylists", "Delete"),
	Showing = THEME:GetString("TabPlaylists", "Showing"),
	ChartCount = THEME:GetString("TabPlaylists", "ChartCount"),
	AverageRating = THEME:GetString("TabPlaylists", "AverageRating"),
	Title = THEME:GetString("TabPlaylists", "Title"),
	ExplainAdd = THEME:GetString("TabPlaylists", "ExplainAddChart"),
	ExplainPlaylist = THEME:GetString("TabPlaylists", "ExplainNewPlaylist"),
	PlayAsCourse = THEME:GetString("TabPlaylists", "PlayAsCourse"),
	Back = THEME:GetString("TabPlaylists", "Back"),
	Next = THEME:GetString("TabPlaylists", "Next"),
	Previous = THEME:GetString("TabPlaylists", "Previous"),
	UploadOnline = THEME:GetString("TabPlaylists", "UploadOnline"),
	UploadExplain = THEME:GetString("TabPlaylists", "UploadExplain"),
	DownloadOnline = THEME:GetString("TabPlaylists", "DownloadOnline"),
	DownloadOnlineExplain = THEME:GetString("TabPlaylists", "DownloadOnlineExplain"),
	DownloadMissing = THEME:GetString("TabPlaylists", "DownloadMissing"),
	DownloadMissingExplain = THEME:GetString("TabPlaylists", "DownloadMissingExplain"),
}

t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(frameX, frameY):zoomto(frameWidth, frameHeight):halign(0):valign(0):diffuse(getMainColor("tabs"))
	end
}
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(frameX, frameY):zoomto(frameWidth, offsetY):halign(0):valign(0)
		self:diffuse(getMainColor("frames")):diffusealpha(0.5)
	end
}
t[#t + 1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(frameX + 5, frameY + offsetY - 11):zoom(0.65):halign(0)
		self:diffuse(Saturation(getMainColor("positive"), 0.1))
		self:settext(translated_info["Title"])
	end
}
t[#t + 1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(frameWidth + 265, frameY + offsetY - 11):zoom(0.65):halign(1)
	end,
	DisplaySinglePlaylistMessageCommand = function(self)
		self:settext(translated_info["ExplainAdd"])
	end,
	DisplayAllPlaylistsMessageCommand = function(self)
		self:settext(translated_info["ExplainPlaylist"])
	end
}

local function BroadcastIfActive(msg)
	if update then
		MESSAGEMAN:Broadcast(msg)
	end
end

local function ButtonActive(self)
	return isOver(self) and update
end

local r = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(frameX, frameY)
	end,
	OnCommand = function(self)
		whee = SCREENMAN:GetTopScreen():GetMusicWheel()
	end,
	DisplaySinglePlaylistMessageCommand = function(self)
		if getTabIndex() ~= 7 then return end
		if update then
			pl = SONGMAN:GetActivePlaylist()
			if pl then
				singleplaylistactive = true
				allplaylistsactive = false

				keylist = pl:GetChartkeys()
				chartlist = pl:GetAllSteps()
				for j = 1, #keylist do
					songlist[j] = SONGMAN:GetSongByChartKey(keylist[j])
					stepslist[j] = SONGMAN:GetStepsByChartKey(keylist[j])
				end

				numplaylistpages = notShit.ceil(#chartlist / chartsperplaylist)

				self:visible(true)
				MESSAGEMAN:Broadcast("DisplayPP")
			else
				singleplaylistactive = false
			end
		else
			self:visible(false)
		end
	end,
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX - 215, rankingY):zoom(0.4):halign(0):maxwidth(460)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			pl = SONGMAN:GetActivePlaylist()
			self:settext(pl:GetName())
			self:visible(true)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			if getTabIndex() == 7 then
				self:visible(false)
				singleplaylistactive = false
				allplaylistsactive = true
			end
		end
	}
}

local function RateDisplayButton(i)
	local o = Def.ActorFrame {
		Name = "RateDisplay",
		InitCommand = function(self)
			self:x(200):diffuse(getMainColor("positive"))
		end,
		UIElements.TextToolTip(1, 1, "Common Large") .. {
			Name = "Text",
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				local ratestring =
					string.format("%.2f", chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetRate()):gsub("%.?0+$", "") ..
					"x"
				self:settext(ratestring)
				self:zoom(fontScale)
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and update and singleplaylistactive then
					chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:ChangeRate(0.1)
					BroadcastIfActive("DisplaySinglePlaylist")
				elseif params.event == "DeviceButton_right mouse button" and update and singleplaylistactive then
					chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:ChangeRate(-0.1)
					BroadcastIfActive("DisplaySinglePlaylist")
				end
			end,
			MouseOverCommand = function(self)
				self:diffusealpha(hoverAlpha)
			end,
			MouseOutCommand = function(self)
				self:diffusealpha(1)
			end,
		}
	}
	return o
end

local function TitleDisplayButton(i)
	local o = Def.ActorFrame {
		Name = "TitleDisplay",
		InitCommand = function(self)
			self:x(15)
		end,
		UIElements.QuadButton(1, 1) .. {
			InitCommand = function(self)
				self:x(-20):zoomto(190, scoreYspacing):halign(0):diffusealpha(0)
			end,
			MouseDownCommand = function(self, params)
				-- wtf
				if params.event == "DeviceButton_left mouse button" and update and chartlist[i + ((currentchartpage - 1) * chartsperplaylist)] and
						chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:IsLoaded() and
						singleplaylistactive and not clickedForSinglePlaylist
				 then
					whee:SelectSong(songlist[i + ((currentchartpage - 1) * chartsperplaylist)])
				end
			end,
			MouseOverCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(0.7)
			end,
			MouseOutCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(1)
			end,
		},
		LoadFont("Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0)
			end,
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				self:zoom(fontScale)
				self:maxwidth(620)
				local chartentry = chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]
				if chartentry == nil then return end
				if chartentry:IsLoaded() then
					local songentry = songlist[i + ((currentchartpage - 1) * chartsperplaylist)]
					self:diffuse(getMainColor("positive"))
					self:settext(songentry:GetDisplayMainTitle())
				else
					self:diffuse(byJudgment("TapNoteScore_Miss"))
					self:settext(chartentry:GetSongTitle())
				end
			end,
			DisplayLanguageChangedMessageCommand = function(self)
				self:playcommand("DisplaySinglePlaylistLevel2")
			end,
		}
	}
	return o
end

local function DeleteChartButton(i)
	local o = Def.ActorFrame {
		Name = "DeleteButton",
		InitCommand = function(self)
			self:x(315)
		end,
		UIElements.TextToolTip(1, 1, "Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0)
				self:zoom(fontScale)
				self:settext(translated_info["Delete"])
				self:diffuse(byJudgment("TapNoteScore_Miss"))
			end,
			DisplaySinglePlaylistLevel2Command = function(self)
				if pl:GetName() == "Favorites" then
					self:visible(false)
				else
					self:visible(true)
				end
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and update and singleplaylistactive then
					pl:DeleteChart(i + ((currentchartpage - 1) * chartsperplaylist))
					MESSAGEMAN:Broadcast("DisplayAllPlaylists")
					MESSAGEMAN:Broadcast("DisplaySinglePlaylist")
				end
			end,
			MouseOverCommand = function(self)
				self:diffusealpha(hoverAlpha)
			end,
			MouseOutCommand = function(self)
				self:diffusealpha(1)
			end,
		}
	}
	return o
end

local function PBDisplayButton(i)
	local o = Def.ActorFrame {
		Name = "PBDisplay",
		InitCommand = function(self)
			self:x(227):zoom(1):halign(0):valign(0)
		end,
		UIElements.QuadButton(1, 1) .. {
			InitCommand = function(self)
				self:x(0):zoomto(40, scoreYspacing):halign(0):diffusealpha(0)
			end,
			MouseDownCommand = function(self, params)
				-- wtf
				if params.event == "DeviceButton_left mouse button" and update and chartlist[i + ((currentchartpage - 1) * chartsperplaylist)] and
						chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:IsLoaded() and
						singleplaylistactive and not clickedForSinglePlaylist
				 then
					whee:SelectSong(songlist[i + ((currentchartpage - 1) * chartsperplaylist)])
				end
			end,
			MouseOverCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(0.7)
			end,
			MouseOutCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(1)
			end,
		},
		LoadFont("Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0)
			end,
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				local function getpb(chartkey, your_rate) --thank you poco i would buy you dr pepper if i would be able to do this
					local scoresatrates = SCOREMAN:GetScoresByKey(chartkey)
					local x = "x"
					if scoresatrates ~= nil then
					  for r, l in pairs(scoresatrates) do
						local rr = r:gsub("["..x.."]+", "")
						if math.abs(rr - your_rate) < 0.001 then
						  local scoresatrate = l:GetScores()
						  return scoresatrate[1] -- either nil or a score
						end
					  end
					end
					return nil
				end
				self:zoom(fontScale)
				self:maxwidth(160)
				if chartlist == nil or chartlist[i + ((currentchartpage - 1) * chartsperplaylist)] == nil then return end
				local pbrate = chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetRate()
				local pbchartkey = keylist[i + ((currentchartpage - 1) * chartsperplaylist)]
				local pb = getpb(pbchartkey, pbrate)
				if pb then
					local bp = pb:GetWifeScore() * 100
					self:settextf("%05.2f%%", bp)
					self:diffuse(getGradeColor(pb:GetWifeGrade()))
				else
					self:settext("")
				end
			end,
			DisplayLanguageChangedMessageCommand = function(self)
				self:playcommand("DisplaySinglePlaylistLevel2")
			end,
		},
	}	
	return o
end

local function DisplayDiff(i)
	local o = Def.ActorFrame {
			Name = "DisplayDiff",
		InitCommand = function(self)
			self:x(290):zoom(1):halign(0):valign(0)
		end,
		UIElements.QuadButton(1,1) .. {
			InitCommand = function(self)
				self:x(-7):zoomto(16, scoreYspacing):halign(0):diffusealpha(0) --you like odd numbers don't you
			end,
			MouseDownCommand = function(self, params)
				-- wtf
				if params.event == "DeviceButton_left mouse button" and update and chartlist[i + ((currentchartpage - 1) * chartsperplaylist)] and
						chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:IsLoaded() and
						singleplaylistactive and not clickedForSinglePlaylist
				 then
					whee:SelectSong(songlist[i + ((currentchartpage - 1) * chartsperplaylist)])
				end
			end,
			MouseOverCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(0.7)
			end,
			MouseOutCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(1)
			end,
		},
		LoadFont("Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0.5)
			end,
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				self:zoom(fontScale)
				self:maxwidth(70)
				local chart = stepslist[i + ((currentchartpage - 1) * chartsperplaylist)]
				if chart == nil then
					self:visible(false)
					return
				else
					self:visible(true)
				end
				local diff = chart:GetDifficulty()
				self:diffuse(byDifficulty(diff))
				self:settext(getShortDifficulty(diff))
			end,
			DisplayLanguageChangedMessageCommand = function(self)
				self:playcommand("DisplaySinglePlaylistLevel2")
			end,
		}
	}
	return o
end

local function rankingLabel(i)
	local chart
	local chartloaded
	local t = Def.ActorFrame {
		InitCommand = function(self)
			self:xy(rankingX + offsetX, rankingY + offsetY + 10 + (i - 1) * scoreYspacing)
			self:visible(false)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(false)
		end,
		DisplayPPMessageCommand = function(self)
			if update then
				chart = chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]
				if chart then
					chartloaded = chartlist[i + ((currentchartpage - 1) * chartsperplaylist)]:IsLoaded()
					self:visible(true)
					self:GetChild("DeleteButton"):queuecommand("DisplaySinglePlaylistLevel2")
					self:GetChild("TitleDisplay"):queuecommand("DisplaySinglePlaylistLevel2")
					self:GetChild("RateDisplay"):queuecommand("DisplaySinglePlaylistLevel2")
					self:GetChild("PBDisplay"):queuecommand("DisplaySinglePlaylistLevel2")
					self:GetChild("DisplayDiff"):queuecommand("DisplaySinglePlaylistLevel2")
					self:GetChild("DeleteButton"):visible(true)
					self:GetChild("TitleDisplay"):visible(true)
					self:GetChild("RateDisplay"):visible(true)
					self:GetChild("PBDisplay"):visible(true)
					self:GetChild("DisplayDiff"):visible(true)
					self:GetChild("PackMouseOver"):visible(true)
					self:GetChild("ChartNumber"):visible(true)
				else
					self:GetChild("DeleteButton"):visible(false)
					self:GetChild("TitleDisplay"):visible(false)
					self:GetChild("RateDisplay"):visible(false)
					self:GetChild("PBDisplay"):visible(false)
					self:GetChild("DisplayDiff"):visible(false)
					self:GetChild("PackMouseOver"):visible(false)
					self:GetChild("ChartNumber"):visible(false)
				end
			else
				self:visible(true)
			end
		end,
		LoadFont("Common Large") .. {
			Name = "ChartNumber",
			InitCommand = function(self)
				self:maxwidth(100)
				self:halign(0):zoom(fontScale)
			end,
			DisplayPPMessageCommand = function(self)
				self:halign(0.5)
				self:diffuse(getMainColor("positive"))
				self:settext(((rankingPage - 1) * chartsperplaylist) + i + ((currentchartpage - 1) * chartsperplaylist) .. ".")
			end
		},
		Def.ActorFrame {
			Name = "PackMouseOver",
			UIElements.QuadButton(1, 1) .. {
				InitCommand = function(self)
					Name = "mouseover",
					self:x(-7):zoomto(212, scoreYspacing):halign(0):diffusealpha(0)
				end,
				MouseOverCommand = function(self)
					self:GetParent():queuecommand("DisplayPack")
				end,
				MouseOutCommand = function(self)
					self:GetParent():queuecommand("UNDisplayPack")
				end,
			},
			Def.ActorFrame {
				Name = "mouseovertextcontainer",
				InitCommand = function(self)
					self:xy(15, -12)
				end,
				DisplayPackCommand = function(self)
					if songlist[i + ((currentchartpage - 1) * chartsperplaylist)] then
						local txt = self:GetChild("text")
						local bg = self:GetChild("BG")
						txt:settext(songlist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetGroupName())
						bg:zoomto(txt:GetZoomedWidth(), txt:GetZoomedHeight() * 1.4)
						self:finishtweening()
						self:diffusealpha(1)
					end
				end,
				UNDisplayPackCommand = function(self)
					if songlist[i + ((currentchartpage - 1) * chartsperplaylist)] then
						local txt = self:GetChild("text")
						local bg = self:GetChild("BG")
						txt:settext(songlist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetGroupName())
						bg:zoomto(txt:GetZoomedWidth(), txt:GetZoomedHeight() * 1.4)
						self:linear(0.25)
						self:diffusealpha(0)
					end
				end,
				Def.Quad {
					Name = "BG",
					InitCommand = function(self)
						self:halign(0)
						self:diffuse(color("0,0,0,0.6"))
					end,
				},
				LoadFont("Common Large") .. {
					Name = "text",
					InitCommand = function(self)
						self:maxwidth(580)
						self:halign(0)
						self:zoom(fontScale)
					end,
				},
			},
		},
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:x(56):maxwidth(160)
				self:halign(0):zoom(fontScale)
			end,
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				if chartloaded then
					local rating = stepslist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetMSD(chart:GetRate(), 1)
					self:settextf("%.2f", rating)
					self:diffuse(byMSD(rating))
				else
					local rating = 0
					self:settextf("%.2f", rating)
					self:diffuse(byJudgment("TapNoteScore_Miss"))
				end
			end
		},
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:x(300)
				self:halign(0):zoom(fontScale)
			end,
			DisplaySinglePlaylistLevel2MessageCommand = function(self)
				self:halign(0.5)
				local diff = stepslist[i + ((currentchartpage - 1) * chartsperplaylist)]:GetDifficulty()
				if chartloaded then
					self:diffuse(byDifficulty(diff))
					self:settext(getShortDifficulty(diff))
				else
					local diff = chart:GetDifficulty()
					self:diffuse(byJudgment("TapNoteScore_Miss"))
					self:settext(getShortDifficulty(diff))
				end
			end
		}
	}
	t[#t + 1] = RateDisplayButton(i)
	t[#t + 1] = TitleDisplayButton(i)
	t[#t + 1] = DeleteChartButton(i)
	t[#t + 1] = PBDisplayButton(i)
	t[#t + 1] = DisplayDiff(i)
	return t
end

-- Buttons for individual playlist manipulation
local b2 = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(215, rankingY)
	end,
	DisplayAllPlaylistsMessageCommand = function(self)
		self:visible(false)
	end,
	DisplaySinglePlaylistMessageCommand = function(self)
		self:visible(true)
	end
}

b2[#b2 + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	InitCommand = function(self)
		self:zoom(0.3):x(capWideScale(86,107)):diffuse(getMainColor("positive"))
		self:settext(translated_info["PlayAsCourse"])
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" and update and singleplaylistactive then
			SCREENMAN:GetTopScreen():StartPlaylistAsCourse(pl:GetName())
		end
	end,
	MouseOverCommand = function(self)
		self:diffusealpha(hoverAlpha)
	end,
	MouseOutCommand = function(self)
		self:diffusealpha(1)
	end,
}

-- Back button
b2[#b2 + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	InitCommand = function(self)
		self:zoom(0.3):x(capWideScale(-195,20)):diffuse(getMainColor("positive"))
		self:settext(translated_info["Back"])
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" and update and singleplaylistactive then
			MESSAGEMAN:Broadcast("DisplayAllPlaylists")
		end
	end,
	MouseOverCommand = function(self)
		self:diffusealpha(hoverAlpha)
	end,
	MouseOutCommand = function(self)
		self:diffusealpha(1)
	end,
}

r[#r + 1] = b2

-- next/prev pages for individual playlists, i guess these could be merged with the allplaylists buttons for efficiency but meh
r[#r + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(frameX - 310, frameY + rankingY + 250)
	end,
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:x(capWideScale(190,200)):halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:settext(translated_info["Next"]):x(370)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(false)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(true)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and currentchartpage < numplaylistpages and singleplaylistactive then
				currentchartpage = currentchartpage + 1
				MESSAGEMAN:Broadcast("DisplaySinglePlaylist")
				MESSAGEMAN:Broadcast("DisplayPP")
			end
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
		end,
	},
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:settext(translated_info["Previous"]):x(50)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(false)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(true)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and currentchartpage > 1 and singleplaylistactive then
				currentchartpage = currentchartpage - 1
				MESSAGEMAN:Broadcast("DisplaySinglePlaylist")
				MESSAGEMAN:Broadcast("DisplayPP")
			end
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
		end,
	},
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:x(capWideScale(230,245))
			self.state = "Download"
			self:queuecommand("MaintainState")
			self.visibilityFunc = function()
				return (singleplaylistactive and SONGMAN:GetActivePlaylist() ~= nil and SONGMAN:GetActivePlaylist():GetName() ~= "Favorites")
					or not singleplaylistactive
			end
		end,
		MaintainStateCommand = function(self)
			if DLMAN:IsLoggedIn() then
				self:visible(self.visibilityFunc())
			else
				self:visible(false)
			end
		end,
		LoginFailedMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		LoginMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		LogOutMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		OnlineUpdateMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self.state = "Download"
			self:queuecommand("MaintainState")
			self:settext(translated_info["DownloadMissing"])
			self:x(capWideScale(250,265)):x(110)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self.state = "Upload"
			self:queuecommand("MaintainState")
			self:settext(translated_info["UploadOnline"])
			self:x(capWideScale(230,245))
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and singleplaylistactive then
				self:playcommand("Invoke")
			elseif params.event == "DeviceButton_left mouse button" and not singleplaylistactive then
				self:playcommand("Invoke")
			end
		end,
		InvokeCommand = function(self)
			if self.state == "Upload" then
				local pl = SONGMAN:GetActivePlaylist()
				ms.ok("Uploading playlist '" .. pl:GetName() .. "'")
				pl:UploadOnline()
			elseif self.state == "Download" then
				ms.ok("Downloading missing playlists...")
				DLMAN:DownloadMissingPlaylists()
			end
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
			if self:IsVisible() then
				if self.state == "Download" then
					TOOLTIP:SetText(translated_info["DownloadMissingExplain"])
					TOOLTIP:Show()
				elseif self.state == "Upload" then
					TOOLTIP:SetText(translated_info["UploadExplain"])
					TOOLTIP:Show()
				end
			end
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
			if self:IsVisible() then
				TOOLTIP:Hide()
			end
		end,
	},
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:x(capWideScale(290,300))
			self:settext(translated_info["DownloadOnline"])
			self:queuecommand("MaintainState")
		end,
		MaintainStateCommand = function(self)
			if DLMAN:IsLoggedIn() then
				local b = singleplaylistactive and SONGMAN:GetActivePlaylist() ~= nil and SONGMAN:GetActivePlaylist():GetName() ~= "Favorites"
				self:visible(b)
			else
				self:visible(false)
			end
		end,
		LoginFailedMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		LoginMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		LogOutMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		OnlineUpdateMessageCommand = function(self)
			self:queuecommand("MaintainState")
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(false)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			local b = DLMAN:IsLoggedIn() and SONGMAN:GetActivePlaylist() ~= nil and SONGMAN:GetActivePlaylist():GetName() ~= "Favorites"
			self:visible(b)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and singleplaylistactive then
				self:playcommand("Invoke")
			end
		end,
		InvokeCommand = function(self)
			local pl = SONGMAN:GetActivePlaylist()
			ms.ok("Downloading playlist '" .. pl:GetName() .. "' from online")
			pl:DownloadOnline()
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
			if self:IsVisible() then
				TOOLTIP:SetText(translated_info["DownloadOnlineExplain"])
				TOOLTIP:Show()
			end
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
			if self:IsVisible() then
				TOOLTIP:Hide()
			end
		end,
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:x(165):halign(0.5):zoom(0.25)
		end,
		SetCommand = function(self)
			self:settextf(
				"%s %i-%i (%i)",
				translated_info["Showing"],
				math.min(((currentchartpage - 1) * chartsperplaylist) + 1, #chartlist),
				math.min(currentchartpage * chartsperplaylist, #chartlist),
				#chartlist
			)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(false)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(true):queuecommand("Set")
		end
	}
}

local function PlaylistTitleDisplayButton(i)
	local o = Def.ActorFrame {
		InitCommand = function(self)
			self:x(275)
		end,
		UIElements.QuadButton(1, 1) .. {
			InitCommand = function(self)
				self:xy(1,-5):zoomto(rankingWidth - 30, scoreYspacing * 2.25):align(0,0)
				self:diffusealpha(0) --please don't forget this -rina
			end,
			MouseOverCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(0.7)
			end,
			MouseOutCommand = function(self)
				self:GetParent():GetChild("Text"):diffusealpha(1)
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and update and allplaylistsactive then
					SONGMAN:SetActivePlaylist(allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetName())
					pl = allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]
					MESSAGEMAN:Broadcast("DisplaySinglePlaylist")
					clickedForSinglePlaylist = true
				end
			end,
			MouseUpMessageCommand = function(self)
				clickedForSinglePlaylist = false
			end,
		},
		LoadFont("Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0):maxwidth(frameWidth * 3 + 140)
				self:diffuse(getMainColor("positive"))
			end,
			AllDisplayMessageCommand = function(self)
				self:zoom(fontScale)
				if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
					self:settext(allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetName())
				end
			end,
		}
	}
	return o
end

local function DeletePlaylistButton(i)
	local o = Def.ActorFrame {
		InitCommand = function(self)
			self:x(580)
		end,
		UIElements.TextToolTip(1, 1, "Common Large") .. {
			Name = "Text",
			InitCommand = function(self)
				self:halign(0):maxwidth(frameWidth * 3 + 140)
			end,
			AllDisplayMessageCommand = function(self)
				if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
					self:settext(translated_info["Delete"])
					self:zoom(fontScale)
					self:diffuse(byJudgment("TapNoteScore_Miss"))
				end

				if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
					if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetName() == "Favorites" then
						self:visible(false)
					else
						self:visible(true)
					end
				end
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and update and allplaylistsactive then
					SONGMAN:DeletePlaylist(allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetName())
					allplaylists = SONGMAN:GetPlaylists()
					numplaylistpages = notShit.ceil(#allplaylists / playlistsperpage)
					MESSAGEMAN:Broadcast("DisplayAllPlaylists")
				end
			end,
			MouseOverCommand = function(self)
				self:diffusealpha(hoverAlpha)
			end,
			MouseOutCommand = function(self)
				self:diffusealpha(1)
			end,
		}
	}
	return o
end

local function PlaylistSelectLabel(i)
	local t = Def.ActorFrame {
		InitCommand = function(self)
			self:xy(rankingX + offsetX, rankingY + offsetY + 20 + (i - 1) * PlaylistYspacing)
			self:visible(true)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(false)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			if update and allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
				self:visible(true)
				MESSAGEMAN:Broadcast("AllDisplay")
			else
				self:visible(false)
			end
		end,
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:halign(0):zoom(fontScale)
				self:maxwidth(100)
			end,
			AllDisplayMessageCommand = function(self)
				self:halign(0.5)
				self:settext(((rankingPage - 1) * chartsperplaylist) + i + ((currentplaylistpage - 1) * playlistsperpage) .. "."):x(260)
			end
		},
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:halign(0):zoom(fontScale)
				self:xy(315, row2Yoffset)
			end,
			AllDisplayMessageCommand = function(self)
				if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
					self:settextf(
						"%s: %d",
						translated_info["ChartCount"],
						allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetNumCharts()
					)
				end
			end
		},
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:halign(0):zoom(fontScale)
				self:xy(480, row2Yoffset)
			end,
			AllDisplayMessageCommand = function(self)
				self:settextf("%s:", translated_info["AverageRating"])
			end
		},
		LoadFont("Common Large") .. {
			InitCommand = function(self)
				self:halign(0):zoom(fontScale)
				self:xy(575, row2Yoffset)
			end,
			AllDisplayMessageCommand = function(self)
				if allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)] then
					local rating = allplaylists[i + ((currentplaylistpage - 1) * playlistsperpage)]:GetAverageRating()
					self:settextf("%.2f", rating)
					self:diffuse(byMSD(rating))
				end
			end
		}
	}
	t[#t + 1] = PlaylistTitleDisplayButton(i)
	t[#t + 1] = DeletePlaylistButton(i)
	return t
end

local playlists = Def.ActorFrame {
	OnCommand = function(self)
		allplaylists = SONGMAN:GetPlaylists()
		numplaylistpages = notShit.ceil(#allplaylists / playlistsperpage)
	end,
	DisplayAllPlaylistsMessageCommand = function(self)
		self:visible(true)
		allplaylists = SONGMAN:GetPlaylists()
		numplaylistpages = notShit.ceil(#allplaylists / playlistsperpage)
	end
}

-- Buttons for general playlist manipulation
local b = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(100, frameHeight + 30)
	end,
	DisplaySinglePlaylistMessageCommand = function(self)
		self:visible(false)
	end,
	DisplayAllPlaylistsMessageCommand = function(self)
		self:visible(true)
	end
}

playlists[#playlists + 1] = b

for i = 1, chartsperplaylist do
	r[#r + 1] = rankingLabel(i)
end

for i = 1, playlistsperpage do
	playlists[#playlists + 1] = PlaylistSelectLabel(i)
end

-- next/prev for all playlists
r[#r + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(frameX + 10, frameY + rankingY + 250)
	end,
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:x(capWideScale(190,200)):halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:settext(translated_info["Next"]):x(50)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			if update then
				self:visible(false)
			end
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			if update then
				self:visible(true)
			end
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and currentplaylistpage < numplaylistpages and allplaylistsactive then
				currentplaylistpage = currentplaylistpage + 1
				MESSAGEMAN:Broadcast("DisplayAllPlaylists")
			end
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
		end,
	},
	UIElements.TextToolTip(1, 1, "Common Large") .. {
		InitCommand = function(self)
			self:halign(0):zoom(0.25):diffuse(getMainColor("positive"))
			self:settext(translated_info["Previous"]):x(-280)
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(false)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(true)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" and currentplaylistpage > 1 and allplaylistsactive then
				currentplaylistpage = currentplaylistpage - 1
				MESSAGEMAN:Broadcast("DisplayAllPlaylists")
			end
		end,
		MouseOverCommand = function(self)
			self:diffusealpha(hoverAlpha)
		end,
		MouseOutCommand = function(self)
			self:diffusealpha(1)
		end,
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:x(-25):halign(0.5):zoom(0.25)
		end,
		SetCommand = function(self)
			self:settextf(
				"%s %i-%i (%i)",
				translated_info["Showing"],
				math.min(((currentplaylistpage - 1) * playlistsperpage) + 1, #allplaylists),
				math.min(currentplaylistpage * playlistsperpage, #allplaylists),
				#allplaylists
			)
		end,
		DisplayAllPlaylistsMessageCommand = function(self)
			self:visible(true):queuecommand("Set")
		end,
		DisplaySinglePlaylistMessageCommand = function(self)
			self:visible(false)
		end
	}
}

t[#t + 1] = playlists
t[#t + 1] = r
return t
