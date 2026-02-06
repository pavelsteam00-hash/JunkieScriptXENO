local type_custom = typeof
if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return function(...) return f(...) end end
    LPH_ENCSTR = function(...) return ... end
    LPH_ENCNUM = function(...) return ... end
    LPH_ENCFUNC = function(func, key1, key2) return func end
    LPH_CRASH = function() end
end

local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Splix"))()
local window = library:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "SILVER PRIVATE - REWORK",color = Color3.fromRGB(140, 0, 255)})

local combat_tab = window:page({name = "COMBAT"})
local visuals_tab = window:page({name = "VISUALS"})

local hitbox_section = combat_tab:section({name = "HITBOX",side = "left",size = 250})
local esp_section = visuals_tab:section({name = "PLAYER ESP",side = "left",size = 250})
local object_esp_section = visuals_tab:section({name = "ORE ESP",side = "right",size = 250})
local backpack_crates_section = visuals_tab:section({name = "OBJECT ESP",side = "right",size = 300})

local validcharacters = {}
local hbc, original_size, hbsize = nil, Vector3.new(1, 1, 1), Vector3.new(3, 3, 3)
local hitboxheadsizex, hitboxheadsizey, hitboxheadtransparency, cancollide = 3, 3, 5, false
local hitboxSleeperCheck = false
local hitboxBotCheck = false

local espEnabled = false
local boxEsp = false
local filledEsp = false
local chamsEsp = false
local infoEsp = false
local checkSleeper = false
local checkBoot = false
local maxDistance = 1000
local espColor = Color3.new(1, 1, 1)
local chamsColor = Color3.new(1, 0, 0)

local objectEspEnabled = false
local stoneEsp = false
local oreEsp = false
local nitrateEsp = false
local objectMaxDistance = 500
local objectCache = {}
local objectEspObjects = {}

local stoneColor = Color3.fromRGB(128, 128, 128)
local oreColor = Color3.fromRGB(205, 127, 50)
local nitrateColor = Color3.fromRGB(255, 255, 255)

local backpackEspEnabled = false
local backpackEspColor = Color3.fromRGB(0, 255, 255)
local backpackCache = {}
local backpackEspObjects = {}

local cratesEspEnabled = false
local crateTotemEsp = false
local crateSafeEsp = false
local crateCartonEsp = false
local crateColaMachineEsp = false

local totemColor = Color3.fromRGB(0, 0, 255)
local safeColor = Color3.fromRGB(0, 255, 255)
local cartonColor = Color3.fromRGB(128, 0, 128)
local colaMachineColor = Color3.fromRGB(128, 128, 0)

local cratesCache = {}
local cratesEspObjects = {}

local enttiyidentification = {}
local function setupEntityIdentification()
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    for i, v in ReplicatedStorage.Shared.entities:GetChildren() do
        local model = v:FindFirstChild("Model")
        if model and model.PrimaryPart then
            enttiyidentification[v.Name] = {
                CollisionGroup = model.PrimaryPart.CollisionGroup,
                Material = model.PrimaryPart.Material,
                Color = model.PrimaryPart.Color
            }
        end
    end
end

setupEntityIdentification()

local function identify_model(model)
    if model.ClassName ~= "Model" then return false, false end
    
    local meshPart = model:FindFirstChildOfClass("MeshPart")
    if meshPart and meshPart.MeshId == "rbxassetid://12939036056" then
        if #model:GetChildren() == 1 then
            return "Stone", model:GetChildren()[1]
        else
            for _, part in model:GetChildren() do
                if part.Color == Color3.fromRGB(248, 248, 248) then
                    return "Nitrate", part
                elseif part.Color == Color3.fromRGB(199, 172, 120) then
                    return "Iron", part
                end
            end
        end
    end
    
    if not model.PrimaryPart then return false, false end
    local primpart = model.PrimaryPart
    for name, entity in enttiyidentification do
        if entity.Color == primpart.Color and entity.Material == primpart.Material and entity.CollisionGroup == primpart.CollisionGroup then
            return name, primpart
        end
    end
    return false, false
end

