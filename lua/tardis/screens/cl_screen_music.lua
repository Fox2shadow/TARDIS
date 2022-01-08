-- Music

local sounds={
    {"Main Theme (2005)", "theme1"},
    {"Main Theme (2009)", "theme2"},
    {"Main Theme (2010)", "theme3"},
    {"Main Theme (2013)", "theme4"},
    {"Ninth Doctor", "nine"},
    {"Tenth Doctor", "ten"},
    {"Eleventh Doctor", "eleven"},
    {"Rose Tyler", "rose"},
    {"Martha Jones", "martha"},
    {"Donna Noble", "donna"},
    {"Amy Pond", "amy"},
    {"River Song", "river"},
    {"Clara Oswald", "clara"},
    {"Abigail's Song", "abigail"},
    {"This is Gallifrey", "thisisgallifrey"},
    {"Gallifrey", "gallifrey"},
    {"Vale Decem", "valedecem"},
    {"The Majestic Tale", "majestictale"},
    {"Forgiven", "forgiven"},
    {"The Wedding of River Song", "weddingofriversong"},
    {"All the Strange Creatures", "allthestrangecreatures"},
    {"You're Fired", "yourefired"},
    {"Whose Enigma", "whoseenigma"},
    {"The Long Song", "thelongsong"},
    {"Infinite Potential", "infinitepotential"},
    {"The New Doctor", "thenewdoctor"},
    {"My Husband's Home", "myhusbandshome"},
    {"Doomsday", "doomsday"},
    {"Dark and Endless Dalek Night", "darkandendlessdaleknight"},
    {"The Greatest Story Never Told", "greateststorynevertold"},
}

--Custom music

local custom_sounds={

}

TARDIS:AddScreen("Music", {id="music", menu=false, order=10, popuponly=true}, function(self,ext,int,frame,screen)

	local text_bar = vgui.Create( "DTextEntry", frame )
	text_bar:SetPlaceholderText("Enter song URL (Clientside Only)")
	text_bar:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	text_bar:SetSize( frame:GetWide()*0.4, frame:GetTall()*0.1 )
	text_bar:SetPos(frame:GetWide()*0.765 - text_bar:GetWide()*0.5, frame:GetTall()*0.2 - text_bar:GetTall()*0.5)
	text_bar.OnEnter = function()
		ext:PlayMusic(text_bar:GetValue())
	end

	local name_bar = vgui.Create( "DTextEntry", frame )
	name_bar:SetPlaceholderText("Enter custom song name")
	name_bar:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	name_bar:SetSize( frame:GetWide()*0.2, frame:GetTall()*0.1 )
	name_bar:SetPos(frame:GetWide()*0.87 - text_bar:GetWide()*0.5, frame:GetTall()*0.35 - text_bar:GetTall()*0.5)

	local x = frame:GetWide()*0.55 - text_bar:GetWide()*0.5
	local y = frame:GetTall()*0.6 - text_bar:GetTall()*0.5

	local url_bar = vgui.Create( "DTextEntry", frame )
	url_bar:SetPlaceholderText("You should not see this")
	url_bar:SetVisible(false)
	url_bar:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	url_bar:SetSize( frame:GetWide()*0.4, frame:GetTall()*0.1 )
	url_bar:SetPos(frame:GetWide()*0.765 - url_bar:GetWide()*0.5, frame:GetTall()*0.4 - url_bar:GetTall()*0.5)

	--Buttons

	local playbutton=vgui.Create("DButton",frame)
	playbutton:SetSize(frame:GetWide()*0.2, text_bar:GetTall())
	playbutton:SetPos(x + text_bar:GetWide()*1.02, y)
	playbutton:SetText("Play")
	playbutton:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	playbutton.DoClick = function()
		ext:PlayMusic(text_bar:GetValue())
	end

	//playselect is the play button for the pre-loaded music

	local playselect=vgui.Create("DButton",frame)
	playselect:SetSize(frame:GetWide()*0.2, text_bar:GetTall())
	playselect:SetPos(frame:GetWide()*-0.05 + playselect:GetWide()*0.5, frame:GetTall()*0.85 + playselect:GetTall()*-0.5)
	playselect:SetText("Play")
	playselect:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	playselect.DoClick = function()
		ext:PlayMusic(url_bar:GetValue())
	end

	local savemus=vgui.Create("DButton",frame)
	savemus:SetSize(frame:GetWide()*0.2, text_bar:GetTall())
	savemus:SetPos(x + text_bar:GetWide()*0.5, y)
	savemus:SetText("Save")
	savemus:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	savemus.DoClick = function()
		print("Save")
	end

	local removemus=vgui.Create("DButton",frame)
	removemus:SetSize(frame:GetWide()*0.2, text_bar:GetTall())
	removemus:SetPos(x + text_bar:GetWide()*0.5, y + text_bar:GetTall()*2)
	removemus:SetText("Remove")
	removemus:SetFont(TARDIS:GetScreenFont(screen, "Default"))

	local stop=vgui.Create("DButton",frame)
	stop:SetSize( frame:GetWide()*0.2, text_bar:GetTall())
	stop:SetPos(x + text_bar:GetWide()*1.02, y + text_bar:GetTall()*2)
	stop:SetText("Stop")
	stop:SetFont(TARDIS:GetScreenFont(screen, "Default"))
	stop.DoClick = function()
		ext:StopMusic()
	end

	--Pre-loaded legacy music select

	local list = vgui.Create("DListView",frame)
	list:SetSize(frame:GetWide()*0.23, frame:GetTall()*0.7)
	list:SetPos(frame:GetWide()*-0.08 + list:GetWide()*0.5, frame:GetTall()*0.4 + list:GetTall()*-0.5)
	list:AddColumn("Pre-loaded music")
	for k,v in pairs(sounds) do
		list:AddLine(v[1])
	end
	function list:OnRowSelected(rowIndex, row)
		url_bar:SetText("https://mattjeanes.com/data/tardis/" .. sounds[rowIndex][2] ..".mp3")
	end

	--Custom music select

	local list = vgui.Create("DListView",frame)
	list:SetSize(frame:GetWide()*0.23, frame:GetTall()*0.85)
	list:SetPos(frame:GetWide()*0.18 + list:GetWide()*0.5, frame:GetTall()*0.475 + list:GetTall()*-0.5)
	list:AddColumn("Custom Music")

	local map = game.GetMap()
	local function updatelist(custom_sounds)
		list:Clear()
		if text_bar ~= nil then
			for k,v in pairs(custom_sounds) do
				list:AddLine(v.name)
			end
		end
	end
	updatelist(custom_sounds)
	function list:OnRowSelected(i,row)
		text_bar:SetText(custom_sounds[rowIndex][2])
	end

end)