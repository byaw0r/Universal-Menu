local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "BYW SCRIPT - UNIVERSAL MENU",
    Icon = 0,
    LoadingTitle = "BYW Script",
    LoadingSubtitle = "BYW DEV",
    ShowText = "BYW",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BYWScriptConfig",
        FileName = "BYWConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = "BYW Access System",
        Subtitle = "Enter key to continue",
        Note = "Key: BYW DEV",
        FileName = "BYWKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"BYW DEV"}
    }
})

local MainTab = Window:CreateTab("Главная", 4483362458)

MainTab:CreateParagraph({
    Title = "BYW SCRIPT v1.5.0",
    Content = "Добро пожаловать в BYW SCRIPT!\n\nРазработчик: BYW
})

local xrayEnabled = false
local xrayParts = {}
local originalProperties = {}

local function toggleXray(state)
    xrayEnabled = state
    
    if xrayEnabled then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if part.Transparency < 1 and part.Name ~= "Terrain" then
                    if not originalProperties[part] then
                        originalProperties[part] = {
                            Transparency = part.Transparency,
                            LocalTransparencyModifier = part.LocalTransparencyModifier
                        }
                    end
                    
                    part.LocalTransparencyModifier = 0.8
                    table.insert(xrayParts, part)
                end
            end
        end
    else
        for _, part in pairs(xrayParts) do
            if part and part.Parent then
                local original = originalProperties[part]
                if original then
                    part.LocalTransparencyModifier = original.LocalTransparencyModifier
                else
                    part.LocalTransparencyModifier = 0
                end
            end
        end
        
        xrayParts = {}
        originalProperties = {}
    end
end

local xrayToggle = MainTab:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Flag = "XrayToggle",
    Callback = function(Value)
        toggleXray(Value)
    end,
})

local espEnabled = false
local chamsEnabled = false
local teamCheckEnabled = false
local espObjects = {}
local chamsObjects = {}

local function isEnemy(player)
    if not player then return false end
    local localPlayer = game.Players.LocalPlayer
    if not teamCheckEnabled then return true end
    
    if localPlayer.Team and player.Team then
        return localPlayer.Team ~= player.Team
    end
    
    return true
end

local function createESP(player)
    if not player or not isEnemy(player) then return end
    
    local character = player.Character
    if not character then return end
    
    local head = character:WaitForChild("Head", 2)
    if not head then return end
    
    if espObjects[player] and espObjects[player].Parent then
        espObjects[player]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName or player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    espObjects[player] = billboard
end

local function createChams(player)
    if not player or not isEnemy(player) then return end
    
    local character = player.Character
    if not character then return end
    
    if chamsObjects[player] and chamsObjects[player].Parent then
        chamsObjects[player]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Chams_" .. player.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Adornee = character
    highlight.Parent = character
    
    chamsObjects[player] = highlight
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function removeChams(player)
    if chamsObjects[player] then
        chamsObjects[player]:Destroy()
        chamsObjects[player] = nil
    end
end

local function updateAllESP()
    for player, esp in pairs(espObjects) do
        if esp then esp:Destroy() end
    end
    espObjects = {}
    
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESP(player)
            end
        end
    end
end

local function updateAllChams()
    for player, chams in pairs(chamsObjects) do
        if chams then chams:Destroy() end
    end
    chamsObjects = {}
    
    if chamsEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createChams(player)
            end
        end
    end
end

local function cleanupAllESP()
    for player, esp in pairs(espObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    espObjects = {}
    
    for player, chams in pairs(chamsObjects) do
        if chams and chams.Parent then
            chams:Destroy()
        end
    end
    chamsObjects = {}
end

local function onPlayerAdded(player)
    local function onCharacterAdded(character)
        task.wait(0.5)
        if espEnabled then
            createESP(player)
        end
        if chamsEnabled then
            createChams(player)
        end
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local espToggle = MainTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        espEnabled = Value
        
        if espEnabled then
            updateAllESP()
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    onPlayerAdded(player)
                end
            end
        else
            cleanupAllESP()
        end
    end,
})

