
----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

-- Debugging Mode
	local bDebugMode = false;
	
-- Localization
	--local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

-- Required Titan variables
	TITAN_SOCIAL_ID = "Social";
	TITAN_SOCIAL_VERSION = "5.1r15";
	TITAN_NIL = false;
	
-- Update frequency
	TITAN_SOCIAL_UPDATE = 15.0;	-- Update every 15 seconds to avoid roster update nastiness

-- Friend-specific variables
	local iFriendsTab = 1;
-- RealID-specific variables
-- Guild-specific variables
	local iGuildTab = 1;

-- Counters for Titan Bar Display
	local iRealIDOnline, iFriendsOnline, iGuildOnline = 0;

	local MOBILE_BUSY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t";
	local MOBILE_AWAY_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t";

-- Class support
	local TitanSocial_ClassMap = {}
	
-- Build the class map
	
	for i = 1, GetNumClasses() do
		local name, className, classId = GetClassInfo(i)
    TitanSocial_ClassMap[LOCALIZED_CLASS_NAMES_MALE[className]] = className
    TitanSocial_ClassMap[LOCALIZED_CLASS_NAMES_FEMALE[className]] = className
	end

----------------------------------------------------------------------
--  Global variables
----------------------------------------------------------------------


----------------------------------------------------------------------
-- TitanPanelSocial_ColorText(text, className)
----------------------------------------------------------------------

function TitanPanelSocialButton_ColorText(text, className)

	local classIndex, coloredText=nil

	local class = TitanSocial_ClassMap[className]
  local color = nil
	if class == nil then
		color = "ffcccccc"
	else
		color = RAID_CLASS_COLORS[class].colorStr
	end
	return "|c"..color..text.."|r"
end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnLoad(self)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnLoad(self)


	--
	-- LOCAL REGISTRY --
	--
	
		self.registry = { 
			id = TITAN_SOCIAL_ID,
			version = TITAN_SOCIAL_VERSION,
			menuText = TITAN_SOCIAL_MENU_TEXT, 
			buttonTextFunction = "TitanPanelSocialButton_GetButtonText",
			tooltipTitle = TITAN_SOCIAL_TOOLTIP,
			tooltipTextFunction = "TitanPanelSocialButton_GetTooltipText",
			iconWidth = 16,
			icon = "Interface\\FriendsFrame\\BroadcastIcon",
			category = "Information",
			controlVariables = {
				ShowIcon = true,
				--ShowLabelText = true,
				DisplayOnRightSide = false
				--ShowRegularText = false,
				--ShowColoredText = true,
			},
			savedVariables = {       
				ShowRealID = 1,
				ShowRealIDBroadcasts = false,
				ShowFriends = 1,
				ShowFriendsNote = 1,
				ShowGuild = 1,
				ShowGuildLabel = false,
				ShowGuildNote = 1,
				ShowSplitRemoteChat = 1,
				ShowGuildONote = 1,
				ShowIcon = 1,
				ShowLabel = 1,
				ShowTooltipTotals = 1,
				ShowMem = false,
			  }
		};

	--
	-- CONFIGURATION --
	--
	
		-- Load these settings from SavedVariables/&Set Defaults
		
		-- Dynamic Settings


	--
	-- EVENT CATCHING --
	--
	
		-- General Events
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
		
		-- RealID Events
		self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
		self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
		self:RegisterEvent("BN_FRIEND_TOON_OFFLINE");
		self:RegisterEvent("BN_FRIEND_TOON_ONLINE");
		self:RegisterEvent("BN_TOON_NAME_UPDATED");
		
		-- Friend Events
		self:RegisterEvent("FRIENDLIST_UPDATE");
		
		-- Guild Events
		self:RegisterEvent("GUILD_ROSTER_UPDATE");
		
end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnEvent(self, event, ...)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnEvent(self, event, ...)

	-- Debugging. Pay no attention to the man behind the curtain.
	if(bDebugMode) then
		DEFAULT_CHAT_FRAME:AddMessage("Social: OnEvent");
		if(event == "PLAYER_ENTERING_WORLD") then
			DEFAULT_CHAT_FRAME:AddMessage(TITAN_SOCIAL_ID.." v"..TITAN_SOCIAL_VERSION.." Loaded.");
		end
		DEFAULT_CHAT_FRAME:AddMessage("Social: Caught Event "..event);
	end

	-- Update button label
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);

end

----------------------------------------------------------------------
-- TitanPanelSocialButton_OnEnter(self)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnEnter(self)

	-- If in a guild, steal roster update. If not, ignore and update anyway
	if (IsInGuild()) then	
		FriendsFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
		GuildRoster();
		FriendsFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
	end

	-- Update Titan button label and tooltip
	TitanPanelButton_UpdateButton(TITAN_SOCIAL_ID);	
	TitanPanelButton_UpdateTooltip(self);
