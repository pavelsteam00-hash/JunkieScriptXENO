local type_custom = typeof
if not LPH_OBFUSCATED then
    LPH_JIT = function(...)
        return ...;
    end;
    LPH_JIT_MAX = function(...)
        return ...;
    end;
    LPH_NO_VIRTUALIZE = function(...)
        return ...;
    end;
    LPH_NO_UPVALUES = function(f)
        return (function(...)
            return f(...);
        end);
    end;
    LPH_ENCSTR = function(...)
        return ...;
    end;
    LPH_ENCNUM = function(...)
        return ...;
    end;
    LPH_ENCFUNC = function(func, key1, key2)
        if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
        return func
    end
    LPH_CRASH = function()
        return print(debug.traceback());
    end;
    SWG_DiscordUser = "swim"
    SWG_DiscordID = 1337
    SWG_Private = true
    SWG_Dev = false
    SWG_Version = "free"
    SWG_Title = 'free swimhub.xyz %s - %s | discord.gg/priv9'
    SWG_ShortName = 'free'
    SWG_FullName = 'ts'
    SWG_FFA = false
end;

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Splix"))()

local window = library:new({
    textsize = 13.5,
    font = Enum.Font.RobotoMono,
    name = "SILVER PRIVATE - REWORK",
    color = Color3.fromRGB(138, 43, 226)
})

local combatTab = window:page({name = "combat"})
local visualsTab = window:page({name = "visuals"})

local hitboxSection = combatTab:section({
    name = "hitbox expander",
    side = "left", 
    size = 250
})

local espSection = visualsTab:section({
    name = "player esp",
    side = "left", 
    size = 250
})

local objectSection = visualsTab:section({
    name = "object esp", 
    side = "right", 
    size = 250
})

local lightingSection = visualsTab:section({
    name = "lighting",
    side = "right", 
    size = 250
})

local workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = cloneref(game:GetService("UserInputService"))

local validcharacters = {}
local hbc, original_size, hbsize = nil, Vector3.new(0.5, 1, 0.5), Vector3.new(5, 5, 5)
local hitboxheadtransparency, cancollide = 0.5, false
local hitboxheadsizex, hitboxheadsizey = 5, 5
local hitboxcolor = Color3.new(1, 0, 0)
local hitboxSleeperCheck = false
local hitboxBotCheck = false

local _Vector3new = Vector3.new
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _IsA = game.IsA

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

local function addtovc(obj)
    if not obj then return end
    if not obj:FindFirstChild("Head") and not obj:FindFirstChild("LowerTorso") then return end
    validcharacters[obj] = obj
end

local function removefromvc(obj)
    if not validcharacters[obj] then return end
    validcharacters[obj] = nil
end

for i, v in next, workspace:GetChildren() do 
    addtovc(v) 
end

workspace.ChildAdded:Connect(LPH_NO_VIRTUALIZE(function(obj)
    addtovc(obj)
end))

workspace.ChildRemoved:Connect(LPH_NO_VIRTUALIZE(function(obj)
    removefromvc(obj)
end))

local hitboxToggle = hitboxSection:toggle({
    name = "enabled", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        if value then
            hbc = LPH_NO_VIRTUALIZE(function()
                return RunService.Heartbeat:Connect(LPH_JIT_MAX(function(delta)
                    local trans = hitboxheadtransparency
                    for i, v in pairs(validcharacters) do
                        local primpart = v and _FindFirstChild(v, 'Head')
                        if primpart then
                            local sleeper = isSleeper(v)
                            local bot = isBot(v)
                            
                            local shouldSkip = (hitboxSleeperCheck and sleeper) or (hitboxBotCheck and bot)
                            
                            if not shouldSkip then
                                primpart.Size = hbsize
                                primpart.Transparency = trans
                                primpart.CanCollide = cancollide
                                primpart.Color = hitboxcolor
                            else
                                primpart.Size = original_size
                                primpart.Transparency = 0
                                primpart.CanCollide = true
                                primpart.Color = Color3.new(1, 1, 1)
                            end
                        end
                    end
                end))
            end)()
        else
            if hbc then 
                hbc:Disconnect() 
                hbc = nil
            end
            
            for i, v in pairs(validcharacters) do
                local primpart = v and _FindFirstChild(v, 'Head')
                if primpart then
                    primpart.Size = original_size
                    primpart.Transparency = 0
                    primpart.CanCollide = true
                    primpart.Color = Color3.new(1, 1, 1)
                end
            end
        end
    end)
})

