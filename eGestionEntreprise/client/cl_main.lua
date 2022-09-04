ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local open = false
local Main = RageUI.CreateMenu(Config.Menu.NomMenu, Config.Menu.DescriptionMenu, nil, nil, 'root_cause5', Config.Menu.Banner)
local subEntreprise = RageUI.CreateSubMenu(Main, "Entreprise", "Interaction")
Main.Closed = function()
  RageUI.Visible(Main, false)
  main = false
end

local listeEntrepriseClient = {}
RegisterNetEvent('eGestionEntreprise:sendListe')
AddEventHandler('eGestionEntreprise:sendListe', function(listeEntrepriseServer)
  listeEntrepriseClient = listeEntrepriseServer
end)

local salairegradeEntrepriseClient = {}
RegisterNetEvent('eGestionEntreprise:sendGradeSalaire')
AddEventHandler('eGestionEntreprise:sendGradeSalaire', function(salairegradeEntrepriseServer)
  salairegradeEntrepriseClient = salairegradeEntrepriseServer
end)

local solde = 0
function GetMoney(name)
  ESX.TriggerServerCallback('eGestionEntreprise:getMoney', function(money)
    solde = money
  end, name)
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

  AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
  
  blockinput = true 
  DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "Somme", ExampleText, "", "", "", MaxStringLenght) 
  while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
    Citizen.Wait(0)
  end 
       
  if UpdateOnscreenKeyboard() ~= 2 then
    local result = GetOnscreenKeyboardResult()
    Citizen.Wait(500) 
    blockinput = false
    return result 
  else
    Citizen.Wait(500) 
    blockinput = false 
    return nil 
  end
end

function getStock(name)
  ESX.TriggerServerCallback('eGestionEntreprise:getStockItems', function(inventory)                
    all_items = inventory
  end, name)
end

local Customs = {
	List1 = 1,
	List2 = 1,
}

all_items = {}
local voirMoney = false
local voirCoffre = false
local voirMoney = false

