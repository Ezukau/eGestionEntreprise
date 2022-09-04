ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local listeEntrepriseServer = {}
RegisterServerEvent("eGestionEntreprise:Liste")
AddEventHandler("eGestionEntreprise:Liste", function()
	local source = source
  local xPlayer = ESX.GetPlayerFromId(_src)

  MySQL.Async.fetchAll("SELECT * FROM jobs", {}, function(result)
    if (result) then
      listeEntrepriseServer = result
      TriggerClientEvent('eGestionEntreprise:sendListe', source, listeEntrepriseServer)
    end
  end)
end)

ESX.RegisterServerCallback('eGestionEntreprise:getMoney', function(source, cb, name)
  TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..name, function(account)
    cb(account.money)
  end)
end)

RegisterNetEvent('eGestionEntreprise:RetraitMoney')
AddEventHandler('eGestionEntreprise:RetraitMoney', function(amount, name, label)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  amount = tonumber(amount)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..name, function(account)
    if account.money >= amount then
      account.removeMoney(amount)
      TriggerClientEvent('esx:showNotification', source, "Vous avez retirez ~"..Config.Menu.CouleurMenu.."~"..amount.."~s~$ du coffre:~"..Config.Menu.CouleurMenu.."~ "..label)
    else
      TriggerClientEvent('esx:showNotification', source, '~r~Pas assez d\'argent dans le coffre !')
    end

  end)
end)

RegisterNetEvent('eGestionEntreprise:DepotMoney')
AddEventHandler('eGestionEntreprise:DepotMoney', function(amount, name, label)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  amount = tonumber(amount)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..name, function(account)
    account.addMoney(amount)
    TriggerClientEvent('esx:showNotification', source, "Vous avez ajoutez ~"..Config.Menu.CouleurMenu.."~"..amount.."~s~$ dans le coffre:~"..Config.Menu.CouleurMenu.."~ "..label)
  end)
end)

ESX.RegisterServerCallback('eGestionEntreprise:getStockItems', function(source, cb, name)
	local all_items = {}
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..name, function(inventory)
		for k,v in pairs(inventory.items) do
			if v.count > 0 then
				table.insert(all_items, {label = v.label,item = v.name, nb = v.count})
			end
		end
	end)
	cb(all_items)
end)

RegisterServerEvent('eGestionEntreprise:takeStockItems')
AddEventHandler('eGestionEntreprise:takeStockItems', function(itemName, count, itemLabel, name, label)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..name, function(inventory)
		inventory.removeItem(itemName, count)
		TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez retirez : [~"..Config.Menu.CouleurMenu.."~x"..count.."~s~] ~"..Config.Menu.CouleurMenu.."~"..itemLabel.."~s~ du coffre :~"..Config.Menu.CouleurMenu.."~ "..label)
	end)
end)

RegisterServerEvent('eGestionEntreprise:putStockItems')
AddEventHandler('eGestionEntreprise:putStockItems', function(amount, item, name, label)
	local xPlayer = ESX.GetPlayerFromId(source)
  amount = tonumber(amount)

  MySQL.Async.fetchAll("SELECT name FROM items WHERE name = '"..item.."'", {}, function(result)
    if (result) then
      for k, v in pairs(result) do
        TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..name, function(inventory)
          inventory.addItem(item, amount)
          TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez ajoutez : [~"..Config.Menu.CouleurMenu.."~x"..amount.."~s~] ~"..Config.Menu.CouleurMenu.."~"..item.."~s~ dans le coffre :~"..Config.Menu.CouleurMenu.."~ "..label)
        end)
      end
    end
  end)
end)

local salairegradeEntrepriseServer = {}
RegisterServerEvent("eGestionEntreprise:GradeSalaire")
AddEventHandler("eGestionEntreprise:GradeSalaire", function(name)
	local source = source
  local xPlayer = ESX.GetPlayerFromId(_src)

  MySQL.Async.fetchAll("SELECT * FROM job_grades WHERE job_name = '"..name.."'", {}, function(result)
    if (result) then
      salairegradeEntrepriseServer = result
      TriggerClientEvent('eGestionEntreprise:sendGradeSalaire', source, salairegradeEntrepriseServer)
    end
  end)
end)

RegisterNetEvent('eGestionEntreprise:gestionsalaire')
AddEventHandler('eGestionEntreprise:gestionsalaire', function(nouveauSalaire, nameGrade, labelGrade, salary, nbGrade, name)
	local source = source
  nouveauSalaire = tonumber(nouveauSalaire)
  MySQL.Async.execute("UPDATE job_grades SET salary = "..nouveauSalaire.." WHERE job_name = '"..name.."' AND name = '"..nameGrade.."'", {}, function()
    TriggerClientEvent('esx:showNotification', source, "Vous avez changez le salaire (~"..Config.Menu.CouleurMenu.."~"..labelGrade.."~s~, ~"..Config.Menu.CouleurMenu.."~"..nbGrade.."~s~) de ~"..Config.Menu.CouleurMenu.."~"..salary.."~s~$ a ~"..Config.Menu.CouleurMenu.."~"..nouveauSalaire.."~s~$")
  end)
end)

RegisterNetEvent('eGestionEntreprise:tryopenmenu')
AddEventHandler('eGestionEntreprise:tryopenmenu', function()
	local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  for k,v in pairs(Config.PermOpenMenu) do
    if xPlayer.getGroup() == v then
      TriggerClientEvent("eGestionEntreprise:openmenu", source)
    end
  end
  

end)