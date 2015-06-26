--TODO
	--Use HowManyCanFit in inventory to stop items from being destroyed
	--Add selling
	--Check for permissions when creating signs
function Initialize(Plugin)
	Plugin:SetName("SignShop")
	Plugin:SetVersion(1)

	cPluginManager:AddHook(cPluginManager.HOOK_UPDATING_SIGN, OnUpdatingSign);
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick);
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnPlayerLeftClick);
	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end
function OnUpdatingSign(World, BlockX, BlockY, BlockZ, Line1, Line2, Line3, Line4, Player)
	if Line1 == "[SignShop]" and Line2 ~= nil and Line3 ~= nil and Line4 ~= nil then
		Player:SendMessage("SignShop created")
		local item = cItem(tonumber(Line4))
		Line4 = ItemToString(item)
		return false, Line1, Line2, Line3, Line4
	end
end
function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	local world = Player:GetWorld()
	local here
	local line1
	local buying
	local selling
	local itemid
	here,line1,buying,selling,itemid = world:GetSignLines(BlockX,BlockY,BlockZ)
	if line1 == "[SignShop]" and here then
		local item = cItem()
		StringToItem(itemid, item)
		--Creates the item
		local inventory = Player:GetInventory()
		--Gets the inventory so it can be modified
		if cPluginManager:CallPlugin("Coiny", "getBalanceByName", Player:GetName()) < tonumber(buying) then
			Player:SendMessage("Ya don't have enough crack mate!")
		else
			cPluginManager:CallPlugin("Coiny", "removeMoneyByName", Player:GetName(), tonumber(buying), "", "", "")
			--Takes away the money
			Player:SendMessage("You bought " .. ItemToString(item) .. " for " .. buying .. " crack!")
			--Tells the player what happend
			inventory:AddItem(item)
			--Gives the player the item
			return true
		end
		
	end
	return false
end
function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, Action)
	local world = Player:GetWorld()
	local inventory = Player:GetInventory
	here,line1,buying,selling,itemid = world:GetSignLines(BlockX,BlockY,BlockZ)
		if line1 == "[SignShop]" and here then
			local item = cItem()
			StringToItem(itemid, item)
			if inventory:HasItems(item) 
				inventory:RemoveItem(item)
				cPluginManager:CallPlugin("Coiny", "addMoneyByName", Player:GetName(), tonumber(selling), "", "", "")
				Player:SendMessage("You sold" .. ItemToString(item) .. " for " .. selling .. " crack!")
				return true
			else
				Player:SendMessage("You don't got that item, mate!")
			end
			return false
		end
end