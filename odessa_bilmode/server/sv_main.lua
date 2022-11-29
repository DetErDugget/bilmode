-- Copyright (C) 2022
-- DetErDugget
-- Github.com/DetErDugget
-- Originally made for OdessaRP

local QBCore = exports['qb-core']:GetCoreObject()


-- SÆLG BIL
RegisterNetEvent('odessa_bilmode:server:sale', function(plate,price,model)
	local src = source
	local result = exports.oxmysql:executeSync('SELECT * FROM brugtebiler WHERE nummerplade = @nummberplade', {
		['@nummerplade'] = plate
	})
	if result[1] then
		TriggerClientEvent("QBCore:Notify",src, "En bil med nummerplade '"..plate.."' er allerede til salg...", "error", 5000)
	else
		exports.oxmysql:execute('INSERT INTO brugtebiler ( nummerplade, pris, model ) VALUES (@nummerplade, @pris, @model)', {
			['@nummerplade'] = plate,
			['@pris'] = price,
			['@model'] = model,
			
		})
		
		TriggerClientEvent("QBCore:Notify", src, "Du satte en bil med nummerplade '"..plate.."' til salg for "..tostring(price).." DKK!", "success", 5000)
	end
end)


-- KØB BIL
RegisterNetEvent('odessa_bilmode:server:buy', function(plate, price)
	local src = source
	local result = exports.oxmysql:executeSync('SELECT * FROM brugtebiler WHERE nummerplade = @nummerplade', {['@nummerplade'] = plate})
	if result[1] then
		exports.oxmysql:executeSync('DELETE FROM brugtebiler WHERE nummerplade = @nummerplade', {
			['@nummerplade'] = plate
		})
		TriggerClientEvent("odessa_bilmode:client:bought",src,plate,result[1].price,result[1].model)
		TriggerClientEvent("QBCore:Notify",src, "Du købte en bil. Tillykke fyr!", "success", 5000)
	else
		TriggerClientEvent("QBCore:Notify", src, "Kunne ikke finde bilen, prøv med en anden nummerplade...", "error", 5000)
	end
end)




QBCore.Functions.CreateCallback('odessa_bilmode:server:getvehs', function(source, cb)
    local result = exports.oxmysql:executeSync('SELECT * FROM brugtebiler')
	cb(result)
end)