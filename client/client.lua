local zones = {}
local blips = {}

CreateThread(function()
  for area, doors in pairs(Config.Doors) do
    for index, door in ipairs(doors) do
      local zoneId = exports.ox_target:addBoxZone({
        name = ('door_%s_%s'):format(area, index),
        coords = door.coords,
        size = Config.OxTargetDefaults.size,
        rotation = Config.OxTargetDefaults.rotation,
        debug = Config.DebugMode,
        options = {
          {
            name = ('ring_%s_%s'):format(area, index),
            label = 'Klingeln',
            icon = 'fa-solid fa-bell',
            distance = Config.OxTargetDefaults.distance,
            onSelect = function(data)
              TriggerServerEvent('mp_TrickOrTreat:server:ring', area, index)
            end
          }
        }
      })
      table.insert(zones, zoneId)

      AddTextEntry('BLIP_CAT_13', 'Halloween-Türen')
      local blip = AddBlipForCoord(
        door.coords.x,
        door.coords.y,
        door.coords.z
      )
      SetBlipSprite(blip, Config.DebugBlip.blip)
      SetBlipColour(blip, Config.DebugBlip.color)
      SetBlipScale(blip, 0.6)
      SetBlipAsShortRange(blip, true)
      SetBlipCategory(blip, 13)
      SetBlipDisplay(blip, 5)

      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(
        ('Tür: %s #%s'):format(area, index)
      )
      EndTextCommandSetBlipName(blip)

      table.insert(blips, blip)
    end
  end
end)

AddEventHandler('onResourceStop', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end

  for _, blip in ipairs(blips) do
    if DoesBlipExist(blip) then
      RemoveBlip(blip)
    end
  end

  if GetResourceState('ox_target') == 'started' then
    for _, zoneId in ipairs(zones) do
      exports.ox_target:removeZone(zoneId)
    end
  end
end)