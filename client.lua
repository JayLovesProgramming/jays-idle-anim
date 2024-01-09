local config = require "config"
local isIdlePlaying = false
local lastActionTime = 0
local lastIdleAnimation = ""

local function cancelEmote()
    if exports.scully_emotemenu:isInEmote() then
        exports.scully_emotemenu:cancelEmote()
    end
end

local function playRandomIdleAnimation()
    local availableAnimations = {}
    for _, anim in ipairs(config.randomIdleAnimations) do
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
        if config.debug then
          print("Playing idle animation:", randomisedAnim)
        end
        Wait(6000)
        cancelEmote()
    end
end

local function handleKeybindRelease()
    if IsPedWalking(cache.ped) then
      lastActionTime = GetGameTimer()
    elseif GetGameTimer() - lastActionTime > config.idleTimeout  then
      cancelEmote()
      if config.debug then
        print("Cancelled emote")
      end
    end
end

CreateThread(function()
    lib.addKeybind({
        name = 'IdleAnimation',
        description = 'Idle animation',
        defaultKey = 'S',
        onReleased = handleKeybindRelease
    })
    while true do
        Wait(1000)
        if config.debug then
          print("Is in emote?", exports.scully_emotemenu:isInEmote())
          Wait(2000)
          print("Is in vehicle?", GetVehiclePedIsIn(cache.ped, false))
          Wait(2000)
          print("Does entity exist?", DoesEntityExist(cache.ped))
          Wait(2000)
          print("Is ped still??", IsPedStill(cache.ped))
          Wait(2000)
        end
        if DoesEntityExist(cache.ped) and GetVehiclePedIsIn(cache.ped, false) == 0  and not IsEntityDead(cache.ped) and IsPedStill(cache.ped) and not exports.scully_emotemenu:isInEmote() then
            if GetGameTimer() - lastActionTime > config.idleTimeout  then
              if config.debug then
                print("Triggered play animation function")
              end
                playRandomIdleAnimation()
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == "jays-idle-anim" then
      Wait(1000)
      cancelEmote()
    end
end)