local hitboxBindKey = nil
local hitboxBindElement = hitboxSection:keybind({
    name = "hitbox bind",
    def = nil,
    callback = LPH_NO_VIRTUALIZE(function(key)
        hitboxBindKey = key
        if key then
            hitboxToggle:set(not hitboxToggle:get())
        end
    end)
})

hitboxSection:colorpicker({
    name = "hitbox color",
    cpname = nil,
    def = Color3.fromRGB(255, 0, 0),
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxcolor = value
    end)
})

hitboxSection:toggle({
    name = "can collide", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        cancollide = value
    end)
})

hitboxSection:toggle({
    name = "sleeper check", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxSleeperCheck = value
    end)
})

hitboxSection:toggle({
    name = "bot check", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxBotCheck = value
    end)
})

hitboxSection:slider({
    name = "transparency", 
    def = 5, 
    max = 10, 
    min = 1, 
    rounding = 1, 
    ticking = false, 
    measuring = "", 
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxheadtransparency = value / 10
    end)
})

hitboxSection:slider({
    name = "size x", 
    def = 5, 
    max = 5, 
    min = 1, 
    rounding = 1, 
    ticking = false, 
    measuring = "", 
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxheadsizex = value
        hbsize = _Vector3new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
    end)
})

hitboxSection:slider({
    name = "size y", 
    def = 5, 
    max = 5, 
    min = 1, 
    rounding = 1, 
    ticking = false, 
    measuring = "", 
    callback = LPH_NO_VIRTUALIZE(function(value)
        hitboxheadsizey = value
        hbsize = _Vector3new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
    end)
})

local ESP_DATA = {
    playerEnabled = false,
    boxEnabled = false,
    boxFilled = false,
    infoEnabled = false,
    chamsEnabled = false,
    hideSleepers = false,
    hideBots = false,
    maxDistance = 1000,
    espColor = Color3.fromRGB(255, 255, 255),
    
    stoneEnabled = false,
    ironEnabled = false,
    nitrateEnabled = false,
    oreChams = false,
    
    fullbright = false,
    fullbrightIntensity = 0,
    fullbrightColor = Color3.fromRGB(255, 255, 255)
}

local originalLighting = {
    Ambient = game:GetService("Lighting").Ambient,
    OutdoorAmbient = game:GetService("Lighting").OutdoorAmbient,
    Brightness = game:GetService("Lighting").Brightness,
    ClockTime = game:GetService("Lighting").ClockTime
}

local function updateFullbright()
    if ESP_DATA.fullbright then
        local intensity = ESP_DATA.fullbrightIntensity / 50
        local baseCol = ESP_DATA.fullbrightColor
        local r = math.clamp(baseCol.R * 255 + (intensity * 155), 0, 255)
        local g = math.clamp(baseCol.G * 255 + (intensity * 155), 0, 255)
        local b = math.clamp(baseCol.B * 255 + (intensity * 155), 0, 255)
        local brightness = 1 + (intensity * 4)
        
        game:GetService("Lighting").Ambient = Color3.fromRGB(r, g, b)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(r, g, b)
        game:GetService("Lighting").Brightness = brightness
        game:GetService("Lighting").ClockTime = 14
    end
end

local playerEspToggle = espSection:toggle({
    name = "player esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.playerEnabled = value
    end)
})

local espBindKey = nil
local espBindElement = espSection:keybind({
    name = "esp bind",
    def = nil,
    callback = LPH_NO_VIRTUALIZE(function(key)
        espBindKey = key
        if key then
            playerEspToggle:set(not playerEspToggle:get())
        end
    end)
})

