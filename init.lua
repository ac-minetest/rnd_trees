-- naturally growing trees
-- rnd, 2015
-- Bertrand the Healer, 2019

-- local TREE_SIZE = 20;
-- local TRUNK_SIZE = 4;
-- local BRANCH_LENGTH = 10.;

local TREE_SIZE = 30;
local TRUNK_SIZE = 10;
local BRANCH_LENGTH = 20.;
local TRUNK_NODE = "default:tree"
local LEAF_NODE = "default:leaves"

-- Generation parameters chat command
minetest.register_chatcommand("treespec", {
	params = "<tree> <trunk> <branch>",
	description = "Set <tree> <trunk> <branch> sizes for rndtrees mod",
	privs = {},
	func = function( _ , params)
		-- Get the command parameters
		param_list = {}
		local i = 1
		for value in string.gmatch(params, "[+-]?[%d]+") do 
			param_list[i] = value
			i = i + 1
		end
		-- Exit with error if there aren't enough
		if i <= 3 then
			return false, "Correct format is '/treespec <tree> <trunk> <branch>'"
		end
		-- Else set parameters
		TREE_SIZE = tonumber(param_list[1])
		TRUNK_SIZE = tonumber(param_list[2])
		BRANCH_LENGTH = tonumber(param_list[3])
		return true, "Tree Size: " .. TREE_SIZE .. ", Trunk Size: " .. TRUNK_SIZE .. ", Branch Length: " .. BRANCH_LENGTH
	end,
})

-- Trunk material chat command
minetest.register_chatcommand("trunkmat", {
	params = "",
	description = "Set trunk material to currently equipped node for rndtrees mod",
	privs = {},
	func = function( name , _ )
		-- If command was not called by player, exit with error message
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		-- If not, check if the player's wielded item is a tree trunk node
		local wielded_item = player:get_wielded_item():get_name()
		local output = ""
		-- If it is, set the trunk node to that, otherwise exit with error message
		if string.match(wielded_item, "tree") or string.match(wielded_item, "trunk") then
			TRUNK_NODE = wielded_item
			output = "Trunk Material: " .. TRUNK_NODE
		else
		 	output = "It doesn't look like that's a trunk node :("
		end
		return true, output
	end,
})

-- Leaf material chat command
minetest.register_chatcommand("leafmat", {
	params = "",
	description = "Set leaf material to currently equipped node for rndtrees mod",
	privs = {},
	func = function( name , _)
		-- If command was not called by player, exit with error message
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		-- If not, check if the player's wielded item is a tree trunk node
		local wielded_item = player:get_wielded_item():get_name()
		local output = ""
		-- If it is, set the trunk node to that, otherwise exit with error message
		if string.match(wielded_item, "leaves") or string.match(wielded_item, "needles") then
			LEAF_NODE = wielded_item
			output = "Leaf Material: " .. LEAF_NODE
		else
			output = "It doesn't look like that's a leaf node :("
		end
		return true, output
	end,
})


-- Tree growth node
minetest.register_node("rnd_trees:tree", {
	description = "naturally growing tree",
	tiles = {"default_tree.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:tree',
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos);
		meta:set_string("infotext","growth started");
		-- Save materials
		meta:set_string("trunkmat", TRUNK_NODE);
		meta:set_string("leafmat", LEAF_NODE);
		-- Save growth parameters
		-- If sizes are negative, use random
		math.randomseed(os.time())
		if TREE_SIZE < 0 then
			math.random()
			meta:set_int("treesize", math.random(math.ceil(TREE_SIZE / -2), TREE_SIZE * -1))
		else
			meta:set_int("treesize", TREE_SIZE)
		end
		if TRUNK_SIZE < 0 then
			math.random()
			meta:set_int("trunksize", math.random(math.ceil(TRUNK_SIZE / -2), TRUNK_SIZE * -1))
		else
			meta:set_int("trunksize", TRUNK_SIZE)
		end
		if BRANCH_LENGTH < 0 then
			math.random()
			meta:set_int("branchlength", math.random(math.ceil(BRANCH_LENGTH / -2), BRANCH_LENGTH * -1))
		else
			meta:set_int("branchlength", BRANCH_LENGTH)
		end
		-- Save growth state
		meta:set_int("life",meta:get_int("treesize"));
		meta:set_int("branch",0);
	end
})

