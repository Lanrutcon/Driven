local addonName, Driven = ...;

local Addon = CreateFrame("FRAME", "Driven");

--Localing most used global variables
local Minimap = Minimap;
local GetPlayerFacing = GetPlayerFacing;

--Initing "switch-counter". See AddOn:SetScript("OnUpdate") for more info. 
local switch = 0;

-------------------
--UTILS

local createFontFrame = Driven.CreateFontFrame;
local frameFade = Driven.FrameFade;


--/UTILS
---------------------


-------------------------------------
--
-- Hides Blizzard elements from MinimapCluster.
--
-------------------------------------
local function hideBlizzardElements()
	--hide blizzard unwanted textures
	MinimapBorderTop:Hide();
	MinimapZoneTextButton:Hide();
	MinimapNorthTag:Hide();
	MinimapCompassTexture:Hide();
	MiniMapWorldMapButton:Hide();
	
	--hide blizzard unwanted buttons
	MinimapZoomIn:Hide();
	MinimapZoomOut:Hide();
	TimeManagerClockButton:Hide();
	GameTimeFrame:Hide();
	MiniMapTrackingButton:Hide();
	MiniMapTracking:Hide();
	
	--hide MinimapPlayerTexture
	Minimap:SetPlayerTexture("");
end


-------------------------------------
--
-- Creates the timeFrame, where time and zone name will be shown.
-- Used in setUpDriven function.
--
-------------------------------------
local function createTimeFrame()

	--creates timeFrame
	Minimap.timeFrame = CreateFrame("FRAME", "DrivenTimeFrame", Minimap);
	local timeFrame = Minimap.timeFrame;	--for a smaller reference
	timeFrame:SetSize(150, 64);
	timeFrame:SetPoint("TOP", Minimap, "BOTTOM");
	
	--timeFrame texture
	timeFrame.texture = timeFrame:CreateTexture();
	timeFrame.texture:SetTexture("Interface\\AddOns\\Driven\\Textures\\timeFrame.blp");
	timeFrame.texture:SetSize(256, 64);
	timeFrame.texture:SetPoint("CENTER");
	
	
	--timeFrame fontStrings
	
	--time fontString
	timeFrame.time = timeFrame:CreateFontString();
	timeFrame.time:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 18, "OUTLINE");
	timeFrame.time:SetTextColor(0.5, 0.5, 0.5, 1);
	timeFrame.time:SetPoint("CENTER", 1, 0);
	
	--zone fontString
	timeFrame.zone = timeFrame:CreateFontString();
	timeFrame.zone:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 18, "OUTLINE");
	timeFrame.zone:SetTextColor(0.5, 0.5, 0.5, 1);
	timeFrame.zone:SetPoint("CENTER", 1, 0);
	
	timeFrame.zone:SetSize(115, 18);
	timeFrame.zone:SetNonSpaceWrap(true);
	
	
	--timeFrame scripts
	timeFrame:SetScript("OnMouseDown", function(self, button)
		if(button == "RightButton") then
			TimeManager_Toggle();
		else
			switch = 5;
		end
	end);
	
	timeFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
		--from Minimal.lua (Minimap_SetTooltip)
		local zoneName = GetZoneText();
		local subzoneName = GetSubZoneText();
		local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
		if ( subzoneName == zoneName ) then
			subzoneName = "";	
		end
		GameTooltip:AddLine( zoneName, 1.0, 1.0, 1.0 );
		if ( pvpType == "sanctuary" ) then
			GameTooltip:AddLine( subzoneName, 0.41, 0.8, 0.94 );	
			GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1);
		elseif ( pvpType == "friendly" ) then
			GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 );	
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1);
		elseif ( pvpType == "hostile" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1);
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.7, 0.0 );	
			GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0);
		elseif ( pvpType == "combat" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );	
			GameTooltip:AddLine(COMBAT_ZONE, 1.0, 0.1, 0.1);
		else
			GameTooltip:AddLine( subzoneName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );	
		end
		GameTooltip:Show();
	end);
	
	timeFrame:SetScript("OnLeave", function(self)
		GameTooltip:Hide();
	end);
	
	--setting TimeManagerFrame & DurabilityFrame below the timeFrame
	TimeManagerFrame:ClearAllPoints();
	TimeManagerFrame:SetPoint("TOP", timeFrame, "BOTTOM", 0, 0);
	
	DurabilityFrame:ClearAllPoints();
	DurabilityFrame:SetPoint("TOP", timeFrame, "BOTTOM", 5, 0);
	
end