local function isTargetBag(model)
    if (model.Name == "Model" and #model:GetChildren() == 2) then
        local p1 = model:FindFirstChild("Part")
        if (p1 and p1:IsA("BasePart")) then
            local s = p1.Size
            if (s.Y < 3 and s.X < 3 and s.Z < 3) then
                return true
            end
        end
    end
    return false
end

local function isTargetCrate(model)
    if not model:IsA("Model") then return false, nil end
    if LocalPlayer.Character and model:IsDescendantOf(LocalPlayer.Character) then return false, nil end
    
    if model:FindFirstChild("State") then
        return true, "Totem"
    end
    
    local children = {}
    for _, child in pairs(model:GetChildren()) do
        children[child.Name] = true
    end
    
    if children['Body'] and children['Wheel'] then
        return true, "Safe"
    elseif children['box'] and children['trash'] then
        return true, "Carton"
    elseif children['Dispenser'] and children['Machine'] then
        return true, "Cola Machine"
    end
    
    return false, nil
end

local playerCache = {}
local espObjects = {}
local chamsObjects = {}

local function addtovc(obj)
    if not obj then return end
    if not obj:FindFirstChild("Head") and not obj:FindFirstChild("LowerTorso") then return end
    validcharacters[obj] = obj
end

local function removefromvc(obj)
    if not validcharacters[obj] then return end
    validcharacters[obj] = nil
end

local function isSleeper(model)
    local lt = model:FindFirstChild("LowerTorso")
    if lt then
        local rj = lt:FindFirstChild("RootRig")
        if rj and typeof(rj.CurrentAngle) == "number" and rj.CurrentAngle ~= 0 then return true end
    end
    return false
end

local function isBot(model)
    local torso = model:FindFirstChild("Torso")
    if torso and torso:FindFirstChild("LeftBooster") then
        return false
    else
        return true
    end
end

local function addToPlayerCache(obj)
    if obj:IsA("Model") then
        local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("LowerTorso")
        if root and obj.Name ~= LocalPlayer.Name then 
            table.insert(playerCache, obj) 
        end
    end
end

local function removeFromPlayerCache(obj)
    for i = #playerCache, 1, -1 do 
        if playerCache[i] == obj then 
            table.remove(playerCache, i) 
        end 
    end
end

local function addToObjectCache(obj)
    if obj:IsA("Model") then
        local espname, mainpart = identify_model(obj)
        if espname and (espname == "Stone" or espname == "Iron" or espname == "Nitrate") then
            table.insert(objectCache, {model = obj, type = espname, part = mainpart})
        end
    end
end

local function removeFromObjectCache(obj)
    for i = #objectCache, 1, -1 do 
        if objectCache[i].model == obj then 
            table.remove(objectCache, i) 
        end 
    end
    if objectEspObjects[obj] then
        objectEspObjects[obj].Visible = false
        objectEspObjects[obj]:Remove()
        objectEspObjects[obj] = nil
    end
end

local function addToBackpackCache(obj)
    if obj:IsA("Model") and isTargetBag(obj) then
        table.insert(backpackCache, {model = obj, part = obj:FindFirstChild("Part")})
    end
end

local function removeFromBackpackCache(obj)
    for i = #backpackCache, 1, -1 do 
        if backpackCache[i].model == obj then 
            table.remove(backpackCache, i) 
        end 
    end
    if backpackEspObjects[obj] then
        backpackEspObjects[obj].Visible = false
        backpackEspObjects[obj]:Remove()
        backpackEspObjects[obj] = nil
    end
end

local function addToCratesCache(obj)
    if obj:IsA("Model") then
        local isCrate, crateType = isTargetCrate(obj)
        if isCrate then
            local primaryPart = obj.PrimaryPart or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                table.insert(cratesCache, {model = obj, type = crateType, part = primaryPart})
            end
        end
    end
end

local function removeFromCratesCache(obj)
    for i = #cratesCache, 1, -1 do 
        if cratesCache[i].model == obj then 
            table.remove(cratesCache, i) 
        end 
    end
    if cratesEspObjects[obj] then
        cratesEspObjects[obj].Visible = false
        cratesEspObjects[obj]:Remove()
        cratesEspObjects[obj] = nil
    end
end

for i, v in next, workspace:GetChildren() do 
    addtovc(v) 
    addToPlayerCache(v)
    addToObjectCache(v)
    addToBackpackCache(v)
    addToCratesCache(v)
end

workspace.ChildAdded:Connect(function(obj)
    addtovc(obj)
    addToPlayerCache(obj)
    addToObjectCache(obj)
    addToBackpackCache(obj)
    addToCratesCache(obj)
end)

workspace.ChildRemoved:Connect(function(obj)
    removefromvc(obj)
    removeFromPlayerCache(obj)
    removeFromObjectCache(obj)
    removeFromBackpackCache(obj)
    removeFromCratesCache(obj)
    if espObjects[obj] then
        for _, drawing in pairs(espObjects[obj]) do
            drawing.Visible = false
            drawing:Remove()
        end
        espObjects[obj] = nil
    end
    if chamsObjects[obj] then
        chamsObjects[obj].Enabled = false
        chamsObjects[obj]:Destroy()
        chamsObjects[obj] = nil
    end
end)

hitbox_section:toggle({name = "hitbox expander",def = false,callback = function(value)
    if hbc then hbc:Disconnect() hbc = nil end
    if value then
        hbc = RunService.Heartbeat:Connect(function(delta)
            for i, v in pairs(validcharacters) do
                local primpart = v and v:FindFirstChild('Head')
                if primpart then
                    local sleeper = isSleeper(v)
                    local bot = isBot(v)
                    
                    local shouldSkip = (hitboxSleeperCheck and sleeper) or (hitboxBotCheck and bot)
                    
                    if not shouldSkip then
                        primpart.Size = hbsize
                        primpart.Transparency = hitboxheadtransparency / 10
                        primpart.CanCollide = cancollide
                    else
                        primpart.Size = original_size
                        primpart.Transparency = 0
                        primpart.CanCollide = true
                    end
                end
            end
        end)
    else
        for i, v in pairs(validcharacters) do
            local primpart = v and v:FindFirstChild('Head')
            if primpart then
                primpart.Size = original_size
                primpart.Transparency = 0
                primpart.CanCollide = true
            end
        end
    end
end})

hitbox_section:toggle({name = "can collide",def = false,callback = function(v)
    cancollide = v
end})

hitbox_section:toggle({name = "sleeper check",def = false,callback = function(value)
    hitboxSleeperCheck = value
end})

hitbox_section:toggle({name = "bot check",def = false,callback = function(value)
    hitboxBotCheck = value
end})

hitbox_section:slider({name = "transparency",def = 5, max = 10,min = 1,rounding = true,ticking = false,measuring = "",callback = function(value)
    hitboxheadtransparency = value
end})

hitbox_section:slider({name = "size x",def = 3, max = 6,min = 1,rounding = true,ticking = false,measuring = "",callback = function(value)
    hitboxheadsizex = value
    hbsize = Vector3.new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
end})

hitbox_section:slider({name = "size y",def = 3, max = 6,min = 1,rounding = true,ticking = false,measuring = "",callback = function(value)
    hitboxheadsizey = value
    hbsize = Vector3.new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
end})

esp_section:toggle({name = "player esp",def = false,callback = function(value)
    espEnabled = value
    if not value then
        for player, esp in pairs(espObjects) do
            esp.box.Visible = false
            esp.fill.Visible = false
            esp.name.Visible = false
            esp.dist.Visible = false
        end
        for player, chams in pairs(chamsObjects) do
            chams.Enabled = false
        end
    end
end})

esp_section:toggle({name = "box esp",def = false,callback = function(value)
    boxEsp = value
end})

esp_section:toggle({name = "filled esp",def = false,callback = function(value)
    filledEsp = value
end})

esp_section:toggle({name = "chams esp",def = false,callback = function(value)
    chamsEsp = value
    if not value then
        for player, chams in pairs(chamsObjects) do
            chams.Enabled = false
        end
    end
end})

esp_section:toggle({name = "info esp",def = false,callback = function(value)
    infoEsp = value
end})

esp_section:toggle({name = "check sleeper",def = false,callback = function(value)
    checkSleeper = value
end})

esp_section:toggle({name = "check boot",def = false,callback = function(value)
    checkBoot = value
end})

esp_section:colorpicker({name = "esp color",cpname = nil,def = Color3.fromRGB(255,255,255),callback = function(value)
    espColor = value
    for player, esp in pairs(espObjects) do
        esp.box.Color = value
        esp.fill.Color = value
        esp.name.Color = value
        esp.dist.Color = value
    end
end})

esp_section:colorpicker({name = "chams color",cpname = nil,def = Color3.fromRGB(255,0,0),callback = function(value)
    chamsColor = value
    for player, chams in pairs(chamsObjects) do
        chams.FillColor = value
    end
end})

esp_section:slider({name = "max distance",def = 1000, max = 1000,min = 100,rounding = true,ticking = false,measuring = "studs",callback = function(value)
    maxDistance = value
end})

object_esp_section:toggle({name = "object esp",def = false,callback = function(value)
    objectEspEnabled = value
    if not value then
        for _, drawing in pairs(objectEspObjects) do
            drawing.Visible = false
        end
    end
end})

object_esp_section:toggle({name = "stone esp",def = false,callback = function(value)
    stoneEsp = value
end})

object_esp_section:toggle({name = "ore esp",def = false,callback = function(value)
    oreEsp = value
end})

object_esp_section:toggle({name = "nitrate esp",def = false,callback = function(value)
    nitrateEsp = value
end})

object_esp_section:slider({name = "max distance",def = 500, max = 1000,min = 50,rounding = true,ticking = false,measuring = "studs",callback = function(value)
    objectMaxDistance = value
end})

backpack_crates_section:toggle({name = "backpack esp",def = false,callback = function(value)
    backpackEspEnabled = value
    if not value then
        for _, drawing in pairs(backpackEspObjects) do
            drawing.Visible = false
        end
    end
end})

backpack_crates_section:colorpicker({name = "backpack color",cpname = nil,def = Color3.fromRGB(0,255,255),callback = function(value)
    backpackEspColor = value
end})

backpack_crates_section:toggle({name = "crates esp",def = false,callback = function(value)
    cratesEspEnabled = value
    if not value then
        for _, drawing in pairs(cratesEspObjects) do
            drawing.Visible = false
        end
    end
end})

backpack_crates_section:toggle({name = "totem",def = false,callback = function(value)
    crateTotemEsp = value
end})

backpack_crates_section:colorpicker({name = "totem color",cpname = nil,def = Color3.fromRGB(0,0,255),callback = function(value)
    totemColor = value
end})

backpack_crates_section:toggle({name = "safe",def = false,callback = function(value)
    crateSafeEsp = value
end})

backpack_crates_section:colorpicker({name = "safe color",cpname = nil,def = Color3.fromRGB(0,255,255),callback = function(value)
    safeColor = value
end})

backpack_crates_section:toggle({name = "carton",def = false,callback = function(value)
    crateCartonEsp = value
end})

backpack_crates_section:colorpicker({name = "carton color",cpname = nil,def = Color3.fromRGB(128,0,128),callback = function(value)
    cartonColor = value
end})

backpack_crates_section:toggle({name = "cola machine",def = false,callback = function(value)
    crateColaMachineEsp = value
end})

backpack_crates_section:colorpicker({name = "cola machine color",cpname = nil,def = Color3.fromRGB(128,128,0),callback = function(value)
    colaMachineColor = value
end})

backpack_crates_section:slider({name = "max distance",def = 500, max = 1000,min = 50,rounding = true,ticking = false,measuring = "studs",callback = function(value)
    objectMaxDistance = value
end})

RunService.RenderStepped:Connect(function()
    if espEnabled then
        local cameraPos = Camera.CFrame.Position
        for _, player in ipairs(playerCache) do
            local root = player:FindFirstChild("LowerTorso") or player:FindFirstChild("HumanoidRootPart")
            if root then
                local sleeper = isSleeper(player)
                local bot = isBot(player)
                local distance = (cameraPos - root.Position).Magnitude
                
                if distance <= maxDistance and 
                   not (checkSleeper and sleeper) and 
                   not (checkBoot and bot) then
                    
                    if chamsEsp then
                        if not chamsObjects[player] or chamsObjects[player].Parent ~= player then
                            if chamsObjects[player] then 
                                chamsObjects[player]:Destroy() 
                            end
                            local highlight = Instance.new("Highlight")
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 1
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = player
                            chamsObjects[player] = highlight
                        end
                        chamsObjects[player].Enabled = true
                        chamsObjects[player].FillColor = chamsColor
                    elseif chamsObjects[player] then 
                        chamsObjects[player].Enabled = false 
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        if not espObjects[player] then
                            espObjects[player] = {
                                box = Drawing.new("Square"),
                                fill = Drawing.new("Square"),
                                name = Drawing.new("Text"),
                                dist = Drawing.new("Text")
                            }
                            espObjects[player].box.Thickness = 1
                            espObjects[player].box.Filled = false
                            espObjects[player].box.ZIndex = 2
                            
                            espObjects[player].fill.Thickness = 0
                            espObjects[player].fill.Filled = true
                            espObjects[player].fill.Transparency = 0.3
                            espObjects[player].fill.ZIndex = 1
                            
                            espObjects[player].name.Size = 10
                            espObjects[player].name.Center = true
                            espObjects[player].name.Font = 2
                            espObjects[player].name.Outline = false
                            espObjects[player].name.ZIndex = 3
                            
                            espObjects[player].dist.Size = 10
                            espObjects[player].dist.Center = true
                            espObjects[player].dist.Font = 2
                            espObjects[player].dist.Outline = false
                            espObjects[player].dist.ZIndex = 3
                        end
                        
                        local esp = espObjects[player]
                        local boxSize = 5000 / screenPos.Z
                        local boxPos = Vector2.new(screenPos.X - boxSize/2, screenPos.Y - boxSize/2)
                        
                        esp.box.Visible = boxEsp
                        esp.box.Size = Vector2.new(boxSize, boxSize)
                        esp.box.Position = boxPos
                        esp.box.Color = espColor
                        
                        esp.fill.Visible = boxEsp and filledEsp
                        esp.fill.Size = Vector2.new(boxSize, boxSize)
                        esp.fill.Position = boxPos
                        esp.fill.Color = espColor
                        
                        esp.name.Visible = infoEsp
                        esp.name.Text = sleeper and "SLEEPER" or (bot and "BOT" or "PLAYER")
                        esp.name.Color = espColor
                        esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize/2 - 15)
                        
                        esp.dist.Visible = infoEsp
                        esp.dist.Text = string.format("[%dm]", math.floor(distance))
                        esp.dist.Color = espColor
                        esp.dist.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize/2 + 0)
                    else
                        if espObjects[player] then
                            espObjects[player].box.Visible = false
                            espObjects[player].fill.Visible = false
                            espObjects[player].name.Visible = false
                            espObjects[player].dist.Visible = false
                        end
                        if chamsObjects[player] then 
                            chamsObjects[player].Enabled = false 
                        end
                    end
                else
                    if espObjects[player] then
                        espObjects[player].box.Visible = false
                        espObjects[player].fill.Visible = false
                        espObjects[player].name.Visible = false
                        espObjects[player].dist.Visible = false
                    end
                    if chamsObjects[player] then 
                        chamsObjects[player].Enabled = false 
                    end
                end
            end
        end
    end
    
    if objectEspEnabled then
        local cameraPos = Camera.CFrame.Position
        for _, objectData in ipairs(objectCache) do
            local model = objectData.model
            local objType = objectData.type
            local part = objectData.part
            
            if part then
                local shouldShow = false
                if objType == "Stone" and stoneEsp then shouldShow = true end
                if objType == "Iron" and oreEsp then shouldShow = true end
                if objType == "Nitrate" and nitrateEsp then shouldShow = true end
                
                if shouldShow then
                    local distance = (cameraPos - part.Position).Magnitude
                    
                    if distance <= objectMaxDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            if not objectEspObjects[model] then
                                objectEspObjects[model] = Drawing.new("Text")
                                objectEspObjects[model].Size = 12
                                objectEspObjects[model].Center = true
                                objectEspObjects[model].Font = 2
                                objectEspObjects[model].Outline = false
                                objectEspObjects[model].ZIndex = 3
                            end
                            
                            local textColor
                            if objType == "Stone" then
                                textColor = stoneColor
                            elseif objType == "Iron" then
                                textColor = oreColor
                            else
                                textColor = nitrateColor
                            end
                            
                            objectEspObjects[model].Visible = true
                            objectEspObjects[model].Color = textColor
                            objectEspObjects[model].Text = string.format("%s [%dm]", objType, math.floor(distance))
                            objectEspObjects[model].Position = Vector2.new(screenPos.X, screenPos.Y)
                        else
                            if objectEspObjects[model] then
                                objectEspObjects[model].Visible = false
                            end
                        end
                    else
                        if objectEspObjects[model] then
                            objectEspObjects[model].Visible = false
                        end
                    end
                else
                    if objectEspObjects[model] then
                        objectEspObjects[model].Visible = false
                    end
                end
            end
        end
    else
        for _, drawing in pairs(objectEspObjects) do
            drawing.Visible = false
        end
    end
    
    if backpackEspEnabled then
        local cameraPos = Camera.CFrame.Position
        for _, backpackData in ipairs(backpackCache) do
            local model = backpackData.model
            local part = backpackData.part
            
            if part then
                local distance = (cameraPos - part.Position).Magnitude
                
                if distance <= objectMaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if not backpackEspObjects[model] then
                            backpackEspObjects[model] = Drawing.new("Text")
                            backpackEspObjects[model].Size = 12
                            backpackEspObjects[model].Center = true
                            backpackEspObjects[model].Font = 2
                            backpackEspObjects[model].Outline = false
                            backpackEspObjects[model].ZIndex = 3
                        end
                        
                        backpackEspObjects[model].Visible = true
                        backpackEspObjects[model].Color = backpackEspColor
                        backpackEspObjects[model].Text = string.format("BACKPACK [%dm]", math.floor(distance))
                        backpackEspObjects[model].Position = Vector2.new(screenPos.X, screenPos.Y)
                    else
                        if backpackEspObjects[model] then
                            backpackEspObjects[model].Visible = false
                        end
                    end
                else
                    if backpackEspObjects[model] then
                        backpackEspObjects[model].Visible = false
                    end
                end
            end
        end
    else
        for _, drawing in pairs(backpackEspObjects) do
            drawing.Visible = false
        end
    end
    
    if cratesEspEnabled then
        local cameraPos = Camera.CFrame.Position
        for _, crateData in ipairs(cratesCache) do
            local model = crateData.model
            local crateType = crateData.type
            local part = crateData.part
            
            if part then
                local shouldShow = false
                local textColor
                
                if crateType == "Totem" and crateTotemEsp then
                    shouldShow = true
                    textColor = totemColor
                elseif crateType == "Safe" and crateSafeEsp then
                    shouldShow = true
                    textColor = safeColor
                elseif crateType == "Carton" and crateCartonEsp then
                    shouldShow = true
                    textColor = cartonColor
                elseif crateType == "Cola Machine" and crateColaMachineEsp then
                    shouldShow = true
                    textColor = colaMachineColor
                end
                
                if shouldShow then
                    local distance = (cameraPos - part.Position).Magnitude
                    
                    if distance <= objectMaxDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            if not cratesEspObjects[model] then
                                cratesEspObjects[model] = Drawing.new("Text")
                                cratesEspObjects[model].Size = 12
                                cratesEspObjects[model].Center = true
                                cratesEspObjects[model].Font = 2
                                cratesEspObjects[model].Outline = false
                                cratesEspObjects[model].ZIndex = 3
                            end
                            
                            cratesEspObjects[model].Visible = true
                            cratesEspObjects[model].Color = textColor
                            cratesEspObjects[model].Text = string.format("%s [%dm]", crateType, math.floor(distance))
                            cratesEspObjects[model].Position = Vector2.new(screenPos.X, screenPos.Y)
                        else
                            if cratesEspObjects[model] then
                                cratesEspObjects[model].Visible = false
                            end
                        end
                    else
                        if cratesEspObjects[model] then
                            cratesEspObjects[model].Visible = false
                        end
                    end
                else
                    if cratesEspObjects[model] then
                        cratesEspObjects[model].Visible = false
                    end
                end
            end
        end
    else
        for _, drawing in pairs(cratesEspObjects) do
            drawing.Visible = false
        end
    end
end)
