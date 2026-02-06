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
local window = library:new({textsize = 13.5,font = Enum.Font.RobotoMono,name = "YES",color = Color3.fromRGB(140, 0, 255)})

local combat_tab = window:page({name = "COMBAT"})
local visuals_tab = window:page({name = "VISUALS"})

local hitbox_section = combat_tab:section({name = "HITBOX",side = "left",size = 250})
local esp_section = visuals_tab:section({name = "PLAYER ESP",side = "left",size = 250})

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

for i, v in next, workspace:GetChildren() do 
    addtovc(v) 
    addToPlayerCache(v) 
end

workspace.ChildAdded:Connect(function(obj)
    addtovc(obj)
    addToPlayerCache(obj)
end)

workspace.ChildRemoved:Connect(function(obj)
    removefromvc(obj)
    removeFromPlayerCache(obj)
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
end)
