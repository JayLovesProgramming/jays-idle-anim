local config = require "config"
local isIdlePlaying = false
local lastActionTime = 0
local idleTimeout = tonumber(config.idleTimeout)
local randomIdleAnim = config.randomIdleAnimations
local lastIdleAnimation = ""

local function cancelEmote()
    if exports.scully_emotemenu:isInEmote() then
        exports.scully_emotemenu:cancelEmote()
    end
end

local function playRandomIdleAnimation()
    local availableAnimations = {}
    for _, anim in ipairs(randomIdleAnim) do
        if anim ~= lastIdleAnimation then
            table.insert(availableAnimations, anim)
        end
    end

    if #availableAnimations > 0 then
        local randomIndex = 1 + math.floor(#availableAnimations * math.random())
        local randomisedAnim = availableAnimations[randomIndex]
        exports.scully_emotemenu:playEmoteByCommand(randomisedAnim)
        isIdlePlaying = true
        lastIdleAnimation = randomisedAnim
        print("Playing idle animation:", randomisedAnim)
    end
end



local function handleKeybindRelease()
    if IsPedWalking(cache.ped) then
        lastActionTime = GetGameTimer()
    elseif GetGameTimer() - lastActionTime > idleTimeout  then
        cancelEmote()
    end
end


CreateThread(function()
    if config.usingQB then 
RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
  Wait(15000)
  CreateThread(function()
      local keybind = lib.addKeybind({
          name = 'IdleAnimation',
          description = 'Idle animation',
          defaultKey = 'S',
          onReleased = handleKeybindRelease
      })
      while true do
          Wait(idleTimeout)
          if DoesEntityExist(cache.ped)
          and not GetVehiclePedIsIn(cache.ped, false) ~= 0 
          and not IsEntityDead(cache.ped) 
          and IsPedStill(cache.ped) 
          and not exports.scully_emotemenu:isInEmote() 
          and not IsPedWalking(cache.ped) then
              if GetGameTimer() - lastActionTime > idleTimeout  then
                  print("Playing IDLE Anim")
                  playRandomIdleAnimation()
              end
          end
      end
  end)
end)
else
  Wait(20000)
  CreateThread(function()
      local keybind = lib.addKeybind({
          name = 'IdleAnimation',
          description = 'Idle animation',
          defaultKey = 'S',
          onReleased = handleKeybindRelease
      })
      while true do
          Wait(idleTimeout)
          if DoesEntityExist(cache.ped)
          and not GetVehiclePedIsIn(cache.ped, false) ~= 0 
          and not IsEntityDead(cache.ped) 
          and IsPedStill(cache.ped) 
          and not exports.scully_emotemenu:isInEmote() 
          and not IsPedWalking(cache.ped) then
              if GetGameTimer() - lastActionTime > idleTimeout  then
                  print("Playing IDLE Anim")
                  playRandomIdleAnimation()
              end
          end
      end
  end)
end
end)
