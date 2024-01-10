local config = require "config"
local randomIdleAnim = config.randomIdleAnimations
local lastIdleAnimation
local isIdlePlaying = false
local lastActionTime = 0
local idleTimeout = tonumber(config.idleTimeout)

local function cancelEmote()
    if config.debug then
        print("[DEBUG] Cancelled EMOTE")
    end
    if config.emoteMenu == "rpemotes" then
        if exports["rpemotes"]:IsPlayerInAnim() then
            exports["rpemotes"]:EmoteCancel(true)
        end
    end
    if config.emoteMenu == "scully" then
        if exports.scully_emotemenu:isInEmote() then
            exports.scully_emotemenu:cancelEmote()
        end
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
        if config.emoteMenu == "rpemotes" then
            exports["rpemotes"]:EmoteCommandStart(randomisedAnim)
        elseif config.emoteMenu == "scully" then
            exports.scully_emotemenu:playEmoteByCommand(randomisedAnim)
        end
        isIdlePlaying = true
        lastIdleAnimation = randomisedAnim
        if config.debug then
            print("Playing idle animation:", randomisedAnim)
        end
    end
end

local function handleKeybindRelease()
    if IsPedWalking(cache.ped) or not IsPedStill(cache.ped) then
        lastActionTime = GetGameTimer()
        if config.debug then
            print("[DEBUG] Ped isn't still so I haven't cancelled the emote")
        end
    elseif GetGameTimer() - lastActionTime > idleTimeout  then
        cancelEmote()
    end
end


CreateThread(function()
if config.usingQB then 
    AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(12000)
    if config.debug then 
        print("[DEBUG] jays-idle-anim script has started")
    end
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
          and not IsPedWalking(cache.ped) then
              if GetGameTimer() - lastActionTime > idleTimeout  then
                if config.debug then
                    print("Playing IDLE Anim")
                end
            if config.emoteMenu == "rpemotes" then
                if not exports["rpemotes"]:IsPlayerInAnim() then
                    playRandomIdleAnimation()
                end
            elseif config.emoteMenu == "scully" then
                    if not exports.scully_emotemenu:isInEmote()  then
                        playRandomIdleAnimation()
                    end
                end
                end
              end
          end
  end)
end)
elseif not config.usingQB and config.debug then
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
          and not IsPedWalking(cache.ped) then
              if GetGameTimer() - lastActionTime > idleTimeout  then
                if config.debug then
                  print("Playing IDLE Anim")
                  if config.emoteMenu == "rpemotes" then
                    if not exports["rpemotes"]:IsPlayerInAnim() then
                        playRandomIdleAnimation()
                    end
                elseif config.emoteMenu == "scully" then
                    if not exports.scully_emotemenu:isInEmote()  then
                            playRandomIdleAnimation()
                        end
                    end
              end
            end
          end
      end
  end)
end
end)
