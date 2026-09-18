--[[
    ANTI-SKID LOADER
    Professional 3-File System
    Load this file only.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- ============================================================
-- EDIT THESE TWO URLS TO MATCH YOUR GITHUB
-- ============================================================
local CONFIG_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Config.lua"
local CORE_URL   = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Core.lua"

local function fail(reason)
    warn("[AntiSkid] " .. tostring(reason))
    pcall(function()
        if Players.LocalPlayer then
            Players.LocalPlayer:Kick("Ur A Bum Skidder Lol")
        end
    end)
end

-- Fetch Config
local successConfig, configSource = pcall(function()
    return game:HttpGet(CONFIG_URL, true)
end)

if not successConfig or type(configSource) ~= "string" or #configSource < 30 then
    fail("Failed to load Config")
    return
end

local configFunc, configErr = loadstring(configSource)
if not configFunc then
    fail("Config compile error")
    return
end

local Config = configFunc()
if type(Config) ~= "table" then
    fail("Invalid Config")
    return
end

-- Fetch Core
local successCore, coreSource = pcall(function()
    return game:HttpGet(CORE_URL, true)
end)

if not successCore or type(coreSource) ~= "string" or #coreSource < 50 then
    fail("Failed to load Core")
    return
end

local coreFunc, coreErr = loadstring(coreSource)
if not coreFunc then
    fail("Core compile error")
    return
end

-- Pass Config into Core and start protection
local ok, err = pcall(function()
    coreFunc(Config)
end)

if not ok then
    fail("Core execution failed: " .. tostring(err))
end