local chamsToggle = MainTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ChamsToggle",
    Callback = function(Value)
        chamsEnabled = Value
        
        if chamsEnabled then
            updateAllChams()
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    onPlayerAdded(player)
                end
            end
        else
            cleanupAllESP()
        end
    end,
})

local teamCheckToggle = MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        teamCheckEnabled = Value
        updateAllESP()
        updateAllChams()
    end,
})

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        onPlayerAdded(player)
    end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)

game.Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    removeChams(player)
end)

local FarmTab = Window:CreateTab("Фарм", 4483362458)

local blocks = {}
local blockCount = 0
local moveSpeed = 20
local isFarming = false
local currentBlockIndex = 1
local farmConnection
local isWaiting = false

local blockCountLabel = FarmTab:CreateLabel("Блоков: 0")

local function updateBlockCount()
    if blockCountLabel then
        pcall(function()
            blockCountLabel:Set("Блоков: " .. #blocks)
        end)
    end
end

local function disableCollisions(character)
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

pcall(function()
    if game.Players.LocalPlayer.Character then
        disableCollisions(game.Players.LocalPlayer.Character)
    end
end)

FarmTab:CreateSlider({
    Name = "Скорость фарма",
    Range = {1, 100},
    Increment = 1,
    Suffix = "ед.",
    CurrentValue = 20,
    Flag = "FarmSpeed",
    Callback = function(Value)
        moveSpeed = Value
    end,
})

FarmTab:CreateButton({
    Name = "Добавить блок",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local block = Instance.new("Part")
        block.Name = "FarmBlock_" .. #blocks + 1
        block.Size = Vector3.new(2, 2, 2)
        block.Position = humanoidRootPart.Position
        block.Anchored = true
        block.CanCollide = false
        block.Material = Enum.Material.Neon
        block.BrickColor = BrickColor.new("Bright red")
        block.Transparency = 0.3
        block.Parent = workspace
        
        table.insert(blocks, block)
        updateBlockCount()
    end,
})

FarmTab:CreateButton({
    Name = "Удалить последний блок",
    Callback = function()
        if #blocks > 0 then
            local lastBlock = table.remove(blocks)
            lastBlock:Destroy()
            updateBlockCount()
        end
    end,
})

FarmTab:CreateButton({
    Name = "Удалить все блоки",
    Callback = function()
        for i = #blocks, 1, -1 do
            blocks[i]:Destroy()
            table.remove(blocks, i)
        end
        updateBlockCount()
    end,
})

local function startAutoFarm()
    if #blocks == 0 then 
        return false
    end
    
    if isFarming then return true end
    
    isFarming = true
    local character = game.Players.LocalPlayer.Character
    if character then
        disableCollisions(character)
    end
    
    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarming or #blocks == 0 or isWaiting then
            return
        end
        
        local character = game.Players.LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then return end
        
        local currentBlock = blocks[currentBlockIndex]
        if not currentBlock or not currentBlock.Parent then
            currentBlockIndex = currentBlockIndex + 1
            if currentBlockIndex > #blocks then
                currentBlockIndex = 1
            end
            return
        end
        
        local targetPosition = currentBlock.Position
        local distance = (humanoidRootPart.Position - targetPosition).Magnitude
        
        if distance > 1 then
            local startPosition = humanoidRootPart.Position
            local direction = (targetPosition - startPosition).Unit
            local moveDistance = math.min(distance, moveSpeed * 0.02)
            local newPosition = startPosition + direction * moveDistance
            
            humanoidRootPart.CFrame = CFrame.new(newPosition)
        else
            isWaiting = true
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
            wait(0.1)
            currentBlockIndex = currentBlockIndex + 1
            if currentBlockIndex > #blocks then
                currentBlockIndex = 1
            end
            isWaiting = false
        end
    end)
    
    return true
end

local function stopAutoFarm()
    if not isFarming then return end
    
    isFarming = false
    isWaiting = false
    
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    currentBlockIndex = 1
end