espSection:colorpicker({
    name = "esp color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.espColor = value
    end)
})

espSection:toggle({
    name = "box esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.boxEnabled = value
    end)
})

espSection:toggle({
    name = "box filled", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.boxFilled = value
    end)
})

espSection:toggle({
    name = "info esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.infoEnabled = value
    end)
})

espSection:toggle({
    name = "chams esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.chamsEnabled = value
    end)
})

espSection:toggle({
    name = "hide sleepers", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.hideSleepers = value
    end)
})

espSection:toggle({
    name = "hide bots", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.hideBots = value
    end)
})

objectSection:toggle({
    name = "stone esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.stoneEnabled = value
    end)
})

objectSection:toggle({
    name = "iron esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.ironEnabled = value
    end)
})

objectSection:toggle({
    name = "nitrate esp", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.nitrateEnabled = value
    end)
})

objectSection:toggle({
    name = "ore chams", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.oreChams = value
    end)
})

local fullbrightToggle = lightingSection:toggle({
    name = "fullbright", 
    def = false, 
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.fullbright = value
        if not value then 
            game:GetService("Lighting").Ambient = originalLighting.Ambient
            game:GetService("Lighting").OutdoorAmbient = originalLighting.OutdoorAmbient
            game:GetService("Lighting").Brightness = originalLighting.Brightness
            game:GetService("Lighting").ClockTime = originalLighting.ClockTime
        end 
    end)
})

local fullbrightBindKey = nil
local fullbrightBindElement = lightingSection:keybind({
    name = "fullbright bind",
    def = nil,
    callback = LPH_NO_VIRTUALIZE(function(key)
        fullbrightBindKey = key
        if key then
            fullbrightToggle:set(not fullbrightToggle:get())
        end
    end)
})

lightingSection:colorpicker({
    name = "fullbright color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.fullbrightColor = value
    end)
})

lightingSection:slider({
    name = "brightness intensity",
    def = 0,
    max = 50,
    min = 0,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = LPH_NO_VIRTUALIZE(function(value)
        ESP_DATA.fullbrightIntensity = value
    end)
})

UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
    if not processed then
        if hitboxBindKey and input.KeyCode == hitboxBindKey then
            hitboxToggle:set(not hitboxToggle:get())
        end
        if espBindKey and input.KeyCode == espBindKey then
            playerEspToggle:set(not playerEspToggle:get())
        end
        if fullbrightBindKey and input.KeyCode == fullbrightBindKey then
            fullbrightToggle:set(not fullbrightToggle:get())
        end
    end
end))

local playerCache = {}
local resourceCache = {}
local espObjects = {}
local chamsObjects = {}
local resourceTexts = {}
local resourceChams = {}

local function addToPlayerCache(obj)
    if obj:IsA("Model") then
        local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("LowerTorso")
        if root and obj.Name ~= LocalPlayer.Name then 
            table.insert(playerCache, obj) 
        end
    end
end

local function addToResourceCache(obj)
    if obj:IsA("Model") then
        local mesh = obj:FindFirstChildOfClass("MeshPart")
        if mesh and (mesh.MeshId == "rbxassetid://12939036056" or mesh.MeshId == "rbxassetid://13425026915") then
            local isFound = false
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") then
                    if child.Color == Color3.fromRGB(248, 248, 248) then
                        table.insert(resourceCache, {
                            model = obj, 
                            part = child, 
                            type = "Nitrate", 
                            color = Color3.fromRGB(255, 255, 255)
                        })
                        isFound = true break
                    elseif child.Color == Color3.fromRGB(199, 172, 120) or child.Color == Color3.fromRGB(255, 170, 80) then
                        table.insert(resourceCache, {
                            model = obj, 
                            part = child, 
                            type = "Iron", 
                            color = Color3.fromRGB(255, 170, 80)
                        })
                        isFound = true break
                    end
                end
            end
            if not isFound then 
                table.insert(resourceCache, {
                    model = obj, 
                    part = mesh, 
                    type = "Stone", 
                    color = Color3.fromRGB(200, 200, 200)
                }) 
            end
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

