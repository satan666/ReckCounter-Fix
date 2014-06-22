--[[  ReckCounter v1.3a by Warflea of Azjol-Nerub
        
       Super simple compact reckoning counter.

       LOCALIZATION HELP REQUESTED

       http://www.curse-gaming.com/mod.php?addid=1769

       Note: This plug in only counts stored reckoning hits.  Stored hits accumulate
             only while AUTO ATTACK is off.

      Updates: 1.1  Hides frame if player is not a paladin.
                    Creates circles instead of text numbers
                    Highlight and shine effects added, thank you Blizzard for the code/reference!
               1.2  Minor graphic fixes
                    Chat commands! Type /reckcounter for options.
               1.3  More algorithm improvements.  Reckoning is a beast to tame...
                    Verbosity commands (off by default).  Tells you why ReckCounter reset.
               1.3a Updated patch number.
                    Added localization file giving non-english client users 
                      easy access to the english texts which require changing.
                   


]]

--Slash command text
RECKCOUNTER_HELP = "ReckCounter Commands:";
RECKCOUNTER_HELP2 = "help | show | hide | lock | unlock | showtext | hidetext | verbose | quiet";
RECKCOUNTER_SHOW = "ReckCounter now displaying.";
RECKCOUNTER_HIDE = "ReckCounter hidden. Type /reck for commands.";
RECKCOUNTER_LOCK = "ReckCounter locked.";
RECKCOUNTER_UNLOCK = "ReckCounter unlocked.";
RECKCOUNTER_SHOWTEXT = "ReckCounter text now displaying.";
RECKCOUNTER_HIDETEXT = "ReckCounter text hidden.";
RECKCOUNTER_VERBOSE = "ReckCounter now in Verbose mode.";
RECKCOUNTER_QUIET = "ReckCounter now in Quiet mode.";

--text color
RECK_RED = .8;
RECK_GREEN = .8;
RECK_BLUE = 0;

--variables
reckcount = 0;
auto_attack = false;
reckcounter_movable = true;
reckcounter_verbose = false;


function reckcounter_OnLoad()
    this:RegisterForDrag("LeftButton");
    this:RegisterEvent("VARIABLES_LOADED"); --Watch for initialization
    --this:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF"); -- Watch for Reckoning procs
    
	
    SLASH_RECKCOUNTER1 = "/reckcounter";
    SLASH_RECKCOUNTER2 = "/reck";
    SlashCmdList["RECKCOUNTER"] = reckcounter_Command;    
end

function reckcounter_Command(msg)
    if ( msg ) then
        reck_command = string.lower(msg);    
        if ( reck_command == "show" ) then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_SHOW , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_core:Show();
        elseif (reck_command == "hide") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HIDE , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_core:Hide();
        elseif (reck_command == "lock") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_LOCK , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_movable = false;
        elseif (reck_command == "unlock") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_UNLOCK , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_movable = true;
        elseif (reck_command == "showtext") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_SHOWTEXT , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_display:Show();
        elseif (reck_command == "hidetext") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HIDETEXT , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_display:Hide();
        elseif (reck_command == "verbose") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_VERBOSE , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_verbose = true;
        elseif (reck_command == "quiet") then
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_QUIET , RECK_RED, RECK_GREEN, RECK_BLUE);
            reckcounter_verbose = false;
        else
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HELP , RECK_RED, RECK_GREEN, RECK_BLUE);
            DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HELP2 , RECK_RED, RECK_GREEN, RECK_BLUE);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HELP , RECK_RED, RECK_GREEN, RECK_BLUE);
        DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HELP2 , RECK_RED, RECK_GREEN, RECK_BLUE);
    end
end


function reckcounter_initialize()
    --Auto hides if Player is a Paladin
    --Sets Reckcounter text above combo gauge (might remove ifv) 
    if (UnitClass("player") ~= "Paladin") then
        reckcounter_core:Hide();
        DEFAULT_CHAT_FRAME:AddMessage(RECKCOUNTER_HIDE , RECK_RED, RECK_GREEN, RECK_BLUE);
    end
    reckcounter_display:SetText("ReckCounter");
    update_reckcounter(0);
end 

