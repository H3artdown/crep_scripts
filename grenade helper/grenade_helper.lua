local grenades_data = require "grenade_data"

local sub = menu.add_subcategory("visuals", "grenade helper")
local enabled = menu.add_checkbox("grenade helper enabled", "s", false, sub)
local auto_throw = menu.add_checkbox("auto throw", "s", false, sub)
local dot_size = menu.add_slider("dot size", "n", 6, 1, 15, sub)
local key = menu.add_keybinder("move key", "n", false, sub)

local function ticks_to_seconds(ticks)
	return ticks*1/64
end

function on_paint()
    if menu.get_value(enabled) ~= 1 then
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

    local map = client.get_mapname()

    local grenades_all = grenades_data.get()
    local grenades_map = grenades_all[map]

    if grenades_map == nil then
        renderer.draw_text(100, 100, 255, 255, 255, 255, false, "smoke helper: map not supported")
        return
    end

    local size_dot = menu.get_value(dot_size)
    local local_x, local_y, local_z = entity.get_prop(local_player, 2, "DT_BasePlayer","m_vecOrigin")
    
    local hud_smokes = 0

    local localyaw, localpitch, localroll = client.get_viewangles()
    local eyepos_x, eyepos_y, eyepos_z = entity.get_eyepos(local_player)
    local playerLocX, playerLocY, playerLocZ = entity.get_prop(local_player, 2, "DT_BasePlayer", "m_vecOrigin")

    local tick_rate = 1.0 / client.tickinterval()
    local item_weapon = weapon.get_itemid(local_player)

    if item_weapon >= 49 or item_weapon <= 42 then
        return
    end
    
    local weapon_name = "none"
    
    if item_weapon == 46 or item_weapon == 48 then
        weapon_name = "weapon_molotov"
    elseif item_weapon == 45 then
        weapon_name = "weapon_smokegrenade"
    elseif item_weapon == 43 then
        weapon_name = "weapon_flashbang"
    elseif item_weapon == 44 then
        weapon_name = "weapon_hegrenade"
    end
                
    if weapon_name == "none" then
        return
    end

    for i=1, #grenades_map do
        local grenade_meta = grenades_map[i]
        
        if grenade_meta ~= nil  then
            local tickrate = grenade_meta["tickrate"] or 64
            local name, grenade, throw_type, x, y, z, pitch, yaw = grenade_meta["name"], grenade_meta["grenade"], grenade_meta["throwType"], grenade_meta["x"], grenade_meta["y"], grenade_meta["z"], grenade_meta["pitch"], grenade_meta["yaw"]
        
            if grenade == weapon_name and tickrate == math.floor(tick_rate) then
                local distance = cmath.vector_distance(x, y, local_z, local_x, local_y, local_z)
                    if distance <= 700 then
                        local fraction, did_hit, end_x, end_y, end_z, hit_end = client.trace_ray(x, y, z, x, y, z - 100.0, local_player, 1174421515)
                        
                        local alpha = 255.0

                        if distance < 200.0 then
                            alpha = 255.0
                        else
                            alpha = (1 - (distance / (700 + 255))) * 255
                        end
                    
                        renderer.draw_circle_3d(x, y, end_z, 15.0, 255, 255, 255, alpha)
                        if distance < 25 then
                            if menu.get_value(key) ~= -1 and client.is_keypressed(menu.get_value(key)) == true then
                                move_x = playerLocX - x
                                move_y = playerLocY - y
                                cmd.set_forwardmove(-move_x * 5)
                                cmd.set_sidemove(move_y * 5)
                                cmd.set_moveyaw(0)
                            end
                        
                            local forward_x, forward_y, forward_z = cmath.angle_vector(pitch, yaw, 0)
                            forward_x = forward_x * 50000
                            forward_y = forward_y * 50000
                            forward_z = forward_z * 50000

                            local smokepos_x = x + forward_x
                            local smokepos_y = y + forward_y
                            local smokepos_z = z + forward_z

                            local viewangles_distance_max = grenade_meta["viewAnglesDistanceMax"] or 0.22
                            local throw_strength = grenade_meta["throwStrength"] or 1

                            local dst_x, dst_y, dst_z = cmath.calc_angles(smokepos_x, smokepos_y, smokepos_z, eyepos_x, eyepos_y, eyepos_z)
                            local viewangles_distance = cmath.get_fov(localyaw, localpitch, localroll, pitch, yaw, 0)

                            local r, g, b, a = 255, 255, 255, 255

                            if viewangles_distance_max > viewangles_distance then
                                r = 0

                                if menu.get_value(auto_throw) == 1 then
                                    if weapon.get_prop(local_player, 3, "DT_BaseCSGrenade", "m_bPinPulled") == true
                                        and weapon.get_prop(local_player, 5, "DT_BaseCSGrenade", "m_flThrowStrength") == throw_strength then
                                        local run_duration = grenade_meta["runDuration"] or 20
                                        if throw_type == "JUMP" then
                                            client.exec("+jump; -attack; -attack2")
                                            client.delayed_exec("-jump", ticks_to_seconds(16) * 1000)
                                        elseif throw_type == "RUN" then
                                            client.exec("+forward; -speed;")
                                            client.delayed_exec("-attack; -attack2; -jump", ticks_to_seconds(run_duration) * 1000)
                                            client.delayed_exec("-forward", ticks_to_seconds(run_duration+9) * 1000)
                                        elseif throw_type == "RUNJUMP" then
                                            client.exec("+forward; -speed;")
                                            client.delayed_exec("+jump; -attack; -attack2;", ticks_to_seconds(run_duration)* 1000)
                                            client.delayed_exec("-jump;", ticks_to_seconds(run_duration+9)* 1000)
                                            client.delayed_exec("-forward", ticks_to_seconds(run_duration+11)* 1000)
                                        else
                                            client.exec("-attack; -attack2")
                                        end
                                    end
                                end
                            end

                            renderer.draw_text(100, 100 + hud_smokes * 70, r, g, b, a, false, "Name: " .. name)
                            renderer.draw_text(100, 100 + hud_smokes * 70 + 15, r, g, b, a, false, "Grenade: " .. grenade)
                            renderer.draw_text(100, 100 + hud_smokes * 70 + 30, r, g, b, a, false, "Throw Type: " .. throw_type)
                            if throw_strength == 0.5 then renderer.draw_text(100, 100 + hud_smokes * 70 + 45, r, g, b, a, false, "Right / Left Click") end
                            if throw_strength == 0 then renderer.draw_text(100, 100 + hud_smokes * 70 + 45, r, g, b, a, false, "Right Click") end
                            if grenade_meta["duck"] then renderer.draw_text(100, 100 + hud_smokes * 70 + 45, r, g, b, a, false, "Duck") end

                            local s1_x, s1_y = renderer.worldtoscreen(smokepos_x, smokepos_y, smokepos_z)
                            local s2_x, s2_y = renderer.worldtoscreen(x, y, local_z)

                            if s1_x ~= 0 and s1_y ~= 0 then
                                renderer.draw_line(s1_x - size_dot, s1_y, s1_x + size_dot, s1_y, 1, r, g, b, a)
                                renderer.draw_line(s1_x, s1_y - size_dot, s1_x , s1_y + size_dot, 1, r, g, b, a)
                            end

                            if s2_x ~= 0 and s2_y ~= 0 then
                                renderer.draw_rect(s2_x, s2_y, 3, 3, 255, 255, 255, 255)
                            end

                            hud_smokes = hud_smokes + 1
                        else
                            local s_x, s_y = renderer.worldtoscreen(x, y, end_z + 30.0)

                            if s_x ~= 0 and s_y ~= 0 then
                                renderer.draw_text(s_x, s_y, 255, 255, 255, alpha, true, name)
                            end
                        end
                    end
                end
            end
    end
end

client.set_event_callback("on_paint","on_paint")