end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnUpdate(self, elapsed)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnUpdate(self, elapsed)
	
	-- From wowwiki, best practices for low-intensity onupdates.
	-- Run updates every TITAN_SOCIAL_UPDATE to keep resources low
	-- and avoid 10s timeout/wait from guild_update_roster
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	
	if (self.TimeSinceLastUpdate > TITAN_SOCIAL_UPDATE) then
		TitanPanelSocialButton_GetButtonText(TitanUtils_GetButton(id));
		self.TimeSinceLastUpdate = 0;
		if(bDebugMode) then
			DEFAULT_CHAT_FRAME:AddMessage("Social: OnUpdate Timer");
		end
	end

end

----------------------------------------------------------------------
--  TitanPanelSocialButton_OnClick(self, button)
----------------------------------------------------------------------

function TitanPanelSocialButton_OnClick(self, button)

	-- Detect mouse clicks
	if (button == "LeftButton") then

		if (TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil or TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~= nil) then
      ToggleFriendsFrame(iFriendsTab);
      FriendsFrame_Update();
    end
    
    if (TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~= nil) then
      ToggleGuildFrame(iGuildTab);
    end
    
	end
	
end

----------------------------------------------------------------------
--  TitanPanelRightClickMenu_PrepareSocialMenu()
----------------------------------------------------------------------