local filterArray = {"Aucun", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
local filter = 1

local label = ""
local name = ""
local nameGrade = ""
local labelGrade = ""
local nbGrade = 0
local salary = 0

local function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function OpenMenu()
  if main then 
    main = false
    RageUI.Visible(Main, false)
    return
  else
    main = true 
    RageUI.Visible(Main, true)
    Citizen.CreateThread(function()
    while main do 
    RageUI.IsVisible(Main,function()

      RageUI.List("~"..Config.Menu.CouleurMenu.."~→ ~s~Filtre :", filterArray, filter, nil, {Preview}, true, {
        
        onListChange = function(i, Item)
          filter = i;
        end,
      })

      RageUI.Separator("~"..Config.Menu.CouleurMenu.."~______________")
      for k,v in pairs(listeEntrepriseClient) do 

        if filter == 1 then 
          if v.name ~= "unemployed" then

            RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~"..v.label, nil, {RightLabel = nil}, true, {
                    
              onSelected = function()
                voirMoney = false
                voirCoffre = false
                voirSalaire = false
                name = v.name
                label = v.label
              end,

            }, subEntreprise)
          end
        elseif starts(v.label:lower(), filterArray[filter]:lower()) then
          RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~"..v.label, nil, {RightLabel = nil}, true, {
                    
            onSelected = function()
              voirMoney = false
              voirCoffre = false
              voirSalaire = false
              name = v.name
              label = v.label
            end,

          }, subEntreprise)
        end
      end
    end)
    
    RageUI.IsVisible(subEntreprise,function()

      RageUI.Separator("Entreprise :~"..Config.Menu.CouleurMenu.."~ "..label)

      RageUI.List("~"..Config.Menu.CouleurMenu.."~→ ~s~ Choix :", {"~"..Config.Menu.CouleurMenu.."~Gestion Argent~s~", "~"..Config.Menu.CouleurMenu.."~Gestion Coffre~s~", "~"..Config.Menu.CouleurMenu.."~Gestion Salaires~s~"}, Customs.List1, nil, {Preview}, true, {
        onListChange = function(i, Item)
        Customs.List1 = i;
        end,
      
        onSelected = function()
          
          if Customs.List1 == 1 then 
            GetMoney(name)
            voirMoney = true
            voirCoffre = false
            voirSalaire = false
          end
        
          if Customs.List1 == 2 then
            getStock(name)
            voirMoney = false
            voirCoffre = true
            voirSalaire = false
          end

          if Customs.List1 == 3 then
            TriggerServerEvent("eGestionEntreprise:GradeSalaire", name)
            voirSalaire = true
            voirMoney = false
            voirCoffre = false
          end

        end,
      })
  

      if voirMoney == true then
        RageUI.Separator("~"..Config.Menu.CouleurMenu.."~______________")
        RageUI.Separator("Argent : ~"..Config.Menu.CouleurMenu.."~"..solde.."~s~$")
        RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~ Déposer un montant", nil, {RightLabel = "→→"}, true, {
            
          onSelected = function()
            local amount = KeyboardInput("Montant:", "", 7)
            if tonumber(amount) then
              if amount ~= nil then
                TriggerServerEvent('eGestionEntreprise:DepotMoney', amount, name, label)
                GetMoney(name)
              else
                ESX.ShowNotification("~r~Montant non définit.")
              end
            else
              ESX.ShowNotification("~r~Montant mal définit.")
            end
          end,
        })

        RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~ Retirer un montant", nil, {RightLabel = '→→'}, true, {
  
          onSelected = function()
            local amount = KeyboardInput("Montant:", "", 7)
            if tonumber(amount) then
              if amount ~= nil then
                TriggerServerEvent('eGestionEntreprise:RetraitMoney', amount, name, label)
                GetMoney(name)
              else
                ESX.ShowNotification("~r~Montant non définit.")
              end
            else
              ESX.ShowNotification("~r~Montant mal définit.")
            end
          end,
        })
      end

      if voirCoffre == true then
        RageUI.Separator("~"..Config.Menu.CouleurMenu.."~______________")
        RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~ Ajout d'item(s)", nil, {RightLabel = '→→'}, true, {
  
          onSelected = function()
            local item = KeyboardInput("Name de l'item:", "", 20)
            local amount = KeyboardInput("Nombre:", "", 4)
            if amount ~= nil and item ~= nil then
              TriggerServerEvent('eGestionEntreprise:putStockItems', amount, item, name, label)
              Citizen.Wait(500)
              getStock(name)
            else
              ESX.showNotification("~r~Nombre/Item non ou mal définit.")
            end
          end,
        })

        if #all_items >= 1 then
          for k,v in pairs(all_items) do
            RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~"..v.label, nil, {RightLabel = "~"..Config.Menu.CouleurMenu.."~x"..v.nb}, true, {onSelected = function()
                local count = KeyboardInput("Combien voulez vous en prendre ?",nil,4)
                count = tonumber(count)
                local itemLabel = v.label
                if count <= v.nb then
                  TriggerServerEvent("eGestionEntreprise:takeStockItems",v.item, count, itemLabel, name, label)
                else
                  ESX.ShowNotification("~r~")
                end
                Citizen.Wait(500)
                getStock(name)
            end});
          end

        else
          RageUI.Separator("")
          RageUI.Separator("~"..Config.Menu.CouleurMenu.."~Coffre vide.~s~")
          RageUI.Separator("")
        end 
      end

      if voirSalaire == true then
        RageUI.Separator("~"..Config.Menu.CouleurMenu.."~______________")
        for k,v in pairs(salairegradeEntrepriseClient) do 
          RageUI.Button("~"..Config.Menu.CouleurMenu.."~→ ~s~ "..v.label.." (~"..Config.Menu.CouleurMenu.."~"..v.grade.."~s~) :", nil, {RightLabel = "~"..Config.Menu.CouleurMenu.."~"..v.salary.."~s~$"}, true, {
            onSelected = function()

              local nouveauSalaire = KeyboardInput('Nouveau salaire:', '', 4)
              nameGrade = v.name
              labelGrade = v.label
              nbGrade = v.grade
              salary = v.salary
              if nouveauSalaire ~= nil then
                if tonumber(nouveauSalaire) then
                  TriggerServerEvent('eGestionEntreprise:gestionsalaire', nouveauSalaire, nameGrade, labelGrade, salary, nbGrade, name)
                  Citizen.Wait(500)
                  TriggerServerEvent("eGestionEntreprise:GradeSalaire", name)
                else
                  ESX.showNotification("~r~Montant mal définit.")
                end
              else
                ESX.showNotification("~r~Montant non définit.")
              end
            
            end,
          })


        end

      end

    end)
    Wait(0)
  end
end)
end
end    

RegisterCommand("gestionEntreprise", function()
  TriggerServerEvent("eGestionEntreprise:tryopenmenu")
end)

RegisterNetEvent('eGestionEntreprise:openmenu')
AddEventHandler('eGestionEntreprise:openmenu', function()
  TriggerServerEvent("eGestionEntreprise:Liste")
  OpenMenu()
end)

--- Ezukau#1144