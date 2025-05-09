local defaultConfig = {
	title = {
		BG_Left = "#1c1c1c",
		BG_Right = "#1c1c1c",
		Line_Left = "#646464",
		Line_Right = "#969696"
	},
	main = {
		highlight = "#64ddff",
		frames = "#000111",
		tabs = "#2E2E2E99",
		enabled = "#4CBB17",
		disabled = "#666666",
		negative = "#FF9999",
		positive = "#6496ff"
	},
	leaderboard = {
		background = "#111111CC",
		border = "#000111",
		text = "#6496ff"
	},
	clearType = {
		MFC = "#66ccff",
		WF = "#dddddd",
		SDP = "#cc8800",
		PFC = "#eeaa00",
		BF = "#999999",
		SDG = "#448844",
		FC = "#66cc66",
		MF = "#cc6666",
		SDCB = "#33bbff",
		Clear = "#33aaff",
		Failed = "#e61e25",
		Invalid = "#e61e25",
		NoPlay = "#666666",
		None = "#666666"
	},
	difficulty = {
		Difficulty_Beginner = "#66ccff", -- light blue
		Difficulty_Easy = "#099948", -- green
		Difficulty_Medium = "#ddaa00", -- yellow
		Difficulty_Hard = "#ff6666", -- red
		Difficulty_Challenge = "#c97bff", -- light blue
		Difficulty_Edit = "#666666", -- gray
		Beginner = "#66ccff",
		Easy = "#099948", -- green
		Medium = "#ddaa00", -- yellow
		Hard = "#ff6666", -- red
		Challenge = "#c97bff", -- Purple
		Edit = "#666666", -- gray
		Difficulty_Crazy = "#cc66ff",
		Difficulty_Freestyle = "#666666",
		Difficulty_Nightmare = "#666666",
		Crazy = "#cc66ff",
		Freestyle = "#666666",
		Nightmare = "#666666"
	},
	difficultyVivid = {
		Difficulty_Beginner = "#0099ff", -- light blue
		Difficulty_Easy = "#00ff00", -- green
		Difficulty_Medium = "#ffff00", -- yellow
		Difficulty_Hard = "#ff0000", -- red
		Difficulty_Challenge = "#cc66ff", -- light blue
		Difficulty_Edit = "#666666", -- gray
		Beginner = "#0099ff", -- light blue
		Easy = "#00ff00", -- green
		Medium = "#ffff00", -- yellow
		Hard = "#ff0000", -- red
		Challenge = "#cc66ff", -- Purple
		Edit = "#666666", -- gray
		Difficulty_Crazy = "#cc66ff",
		Difficulty_Freestyle = "#666666",
		Difficulty_Nightmare = "#666666",
		Crazy = "#cc66ff",
		Freestyle = "#666666",
		Nightmare = "#666666"
	},
	grades = {
		Grade_Tier01 = "#ffffff", -- AAAAA
		Grade_Tier02 = "#66ccff", -- AAAA:
		Grade_Tier03 = "#66ccff", -- AAAA.
		Grade_Tier04 = "#66ccff", -- AAAA
		Grade_Tier05 = "#eebb00", -- AAA:
		Grade_Tier06 = "#eebb00", -- AAA.
		Grade_Tier07 = "#eebb00", -- AAA
		Grade_Tier08 = "#66cc66", -- AA:
		Grade_Tier09 = "#66cc66", -- AA.
		Grade_Tier10 = "#66cc66", -- AA
		Grade_Tier11 = "#da5757", -- A:
		Grade_Tier12 = "#da5757", -- A.
		Grade_Tier13 = "#da5757", -- A
		Grade_Tier14 = "#5b78bb", -- B
		Grade_Tier15 = "#c97bff", -- C
		Grade_Tier16 = "#8c6239", -- D
		Grade_Tier17 = "#000000",
		Grade_Failed = "#cdcdcd", -- F
		Grade_None = "#666666" -- no play
	},
	judgment = {
		-- Colors of each Judgment types
		TapNoteScore_W1 = "#99ccff",
		TapNoteScore_W2 = "#f2cb30",
		TapNoteScore_W3 = "#14cc8f",
		TapNoteScore_W4 = "#1ab2ff",
		TapNoteScore_W5 = "#ff1ab3",
		TapNoteScore_Miss = "#cc2929",
		HoldNoteScore_Held = "#f2cb30",
		HoldNoteScore_LetGo = "#cc2929"
	},
	songLength = {
		normal = "#FFFFFF", -- normal
		long = "#ff9a00", --orange
		marathon = "#da5757" -- red
	},
	combo = {
		Marv_FullCombo = "#00aeef",
		Perf_FullCombo = "#fff568",
		FullCombo = "#a4ff00",
		RegularCombo = "#ffffff",
		ComboLabel = "#ffffff"
	},
	laneCover = {
		cover = "#333333",
		bpmText = "#4CBB17",
		heightText = "#FFFFFF"
	}
}

