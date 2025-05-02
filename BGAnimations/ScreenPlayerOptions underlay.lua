t = Def.ActorFrame { }

t[#t + 1] =
	LoadActor(THEME:GetPathG("", "_OptionsScreen")) ..
	{
		OnCommand = function(self)
			self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):Center():zoom(0.5):diffusealpha(1)
		end
	}


return t
