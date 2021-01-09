local MP_011JSON = require "MP_011"
local MP_013JSON = require "MP_013"

local MP_011 = json.decode(MP_011JSON)
local MP_013 = json.decode(MP_013JSON)


local function DecodeParams(p_Table)
    if(p_Table == nil) then
        print("No table received")
        return false
	end
	for s_Key, s_Value in pairs(p_Table) do
		if s_Key == 'transform' or s_Key == 'localTransform'then
			local s_LinearTransform = LinearTransform(
					Vec3(s_Value.left.x, s_Value.left.y, s_Value.left.z),
					Vec3(s_Value.up.x, s_Value.up.y, s_Value.up.z),
					Vec3(s_Value.forward.x, s_Value.forward.y, s_Value.forward.z),
					Vec3(s_Value.trans.x, s_Value.trans.y, s_Value.trans.z))

			p_Table[s_Key] = s_LinearTransform

		elseif type(s_Value) == "table" then
			p_Table[s_Key] = DecodeParams(s_Value)
		end

	end

	return p_Table
end

Events:Subscribe('Partition:Loaded', function(p_Partition)
	if p_Partition == nil then
		return
	end
	
	local s_Instances = p_Partition.instances

	for _, l_Instance in pairs(s_Instances) do
		if l_Instance == nil then
			print('Instance is null?')
			break
		end
		if(l_Instance.typeInfo.name == "LevelData") then
			local s_Instance = LevelData(l_Instance)
			local map = SharedUtils:GetLevelName()
			if(s_Instance.name == map) then
				print("Loading custom map data for " .. map)

				if map == "Levels/MP_011/MP_011" then
					CustomLevelData = MP_011
					return
				end
				if map == "Levels/MP_013/MP_013" then
					CustomLevelData = MP_013
					return
				end
				CustomLevelData = nil
				print("Fucked up G. Wollah geen map data voor deze.")

			end
		end
	end
end)

NetEvents:Subscribe('MapLoader:GetLevel', function(player)
	print('Sending level to ' .. player.name)
	NetEvents:SendTo('MapLoader:GetLevel', player, CustomLevelData)
end)

