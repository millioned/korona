local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Discord Webhook функция
local function sendToDiscord(playerName, userId, placeId, jobId)
    local webhookUrl = "https://discord.com/api/webhooks/1430085753265721394/ShzI53J6c5gG90vEVaZrUc-2qyTdCF67unmElHd5GStdGy_89PGLNpbZR3yHJq_iTxEc" -- Замени на свой вебхук
    
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "👑 Korona V1.0 | Script Injected",
            ["description"] = "Пользователь заинжектил скрипт",
            ["color"] = 10181046,
            ["fields"] = {
                {
                    ["name"] = "👤 Игрок",
                    ["value"] = "```" .. playerName .. "```",
                    ["inline"] = true
                },
                {
                    ["name"] = "🆔 User ID",
                    ["value"] = "```" .. userId .. "```",
                    ["inline"] = true
                },
                {
                    ["name"] = "🎮 Место",
                    ["value"] = "```" .. placeId .. "```",
                    ["inline"] = true
                },
                {
                    ["name"] = "🔧 Job ID",
                    ["value"] = "```" .. jobId .. "```",
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Korona V1.0 | " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }}
    }
    
    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    
    pcall(function()
        game:GetService("HttpService"):PostAsync(webhookUrl, jsonData)
    end)
end

-- Отправляем уведомление при инжекте
local player = game:GetService("Players").LocalPlayer
sendToDiscord(
    player.Name, 
    tostring(player.UserId), 
    tostring(game.PlaceId), 
    game.JobId
)

local Window = Rayfield:CreateWindow({
   Name = "👑Korona V1.0 | PvP Helper",
   Icon = 0,
   LoadingTitle = "👑Korona V1.0 | Loading",
   LoadingSubtitle = "Too Ez",
   ShowText = "Rayfield",
   Theme = "Amethyst",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/N84vWH2kBu",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "👑Korona V1.0 | Key System",
      Subtitle = "Key System",
      Note = "Get Key https://discord.gg/N84vWH2kBu",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"1"}
   }
})

local Tab = Window:CreateTab("Visuals", 4483362458)

local Slider = Tab:CreateSlider({
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

local Divider = Tab:CreateDivider()
local Section = Tab:CreateSection("ESP")

local highlightInstances = {}
local currentTarget = ""
local espEnabled = false
local currentESPColor = Color3.fromRGB(255, 0, 0)

local function getPlayerList()
    local playerList = {}
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            local displayText = player.DisplayName .. " (@" .. player.Name .. ")"
            table.insert(playerList, displayText)
        end
    end
    return playerList
end

local function getPlayerFromSelection(selectedText)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        local displayText = player.DisplayName .. " (@" .. player.Name .. ")"
        if displayText == selectedText then
            return player
        end
    end
    return nil
end

local function createHighlight(player)
    if highlightInstances[player.Name] then
        highlightInstances[player.Name]:Destroy()
        highlightInstances[player.Name] = nil
    end
    
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "KoronaESP_" .. player.Name
    highlight.Adornee = player.Character
    highlight.Parent = game:GetService("CoreGui")
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = currentESPColor
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = currentESPColor
    highlight.OutlineTransparency = 0
    
    highlightInstances[player.Name] = highlight
    
    player.CharacterAdded:Connect(function(character)
        if highlightInstances[player.Name] and highlightInstances[player.Name].Parent then
            highlightInstances[player.Name].Adornee = character
        end
    end)
end

local function updateESPColors()
    for playerName, highlight in pairs(highlightInstances) do
        if highlight and highlight.Parent then
            highlight.FillColor = currentESPColor
            highlight.OutlineColor = currentESPColor
        end
    end
end

local function clearAllHighlights()
    for playerName, highlight in pairs(highlightInstances) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlightInstances = {}
end

local function updateESP()
    clearAllHighlights()
    
    if espEnabled and currentTarget ~= "" then
        local player = getPlayerFromSelection(currentTarget)
        if player then
            createHighlight(player)
            return true
        end
    end
    return false
end

local Toggle = Tab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
        espEnabled = Value
        local success = updateESP()
        
        if Value then
            if success then
                Rayfield:Notify({
                   Title = "ESP",
                   Content = "ESP system enabled for: " .. currentTarget,
                   Duration = 3,
                   Image = 0,
                })
            else
                Rayfield:Notify({
                   Title = "ESP",
                   Content = "ESP enabled but no target selected",
                   Duration = 3,
                   Image = 0,
                })
            end
        else
            Rayfield:Notify({
               Title = "ESP",
               Content = "ESP system disabled",
               Duration = 2,
               Image = 0,
            })
        end
   end,
})

local ColorPicker = Tab:CreateColorPicker({
    Name = "ESP Color Picker",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ColorPicker1",
    Callback = function(Value)
        currentESPColor = Value
        updateESPColors()
        
        Rayfield:Notify({
            Title = "ESP Color Changed",
            Content = "ESP color updated successfully",
            Duration = 2,
            Image = 0,
        })
    end
})