-------------------------------------
--
-- Creates the dropDown menu and its button, where some Blizzard functionalities are stored (e.g. Calendar).
-- Used in setUpDriven function.
--
-------------------------------------
local function createDropDownMenu()

	--create dropdownMenu button
	local menuButton = CreateFrame("Button", "DrivenDropDownButton", Minimap);
	menuButton:SetSize(32,32);
	menuButton:SetPoint("RIGHT", Minimap, "LEFT",  -10, 0);
	
	menuButton:SetNormalTexture("Interface\\AddOns\\Driven\\Textures\\minimapMenuButtonNormal.blp");
	menuButton:SetHighlightTexture("Interface\\AddOns\\Driven\\Textures\\minimapMenuButtonHighlight.blp");
	menuButton:SetPushedTexture("Interface\\AddOns\\Driven\\Textures\\minimapMenuButtonPushed.blp");
	
	menuButton:SetScript("OnClick", function(self, button)
		if(self.dropDownMenu:IsShown()) then
			DropDownList1:Hide();
			frameFade(self.dropDownMenu, 0.25, 1, 0, true);
		else
			frameFade(self.dropDownMenu, 0.25, 0, 1);
		end
		PlaySound("igMainMenuOptionCheckBoxOn");
	end);

	--create dropdownMenu
	menuButton.dropDownMenu = CreateFrame("FRAME", "DrivenDropDownMenu", menuButton);
	menuButton.dropDownMenu:SetSize(150, 120);
	menuButton.dropDownMenu:SetPoint("TOPRIGHT", menuButton, "LEFT", -20, 25);
	menuButton.dropDownMenu:SetFrameStrata("HIGH");
	
	menuButton.dropDownMenu.background = menuButton.dropDownMenu:CreateTexture();
	menuButton.dropDownMenu.background:SetTexture(0,0,0, 0.75);
	menuButton.dropDownMenu.background:SetAllPoints();
	menuButton.dropDownMenu.background:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 1);
	
	menuButton.dropDownMenu:Hide();
	
	--create buttons in dropdownMenu
	menuButton.dropDownMenu.worldMap = createFontFrame("World Map", menuButton.dropDownMenu, 0, -14, function(self) ToggleFrame(WorldMapFrame) frameFade(self:GetParent(), 0.25, 1, 0, true) end);
	menuButton.dropDownMenu.calendar = createFontFrame("Calendar", menuButton.dropDownMenu, 0, -36-14, function(self) ToggleCalendar() frameFade(self:GetParent(), 0.25, 1, 0, true) end);
	menuButton.dropDownMenu.tracking = createFontFrame("Tracking", menuButton.dropDownMenu, 0, -36*2-14, function(self) ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self:GetName(), 0, -5) end);
	
end


-------------------------------------
--
-- Setups the addOn.
--
-------------------------------------
local function setUpDriven()

	hideBlizzardElements();
	
	--change border texture
	MinimapBorder:SetTexture("Interface\\AddOns\\Driven\\Textures\\border.blp");
	MinimapBorder:SetTexCoord(0,1,0,1);
	MinimapBorder:SetSize(218, 218);
	MinimapBorder:ClearAllPoints();
	MinimapBorder:SetPoint("CENTER", Minimap);
	
	--change minimap icons
	Minimap:SetBlipTexture("Interface\\AddOns\\Driven\\Textures\\OBJECTICONS.blp");
	
	--creates the fog texture in minimap
	Minimap.fog = Minimap:CreateTexture(nil, "OVERLAY");
	Minimap.fog:SetTexture("Interface\\AddOns\\Driven\\Textures\\fog.blp");
	Minimap.fog:SetSize(315, 315);
	Minimap.fog:SetPoint("CENTER", Minimap);
	
	
	createTimeFrame();
	
	createDropDownMenu();
	
	Minimap:SetScript("OnMouseWheel", function(self, value)
		if(value == 1 and Minimap:GetZoom() < 5) then
			Minimap:SetZoom(Minimap:GetZoom() + 1);
			PlaySound("igMiniMapZoomIn");
		elseif(value == -1 and Minimap:GetZoom() ~= 0) then
			Minimap:SetZoom(Minimap:GetZoom() - 1);
			PlaySound("igMiniMapZoomOut");
		end
	end);
	
end


--total: Total Elapsed, showZone: boolean.
local total, showZone = 0, false;
local radians = GetPlayerFacing();
-------------------------------------
--
-- AddOn SetScript OnUpdate
-- "Fog" texture, time and zone name is updated here.
--
-------------------------------------
Addon:SetScript("OnUpdate", function(self, elapsed)
	local temp = GetPlayerFacing();
	if(radians ~= temp) then
		radians = temp;
		Minimap.fog:SetRotation(radians);
	end
	
	--every 5secs, switch to time/zone
	switch = switch + elapsed;
	if(switch > 5) then
		switch = 0;
		showZone = showZone == false;
	end
	
	--small throttle, there's no need to "update" the fontString every frame (1 second)
	total = total + elapsed;
	if(total > 1 or switch == 0) then
		total = 0;
		if(showZone) then
			if(Minimap.timeFrame.time:IsShown()) then
				frameFade(Minimap.timeFrame.time, 0.5, 1, 0, true);
				frameFade(Minimap.timeFrame.zone, 0.5, 0, 1);
			end
		else
			if(Minimap.timeFrame.zone:IsShown()) then
				frameFade(Minimap.timeFrame.zone, 0.5, 1, 0, true);
				frameFade(Minimap.timeFrame.time, 0.5, 0, 1);
			end
			Minimap.timeFrame.time:SetText(GameTime_GetTime(false));
		end
	end
	
end);


-------------------------------------
--
-- Addon SetScript OnEvent
-- Inits Driven and updates zone text when changing zones.
--
-- Handled events:
-- "PLAYER_ENTERING_WORLD"
-- "ZONE_CHANGED"
-- "ZONE_CHANGED_INDOORS"
-- "ZONE_CHANGED_NEW_AREA"
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		setUpDriven();
		Addon:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
	Minimap.timeFrame.zone:SetText(GetMinimapZoneText());
end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");
Addon:RegisterEvent("ZONE_CHANGED");
Addon:RegisterEvent("ZONE_CHANGED_INDOORS");
Addon:RegisterEvent("ZONE_CHANGED_NEW_AREA");