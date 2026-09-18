--[[
    #Antiskids
]]

return function(Config)
    if type(Config) ~= "table" then
        return
    end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer

    -- ============================================================
    -- 
    -- ============================================================
    local Runtime = {
        Id = HttpService:GenerateGUID(false),
        Connections = {},
        Destroyed = false,
        Stage1 = false,
        Stage2 = false,
        Stage3 = false
    }

    getgenv().AntiSkidRuntimeId = Runtime.Id

    local function isValid()
        return not Runtime.Destroyed and getgenv().AntiSkidRuntimeId == Runtime.Id
    end

    local function track(conn)
        if conn then
            table.insert(Runtime.Connections, conn)
        end
        return conn
    end

    local function cleanup()
        Runtime.Destroyed = true
        for _, conn in ipairs(Runtime.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        table.clear(Runtime.Connections)
    end

    if getgenv().AntiSkidActive then
        if getgenv().AntiSkidCleanup then
            pcall(getgenv().AntiSkidCleanup)
        end
    end
    getgenv().AntiSkidActive = true
    getgenv().AntiSkidCleanup = cleanup

    local function log(msg)
        if Config.Debug then
            print("[AntiSkid] " .. tostring(msg))
        end
    end

    local function kick()
        pcall(function()
            if LocalPlayer then
                LocalPlayer:Kick(Config.KickMessage or "Ur A Bum Skidder Lol")
            end
        end)
        cleanup()
    end

    -- ============================================================
    -- 
    -- ============================================================
    local function stage1()
        if type(Config.Version) ~= "string" or Config.Version ~= "3.0.0" then
            return false
        end
        if Config.KickMessage ~= "Ur A Bum Skidder Lol" then
            return false
        end
        if type(Config.MarkerA) ~= "string" or Config.MarkerA ~= "ANTI_SKID_STAGE_ONE" then
            return false
        end

        Runtime.Stage1 = true
        log("Stage 1 passed")
        return true
    end

    -- ============================================================
    -- 
    -- ============================================================
    local function stage2()
        if not Runtime.Stage1 then return false end

        if Config.MarkerB ~= "ANTI_SKID_STAGE_TWO" then
            return false
        end
        if Config.MarkerC ~= "ANTI_SKID_STAGE_THREE" then
            return false
        end
        if getgenv().AntiSkidRuntimeId ~= Runtime.Id then
            return false
        end
        if type(stage1) ~= "function" or type(kick) ~= "function" then
            return false
        end

        Runtime.Stage2 = true
        log("Stage 2 passed")
        return true
    end

    -- ============================================================
    -- 
    -- ============================================================
    local function stage3()
        if not isValid() then return false end
        if not Runtime.Stage1 or not Runtime.Stage2 then return false end

        if Config.KickMessage ~= "Ur A Bum Skidder Lol" then
            return false
        end
        if Config.Version ~= "3.0.0" then
            return false
        end
        if getgenv().AntiSkidRuntimeId ~= Runtime.Id then
            return false
        end

        Runtime.Stage3 = true
        return true
    end

    -- ============================================================
    -- 
    -- ============================================================
    if not stage1() then
        kick()
        return
    end

    if not stage2() then
        kick()
        return
    end

    local lastCheck = 0
    track(RunService.Heartbeat:Connect(function()
        if not isValid() then return end

        local now = tick()
        if now - lastCheck < (Config.CheckInterval or 2.5) then return end
        lastCheck = now

        if not stage3() then
            log("Stage 3 failed - script edited or tampered")
            kick()
        end
    end))

    log("All 3 stages active. Protection running.")
    print("[AntiSkid] 3-Stage Protection Online | Version " .. Config.Version)
end