colorConfig = create_setting("colorConfig", "colorConfig.lua", defaultConfig, -1)
--colorConfig:load()

--keys to current table. Assumes a depth of 2.
local curColor = {"", ""}

function getTableKeys()
	return curColor
end

function setTableKeys(table)
	curColor = table
end

function getDefaultColorForCurColor()
	return defaultConfig[curColor[1]][curColor[2]]
end

function getMainColor(type)
	return color(colorConfig:get_data().main[type])
end

function getLeaderboardColor(type)
	return color(colorConfig:get_data().leaderboard[type])
end

function getLaneCoverColor(type)
	return color(colorConfig:get_data().laneCover[type])
end

function getGradeColor(grade)
	return color(colorConfig:get_data().grades[grade]) or color(colorConfig:get_data().grades["Grade_None"])
end

function getDifficultyColor(diff)
	return color(colorConfig:get_data().difficulty[diff]) or color("#ffffff")
end

function getVividDifficultyColor(diff)
	return color(colorConfig:get_data().difficultyVivid[diff]) or color("#ffffff")
end

function getTitleColor(type)
	return color(colorConfig:get_data().title[type])
end

function getComboColor(type)
	return color(colorConfig:get_data().combo[type])
end

-- expecting ms input (153, 13.321, etc) so convert to seconds to compare to judgment windows -mina
function offsetToJudgeColor(offset, scale)
	local offset = math.abs(offset / 1000)
	if not scale then
		scale = PREFSMAN:GetPreference("TimingWindowScale")
	end
	if offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= math.max(scale * PREFSMAN:GetPreference("TimingWindowSecondsW5"), 0.180) then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

-- 30% hardcoded, should var but lazy atm -mina
function offsetToJudgeColorAlpha(offset, scale)
	local offset = math.abs(offset / 1000)
	if not scale then
		scale = PREFSMAN:GetPreference("TimingWindowScale")
	end
	if offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"] .. "48")
	elseif offset <= math.max(scale * PREFSMAN:GetPreference("TimingWindowSecondsW5"), 0.180) then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"] .. "48")
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"] .. "48")
	end
end

-- 30% hardcoded, should var but lazy atm -mina
function customOffsetToJudgeColor(offset, windows)
	local offset = math.abs(offset)
	if offset <= windows.TapNoteScore_W1 then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= windows.TapNoteScore_W2 then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= windows.TapNoteScore_W3 then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= windows.TapNoteScore_W4 then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= windows.TapNoteScore_W5 then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

function byJudgment(judge)
	return color(colorConfig:get_data().judgment[judge])
end

function byDifficulty(diff)
	return color(colorConfig:get_data().difficulty[diff])
end

-- i guess if i'm going to use this naming convention it might as well be complete and standardized which means redundancy -mina
function byGrade(grade)
	return color(colorConfig:get_data().grades[grade]) or color(colorConfig:get_data().grades["Grade_None"])
end

-- Colorized stuff
function byMSD(x)
	if x then
		return HSV(math.max(95 - (x / 40) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

function byMusicLength(x)
	if x then
		x = math.min(x, 600)
		return HSV(math.max(95 - (x / 900) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

function byFileSize(x)
	if x then
		x = math.min(x, 600)
		return HSV(math.max(95 - (x / 1025) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

-- yes i know i shouldnt hardcode this -mina
function bySkillRange(x)
	if x <= 10 then
		return color("#66ccff")
	elseif x <= 15 then
		return color("#099948")
	elseif x <= 21 then
		return color("#ddaa00")
	elseif x <= 25 then
		return color("#ff6666")
	else
		return color("#c97bff")
	end
end

-- the graph kills itself if this function doesn't exist soooooo i'll just put this
-- also if you attempt to make the colors the same as the byMSD function the graph also kills itself, dunno why and i don't really care
function getMSDColor(MSD)
	if MSD then
		return HSV(math.min(220,math.max(280 - MSD*11, -40)), 0.5, 1)
	end
	return HSV(0, 0.9, 0.9)
end