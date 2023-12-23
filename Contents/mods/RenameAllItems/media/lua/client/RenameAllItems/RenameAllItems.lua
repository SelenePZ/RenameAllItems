RenameAllItems = RenameAllItems or {}

local MAXIMUM_RENAME_LENGTH = 28

function RenameAllItems.OnFillInventoryObjectContextMenu(player, context, items)
    if #items == 1 then
        local item = items[1]
        if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end
        if instanceof(item, "InventoryItem") and not item:IsMap() and not instanceof(item, "InventoryContainer") and not instanceof(item, "Food") and not instanceof(item, "Key") and item:getType() ~= "KeyRing" and item:isInPlayerInventory() then
            context:addOption(getText("ContextMenu_RenameItem"), item, RenameAllItems.onRenameItem, player)
        end
    end
end

function RenameAllItems.onRenameItem(bag, player)
    local modal = ISTextBox:new(0, 0, 280, 180, getText("ContextMenu_RenameItem"), bag:getName(), nil, RenameAllItems.onRenameItemClick, player, getSpecificPlayer(player), bag);
    modal:initialise();
    modal:addToUIManager();
    if JoypadState.players[player+1] then
        setJoypadFocus(player, modal)
    end
end

function RenameAllItems:onRenameItemClick(button, player, item)
    local playerNum = player:getPlayerNum()
    if button.internal == "OK" then
		local length = button.parent.entry:getInternalText():len()
        if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
			if length <= MAXIMUM_RENAME_LENGTH then 
				item:setName(button.parent.entry:getText());
                item:setCustomName(true);
				local pdata = getPlayerData(playerNum);
				pdata.playerInventory:refreshBackpacks();
				pdata.lootInventory:refreshBackpacks();
                local x = math.floor(player:getX())
                local y = math.floor(player:getY())
                local z = math.floor(player:getZ())
                ISLogSystem.sendLog(player, "tracking", "[" .. player:getUsername() .. "][" .. player:getDescriptor():getForename() .. "][".. player:getDescriptor():getSurname() .."][ItemRenamed][" .. x .. "," .. y .. "," .. z .. "] " .. item:getType() .. "," .. button.parent.entry:getText())
			else
				player:Say(getText("IGUI_PlayerText_ItemNameTooLong", MAXIMUM_RENAME_LENGTH));
			end
        end
    end
    if JoypadState.players[playerNum+1] then
        setJoypadFocus(playerNum, getPlayerInventory(playerNum))
    end
end

Events.OnFillInventoryObjectContextMenu.Add(RenameAllItems.OnFillInventoryObjectContextMenu)