function update_reckcounter(reck)
    --Updates GUI to reflect reckonings stored
    --Shamelessly cut from ComboFrame.lua
    if ( reck > 0 ) then		
        for i=1, 4 do
	    comboPointHighlight = getglobal("ReckCounter"..i.."Highlight");
	    comboPointShine = getglobal("ReckCounter"..i.."Shine");
	    if ( i <= reck ) then
	        if ( comboPointHighlight:GetAlpha() == 0 or reck == 4) then
		    -- Fade in the highlight and set a function that triggers when it is done fading
		    fadeInfo = {};
                    fadeInfo.mode = "IN";
		    fadeInfo.timeToFade = .4;
		    fadeInfo.finishedFunc = ComboPointShineFadeIn;
		    fadeInfo.finishedArg1 = comboPointShine;
		    UIFrameFade(comboPointHighlight, fadeInfo);
		end
	    else
	        comboPointHighlight:SetAlpha(0);
		comboPointShine:SetAlpha(0);
	    end
	end
    else
        ReckCounter1Highlight:SetAlpha(0);
	ReckCounter1Shine:SetAlpha(0);
	ReckCounter2Highlight:SetAlpha(0);
	ReckCounter2Shine:SetAlpha(0);
	ReckCounter3Highlight:SetAlpha(0);
	ReckCounter3Shine:SetAlpha(0);
	ReckCounter4Highlight:SetAlpha(0);
	ReckCounter4Shine:SetAlpha(0);
    end
end

function reckcounter_OnEvent()  
    if(event == "VARIABLES_LOADED" ) then 
        reckcounter_initialize(); 
		this:RegisterEvent("PLAYER_ENTER_COMBAT"); -- Events below are for resetting ReckCounter
		this:RegisterEvent("PLAYER_LEAVE_COMBAT");
		this:RegisterEvent("PLAYER_DEAD");
		this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
		this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES");
		
		this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");
		this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS");
		this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE");
	end
    
	if (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE") then 
		if (arg1 and not auto_attack) then  
			if (reckcount < 4 and string.find(arg1, "crits you")) then
				reckcount = reckcount + 1;
				update_reckcounter(reckcount)
			end
		end	
    end
	
	--[[
		FUCK THIS EVENT HANDLER :)
		
    if ( event == "CHAT_MSG_SPELL_SELF_BUFF" ) then
		if ( auto_attack == false ) then       
            if (reckcount < 4) then
                if (string.find(arg1, RECKCOUNTER_RECKONING) ~= nil) then 
                    reckcount = reckcount + 1;
                    update_reckcounter(reckcount);
                end
            end
        end 
    end
	--]]
	
    if ( event == "PLAYER_ENTER_COMBAT" ) then
        auto_attack = true;
    end   

    if ( event == "PLAYER_LEAVE_COMBAT" ) then
        auto_attack = false;
        reckcounter_reset("Player changed targets after activating auto attack.");
    end

    if ( event == "PLAYER_DEAD" ) then
        auto_attack = false;
        reckcounter_reset("Player has died.");
    end
    
    if ( event == "CHAT_MSG_COMBAT_SELF_HITS" ) then
        --Check to see if hit was a weapon hit
        --If it was, reset ReckCounter.
        --Sea.IO.banner("CMCSH",arg1,arg2,arg3,arg4);
        if ( string.find(arg1, RECKCOUNTER_YOUHIT) ~= nil or string.find(arg1, RECKCOUNTER_YOUCRIT) ~= nil) then
            reckcounter_reset("Player started auto attack (hit).");
        end
    end
    
    if ( event == "CHAT_MSG_COMBAT_SELF_MISSES" ) then
        --Sea.IO.banner("CMCSM",arg1,arg2,arg3,arg4);
        reckcounter_reset("Player started auto attack (miss).");
    end
end

function reckcounter_OnDragStart()
    if (reckcounter_movable == true ) then
        this:StartMoving();
        this.isMoving = true;
    end
end

function reckcounter_OnDragStop()
    this:StopMovingOrSizing();
    this.isMoving = false;
end

function reckcounter_reset(reason)
    if (reckcounter_verbose == true and reckcount > 0) then
        DEFAULT_CHAT_FRAME:AddMessage("ReckCounter Reset! " .. reason , RECK_RED, RECK_GREEN, RECK_BLUE);
    end
    reckcount = 0;
    update_reckcounter(reckcount);
end


function ComboPointShineFadeIn(frame)
        -- Shamelessly cut from ComboFrame.lua
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = .6;
	fadeInfo.finishedFunc = ComboPointShineFadeOut;
	fadeInfo.finishedArg1 = frame:GetName();
	UIFrameFade(frame, fadeInfo);
end


function ComboPointShineFadeOut(frameName)
	UIFrameFadeOut(getglobal(frameName), .8);
end