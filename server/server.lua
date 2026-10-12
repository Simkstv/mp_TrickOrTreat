local lastRing = {}

RegisterNetEvent('mp_TrickOrTreat:server:ring', function(area, index)
  local playerId = source

  if type(area) ~= 'string' or type(index) ~= 'number' then return end
  if index % 1 ~= 0 then return end

  local doors = Config.Doors[area]
  local door = doors and doors[index]
  if not door then return end

  local ped = GetPlayerPed(playerId)
  if ped == 0 then return end

  local distance = #(GetEntityCoords(ped) - door.coords)
  if distance > Config.OxTargetDefaults.distance + 1.0 then return end

  local identifier = GetPlayerIdentifierByType(playerId, 'license')
  if not identifier then return end

  -- Feste Tür-ID bevorzugen, ansonsten Koordinaten verwenden.
  local doorId = door.id or ('%.3f_%.3f_%.3f'):format(
    door.coords.x, door.coords.y, door.coords.z
  )
  local visitKey = ('trickortreat:visited:%s:%s'):format(identifier, doorId)

  if GetResourceKvpInt(visitKey) == 1 then
    TriggerClientEvent('ox_lib:notify', playerId, {
      title = 'Trick or Treat',
      description = 'Du hast an dieser Tür bereits geklingelt.',
      type = 'error'
    })
    return
  end

  -- Kurzer Spamschutz: maximal einmal alle 5 Sekunden.
  local now = os.time()
  if lastRing[playerId] and now - lastRing[playerId] < 5 then return end
  lastRing[playerId] = now

  local result = math.random(1, 2) == 1 and 'trick' or 'treat'

  if Config.DebugMode then
    print(('Spieler %s klingelt: %s, Tür %s → %s'):format(
      playerId, area, index, result
    ))
  end

  local rewards = result == 'trick' and Config.Tricks or Config.Treats
  if not rewards or #rewards == 0 then
    print(('[mp_TrickOrTreat] Keine Items für %s konfiguriert.'):format(result))
    return
  end

  -- Zufälliger Eintrag aus der passenden Liste.
  local reward = rewards[math.random(1, #rewards)]
  local amount = math.random(reward.ammount.min, reward.ammount.max)

  if not exports.ox_inventory:CanCarryItem(playerId, reward.item, amount) then
    if Config.DebugMode then
      print(('[mp_TrickOrTreat] Spieler %s kann %sx %s nicht tragen.'):format(
        playerId, amount, reward.item
      ))
    end
    return
  end

  -- Vor der Vergabe sperren, um doppelte Anfragen zu verhindern.
  SetResourceKvpInt(visitKey, 1)

  local success, response = exports.ox_inventory:AddItem(
    playerId, reward.item, amount
  )

  if not success then
    -- Bei fehlgeschlagener Vergabe erneuten Versuch erlauben.
    DeleteResourceKvp(visitKey)

    print(('[mp_TrickOrTreat] Itemvergabe fehlgeschlagen: %s'):format(
      tostring(response)
    ))
    return
  end
end)

AddEventHandler('playerDropped', function()
  lastRing[source] = nil
end)