-- Growing function
minetest.register_abm({
	nodenames = {"rnd_trees:tree"},
	neighbors = {"air"},
	interval = 1.0,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		
		
		local meta = minetest.get_meta(pos);
		-- Get growth state
		local life = meta:get_int("life");
		local branch = meta:get_int("branch");
		-- Get materials
		local trunkmat = meta:get_string("trunkmat");
		local leafmat = meta:get_string("leafmat");
		-- Get growth parameters
		local treesize = meta:get_int("treesize")
		local trunksize = meta:get_int("trunksize")
		local branchlength = meta:get_int("branchlength")
		-- Replace old growth node with trunk material
		minetest.set_node(pos, {name = trunkmat});
		
		
		-- LEAVES 
		if life<=0 or (life < treesize - trunksize and math.random(5)==1)  then  -- either end of growth or above trunk randomly
				local r;
				if life <=0 then r = math.random(2)+1; -- determine leaves region size
					else r = math.random(2);
				end
				
				local i,j,k
				for i=-r,r do
					for j=-r,r do
						for k = -r,r do
							local p = {x=pos.x+i,y=pos.y+j,z=pos.z+k};
							if minetest.get_node(p).name == "air" and math.random(3)==1 then
								minetest.set_node(p,{name=leafmat});
							end
						end
					end
				end				
		end
		if life<=0 then return end -- stop growth
		
		
		local above  = {x=pos.x,y=pos.y+1,z=pos.z};
		local nodename = minetest.get_node(above).name
		
		-- GROWTH
		if nodename == "air" or nodename == leafmat then -- can we grow up
			
			if math.random(3)==1 then -- occasionaly change direction of growth a little
				above.x=above.x+math.random(3)-2;
				above.z=above.z+math.random(3)-2;
			end
			
			-- BRANCHING
			if (math.random(3)==1 or branch == 0) and life < treesize - trunksize then -- not yet in branch
				
				local dir = {x=math.random(5)-3,y=math.random(2)-1,z=math.random(5)-3};
				--if math.random(2)==1 then dir.y=(math.random(3)-2) end -- occassionaly branch nonhorizontaly 
				local dirlen = math.sqrt(dir.x*dir.x+dir.y*dir.y+dir.z*dir.z);
				if dirlen == 0 then dirlen = 1 end;	dir.x=dir.x/dirlen; dir.y=dir.y/dirlen; dir.z=dir.z/dirlen; -- normalize
				
				local length = math.random(math.pow(life/treesize,1.5)*branchlength)+1; -- length of branch
				for i=1,length-1 do
					local p = {x=above.x+dir.x*i,y=above.y+dir.y*i,z=above.z+dir.z*i};
					nodename = minetest.get_node(p).name;
					if  nodename== "air" or nodename == leafmat then
						minetest.set_node(p,{name=trunkmat});
					end
				end
				local grow = {x=above.x+dir.x*length,y=above.y+dir.y*length,z=above.z+dir.z*length};
				minetest.set_node(grow,{name="rnd_trees:tree"});
				meta = minetest.get_meta(grow);
				-- Save growth state to new growth node
				meta:set_int("life",life*math.pow(0.8,branch)-1);meta:set_int("branch",branch+length); -- remember that we branched
				meta:set_string("infotext","branch, life ".. life-1);
				-- Save tree materials
				meta:set_string("trunkmat", trunkmat);
				meta:set_string("leafmat", leafmat);
				-- Save growth parameters
				meta:set_int("treesize", treesize)
				meta:set_int("trunksize", trunksize)
				meta:set_int("branchlength", branchlength)
				
			end
	
			-- add new growing part
			minetest.set_node(above,{name="rnd_trees:tree"});
			meta = minetest.get_meta(above);
			-- Save growth state
			meta:set_int("life",life-1);meta:set_int("branch",branch); -- decrease life
			meta:set_string("infotext","growing, life ".. life-math.random(treesize*0.25));
			-- Save tree materials
			meta:set_string("trunkmat", trunkmat);
			meta:set_string("leafmat", leafmat);
			-- Save growth parameters
			meta:set_int("treesize", treesize)
			meta:set_int("trunksize", trunksize)
			meta:set_int("branchlength", branchlength)
			
			 if branch==0 then -- make main trunk a bit thicker
				-- for i = -1,1 do
					-- for j = -1,1 do
						-- if math.random(4)==1 then
							minetest.set_node({x=pos.x+1,y=pos.y,z=pos.z},{name=trunkmat});
							minetest.set_node({x=pos.x-1,y=pos.y,z=pos.z},{name=trunkmat});
							minetest.set_node({x=pos.x,y=pos.y,z=pos.z+1},{name=trunkmat});
							minetest.set_node({x=pos.x,y=pos.y,z=pos.z-1},{name=trunkmat});
						-- end
					-- end
				-- end
				
			end
			
			
		end
		
	end,
})