local Dropdown = Tab:CreateDropdown({
   Name = "Select Player for ESP",
   Options = getPlayerList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Options)
        if #Options > 0 then
            currentTarget = Options[1]
            local player = getPlayerFromSelection(currentTarget)
            
            if player then
                if espEnabled then
                    updateESP()
                    Rayfield:Notify({
                       Title = "ESP Target",
                       Content = "Now tracking: " .. player.DisplayName,
                       Duration = 3,
                       Image = 0,
                    })
                else
                    Rayfield:Notify({
                       Title = "ESP Target",
                       Content = "Target set: " .. player.DisplayName .. " (Enable ESP Toggle)",
                       Duration = 3,
                       Image = 0,
                    })
                end
            end
        end
   end,
})

local function updatePlayerList()
    local newOptions = getPlayerList()
    
    Dropdown:SetOptions(newOptions)
    
    if currentTarget ~= "" then
        local playerStillExists = false
        for _, option in pairs(newOptions) do
            if option == currentTarget then
                playerStillExists = true
                break
            end
        end
        
        if not playerStillExists then
            currentTarget = ""
            if #newOptions > 0 then
                currentTarget = newOptions[1]
            end
            if espEnabled then
                updateESP()
            end
        end
    elseif #newOptions > 0 and currentTarget == "" then
        currentTarget = newOptions[1]
        if espEnabled then
            updateESP()
        end
    end
end

local function rejoinServer()
    local teleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    Rayfield:Notify({
        Title = "Rejoining Server",
        Content = "Rejoining current server...",
        Duration = 3,
        Image = 0,
    })
    
    teleportService:TeleportToPlaceInstance(placeId, jobId, game:GetService("Players").LocalPlayer)
end

local Divider = Tab:CreateDivider()

local Slider2 = Tab:CreateSlider({
   Name = "Saturation",
   Range = {-100, 100},
   Increment = 1,
   Suffix = "Saturation",
   CurrentValue = 0,
   Flag = "Saturation",
   Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        
        if not Lighting:FindFirstChild("ColorCorrection") then
            local colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Name = "ColorCorrection"
            colorCorrection.Parent = Lighting
        end
        
        Lighting.ColorCorrection.Saturation = Value / 100
   end,
})

local Slider3 = Tab:CreateSlider({
   Name = "Brightness",
   Range = {-100, 100},
   Increment = 1,
   Suffix = "Brightness",
   CurrentValue = 0,
   Flag = "Brightness",
   Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        
        if not Lighting:FindFirstChild("ColorCorrection") then
            local colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Name = "ColorCorrection"
            colorCorrection.Parent = Lighting
        end
        
        Lighting.ColorCorrection.Brightness = Value / 100
   end,
})

local Divider = Tab:CreateDivider()

local Button = Tab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
        rejoinServer()
   end,
})

game:GetService("Players").PlayerAdded:Connect(function(player)
    updatePlayerList()
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if highlightInstances[player.Name] then
        highlightInstances[player.Name]:Destroy()
        highlightInstances[player.Name] = nil
    end
    updatePlayerList()
end)

updatePlayerList()

Rayfield:Notify({
    Title = "Korona V1.0 Loaded",
    Content = "ESP system ready!",
    Duration = 5,
    Image = 0,
})

while true do
    task.wait(10)
    updatePlayerList()
end

local SkyTab = Window:CreateTab("Sky", 4483362458)

local Toggle2 = SkyTab:CreateToggle({
   Name = "Custom Skybox",
   CurrentValue = false,
   Flag = "SkyToggle",
   Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        
        if Value then
            for _, existingSky in pairs(Lighting:GetChildren()) do
                if existingSky:IsA("Sky") then
                    existingSky:Destroy()
                end
            end
            
            local newSky = Instance.new("Sky")
            newSky.Name = "KoronaSkybox"
            newSky.SkyboxBk = "http://www.roblox.com/asset/?id=154185004"
            newSky.SkyboxDn = "http://www.roblox.com/asset/?id=154184960"
            newSky.SkyboxFt = "http://www.roblox.com/asset/?id=154185021"
            newSky.SkyboxLf = "http://www.roblox.com/asset/?id=154184943"
            newSky.SkyboxRt = "http://www.roblox.com/asset/?id=154184972"
            newSky.SkyboxUp = "http://www.roblox.com/asset/?id=154185031"
            newSky.Parent = Lighting
            
            Rayfield:Notify({
                Title = "Skybox",
                Content = "Custom skybox enabled",
                Duration = 3,
                Image = 0,
            })
        else
            for _, existingSky in pairs(Lighting:GetChildren()) do
                if existingSky:IsA("Sky") then
                    existingSky:Destroy()
                end
            end
            
            Rayfield:Notify({
                Title = "Skybox",
                Content = "Custom skybox disabled",
                Duration = 3,
                Image = 0,
            })
        end
   end,
})
