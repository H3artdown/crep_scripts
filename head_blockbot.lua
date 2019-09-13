notify.add("Troll head block by kazumi")
local enabled = menu.add_checkbox("block bot", "head block", false, 0)
local key = menu.add_keybinder("block hold key", "head block", false, 0)
    
function on_setup_command()
    if menu.get_value(enabled) ~= 1 then
      return
    end
    
    if menu.get_value(key) == -1 then
      return
    end
    
    if client.is_keypressed(menu.get_value(key)) ~= true then
        return
    end
    
    local local_id = client.get_localplayer()
    
    if entity.is_alive(local_id) == true then
        local blockplayer = entity.get_prop(local_id, 4, "DT_BasePlayer", "m_hGroundEntity")
        
        if blockplayer ~= 0 then
           local playerLocX, playerLocY, playerLocZ = entity.get_prop(local_id, 2, "DT_BasePlayer", "m_vecOrigin")
            local p_x, p_y, p_z = entity.get_prop(blockplayer, 2, "DT_BasePlayer","m_vecOrigin")
            local distancex, distancey = playerLocX - p_x, playerLocY - p_y
            if entity.is_alive(blockplayer) == true then
                cmd.set_forwardmove(-distancex * 500)
                cmd.set_sidemove(distancey * 500)
                cmd.set_moveyaw(0)
            end
        end
    end
end

client.set_event_callback("setup_command","on_setup_command")
