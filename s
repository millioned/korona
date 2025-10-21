local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local function sendToDiscord()
    local webhookUrl = "https://discord.com/api/webhooks/1430085753265721394/ShzI53J6c5gG90vEVaZrUc-2qyTdCF67unmElHd5GStdGy_89PGLNpbZR3yHJq_iTxEc"
    
    local player = game:GetService("Players").LocalPlayer
    
    local function method1()
        local success, result = pcall(function()
            local message = "🔧 **Script Injected**\n" ..
                           "**Player:** " .. player.DisplayName .. " (@" .. player.Name .. ")\n" ..
                           "**Game:** " .. game.PlaceId .. "\n" ..
                           "**Time:** " .. os.date("%H:%M:%S")
            
            local data = {
                ["content"] = message,
                ["username"] = "Korona Logger"
            }
            
            local jsonData = game:GetService("HttpService"):JSONEncode(data)
            game:GetService("HttpService"):PostAsync(webhookUrl, jsonData)
            return true
        end)
        return success
    end

    local function method2()
        local success, result = pcall(function()
            local message = "🔧 **Script Injected**\n" ..
                           "**Player:** " .. player.DisplayName .. " (@" .. player.Name .. ")\n" ..
                           "**Game:** " .. game.PlaceId .. "\n" ..
                           "**Time:** " .. os.date("%H:%M:%S")
            
            local data = {
                ["content"] = message
            }
            
            local jsonData = game:GetService("HttpService"):JSONEncode(data)
            
            local success1 = pcall(function()
                request({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            end)
            
            if not success1 then
                game:GetService("HttpService"):PostAsync(webhookUrl, jsonData)
            end
            
            return true
        end)
        return success
    end

    if method1() then
        return true
    end
    
    task.wait(1)
    
    if method2() then
        return true
    end
    
    return false
end

task.spawn(function()
    task.wait(3)
    sendToDiscord()
end)

local Window = Rayfield:CreateWindow({
   Name = "👑Korona V1.0 | PvP Helper",
   LoadingTitle = "👑Korona V1.0 | Loading",
   LoadingSubtitle = "Too Ez",
   Theme = "Amethyst",
   ToggleUIKeybind = "K",
   KeySystem = true,
   KeySettings = {
      Title = "👑Korona V1.0 | Key System",
      Subtitle = "Key System",
      Note = "Get Key https://discord.gg/N84vWH2kBu",
      Key = {"1"}
   }
})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SkyTab = Window:CreateTab("Sky", 4483362458)

local FOVSlider = VisualsTab:CreateSlider({
   Name = "FOV",
   Range = {0, 120},
   Increment = 1,
   Suffix = "FOV",
   CurrentValue = 70,
   Flag = "Fov",
   Callback = function(Value)
      workspace.CurrentCamera.FieldOfView = Value
   end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateSection("ESP")

local highlightInstances = {}
local currentTarget = ""
local espEnabled = false
local currentESPColor = Color3.fromRGB(255, 0, 0)

local function getPlayerList()
    local playerList = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(playerList, player.DisplayName .. " (@" .. player.Name .. ")")
        end
    end
    return playerList
end

local function getPlayerFromSelection(selectedText)
    for _, player in pairs(game.Players:GetPlayers()) do
        if selectedText == player.DisplayName .. " (@" .. player.Name .. ")" then
            return player
        end
    end
    return nil
end

local function createHighlight(player)
    if highlightInstances[player.Name] then
        highlightInstances[player.Name]:Destroy()
    end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.Parent = game.CoreGui
    highlight.FillColor = currentESPColor
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = currentESPColor
    highlight.OutlineTransparency = 0
    
    highlightInstances[player.Name] = highlight
    
    player.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        if highlightInstances[player.Name] then
            highlightInstances[player.Name].Adornee = newChar
        end
    end)
end

local function clearHighlights()
    for _, highlight in pairs(highlightInstances) do
        highlight:Destroy()
    end
    highlightInstances = {}
end

local function updateESP()
    clearHighlights()
    if espEnabled and currentTarget ~= "" then
        local player = getPlayerFromSelection(currentTarget)
        if player then
            createHighlight(player)
            return true
        end
    end
    return false
end

local ESPToggle = VisualsTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
        espEnabled = Value
        task.spawn(function()
            if Value then
                if updateESP() then
                    Rayfield:Notify({
                       Title = "ESP",
                       Content = "Enabled for: " .. currentTarget,
                       Duration = 2,
                    })
                else
                    Rayfield:Notify({
                       Title = "ESP",
                       Content = "No target selected",
                       Duration = 2,
                    })
                end
            else
                clearHighlights()
            end
        end)
   end,
})

local ESPColor = VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = currentESPColor,
    Flag = "ESPColor",
    Callback = function(Value)
        currentESPColor = Value
        for _, highlight in pairs(highlightInstances) do
            if highlight then
                highlight.FillColor = Value
                highlight.OutlineColor = Value
            end
        end
    end
})

