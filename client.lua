local config = config
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
    if config.useSingleEmote then
        if config.debug then
            print("[DEBUG] Playing idle animation:", config.singleEmote)
        end
        if config.emoteMenu == "rpemotes" then
            exports["rpemotes"]:EmoteCommandStart(config.singleEmote)
        elseif config.emoteMenu == "scully" then
            exports.scully_emotemenu:playEmoteByCommand(config.singleEmote)
        end
    else
    local availableAnimations = {}
    for _, anim in ipairs(randomIdleAnim) do
        if anim ~= lastIdleAnimation then
            table.insert(availableAnimations, anim)
        end
    end
    if #availableAnimations > 0 then
        local randomIndex = 1 + math.floor(#availableAnimations * math.random())
        local randomisedAnim = availableAnimations[randomIndex]
        if config.debug then
            print("[DEBUG] Playing idle animation:", randomisedAnim)
        end
        if config.emoteMenu == "rpemotes" then
            exports["rpemotes"]:EmoteCommandStart(randomisedAnim)
        elseif config.emoteMenu == "scully" then
            exports.scully_emotemenu:playEmoteByCommand(randomisedAnim)
        end
        isIdlePlaying = true
        lastIdleAnimation = randomisedAnim
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

local function simpleCheck()
    if DoesEntityExist(PlayerPedId())
    and IsPedStill(PlayerPedId()) 
    and GetVehiclePedIsIn(PlayerPedId(), false) == 0 
    and not IsEntityDead(PlayerPedId()) 
    and not IsPedWalking(PlayerPedId()) then    
        return true 
    else
        if config.debug then
            print("[DEBUG] Failed Simple Check")
        end
        return false
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
                    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                        Wait(idleTimeout * 2)
                    end
                    
                        if GetGameTimer() - lastActionTime > idleTimeout and simpleCheck() then
                            -- if config.debug then
                            --     print("[DEBUG] Trying to play animation")
                            -- end
                            if config.emoteMenu == "rpemotes" then
                                if not exports["rpemotes"]:IsPlayerInAnim() then
                                    playRandomIdleAnimation()
                                end
                            elseif config.emoteMenu == "scully" then
                                if config.debug then
                                    print("[DEBUG] Is in animation? =  ",exports.scully_emotemenu:isInEmote())
                                end
                                if not exports.scully_emotemenu:isInEmote() then

                                    playRandomIdleAnimation()
                                end
                            end
                        end
                    end
            end)
        end
    else
        CreateThread(function()
            Wait(20000)
            -- ADD UR LOGIC HERE TO CHECK IF PLAYER IS SPAWNED IN.
            while true do
                Wait(idleTimeout)
                if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                    Wait(idleTimeout * 2)
                end
                    if GetGameTimer() - lastActionTime > idleTimeout and simpleCheck() then
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
        end)
    end
end)

-- Command --
RegisterCommand('cancelidleanimW', function()
    handleKeybindRelease()
end)
RegisterCommand('cancelidleanimA', function()
    handleKeybindRelease()
end)
RegisterCommand('cancelidleanimS', function()
    handleKeybindRelease()
end)
RegisterCommand('cancelidleanimD', function()
    handleKeybindRelease()
end)
-- Key Mappings --
RegisterKeyMapping('cancelidleanimW', 'Cancel Idle Animation (W)', 'keyboard', 'w')
RegisterKeyMapping('cancelidleanimA', 'Cancel Idle Animation (A)', 'keyboard', 'a')
RegisterKeyMapping('cancelidleanimS', 'Cancel Idle Animation (S)', 'keyboard', 's')
RegisterKeyMapping('cancelidleanimD', 'Cancel Idle Animation (D)', 'keyboard', 'd')

-- When the resource restarts >> cancel emote pretty please --
AddEventHandler("onResourceStop", function(resourceName) -- Used for when the resource is restarted while in game
	if GetCurrentResourceName() ~= resourceName then
        return 
    end
    cancelEmote()
end)

