-- Copyright (C) 2022
-- DetErDugget
-- Github.com/DetErDugget
-- Originally made for OdessaRP
QBCore = exports['qb-core']:GetCoreObject()


RegisterCommand("sellcar", function(source, args, rawCommand)
	local ped = PlayerPedId()
	local penge = tonumber(args[1])
	if IsPedInAnyVehicle(ped,false) then
		if penge and type(penge) == "number" and penge >= 0 then
			local vehicle = GetVehiclePedIsIn(ped)
			local plate = GetVehicleNumberPlateText(vehicle)
			local model = GetEntityModel(vehicle)
			TriggerServerEvent("odessa_bilmode:server:sale",plate,penge,model)
			DeleteEntity(vehicle,true)
		else
			QBCore.Functions.Notify("Indtast et gyldigt beløb.", "error", 5000)
		end
	else
		QBCore.Functions.Notify("Du skal sidde i bilen for at sælge den.", "error", 5000)
	end
end, false)

RegisterCommand("buycar", function(source, args, rawCommand)
	if type(args[1]) == "string" then
		TriggerServerEvent("odessa_bilmode:server:buy",args[1])
	end
end)




RegisterCommand('carlist', function()
    local carlist = {}
	local cbres 
	QBCore.Functions.TriggerCallback('odessa_bilmode:server:getvehs', function(result)
		cbres = result
	end)
	while not cbres do Wait(50) end
    carlist[#carlist + 1] = {
        isMenuHeader = true,
        header = 'Bil til salg',
        icon = 'fa-solid fa-infinity'
    }
    for k,v in pairs(cbres) do 
        carlist[#carlist + 1] = {
            header = v.nummerplade,
            txt = 'Kan købes for '..v.pris,
            icon = 'fa-solid fa-face-grin-tears',
            params = {
                event = 'odessa_bilmode:client:buymode', 
                args = {
                    nummerplade = v.nummerplade,
                    pris = v.pris
                }
            }
        }
    end
    exports['qb-menu']:openMenu(carlist)
end)

RegisterNetEvent('odessa_bilmode:client:buymode', function(data)
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped,false) then
		TriggerServerEvent("odessa_bilmode:server:buy",data.nummerplade,data.pris)
	else
		QBCore.Functions.Notify("Du må ikke sidde i en bil.", "error", 5000)
	end
end)

RegisterNetEvent('odessa_bilmode:client:bought', function(plate,price,model)
	local ModelHash = tonumber(model)
	RequestModel(ModelHash) 
	while not HasModelLoaded(ModelHash) do 
	  Citizen.Wait(50)
	end
	local ped = PlayerPedId()
	local Vehicle = CreateVehicle(ModelHash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
	SetVehicleNumberPlateText(Vehicle,plate)
	SetModelAsNoLongerNeeded(ModelHash) 
	SetPedIntoVehicle(ped,Vehicle,-1)
end)