function TitanPanelRightClickMenu_PrepareSocialMenu()     
	
	local info = {};
	
	
	-- Level 2
	if _G["UIDROPDOWNMENU_MENU_LEVEL"] == 2 then
	
		-- RealID Menu
		if _G["UIDROPDOWNMENU_MENU_VALUE"] == "RealID" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_REALID, _G["UIDROPDOWNMENU_MENU_LEVEL"]);

			-- Show RealID Friends
				local temptable = {TITAN_SOCIAL_ID, "ShowRealID"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_REALID_FRIENDS;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
			-- Show RealID Broadcasts
				local temptable = {TITAN_SOCIAL_ID, "ShowRealIDBroadcasts"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_REALID_BROADCASTS;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDBroadcasts");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
		end
		
		-- Friends Menu
		if _G["UIDROPDOWNMENU_MENU_VALUE"] == "Friends" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_FRIENDS, _G["UIDROPDOWNMENU_MENU_LEVEL"]);

			-- Show Friends
				local temptable = {TITAN_SOCIAL_ID, "ShowFriends"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_FRIENDS_SHOW;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
			-- Show Friend Notes
			local temptable = {TITAN_SOCIAL_ID, "ShowFriendsNote"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_FRIENDS_NOTE;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowFriendsNote");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
		end
		
		-- Guild Menu
		if _G["UIDROPDOWNMENU_MENU_VALUE"] == "Guild" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_GUILD, _G["UIDROPDOWNMENU_MENU_LEVEL"]);

			-- Show Guild Members
				local temptable = {TITAN_SOCIAL_ID, "ShowGuild"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_GUILD_MEMBERS;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
			-- Show Guild Name as Label
				local temptable = {TITAN_SOCIAL_ID, "ShowGuildLabel"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_GUILD_LABEL;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildLabel");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
			-- Show Guild Note
				local temptable = {TITAN_SOCIAL_ID, "ShowGuildNote"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_GUILD_NOTE;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildNote");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
			-- Show Officer Note
				local temptable = {TITAN_SOCIAL_ID, "ShowGuildONote"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_GUILD_ONOTE;
				info.value = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildONote");
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
      -- Show Separate Remote Chat
				local temptable = {TITAN_SOCIAL_ID, "ShowSplitRemoteChat"};
				info = {};
				info.text = TITAN_SOCIAL_MENU_GUILD_REMOTE_CHAT;
				info.valeu = temptable;
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar(temptable);
					end
				info.checked = TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat")
				info.keepShowOnClick = 1;
				UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
				
		end
		
		if _G["UIDROPDOWNMENU_MENU_VALUE"] == "Options" then
			TitanPanelRightClickMenu_AddTitle(TITAN_SOCIAL_MENU_OPTIONS, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
		end
		
		return
	end
  
  
	-- Level 1
	
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SOCIAL_ID].menuText);
	
	-- RealID Menu
		info={};
		info.text = TITAN_SOCIAL_MENU_REALID;
		info.value = "RealID";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	
	-- Friends Menu
		info = {};
		info.text = TITAN_SOCIAL_MENU_FRIENDS;
		info.value = "Friends";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
		
	-- Guild Menu
		info = {};
		info.text = TITAN_SOCIAL_MENU_GUILD;
		info.value = "Guild";
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddToggleIcon(TITAN_SOCIAL_ID);
	TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_LABEL, TITAN_SOCIAL_ID, "ShowLabel");
	TitanPanelRightClickMenu_AddToggleVar(TITAN_SOCIAL_MENU_MEM, TITAN_SOCIAL_ID, "ShowMem");
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(TITAN_SOCIAL_MENU_HIDE, TITAN_SOCIAL_ID, TITAN_PANEL_MENU_FUNC_HIDE);



end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetButtonText(id)
----------------------------------------------------------------------

function TitanPanelSocialButton_GetButtonText(id)
	local label = " "
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowLabel") then
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildLabel") and TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") and IsInGuild() then
			local guildName = GetGuildInfo("player")
			if guildName then
				label = guildName..": "
			else
				label = "...: "
			end
		else
			label = TITAN_SOCIAL_BUTTON_TITLE
		end
	end

	local comps = {}

	if TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") then
		table.insert(comps, "|cff00A2E8"..select(2, BNGetNumFriends()).."|r")
	end
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") then
		table.insert(comps, "|cffFFFFFF"..select(2,GetNumFriends()).."|r")
	end
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") then
		local online, remote = select(2, GetNumGuildMembers())
		local _, online, remote = GetNumGuildMembers()
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat") then
			remote = remote - online
		else
			online, remote = remote, nil
		end
		table.insert(comps, "|cff00FF00"..online.."|r")
		if remote ~= nil then
			table.insert(comps, "|cff00BB00"..remote.."|r")
		end
	end

	label = label .. table.concat(comps, " |cffffd200/|r ")

	return TITAN_SOCIAL_BUTTON_TITLE, label;
end

----------------------------------------------------------------------
-- TitanPanelSocialButton_GetTooltipText()
----------------------------------------------------------------------

function TitanPanelSocialButton_GetTooltipText()

	local iRealIDTotal, iRealIDOnline = 0;
	local iFriendsTotal, iFriendsOnline = 0;
	local iGuildTotal, iGuildOnline = 0;
	local tTooltipRichText, playerStatus, clientName = "";
	local bGuildOffline = GetGuildRosterShowOffline()	-- Enable/disable including offline guild members
	
	--
	--	RealID Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowRealID") ~=nil) then
		iRealIDTotal, iRealIDOnline = BNGetNumFriends();
		--iRealIDOnline  = "|cff00A2E8"..iRealIDOnline.."|r";

		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REALID).."\t".."|cff00A2E8"..iRealIDOnline.."|r"..TitanUtils_GetNormalText("/"..iRealIDTotal).."\n"
		
		for friendIndex=1, iRealIDOnline do

			presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfo(friendIndex)
			unknowntoon, toonName, client, realmName, realmID, faction, race, className, unknown, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(presenceID)

			-- playerStatus
				if (isAFK) then
					playerStatus = "AFK"
				elseif (isDND) then
					playerStatus = "DND"
				else
					playerStatus = ""
				end
				
			-- Client Information
				if (client == "S2") then
					clientName = "S2"
				elseif (client == "D3") then
					clientName = "D3"
				else
					clientName = "??"
				end
			
			-- Stan Smith {SC2} ToonName 80 <AFK/DND>\t Location
			-- Stan Smith Toonname 80 (SC2)
			
			if(client ~= "WoW") then
				-- Client Name
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..clientName.."|r  "
				tTooltipRichText = tTooltipRichText.."|cffCCCCCC"..toonName.."|r ";
			else
				-- Character Level
				tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  "
				-- Character
				tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(toonName, className).." ";
			end
			
			-- Character
			--tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(toonName, className).." ";
			
			-- Full Name
			local fullName
			if isBattleTagPresence then
				fullName = battleTag
			else
				fullName = presenceName
			end
			tTooltipRichText = tTooltipRichText.."[|cff00A2E8"..fullName.."|r]  "
			
			-- Status
			if (playerStatus ~= 0) then
                  if (playerStatus == 1) then
                    tTooltipRichText = tTooltipRichText.."|cffFFFFFF".."<AFK>".."|r  ";
                  end
	           end
			
			-- Broadcast
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowRealIDBroadcasts") ~= nil) then
				if (broadcastText ~= nil) then
				-- it seems as though newlines in broadcastText reset the coloration
				-- Also try to nudge subsequent lines over a bit
				local color = "|cff00A2E8"
				broadcastText = broadcastText:gsub("\n", "|r".."\n        "..color)
				tTooltipRichText = tTooltipRichText..color..broadcastText.."|r ";
				end
			end
			
			-- Character Location
			tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..gameText.."|r\n";

		end
	end
	
	--
	-- Friends
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowFriends") ~=nil) then
	
		iFriendsTotal, iFriendsOnline = GetNumFriends();
	
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_FRIENDS).."\t".."|cffFFFFFF"..iFriendsOnline.."|r"..TitanUtils_GetNormalText("/"..iFriendsTotal).."\n"
		
		for friendIndex=1, iFriendsOnline do
		
			name, level, class, area, connected, playerStatus, playerNote, RAF = GetFriendInfo(friendIndex);
			
			-- toonName Fix
				if (name == "") then
					name = "Unknown"
				end
			
			-- Level
			tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..level.."|r  ";
			
			-- Name
			tTooltipRichText = tTooltipRichText..TitanPanelSocialButton_ColorText(name, class).." ";

			-- Status
			if (playerStatus ~= 0) then
                  if (playerStatus == 1) then
                    tTooltipRichText = tTooltipRichText.."|cffFFFFFF".."<AFK>".."|r  ";
                  end
	           end
			
			-- Notes
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowFriendsNote") ~= nil) then
				if(playerNote ~= nil) then
					tTooltipRichText = tTooltipRichText.."|cffFFFFFF"..playerNote.."|r ";
				end
			end
			
			-- Location
			--tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..area.."|r\n";
			if (area ~= nil) then 
				tTooltipRichText = tTooltipRichText.."\t|cffFFFFFF"..area.."|r\n" 
			end 
		
		end
	end
	
	--
	-- Guild
	--
	
	if(TitanGetVar(TITAN_SOCIAL_ID, "ShowGuild") ~=nil) then
	
		-- Turn off showoffline for tooltip
		SetGuildRosterShowOffline(false);
		
		iGuildTotal, iGuildOnline, iGuildRemote = GetNumGuildMembers();
		--iGuildOnline   = "|cff00FF00"..iGuildOnline.."|r";
		
		local remoteChatText = nil
		local numGuild = iGuildRemote
		if TitanGetVar(TITAN_SOCIAL_ID, "ShowSplitRemoteChat") ~= nil then
			remoteChatText = ""
			numGuild = iGuildOnline
		end
		local guildText = ""
		
		for guildIndex=1, iGuildRemote do
		
			name, rank, rankIndex, level, class, zone, note, officernote, online, playerStatus, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(guildIndex);
			
			local currentText = ""
			
			-- toonName Fix
				if (name=="") then
					name = "Unknown"
				end
			
			local isRemote = (guildIndex > iGuildOnline)
			if isMobile then
				if isRemote then zone = REMOTE_CHAT end
				if playerStatus == 2 then
					name = MOBILE_BUSY_ICON..name
				elseif playerStatus == 1 then
					name = MOBILE_AWAY_ICON..name
				else
					name = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..name
				end
			end
			
			-- 80 {color=class::Playername} {<AFK>} Rank Note ONote\t Location
			
			-- Level
			currentText = currentText.."|cffFFFFFF"..level.."|r  "

			-- Name
			currentText = currentText..TitanPanelSocialButton_ColorText(name, class).." ";

			-- Status
			if (playerStatus ~= 0) then
                  if (playerStatus == 1) then
                    currentText = currentText.."|cffFFFFFF".."<AFK>".."|r  ";
                  else
                    currentText = currentText.."|cffFFFFFF".."<DND>".."|r  ";
                  end
	           end

			-- Rank
			currentText = currentText..rank.."  ";
			
			-- Notes
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildNote") ~= nil) then
				currentText = currentText.."|cffFFFFFF"..note.."|r  "
			end
			
			-- Officer Notes
			if(TitanGetVar(TITAN_SOCIAL_ID, "ShowGuildONote") ~= nil) then
				if(CanViewOfficerNote()) then
					currentText = currentText.."|cffAAFFAA"..officernote.."|r  "
				end
			end
			
			-- Location
			if (zone ~= nil) then 
				currentText = currentText.."\t|cffFFFFFF"..zone.."|r\n"
			else
				currentText = currentText.."\n"
			end
			
			if isRemote and remoteChatText ~= nil then
				remoteChatText = remoteChatText..currentText
			else
				guildText = guildText..currentText
			end
			
		end
		
		-- Reset ShowOffline Guild Members to original value
		if (bGuildOffline) then
			SetGuildRosterShowOffline(true);
		end
		
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_GUILD).."\t".."|cff00FF00"..numGuild.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"..guildText

		if remoteChatText ~= nil then
			local numRemoteChat = iGuildRemote - iGuildOnline
			tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_REMOTE_CHAT).."\t".."|cff00FF00"..numRemoteChat.."|r"..TitanUtils_GetNormalText("/"..iGuildTotal).."\n"..remoteChatText
		end
	
	end
	
	if (TitanGetVar(TITAN_SOCIAL_ID, "ShowMem") ~=nil) then
		tTooltipRichText = tTooltipRichText.." \n"..TitanUtils_GetNormalText(TITAN_SOCIAL_TOOLTIP_MEM).."\t|cff00FF00"..floor(GetAddOnMemoryUsage("TitanSocial")).." "..TITAN_SOCIAL_TOOLTIP_MEM_UNIT.."|r";
	end
	
	return tTooltipRichText;
end








