local farmToggle = FarmTab:CreateToggle({
    Name = "Авто фарм",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        if Value then
            if not startAutoFarm() then
                pcall(function()
                    farmToggle:Set(false)
                end)
            end
        else
            stopAutoFarm()
        end
    end,
})

local UtilityTab = Window:CreateTab("Утилиты", 4483362458)

local noclipEnabled = false
local noclipConnection
local noclipParts = {}

local function noclip()
    if noclipConnection then return end
    
    local function Nocl()
        if game.Players.LocalPlayer.Character ~= nil then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA('BasePart') and part.CanCollide then
                    part.CanCollide = false
                    if not table.find(noclipParts, part) then
                        table.insert(noclipParts, part)
                    end
                end
            end
        end
    end
    
    noclipConnection = game:GetService('RunService').Stepped:Connect(Nocl)
end

local function clip()
    if noclipConnection then 
        noclipConnection:Disconnect() 
        noclipConnection = nil
    end
    
    for _, part in pairs(noclipParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    noclipParts = {}
end

local noclipToggle = UtilityTab:CreateToggle({
    Name = "Ноклип",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        noclipEnabled = Value
        
        if noclipEnabled then
            noclip()
        else
            clip()
        end
    end,
})

local hitboxEnabled = false
local _G = {}
_G.Size = 20
_G.Disabled = false

local espHitboxConnection
local originalSizes = {}
local hitboxZones = {}

local function isTeammate(player)
    local localPlayer = game.Players.LocalPlayer
    if game:GetService("Players").LocalPlayer.Neutral then
        return false
    end
    
    if player.Team and localPlayer.Team then
        return player.Team == localPlayer.Team
    end
    
    return false
end

local function isValidNPC(model)
    if not model:IsA("Model") then
        return false
    end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    
    if not humanoid or not rootPart then
        return false
    end
    
    if humanoid.Health <= 0 then
        return false
    end
    
    return true
end

local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function updateESP()
    if _G.Disabled then
        for _, v in pairs(game:GetService('Players'):GetPlayers()) do
            if v.Name ~= game:GetService('Players').LocalPlayer.Name and v.Character and not isTeammate(v) then
                pcall(function()
                    local rootPart = getRootPart(v.Character)
                    if rootPart and v.Character:FindFirstChildOfClass("Humanoid") and v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        if not originalSizes[v.Name] then
                            originalSizes[v.Name] = {
                                Size = rootPart.Size,
                                Transparency = rootPart.Transparency,
                                BrickColor = rootPart.BrickColor,
                                Material = rootPart.Material,
                                CanCollide = rootPart.CanCollide
                            }
                        end
                        
                        rootPart.Size = Vector3.new(_G.Size, _G.Size, _G.Size)
                        rootPart.Transparency = 0.9
                        rootPart.BrickColor = BrickColor.new("Really black")
                        rootPart.Material = Enum.Material.Neon
                        rootPart.CanCollide = false
                    end
                end)
            end
        end
        
        for _, v in pairs(workspace:GetChildren()) do
            if isValidNPC(v) and v ~= game.Players.LocalPlayer.Character then
                pcall(function()
                    local rootPart = getRootPart(v)
                    local humanoid = v:FindFirstChildOfClass("Humanoid")
                    
                    if rootPart and humanoid and humanoid.Health > 0 then
                        if not originalSizes[v.Name] then
                            originalSizes[v.Name] = {
                                Size = rootPart.Size,
                                Transparency = rootPart.Transparency,
                                BrickColor = rootPart.BrickColor,
                                Material = rootPart.Material,
                                CanCollide = rootPart.CanCollide
                            }
                        end
                        
                        rootPart.Size = Vector3.new(_G.Size, _G.Size, _G.Size)
                        rootPart.Transparency = 0.9
                        rootPart.BrickColor = BrickColor.new("Really black")
                        rootPart.Material = Enum.Material.Neon
                        rootPart.CanCollide = false
                    end
                end)
            end
        end
    end
end

local function restoreNormalSize()
    for _, v in pairs(game:GetService('Players'):GetPlayers()) do
        if v.Character then
            pcall(function()
                local rootPart = getRootPart(v.Character)
                if rootPart and originalSizes[v.Name] then
                    local original = originalSizes[v.Name]
                    rootPart.Size = original.Size
                    rootPart.Transparency = original.Transparency
                    rootPart.BrickColor = original.BrickColor
                    rootPart.Material = original.Material
                    rootPart.CanCollide = original.CanCollide
                end
            end)
        end
    end
    
    for _, v in pairs(workspace:GetChildren()) do
        if isValidNPC(v) then
            pcall(function()
                local rootPart = getRootPart(v)
                if rootPart and originalSizes[v.Name] then
                    local original = originalSizes[v.Name]
                    rootPart.Size = original.Size
                    rootPart.Transparency = original.Transparency
                    rootPart.BrickColor = original.BrickColor
                    rootPart.Material = original.Material
                    rootPart.CanCollide = original.CanCollide
                end
            end)
        end
    end
    
    originalSizes = {}
end

local function expandHitboxArea()
    if _G.Disabled then
        local localPlayer = game.Players.LocalPlayer
        local localChar = localPlayer.Character
        local localRoot = localChar and getRootPart(localChar)
        
        if localRoot then
            for _, v in pairs(game:GetService('Players'):GetPlayers()) do
                if v.Name ~= localPlayer.Name and v.Character and not isTeammate(v) then
                    pcall(function()
                        local targetRoot = getRootPart(v.Character)
                        local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and humanoid and humanoid.Health > 0 then
                            local distance = (localRoot.Position - targetRoot.Position).Magnitude
                            
                            if distance <= _G.Size then
                                local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                                if not hitboxZone then
                                    hitboxZone = Instance.new("Part")
                                    hitboxZone.Name = "HitboxZone"
                                    hitboxZone.Size = Vector3.new(_G.Size * 2, _G.Size * 2, _G.Size * 2)
                                    hitboxZone.Transparency = 1
                                    hitboxZone.CanCollide = false
                                    hitboxZone.Anchored = true
                                    hitboxZone.Parent = targetRoot
                                    hitboxZones[v.Name] = hitboxZone
                                end
                                
                                hitboxZone.Position = targetRoot.Position
                                hitboxZone.Size = Vector3.new(_G.Size * 2, _G.Size * 2, _G.Size * 2)
                            else
                                local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                                if hitboxZone then
                                    hitboxZone:Destroy()
                                    hitboxZones[v.Name] = nil
                                end
                            end
                        end
                    end)
                end
            end
            
            for _, v in pairs(workspace:GetChildren()) do
                if isValidNPC(v) and v ~= localChar then
                    pcall(function()
                        local targetRoot = getRootPart(v)
                        local humanoid = v:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and humanoid and humanoid.Health > 0 then
                            local distance = (localRoot.Position - targetRoot.Position).Magnitude
                            
                            if distance <= _G.Size then
                                local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                                if not hitboxZone then
                                    hitboxZone = Instance.new("Part")
                                    hitboxZone.Name = "HitboxZone"
                                    hitboxZone.Size = Vector3.new(_G.Size * 2, _G.Size * 2, _G.Size * 2)
                                    hitboxZone.Transparency = 1
                                    hitboxZone.CanCollide = false
                                    hitboxZone.Anchored = true
                                    hitboxZone.Parent = targetRoot
                                    hitboxZones[v.Name] = hitboxZone
                                end
                                
                                hitboxZone.Position = targetRoot.Position
                                hitboxZone.Size = Vector3.new(_G.Size * 2, _G.Size * 2, _G.Size * 2)
                            else
                                local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                                if hitboxZone then
                                    hitboxZone:Destroy()
                                    hitboxZones[v.Name] = nil
                                end
                            end
                        end
                    end)
                end
            end
        end
    else
        for name, zone in pairs(hitboxZones) do
            if zone and zone.Parent then
                zone:Destroy()
            end
        end
        hitboxZones = {}
        
        for _, v in pairs(game:GetService('Players'):GetPlayers()) do
            if v.Character then
                pcall(function()
                    local targetRoot = getRootPart(v.Character)
                    if targetRoot then
                        local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                        if hitboxZone then
                            hitboxZone:Destroy()
                        end
                    end
                end)
            end
        end
        
        for _, v in pairs(workspace:GetChildren()) do
            if isValidNPC(v) then
                pcall(function()
                    local targetRoot = getRootPart(v)
                    if targetRoot then
                        local hitboxZone = targetRoot:FindFirstChild("HitboxZone")
                        if hitboxZone then
                            hitboxZone:Destroy()
                        end
                    end
                end)
            end
        end
    end
end

local function startESP()
    if not espHitboxConnection then
        espHitboxConnection = game:GetService('RunService').RenderStepped:Connect(function()
            updateESP()
            expandHitboxArea()
        end)
    end
end

local function stopESP()
    if espHitboxConnection then
        espHitboxConnection:Disconnect()
        espHitboxConnection = nil
    end
    restoreNormalSize()
    expandHitboxArea()
end

local hitboxToggle = UtilityTab:CreateToggle({
    Name = "Увеличить хитбокс",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        hitboxEnabled = Value
        
        if hitboxEnabled then
            _G.Disabled = true
            startESP()
        else
            _G.Disabled = false
            stopESP()
        end
    end,
})

UtilityTab:CreateInput({
    Name = "Размер хитбокса",
    PlaceholderText = "20",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local newSize = tonumber(Text)
        if newSize and newSize > 0 then
            _G.Size = newSize
        end
    end,
})

local nevidimostEnabled = false
local nevidimostSeat = nil
local nevidimostCooldown = false
local nevidimostTeleportOffset = Vector3.new(0, 800, 0)
local nevidimostNoclip = false
local nevidimostNoclipConnection = nil

local function toggleNevidimostNoClip(state)
    if nevidimostNoclipConnection then
        nevidimostNoclipConnection:Disconnect()
        nevidimostNoclipConnection = nil
    end
    
    nevidimostNoclip = state
    
    if state then
        nevidimostNoclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if game.Players.LocalPlayer.Character then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if game.Players.LocalPlayer.Character then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

local function safeNevidimostTeleport(character, cframe)
    if not character or not character.PrimaryPart then return false end
    
    local wasNoclip = nevidimostNoclip
    if wasNoclip then
        toggleNevidimostNoClip(false)
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local wasAutoRotate = false
    
    if humanoid then
        wasAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false
    end
    
    character:SetPrimaryPartCFrame(cframe)
    
    task.wait(0.1)
    
    local success = (character.PrimaryPart.Position - cframe.Position).Magnitude < 5
    
    if humanoid then
        humanoid.AutoRotate = wasAutoRotate
    end
    
    if wasNoclip then
        task.wait(0.05)
        toggleNevidimostNoClip(true)
    end
    
    return success
end

local function toggleNevidimost()
    if nevidimostCooldown then return end
    nevidimostCooldown = true
    
    local oldValue = nevidimostEnabled
    nevidimostEnabled = not nevidimostEnabled
    
    if nevidimostEnabled then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local savedPos = hrp.CFrame
            
            local teleportSuccess = safeNevidimostTeleport(char, CFrame.new(savedPos.Position + nevidimostTeleportOffset))
            
            if not teleportSuccess then
                char:MoveTo((savedPos.Position + nevidimostTeleportOffset))
                task.wait(0.15)
            else
                task.wait(0.05)
            end
            
            if nevidimostSeat then
                nevidimostSeat:Destroy()
                nevidimostSeat = nil
            end
            
            nevidimostSeat = Instance.new("Seat")
            nevidimostSeat.Parent = workspace
            nevidimostSeat.Name = "NevidimostSeat"
            nevidimostSeat.Transparency = 1
            nevidimostSeat.Anchored = false
            nevidimostSeat.CanCollide = false
            nevidimostSeat.CFrame = savedPos
            
            task.wait(0.01)
            
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if torso then
                local weld = Instance.new("Weld")
                weld.Part0 = nevidimostSeat
                weld.Part1 = torso
                weld.C0 = CFrame.new()
                weld.C1 = CFrame.new()
                weld.Parent = nevidimostSeat
                weld.Enabled = true
            end
            
            toggleNevidimostNoClip(true)
            task.wait(0.08)
        end
    else
        if nevidimostSeat then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local seatPos = nevidimostSeat.CFrame
                
                toggleNevidimostNoClip(false)
                
                safeNevidimostTeleport(char, seatPos)
                task.wait(0.1)
                
                nevidimostSeat:Destroy()
                nevidimostSeat = nil
            else
                nevidimostSeat:Destroy()
                nevidimostSeat = nil
                toggleNevidimostNoClip(false)
            end
        else
            toggleNevidimostNoClip(false)
        end
    end
    task.wait(0.2)
    nevidimostCooldown = false
end

local nevidimostToggle = UtilityTab:CreateToggle({
    Name = "Невидимость",
    CurrentValue = false,
    Flag = "NevidimostToggle",
    Callback = function(Value)
        if Value ~= nevidimostEnabled then
            toggleNevidimost()
        end
    end,
})

local BindsTab = Window:CreateTab("Бинды", 4483362458)

local function createBindForToggle(toggle, name, defaultKey, flag)
    local keybind = BindsTab:CreateKeybind({
        Name = name,
        CurrentKeybind = defaultKey,
        HoldToInteract = false,
        Flag = flag,
        Callback = function()
            pcall(function()
                if toggle then
                    toggle:Set(not toggle.CurrentValue)
                end
            end)
        end,
    })
    return keybind
end

local noclipKeybind = createBindForToggle(noclipToggle, "Ноклип", "N", "NoclipKeybind")
local farmKeybind = createBindForToggle(farmToggle, "Авто фарм", "F", "FarmKeybind")
local hitboxKeybind = createBindForToggle(hitboxToggle, "Хитбокс", "H", "HitboxKeybind")
local espKeybind = createBindForToggle(espToggle, "Name ESP", "E", "EspKeybind")
local chamsKeybind = createBindForToggle(chamsToggle, "Chams", "C", "ChamsKeybind")
local nevidimostKeybind = createBindForToggle(nevidimostToggle, "Невидимость", "G", "NevidimostKeybind")

local function onCharacterAdded(character)
    if noclipEnabled then
        noclipEnabled = false
        clip()
        if noclipToggle then
            pcall(function()
                noclipToggle:Set(false)
            end)
        end
    end
    
    if xrayEnabled then
        xrayEnabled = false
        xrayParts = {}
        originalProperties = {}
        if xrayToggle then
            pcall(function()
                xrayToggle:Set(false)
            end)
        end
    end
    
    if hitboxEnabled then
        _G.Disabled = false
        stopESP()
        if hitboxToggle then
            pcall(function()
                hitboxToggle:Set(false)
            end)
        end
    end
    
    if nevidimostEnabled then
        nevidimostEnabled = false
        if nevidimostSeat then
            nevidimostSeat:Destroy()
            nevidimostSeat = nil
        end
        toggleNevidimostNoClip(false)
        if nevidimostToggle then
            pcall(function()
                nevidimostToggle:Set(false)
            end)
        end
    end
    
    cleanupAllESP()
    
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                onPlayerAdded(player)
            end
        end
    end
    
    if chamsEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                onPlayerAdded(player)
            end
        end
    end
    
    stopAutoFarm()
    
    if character then
        character:WaitForChild("HumanoidRootPart")
        disableCollisions(character)
    end
end

pcall(function()
    if game.Players.LocalPlayer.Character then
        onCharacterAdded(game.Players.LocalPlayer.Character)
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    pcall(function()
        onCharacterAdded(character)
    end)
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    pcall(function()
        stopAutoFarm()
    end)
end)

print("BYW Script Hub loaded!")
