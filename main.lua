--TODO
	--Use HowManyCanFit in inventory to stop items from being destroyed
	--Add selling
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
	if Line1 == "[SignShop]" and Line2 ~= nil and Line3 ~= nil and Line4 ~= nil and Player:HasPermission("SignShop.create") then
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
	local prices
	local amount
	local itemid
	here,line1,prices,amount,itemid = world:GetSignLines(BlockX,BlockY,BlockZ)
	if line1 == "[SignShop]" and here then
		local item = cItem()
		StringToItem(itemid, item)
		item:AddCount(tonumber(amount-1))
		--Creates the item
		local inventory = Player:GetInventory()
		--Gets the inventory so it can be modified
		local buying = {}
		buying = StringSplit(prices, ":") --Splits it into buying and selling
		if cPluginManager:CallPlugin("Coiny", "getBalanceByName", Player:GetName()) < tonumber(buying[1]) then
			Player:SendMessage("Ya don't have enough crack mate!")
		else
			cPluginManager:CallPlugin("Coiny", "removeMoneyByName", Player:GetName(), tonumber(buying[1]), "", "", "")
			--Takes away the money
			Player:SendMessage("You bought " .. amount .. " ".. ItemToString(item) .. " for " .. buying[1] .. " crack!")
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
	local inventory = Player:GetInventory()
	local line1
	local prices
	local amount
	local itemid
	here,line1,prices,amount,itemid = world:GetSignLines(BlockX,BlockY,BlockZ)
		if line1 == "[SignShop]" and here then
			local item = cItem()
			local selling = {}
			selling = StringSplit(prices, ":")
			StringToItem(itemid, item)
			item:AddCount(tonumber(amount-1))
			if inventory:HasItems(item) then
				inventory:RemoveItem(item)
				cPluginManager:CallPlugin("Coiny", "addMoneyByName", Player:GetName(), tonumber(selling[2]), "", "", "")
				Player:SendMessage("You sold " .. amount .. " " ..ItemToString(item) .. " for " .. selling[2] .. " crack!")
				return true
			else
				Player:SendMessage("You don't got that item, mate!")
				return false
			end
			return false
		end
end