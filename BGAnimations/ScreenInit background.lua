local t = Def.ActorFrame {}



t[#t + 1] =
	Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	LeftClickMessageCommand = function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	Def.ActorFrame {
		Def.Quad {
			InitCommand = function(self)
				self:zoomto(SCREEN_WIDTH, 0)
			end,
			OnCommand = function(self)
				self:diffusealpha(0):sleep(2):linear(0.25)
			end
		},
		LoadFont("Common Normal") ..
			{
				Text = "you never know what happens here",
				InitCommand = function(self)
					self:y(0)
				end,
				OnCommand = function(self)
					self:zoom(1):diffuse(color("#6496ff")):sleep(2):linear(3):diffuse(color("#111111")):diffusealpha(0)
				end,
			},
				}
	}
t[#t + 1] = LoadActor(THEME:GetPathS("ScreenInit", "Sound")) ..
			{
				OnCommand = function(self) 
					self:play() 
				end,
			}
return t
