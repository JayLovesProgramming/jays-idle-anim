local lastIdleAnimation = nil
local isIdlePlaying = false
local lastActionTime = 0
local randomIdleAnim = config.randomIdleAnimations
local idleTimeout = config.idleTimeout

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
            print("[DEBUG] Playing idle animation:", randomisedAnim)
        end
    end
end

local function handleKeybindRelease()
    if IsPedWalking(PlayerPedId()) or not IsPedStill(PlayerPedId()) then
        lastActionTime = GetGameTimer()
        if config.debug then
            print("[DEBUG] Ped isn't still so I haven't cancelled the emote")
        end
    elseif GetGameTimer() - lastActionTime > idleTimeout then
        cancelEmote()
    end
end

CreateThread(function()
    if config.usingQB then 
        if LocalPlayer.state.isLoggedIn then
            Wait(10000) -- Small delay to stop it playing while in multicharacter // Leave this for now
            if config.debug then 
                print("[DEBUG] jays-idle-anim script has started")
            end
            CreateThread(function()
                while true do
                    Wait(idleTimeout)
                    if DoesEntityExist(PlayerPedId())
                    and not GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 
                    and not IsEntityDead(PlayerPedId()) 
                    and IsPedStill(PlayerPedId()) 
                    and not IsPedWalking(PlayerPedId()) then
                        if GetGameTimer() - lastActionTime > idleTimeout  then
                            if config.debug then
                                print("[DEBUG] Trying to play animation")
                            end
                            if config.emoteMenu == "rpemotes" then
                                if not exports["rpemotes"]:IsPlayerInAnim() then
                                    playRandomIdleAnimation()
                                end
                            elseif config.emoteMenu == "scully" then
                                if not exports.scully_emotemenu:isInEmote() then
                                    playRandomIdleAnimation()
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        CreateThread(function()
            while true do
                Wait(idleTimeout)
                if DoesEntityExist(PlayerPedId())
                and not GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 
                and not IsEntityDead(PlayerPedId()) 
                and IsPedStill(PlayerPedId()) 
                and not IsPedWalking(PlayerPedId()) then
                    if GetGameTimer() - lastActionTime > idleTimeout  then
                        if config.debug then
                            print("[DEBUG] Trying to play animation")
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
    end
end)

-- Command --
RegisterCommand('cancelidleanim', function()
    handleKeybindRelease()
end)

-- Key Mappings --
RegisterKeyMapping('cancelidleanim', 'Cancel Idle Animation (W)', 'keyboard', 'w')
RegisterKeyMapping('cancelidleanim', 'Cancel Idle Animation (A)', 'keyboard', 'a')
RegisterKeyMapping('cancelidleanim', 'Cancel Idle Animation (S)', 'keyboard', 's')
RegisterKeyMapping('cancelidleanim', 'Cancel Idle Animation (D)', 'keyboard', 'd')

-- When the resource restarts >> cancel emote pretty please --
AddEventHandler("onResourceStop", function(resourceName) -- Used for when the resource is restarted while in game
	if GetCurrentResourceName() ~= resourceName then
        return 
    end
    cancelEmote()
end)

