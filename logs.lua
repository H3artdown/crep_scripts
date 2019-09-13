notify.add("event log by kazumi")

local event_log = menu.add_checkbox("event log", "misc", false, 0)

local hitgroups =
{
  [1] = "generic",
  [2] = "head",
  [3] = "chest",
  [4] = "pelvis",
  [5] = "left arm",
  [6] = "right arm",
  [7] = "left leg",
  [8] = "right leg",
}

function on_player_hurt(e)
    if menu.get_value(event_log) ~= 1 then
      return
    end

    local attacker = e.attacker
    local attacker_id = entity.get_userid(attacker)

    local victim = e.userid
    local victim_id = entity.get_userid(victim)

    if attacker_id == client.get_localplayer() then
      notify.add("Dealt " .. e.dmg_health .. " damage to " .. entity.get_name(victim_id) .. " in the " .. hitgroups[e.hitgroup + 1])
    end
end

function on_item_purchase(e)
    if menu.get_value(event_log) ~= 1 then
      return
    end

    local user = e.userid
    local user_id = entity.get_userid(user)

    if entity.is_enemy(user_id) == true then
      notify.add(entity.get_name(user_id) .. " purchased " .. e.weapon)
    end
end

function on_bomb_defused(e)

    if menu.get_value(event_log) ~= 1 then
      return
    end

    local user = e.userid
    local user_id = entity.get_userid(user)

    notify.add(entity.get_name(user_id) .. " defused the bomb" )

end

function on_bomb_begindefuse(e)

    if menu.get_value(event_log) ~= 1 then
      return
    end

    local user = e.userid
    local user_id = entity.get_userid(user)

    notify.add(entity.get_name(user_id) .. " is defusing" )
	
end

function on_bomb_beginplant(e)

    if menu.get_value(event_log) ~= 1 then
      return
    end

    local user = e.userid
    local user_id = entity.get_userid(user)

    notify.add(entity.get_name(user_id) .. " is planting" )
	
end

client.set_event_callback("player_hurt","on_player_hurt")
client.set_event_callback("item_purchase","on_item_purchase")

client.set_event_callback("bomb_beginplant","on_bomb_beginplant")
client.set_event_callback("bomb_begindefuse","on_bomb_begindefuse")
client.set_event_callback("bomb_defused","on_bomb_defused")

