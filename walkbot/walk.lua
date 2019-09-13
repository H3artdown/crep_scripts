local maps = {}

function get()
	maps_data = {}
    maps_data['de_dust2'] = {{id=1,x=-753.722046, y=-826.822388, z=116.931046}, {id=2,x=-279.545288, y=-836.627075, z=126.568314}, {id=3,x=186.028931, y=-751.290955, z=55.286530}, {id=4,x=389.825439, y=-129.798447, z=59.005398}, {id=5,x=638.512329, y=288.993439, z=64.561020}, {id=6,x=719.332458, y=445.776855, z=66.207138}, {id=7,x=543.394470, y=673.428284, z=66.244339}, {id=8,x=1166.515869, y=1123.997681, z=63.894585}, {id=9,x=1402.401245, y=818.431824, z=51.861401}, {id=10,x=1432.688843, y=2170.362061, z=55.501156}, {id=11,x=1431.325073, y=2988.046143, z=184.163422}, {id=12,x=1172.846558, y=2921.277344, z=192.171829}, {id=13,x=873.323181, y=2562.331299, z=159.067505}, {id=14,x=367.280243, y=2470.646973, z=160.203766}   , {id=15,x=360.665039, y=1816.083008, z=161.929474}, {id=16,x=363.080292, y=1430.804321, z=64.451950}, {id=17,x=-169.908234, y=1421.214966, z=63.702827}, {id=18,x=-177.645370, y=653.214050, z=66.093811}, {id=19,x=-402.862976, y=518.535461, z=60.411346}, {id=20,x=-402.750519, y=1477.687500, z=-62.393364}, {id=21,x=-386.258606, y=1614.196533, z=-62.796425}, {id=22,x=-539.639771, y=1732.673096, z=-52.499336}, {id=23,x=-224.386475, y=2120.813477, z=-62.709877}, {id=24,x=257.462585, y=2148.796387, z=-63.384659}, {id=25,x= -956.499268, y=2179.088379, z=1.625454}, {id=26,x=-1297.879639, y=2171.326660, z=67.411751}, {id=27,x=-1495.194824, y=2362.330322, z=63.091255}, {id=28,x=-1955.820190, y=2150.338379, z=61.569221}, {id=29,x=-1963.830078, y=1165.858398, z=96.232941}, {id=30,x=-1656.480835, y=1130.983765, z=95.209984}, {id=31,x=-1311.232056, y=1108.251709, z=97.632225}, {id=32,x=-1095.107422, y=1113.495850, z=27.564640}, {id=33,x=-1065.921753, y=1432.968750, z=-47.906197}, {id=34,x=-1072.652832, y=1137.734009, z=14.917271}, {id=35,x=-1310.938843, y=1079.671143, z=100.150780}, {id=36,x=-1673.429688, y=1124.797607, z=95.235229}, {id=37,x=-1680.303955, y=188.775970, z=63.828693}, {id=38,x=-1927.352539, y=-100.937103, z=64.118790}, {id=39,x=-1913.885376, y=-601.114746, z=186.330750}, {id=40,x=-1797.410645, y=-842.324524, z=179.564758}, {id=41,x=-1155.348511, y=-844.720215, z=180.315964}
    }
    --, , {id=,x=, y=, z=}
    return maps_data
end

maps.get = get
local walk_data = maps

local move_x, move_y = 0, 0
local last_node = 0
local current_node = 0
local search_node = false

function on_paint()
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

    local data_all = walk_data.get()
    local map_data = data_all[map]

    if map_data == nil then
        return
    end
    
    for i=1, #map_data do
        local node_meta = map_data[i]
        local x, y, z = node_meta["x"], node_meta["y"], node_meta["z"]
        local s_x, s_y = renderer.worldtoscreen(x, y, z)
        
        if s_x ~= 0 and s_y ~= 0 then
            --renderer.draw_text(s_x, s_y, 255, 255, 255, 255, false, "node")
        end
    end
    
    
    local max_dist = 999

    if map_data == nil then
        return
    end
    
    if current_node == 0 then
        search_node = true
    end
    
    if current_node ~= 0 then
        search_node = false
    end
    
    if search_node == true then
        local ex, ey, ez = entity.get_eyepos(local_player)

        for i=1, #map_data do
            if i ~= last_node and i > last_node then
                local node_meta = map_data[i]
                local x, y, z = node_meta["x"], node_meta["y"], node_meta["z"]

                local fraction = client.trace_ray(ex, ey, ez, x, y, z, local_player, 1174421515)

                if fraction > 0.99 then
                    local dist = cmath.vector_distance(ex, ey, ez, x, y, z)

                    if dist < max_dist then
                        max_dist = dist
                        current_node = i
                    end 
                end
            end
        end
    end
    local players = entity.get_entities("CCSPlayer")
    
    if players ~= nil then
        for i=1, #players do
           local p_x, p_y, p_z = entity.get_prop(players[i], 2, "DT_BasePlayer","m_vecOrigin")
            if entity.is_enemy(players[i]) and entity.is_visible(players[i]) then
                cmd.set_forwardmove(0)
                return
            end
        end
    end
    
    
    if current_node ~= 0 then
        search_node = false
        local ex, ey, ez = entity.get_eyepos(local_player)
            
        local node_meta = map_data[current_node]
        local c_x, c_y, c_z = node_meta["x"], node_meta["y"], node_meta["z"]
        local fraction, did_hit, end_x, end_y, end_z, hit_end = client.trace_ray(ex, ey, ez, c_x, c_y, c_z, local_player, 1174421515)

        if fraction < 0.99 and hit_end == 0 then
            current_node = 0
            last_node = 0
        end
        
        local dist2 = cmath.vector_distance(ex, ey, ez, c_x, c_y, ez)
        
        if dist2 < 15.0 then
            last_node = current_node
            
            current_node = current_node + 1
            
            if current_node + 1 > #map_data then
                current_node = 1
            end
        end 
        
        local pitch_1, yaw_1, roll_l = cmath.calc_angles(ex, ey, ez, c_x, c_y, c_z)
        
        cmd.set_forwardmove(450)
        cmd.set_yaw(yaw_1)
    end
end

function on_player_spawn(e)
    local user = e.userid
    local ent = entity.get_userid(user)
    
    if ent == client.get_localplayer() then
        client.exec("buy ak47; buy m4a1")
    end
end

client.set_event_callback("setup_command","on_paint")
client.set_event_callback("player_spawn","on_player_spawn")