local function removeFromResourceCache(obj)
    for i = #resourceCache, 1, -1 do 
        if resourceCache[i].model == obj or resourceCache[i].part == obj then 
            if resourceTexts[resourceCache[i].part] then
                resourceTexts[resourceCache[i].part].Visible = false
                resourceTexts[resourceCache[i].part]:Remove()
                resourceTexts[resourceCache[i].part] = nil
            end
            if resourceChams[resourceCache[i].part] then
                resourceChams[resourceCache[i].part].Enabled = false
                resourceChams[resourceCache[i].part]:Destroy()
                resourceChams[resourceCache[i].part] = nil
            end
            table.remove(resourceCache, i) 
        end 
    end
end

workspace.ChildAdded:Connect(LPH_NO_VIRTUALIZE(function(obj)
    addToPlayerCache(obj)
    addToResourceCache(obj)
end))

workspace.ChildRemoved:Connect(LPH_NO_VIRTUALIZE(function(obj)
    removeFromPlayerCache(obj)
    removeFromResourceCache(obj)
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
end))

for _, obj in ipairs(workspace:GetChildren()) do
    addToPlayerCache(obj)
    addToResourceCache(obj)
end

RunService.RenderStepped:Connect(LPH_JIT_MAX(LPH_NO_VIRTUALIZE(function()
    updateFullbright()
    
    local cameraPos = Camera.CFrame.Position
    
    if ESP_DATA.playerEnabled then
        for _, player in ipairs(playerCache) do
            local root = player:FindFirstChild("LowerTorso") or player:FindFirstChild("HumanoidRootPart")
            if root then
                local sleeper = isSleeper(player)
                local bot = isBot(player)
                local distance = (cameraPos - root.Position).Magnitude
                
                if distance <= ESP_DATA.maxDistance and 
                   not (ESP_DATA.hideSleepers and sleeper) and 
                   not (ESP_DATA.hideBots and bot) then
                    
                    if ESP_DATA.chamsEnabled then
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
                        chamsObjects[player].FillColor = ESP_DATA.espColor
                    elseif chamsObjects[player] then 
                        chamsObjects[player].Enabled = false 
                    end
                    
                    local screenPos, onScreen = _WorldToViewportPoint(Camera, root.Position)
                    if onScreen then
                        if not espObjects[player] then
                            espObjects[player] = {
                                box = Drawing.new("Square"),
                                fill = Drawing.new("Square"),
                                tag = Drawing.new("Text"),
                                dist = Drawing.new("Text")
                            }
                            espObjects[player].box.Thickness = 1
                            espObjects[player].box.Filled = false
                            espObjects[player].box.ZIndex = 2
                            
                            espObjects[player].fill.Thickness = 0
                            espObjects[player].fill.Filled = true
                            espObjects[player].fill.Transparency = 0.3
                            espObjects[player].fill.ZIndex = 1
                            
                            espObjects[player].tag.Size = 13
                            espObjects[player].tag.Center = true
                            espObjects[player].tag.Font = 2
                            espObjects[player].tag.Outline = false
                            espObjects[player].tag.ZIndex = 3
                            
                            espObjects[player].dist.Size = 13
                            espObjects[player].dist.Center = true
                            espObjects[player].dist.Font = 2
                            espObjects[player].dist.Outline = false
                            espObjects[player].dist.ZIndex = 3
                        end
                        
                        local esp = espObjects[player]
                        local boxSize = 6000 / screenPos.Z
                        local boxPos = Vector2.new(screenPos.X - boxSize/2, screenPos.Y - boxSize/2)
                        
                        esp.box.Visible = ESP_DATA.boxEnabled
                        esp.box.Size = Vector2.new(boxSize, boxSize)
                        esp.box.Position = boxPos
                        esp.box.Color = ESP_DATA.espColor
                        
                        esp.fill.Visible = ESP_DATA.boxEnabled and ESP_DATA.boxFilled
                        esp.fill.Size = Vector2.new(boxSize, boxSize)
                        esp.fill.Position = boxPos
                        esp.fill.Color = ESP_DATA.espColor
                        
                        local tagText = sleeper and "SLEEPER" or (bot and "BOT" or "PLAYER")
                        esp.tag.Visible = ESP_DATA.infoEnabled
                        esp.tag.Text = tagText
                        esp.tag.Color = ESP_DATA.espColor
                        esp.tag.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize/2 + 2)
                        
                        esp.dist.Visible = ESP_DATA.infoEnabled
                        esp.dist.Text = string.format("[%dm]", math.floor(distance))
                        esp.dist.Color = ESP_DATA.espColor
                        esp.dist.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize/2 + 15)
                    else
                        if espObjects[player] then
                            espObjects[player].box.Visible = false
                            espObjects[player].fill.Visible = false
                            espObjects[player].tag.Visible = false
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
                        espObjects[player].tag.Visible = false
                        espObjects[player].dist.Visible = false
                    end
                    if chamsObjects[player] then 
                        chamsObjects[player].Enabled = false 
                    end
                end
            end
        end
    else
        for player, esp in pairs(espObjects) do
            esp.box.Visible = false
            esp.fill.Visible = false
            esp.tag.Visible = false
            esp.dist.Visible = false
        end
        for player, chams in pairs(chamsObjects) do
            chams.Enabled = false
        end
    end
    
    for i = #resourceCache, 1, -1 do
        local resource = resourceCache[i]
        if not resource.part or not resource.part.Parent or not resource.model or not resource.model.Parent then
            table.remove(resourceCache, i)
        else
            local enabled = (resource.type == "Stone" and ESP_DATA.stoneEnabled) or 
                           (resource.type == "Iron" and ESP_DATA.ironEnabled) or 
                           (resource.type == "Nitrate" and ESP_DATA.nitrateEnabled)
            
            if enabled then
                local distance = (cameraPos - resource.part.Position).Magnitude
                if distance <= ESP_DATA.maxDistance then
                    local screenPos, onScreen = _WorldToViewportPoint(Camera, resource.part.Position)
                    if onScreen then
                        if not resourceTexts[resource.part] then
                            resourceTexts[resource.part] = Drawing.new("Text")
                            resourceTexts[resource.part].Size = 13
                            resourceTexts[resource.part].Center = true
                            resourceTexts[resource.part].Font = 2
                            resourceTexts[resource.part].Color = resource.color
                            resourceTexts[resource.part].Outline = false
                            resourceTexts[resource.part].ZIndex = 1
                        end
                        resourceTexts[resource.part].Visible = true
                        resourceTexts[resource.part].Text = string.format("%s [%dm]", resource.type, math.floor(distance))
                        resourceTexts[resource.part].Position = Vector2.new(screenPos.X, screenPos.Y)
                        
                        if ESP_DATA.oreChams then
                            if not resourceChams[resource.part] or resourceChams[resource.part].Parent ~= resource.model then
                                if resourceChams[resource.part] then 
                                    resourceChams[resource.part]:Destroy() 
                                end
                                local highlight = Instance.new("Highlight")
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 1
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent = resource.model
                                resourceChams[resource.part] = highlight
                            end
                            resourceChams[resource.part].Enabled = true
                            resourceChams[resource.part].FillColor = resource.color
                        elseif resourceChams[resource.part] then 
                            resourceChams[resource.part].Enabled = false 
                        end
                    else
                        if resourceTexts[resource.part] then 
                            resourceTexts[resource.part].Visible = false 
                        end
                        if resourceChams[resource.part] then 
                            resourceChams[resource.part].Enabled = false 
                        end
                    end
                else
                    if resourceTexts[resource.part] then 
                        resourceTexts[resource.part].Visible = false 
                    end
                    if resourceChams[resource.part] then 
                        resourceChams[resource.part].Enabled = false 
                    end
                end
            else
                if resourceTexts[resource.part] then 
                    resourceTexts[resource.part].Visible = false 
                end
                if resourceChams[resource.part] then 
                    resourceChams[resource.part].Enabled = false 
                end
            end
        end
    end
end)))
