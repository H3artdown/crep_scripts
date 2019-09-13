local vote_option = { }
local current_tickcount = 0

local call_first_vote = true
local cooldown_callvote_swapteams = 0
local cooldown_callvote_changelevel = 0
local callvote_swapteams_start_time = 0
local callvote_changelevel_start_time = 0
local swapteams_cooldown = false
local changelevel_cooldown = false
local any_vote_started_start_time = 0
local any_vote_started_cooldown = false

local sub = menu.add_subcategory("misc", "anti kick")
local enabled = menu.add_checkbox("anti kick enabled", "s", false, sub)
local steal_name = menu.get_control("general misc", "steal name")

function on_vote_options(event)
    if menu.get_value(enabled) ~= 1 then
        return
    end
    
    vote_option[0] = event.option1
    vote_option[1] = event.option2
    vote_option[2] = event.option3
    vote_option[3] = event.option4
    vote_option[4] = event.option5

    current_tickcount = client.realtime()
end

function on_vote_cast(event)
    if menu.get_value(enabled) ~= 1 then
        return
    end
    
	local userid = event.entityid
	if userid == nil then
		return
	end
	local map = client.get_mapname()

	if client.get_localplayer() == userid then
		if current_tickcount + 2 > client.realtime() then
			if vote_option[event.vote_option] == "No" then
				if call_first_vote == false and changelevel_cooldown == false and any_vote_started_cooldown == false then
					client.exec("callvote changelevel ".. map)
					call_first_vote = true
					changelevel_cooldown = true
					callvote_changelevel_start_time = client.curtime()

					any_vote_started_start_time = client.curtime()
					any_vote_started_cooldown = true
                    menu.set_value(steal_name, 1)
				elseif swapteams_cooldown == false and any_vote_started_cooldown == false then
					client.exec("callvote swapteams")
					call_first_vote = false
					swapteams_cooldown = true
					callvote_swapteams_start_time = client.curtime()

					any_vote_started_start_time = client.curtime()
					any_vote_started_cooldown = true
                    menu.set_value(steal_name, 1)
				end

			end
		end
	end
end

function on_paint()
    if menu.get_value(enabled) ~= 1 then
        return
    end
    
    if client.is_ingame() ~= true then
      return
    end
    
    local lowest_cooldown = 0

    local curtime = client.curtime()
    local cooldown_callvote_swapteams_static = 300 - (curtime - callvote_swapteams_start_time)
    local cooldown_callvote_changelevel_static = 300 - (curtime - callvote_changelevel_start_time)
    -- run timer, counts down
    if swapteams_cooldown == true then
    if cooldown_callvote_swapteams_static < 0 then
        swapteams_cooldown = false
    end
    cooldown_callvote_swapteams = cooldown_callvote_swapteams_static
    else
    cooldown_callvote_swapteams = 0
    end

    if changelevel_cooldown == true then
    if cooldown_callvote_changelevel_static < 0 then
        changelevel_cooldown = false
    end
        cooldown_callvote_changelevel = cooldown_callvote_changelevel_static
    else
        cooldown_callvote_changelevel = 0
    end

    if any_vote_started_cooldown == true then
    if math.min(cooldown_callvote_swapteams, cooldown_callvote_changelevel) < 90 then
        lowest_cooldown = 90 - (curtime - any_vote_started_start_time)
        if lowest_cooldown < 0 then
            any_vote_started_cooldown = false
        end
    else
        lowest_cooldown = math.min(cooldown_callvote_swapteams, cooldown_callvote_changelevel)
    end
    else
    lowest_cooldown = math.min(cooldown_callvote_swapteams, cooldown_callvote_changelevel)
    end
end

client.set_event_callback("on_paint","on_paint")
client.set_event_callback("vote_cast","on_vote_cast")
client.set_event_callback("vote_options","on_vote_options")