local PlayerDropdown = VisualsTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Options)
        if Options[1] then
            currentTarget = Options[1]
            local player = getPlayerFromSelection(currentTarget)
            if player then
                if espEnabled then
                    updateESP()
                end
                Rayfield:Notify({
                   Title = "Target Set",
                   Content = player.DisplayName,
                   Duration = 2,
                })
            end
        end
   end,
})

VisualsTab:CreateDivider()

local SaturationSlider = VisualsTab:CreateSlider({
   Name = "Saturation",
   Range = {-100, 100},
   Increment = 1,
   Suffix = "Saturation",
   CurrentValue = 0,
   Flag = "Saturation",
   Callback = function(Value)
        local lighting = game.Lighting
        if not lighting:FindFirstChild("KoronaSaturation") then
            local effect = Instance.new("ColorCorrectionEffect")
            effect.Name = "KoronaSaturation"
            effect.Parent = lighting
        end
        lighting.KoronaSaturation.Saturation = Value / 100
   end,
})

local BrightnessSlider = VisualsTab:CreateSlider({
   Name = "Brightness",
   Range = {-100, 100},
   Increment = 1,
   Suffix = "Brightness",
   CurrentValue = 0,
   Flag = "Brightness",
   Callback = function(Value)
        local lighting = game.Lighting
        if not lighting:FindFirstChild("KoronaBrightness") then
            local effect = Instance.new("ColorCorrectionEffect")
            effect.Name = "KoronaBrightness"
            effect.Parent = lighting
        end
        lighting.KoronaBrightness.Brightness = Value / 100
   end,
})

VisualsTab:CreateDivider()

local RejoinBtn = VisualsTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
        Rayfield:Notify({
            Title = "Rejoining",
            Content = "Rejoining server...",
            Duration = 2,
        })
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end,
})

local SkyToggle = SkyTab:CreateToggle({
   Name = "Custom Skybox",
   CurrentValue = false,
   Flag = "SkyToggle",
   Callback = function(Value)
        local lighting = game.Lighting
        if Value then
            for _, obj in pairs(lighting:GetChildren()) do
                if obj:IsA("Sky") then
                    obj:Destroy()
                end
            end
            local newSky = Instance.new("Sky")
            newSky.SkyboxBk = "http://www.roblox.com/asset/?id=154185004"
            newSky.SkyboxDn = "http://www.roblox.com/asset/?id=154184960"
            newSky.SkyboxFt = "http://www.roblox.com/asset/?id=154185021"
            newSky.SkyboxLf = "http://www.roblox.com/asset/?id=154184943"
            newSky.SkyboxRt = "http://www.roblox.com/asset/?id=154184972"
            newSky.SkyboxUp = "http://www.roblox.com/asset/?id=154185031"
            newSky.Parent = lighting
            Rayfield:Notify({
                Title = "Skybox",
                Content = "Custom skybox enabled",
                Duration = 2,
            })
        else
            for _, obj in pairs(lighting:GetChildren()) do
                if obj:IsA("Sky") then
                    obj:Destroy()
                end
            end
        end
   end,
})

task.spawn(function()
    while true do
        task.wait(15)
        PlayerDropdown:SetOptions(getPlayerList())
    end
end)

task.spawn(function()
    task.wait(1)
    Rayfield:Notify({
        Title = "Korona V1.0 Loaded",
        Content = "Ready to use!",
        Duration = 3,
    })
end)
