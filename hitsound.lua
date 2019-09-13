notify.add("Hitmarker by kazumi")

local sub = menu.add_subcategory("misc", "hitmarkers")
local hitsound = menu.add_checkbox("hit sound", "s", false, sub)
local hitmarker = menu.add_checkbox("hit marker", "s", false, sub)

local last_hurt_time = 0

function on_player_hurt(e)
    local attacker = e.attacker
    local attacker_id = entity.get_userid(attacker)
    
    if attacker_id == client.get_localplayer() then
        if menu.get_value(hitsound) == 1 then
            client.exec("play buttons\\arena_switch_press_02.wav")
        end
        if menu.get_value(hitmarker) == 1 then
            last_hurt_time = client.realtime()
        end
    end
end

function on_paint()
    if menu.get_value(hitmarker) ~= 1 then
        return
    end
    
    if client.is_ingame() ~= true then
        return
    end
    
    local local_player = client.get_localplayer()
    
    if local_player == nil then
        return
    end
    
    if entity.is_alive(local_player) ~= true then
        return
    end
    
    local width, height = client.get_screensize()
    local screen_center_x, screen_center_y;
    screen_center_x = width / 2;
    screen_center_y = height / 2;
    
    realtime = client.realtime()
    duration = 0.40
    
    if last_hurt_time + duration > realtime then
        local alpha = 255
        if ((last_hurt_time - (realtime - duration) < (duration / 2))) then
            alpha = (last_hurt_time - (realtime - duration)) / (duration / 2) * 255;
        end
        
        renderer.draw_line(screen_center_x - 4 * 2, screen_center_y - 4 * 2, screen_center_x - 4, screen_center_y - 4, 1,255, 255, 255, alpha);
        renderer.draw_line(screen_center_x - 4 * 2, screen_center_y + 4 * 2, screen_center_x - 4, screen_center_y + 4, 1,255, 255, 255, alpha);
		renderer.draw_line(screen_center_x + 4 * 2, screen_center_y + 4 * 2, screen_center_x + 4, screen_center_y + 4, 1,255, 255, 255, alpha);
		renderer.draw_line(screen_center_x + 4 * 2, screen_center_y - 4 * 2, screen_center_x + 4, screen_center_y - 4, 1,255, 255, 255, alpha);
    end
end

client.set_event_callback("on_paint","on_paint")
client.set_event_callback("player_hurt","on_player_hurt")