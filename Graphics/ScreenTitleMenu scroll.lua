local gc = Var("GameCommand")

return Def.ActorFrame {
	LoadFont("Common Normal") ..
		{
			Text = THEME:GetString("ScreenTitleMenu", gc:GetText()),
			OnCommand = function(self)
				self:xy(300, -32)
			end,
			GainFocusCommand = function(self)
				self:zoom(0.61):diffuse(getMainColor('positive'))
			end,
			LoseFocusCommand = function(self)
				self:zoom(0.55):diffuse(getTitleColor('Line_Left'))
			end
		}
}
