local LPH_JIT = function(f) return f end
local LPH_NO_VIRTUALIZE = function(f) return function(...) return f(...) end end
local LPH_NO_UPVALUES = function(f) return function(...) return f(...) end end

if not _G["__LPH_OBFUSCATED__"] then
    _G["__LPH_OBFUSCATED__"] = true
    _G["LPH_JIT"] = LPH_JIT
    _G["LPH_NO_VIRTUALIZE"] = LPH_NO_VIRTUALIZE
    _G["LPH_NO_UPVALUES"] = LPH_NO_UPVALUES
end

local function _GET_SERVICE(name)
    local s, r = pcall(function()
        return cloneref(game:GetService(name))
    end)
    return s and r or nil
end

local _wait, _spawn = task.wait, task.spawn
local _floor, _clamp = math.floor, math.clamp
local _rand = math.random
local _ins, _rem = table.insert, table.remove
local _v2, _v3 = Vector2.new, Vector3.new
local _c3 = Color3.fromRGB
local _c3hsv = Color3.fromHSV
local _fmt = string.format

local _RS = _GET_SERVICE("RunService")
local _PL = _GET_SERVICE("Players")
local _WS = _GET_SERVICE("Workspace")
local _UI = _GET_SERVICE("UserInputService")
local _LT = _GET_SERVICE("Lighting")
local _CA = _WS.CurrentCamera
local _LP = _PL.LocalPlayer

local _mmr = mousemoverel
local _rcst = _WS.Raycast
local _drw = Drawing.new

local _OLT = {
    A = _LT.Ambient,
    OA = _LT.OutdoorAmbient,
    B = _LT.Brightness,
    CT = _LT.ClockTime
}

local _S1 = LPH_NO_VIRTUALIZE(function()
    return {
        _A = false,
        _WC = false,
        _TA = "Head",
        _FS = 80,
        _SM = 5,
        _SC = false,
        _IB = false,
        _SF = false,
        _FC = _c3(255, 255, 255),
        _FSC = false,
        _FSC1 = _c3(255, 0, 0),
        _FSC2 = _c3(0, 255, 0),
        _HA = false,
        _HS = 2,
        _HT = 0.5,
        _HWC = false,
        _HCC = true,
        _HC = _c3(255, 255, 255),
        _MD = 1000,
        _B = nil,
        _Active = false,
        _ShowFOV = false,
        _FOVSize = 80,
        _Smoothness = 5,
        _WallCheck = false,
        _SleeperCheck = false,
        _IgnoreBots = false,
        _HitboxActive = false,
        _HitboxSize = 2,
        _HitboxColor = _c3(255, 255, 255),
        _HitboxTransparency = 0.5,
        _HitboxCanCollide = true,
        _HitboxWallCheck = false
    }
end)()

local _S2 = LPH_NO_VIRTUALIZE(function()
    return {
        _PE = false,
        _BE = false,
        _BF = false,
        _IE = false,
        _CE = false,
        _SC = false,
        _HB = false,
        _SE = false,
        _NE = false,
        _OC = false,
        _MD = 1000,
        _C = _c3(255, 255, 255),
        _B = nil,
        _HB_B = nil,
        _FBB = nil,
        _FB = false,
        _FBI = 0,
        _FBC = _c3(255, 255, 255),
        _PlayerESP = false,
        _BoxESP = false,
        _BoxFilled = false,
        _InfoESP = false,
        _ChamsEnabled = false,
        _ESPColor = _c3(255, 255, 255),
        _StoneESP = false,
        _IronESP = false,
        _NitrateESP = false,
        _OreChams = false,
        _SleeperCheck = false,
        _HideBots = false,
        _FullBright = false
    }
end)()

local _S3 = LPH_NO_VIRTUALIZE(function()
    return {
        _V = false,
        _M = false,
        _DS = nil,
        _L = false,
        _IB = nil,
        _AC = _c3(180, 120, 255),
        _BC = _c3(10, 10, 12),
        _SC = _c3(15, 15, 18),
        _SHC = _c3(15, 15, 18),
        _BrC = _c3(30, 30, 35),
        _TC = _c3(255, 255, 255),
        _MC = {left = {}, right = {}, entity = {}},
        _UIC = {},
        _Visible = false,
        _Loaded = false,
        _Moving = false,
        _DraggingSlider = false,
        _IsBinding = nil,
        _MenuComponents = {left = {}, right = {}, entity = {}},
        _UIComponents = {}
    }
end)()

local _ESTO, _RSTO, _RCHC, _P_CACH, _R_CACH, _CHMC, _NOTIF, _OSZ, _OCOL, _OCC = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local _LCKT = nil
local _mP = _v2(200, 200)
local _mD = _v2(760, 580)
local _dSO = _v2(0, 0)

local _RCP = RaycastParams.new()
_RCP.FilterType = Enum.RaycastFilterType.Exclude

local function _CD(t, p)
    local o = _drw(t)
    for k, v in pairs(p) do 
        pcall(function() o[k] = v end) 
    end
    _ins(_S3._UIC, o)
    return o
end

local function _UFB()
    if _S2._FB then
        local iS = _S2._FBI / 50
        local baseCol = _S2._FBC
        local r = _clamp(baseCol.R * 255 + (iS * 155), 0, 255)
        local g = _clamp(baseCol.G * 255 + (iS * 155), 0, 255)
        local b = _clamp(baseCol.B * 255 + (iS * 155), 0, 255)
        local bV = 1 + (iS * 4)
        
        _LT.Ambient = _c3(r, g, b)
        _LT.OutdoorAmbient = _c3(r, g, b)
        _LT.Brightness = bV
        _LT.ClockTime = 14
    end
end

local _FOV_CIRCLE = _CD("Circle", {Thickness = 1, NumSides = 64, Radius = 80, Visible = false, ZIndex = 999})

local function _f1(v53) 
    local l_Torso_0 = v53:FindFirstChild("Torso");
    if l_Torso_0 and l_Torso_0:FindFirstChild("LeftBooster") then
        return false;
    else
        return true;
    end;
end;

local function _f2(model)
    local lt = model:FindFirstChild("LowerTorso")
    if lt then
        local rj = lt:FindFirstChild("RootRig")
        if rj and typeof(rj.CurrentAngle) == "number" and rj.CurrentAngle ~= 0 then return true end
    end
    return false
end

local function _f3(part)
    if not part then return false end
    _RCP.FilterDescendantsInstances = {_LP.Character, part.Parent, _CA}
    local origin = _CA.CFrame.Position
    local direction = (part.Position - origin)
    local ray = _WS:Raycast(origin, direction, _RCP)
    return ray == nil
end

local function _GAP(model)
    if not model then return nil end
    if _S1._TA == "Head" then 
        return model:FindFirstChild("Head")
    else 
        local b = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Chest") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
        return b
    end
end

local function _REESP(obj)
    if _ESTO[obj] then
        pcall(function() 
            _ESTO[obj].Box.Visible = false
            _ESTO[obj].Fill.Visible = false
            _ESTO[obj].Tag.Visible = false
            _ESTO[obj].Dist.Visible = false
            _ESTO[obj].Box:Remove() 
            _ESTO[obj].Fill:Remove() 
            _ESTO[obj].Tag:Remove()
            _ESTO[obj].Dist:Remove() 
        end)
        _ESTO[obj] = nil
    end
end

local function _RERESP(part)
    if _RSTO[part] then
        pcall(function() 
            _RSTO[part].Visible = false
            _RSTO[part]:Remove() 
        end)
        _RSTO[part] = nil
    end
    if _RCHC[part] then
        pcall(function() 
            _RCHC[part].Enabled = false
            _RCHC[part]:Destroy() 
        end)
        _RCHC[part] = nil
    end
end

local function _U_CACHE()
    local function add(obj)
        pcall(function()
            if obj:IsA("Model") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("LowerTorso")
                if root and obj.Name ~= _LP.Name then _ins(_P_CACH, obj) end
                
                local mesh = obj:FindFirstChildOfClass("MeshPart")
                if mesh and (mesh.MeshId == "rbxassetid://12939036056" or mesh.MeshId == "rbxassetid://13425026915") then
                    local isFound = false
                    local o_children = obj:GetChildren()
                    for j = 1, #o_children do
                        local child = o_children[j]
                        if child:IsA("BasePart") then
                            if child.Color == _c3(248, 248, 248) then
                                _ins(_R_CACH, {model = obj, part = child, type = "Nitrate", color = _c3(255, 255, 255)})
                                isFound = true break
                            elseif child.Color == _c3(199, 172, 120) or child.Color == _c3(255, 170, 80) then
                                _ins(_R_CACH, {model = obj, part = child, type = "Iron", color = _c3(255, 170, 80)})
                                isFound = true break
                            end
                        end
                    end
                    if not isFound then _ins(_R_CACH, {model = obj, part = mesh, type = "Stone", color = _c3(200, 200, 200)}) end
                end
            end
        end)
    end

    _WS.ChildAdded:Connect(add)
    _WS.ChildRemoved:Connect(function(obj)
        for i = #_P_CACH, 1, -1 do if _P_CACH[i] == obj then _rem(_P_CACH, i) end end
        for i = #_R_CACH, 1, -1 do 
            if _R_CACH[i].model == obj or _R_CACH[i].part == obj then 
                _RERESP(_R_CACH[i].part)
                _rem(_R_CACH, i) 
            end 
        end
        if _ESTO[obj] then _REESP(obj) end
    end)
    
    local all = _WS:GetChildren()
    for i = 1, #all do add(all[i]) end
end

_spawn(_U_CACHE)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Splix"))()

local window = library:new({
    textsize = 13.5,
    font = Enum.Font.RobotoMono,
    name = "SILVER PRIVATE",
    color = Color3.fromRGB(180, 120, 255)
})

local combatTab = window:page({name = "COMBAT"})
local visualsTab = window:page({name = "VISUALS"})
local entityTab = window:page({name = "ENTITY"})

local combatMainSection = combatTab:section({name = "Aimbot Settings", side = "left", size = 250})
local combatFovSection = combatTab:section({name = "FOV Settings", side = "left", size = 250})
local combatHitboxSection = combatTab:section({name = "Hitbox", side = "right", size = 250})

local visualsPlayerSection = visualsTab:section({name = "Player ESP", side = "left", size = 250})
local visualsLightingSection = visualsTab:section({name = "Lighting", side = "right", size = 250})

local entityOreSection = entityTab:section({name = "Ore ESP", side = "left", size = 250})

local aimbotToggle, showFovToggle, fovScannerToggle, ignoreSleepersToggle, ignoreBotsToggle, wallCheckToggle
local fovSizeSlider, smoothnessSlider
local hitboxToggle, canCollideToggle, hitboxWallCheckToggle, hitboxSizeSlider, hitboxTransparencySlider
local playerEspToggle, boxEspToggle, boxFilledToggle, infoEspToggle, chamsEspToggle, hideSleepersToggle, hideBotsToggle
local fullbrightToggle, brightnessSlider
local stoneEspToggle, ironEspToggle, nitrateEspToggle, oreChamsToggle

local targetAreaButtonRef

aimbotToggle = combatMainSection:toggle({
    name = "Aimbot Master", 
    def = false,
    callback = function(value) 
        _S1._A = value
    end
})

combatMainSection:keybind({
    name = "Aimbot Keybind",
    def = nil,
    callback = function(key)
        _S1._B = key
    end
})

combatMainSection:colorpicker({
    name = "FOV Color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = function(value)
        _S1._FC = value
    end
})

ignoreSleepersToggle = combatMainSection:toggle({
    name = "Ignore Sleepers", 
    def = false,
    callback = function(value) 
        _S1._SC = value 
    end
})

ignoreBotsToggle = combatMainSection:toggle({
    name = "Ignore Bots", 
    def = false,
    callback = function(value) 
        _S1._IB = value 
    end
})

wallCheckToggle = combatMainSection:toggle({
    name = "Wall Check", 
    def = false,
    callback = function(value) 
        _S1._WC = value 
    end
})

showFovToggle = combatMainSection:toggle({
    name = "Show FOV", 
    def = false,
    callback = function(value) 
        _S1._SF = value 
    end
})

fovScannerToggle = combatMainSection:toggle({
    name = "FOV Scanner", 
    def = false,
    callback = function(value) 
        _S1._FSC = value 
    end
})

targetAreaButtonRef = combatMainSection:button({
    name = "Target Area: Head",
    callback = function()
        if _S1._TA == "Head" then
            _S1._TA = "Body"
            targetAreaButtonRef:rename("Target Area: Torso")
        else
            _S1._TA = "Head"
            targetAreaButtonRef:rename("Target Area: Head")
        end
    end
})

hitboxToggle = combatHitboxSection:toggle({
    name = "Hitbox Expander", 
    def = false,
    callback = function(value) 
        _S1._HA = value 
    end
})

combatHitboxSection:keybind({
    name = "Hitbox Keybind",
    def = nil,
    callback = function(key)
        _S2._HB_B = key
    end
})

combatHitboxSection:colorpicker({
    name = "Hitbox Color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = function(value)
        _S1._HC = value
    end
})

canCollideToggle = combatHitboxSection:toggle({
    name = "CanCollide Hitbox", 
    def = true,
    callback = function(value) 
        _S1._HCC = value 
    end
})

hitboxWallCheckToggle = combatHitboxSection:toggle({
    name = "Hitbox Wallcheck", 
    def = false,
    callback = function(value) 
        _S1._HWC = value 
    end
})

hitboxSizeSlider = combatHitboxSection:slider({
    name = "Hitbox Size",
    def = 2,
    max = 4,
    min = 1,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = function(value)
        _S1._HS = value
    end
})

hitboxTransparencySlider = combatHitboxSection:slider({
    name = "Hitbox Transparency",
    def = 5,
    max = 10,
    min = 0,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = function(value)
        _S1._HT = value/10
    end
})

fovSizeSlider = combatFovSection:slider({
    name = "FOV Size",
    def = 80,
    max = 200,
    min = 20,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = function(value)
        _S1._FS = value
    end
})

smoothnessSlider = combatFovSection:slider({
    name = "Smoothness",
    def = 5,
    max = 20,
    min = 1,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = function(value)
        _S1._SM = value
    end
})

combatFovSection:colorpicker({
    name = "FOV SCANER COLOR 1",
    cpname = nil,
    def = Color3.fromRGB(255, 0, 0),
    callback = function(value)
        _S1._FSC1 = value
    end
})

combatFovSection:colorpicker({
    name = "FOV SCANER COLOR 2",
    cpname = nil,
    def = Color3.fromRGB(0, 255, 0),
    callback = function(value)
        _S1._FSC2 = value
    end
})

playerEspToggle = visualsPlayerSection:toggle({
    name = "Player ESP", 
    def = false,
    callback = function(value) 
        _S2._PE = value 
    end
})

visualsPlayerSection:keybind({
    name = "ESP Keybind",
    def = nil,
    callback = function(key)
        _S2._B = key
    end
})

visualsPlayerSection:colorpicker({
    name = "ESP Color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = function(value)
        _S2._C = value
    end
})

boxEspToggle = visualsPlayerSection:toggle({
    name = "Box ESP", 
    def = false,
    callback = function(value) 
        _S2._BE = value 
    end
})

boxFilledToggle = visualsPlayerSection:toggle({
    name = "Box Filled", 
    def = false,
    callback = function(value) 
        _S2._BF = value 
    end
})

infoEspToggle = visualsPlayerSection:toggle({
    name = "Info ESP", 
    def = false,
    callback = function(value) 
        _S2._IE = value 
    end
})

chamsEspToggle = visualsPlayerSection:toggle({
    name = "Chams ESP", 
    def = false,
    callback = function(value) 
        _S2._CE = value 
    end
})

hideSleepersToggle = visualsPlayerSection:toggle({
    name = "Hide Sleepers", 
    def = false,
    callback = function(value) 
        _S2._SE = value 
    end
})

hideBotsToggle = visualsPlayerSection:toggle({
    name = "Hide Bots", 
    def = false,
    callback = function(value) 
        _S2._NE = value 
    end
})

fullbrightToggle = visualsLightingSection:toggle({
    name = "FullBright", 
    def = false,
    callback = function(value) 
        _S2._FB = value 
        if not value then 
            _LT.Ambient = _OLT.A 
            _LT.OutdoorAmbient = _OLT.OA 
            _LT.Brightness = _OLT.B 
        end 
    end
})

visualsLightingSection:keybind({
    name = "Fullbright Keybind",
    def = nil,
    callback = function(key)
        _S2._FBB = key
    end
})

visualsLightingSection:colorpicker({
    name = "Fullbright Color",
    cpname = nil,
    def = Color3.fromRGB(255, 255, 255),
    callback = function(value)
        _S2._FBC = value
    end
})

brightnessSlider = visualsLightingSection:slider({
    name = "Brightness Intensity",
    def = 0,
    max = 50,
    min = 0,
    rounding = true,
    ticking = false,
    measuring = "",
    callback = function(value)
        _S2._FBI = value
    end
})

stoneEspToggle = entityOreSection:toggle({
    name = "Stone ESP", 
    def = false,
    callback = function(value) 
        _S2._StoneESP = value 
    end
})

ironEspToggle = entityOreSection:toggle({
    name = "Iron ESP", 
    def = false,
    callback = function(value) 
        _S2._IronESP = value 
    end
})

nitrateEspToggle = entityOreSection:toggle({
    name = "Nitrate ESP", 
    def = false,
    callback = function(value) 
        _S2._NitrateESP = value 
    end
})

oreChamsToggle = entityOreSection:toggle({
    name = "Ore Chams", 
    def = false,
    callback = function(value) 
        _S2._OC = value 
    end
})

_S3._V = false
_S3._L = true

local _lastTick = tick()
_RS.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if not _S3._L then return end
    local _now = tick()
    local _dt = _now - _lastTick
    _lastTick = _now

    _UFB()
    
    local mPos = _UI:GetMouseLocation()
    local cPos = _CA.CFrame.Position
    
    _FOV_CIRCLE.Position = mPos
    _FOV_CIRCLE.Radius = _S1._FS
    _FOV_CIRCLE.Visible = _S1._A and _S1._SF

    if _S1._A and _S1._FSC then
        local st = nil
        local mD = math.huge
        for i = 1, #_P_CACH do
            local p = _P_CACH[i]
            local root = p:FindFirstChild("HumanoidRootPart") or p:FindFirstChild("LowerTorso")
            if root and (cPos - root.Position).Magnitude <= 1000 then
                if not (_S1._SC and _f2(p)) and not (_S1._IB and _f1(p)) then
                    local part = _GAP(p)
                    if part then
                        local sPos, onS = _CA:WorldToViewportPoint(part.Position)
                        if onS then
                            local screenPos = _v2(sPos.X, sPos.Y)
                            local mg = (screenPos - mPos).Magnitude
                            if mg < _S1._FS and mg < mD then 
                                mD = mg 
                                st = part 
                            end
                        end
                    end
                end
            end
        end
        
        if st then
            if _f3(st) then
                _FOV_CIRCLE.Color = _S1._FSC2
            else
                _FOV_CIRCLE.Color = _S1._FSC1
            end
        else
            _FOV_CIRCLE.Color = _S1._FSC1
        end
    elseif _S1._A and _S1._SF then
        _FOV_CIRCLE.Color = _S1._FC
    end

    if _S2._PE then
        for i = 1, #_P_CACH do
            local p = _P_CACH[i]
            local root = p:FindFirstChild("LowerTorso") or p:FindFirstChild("HumanoidRootPart")
            if root then
                local sleeper, bot = _f2(p), _f1(p)
                local dist = (cPos - root.Position).Magnitude
                if dist <= 1000 and not ((_S2._SE and sleeper) or (_S2._NE and bot)) then
                    if _S2._CE then
                        if not _CHMC[p] or _CHMC[p].Parent ~= p then
                            if _CHMC[p] then _CHMC[p]:Destroy() end
                            local h = Instance.new("Highlight")
                            h.FillTransparency, h.OutlineTransparency, h.DepthMode, h.Parent = 0.5, 1, Enum.HighlightDepthMode.AlwaysOnTop, p
                            _CHMC[p] = h
                        end
                        _CHMC[p].Enabled, _CHMC[p].FillColor = true, _S2._C
                    elseif _CHMC[p] then _CHMC[p].Enabled = false end
                    
                    local sPos, onS = _CA:WorldToViewportPoint(root.Position)
                    if onS then
                        if not _ESTO[p] then
                            _ESTO[p] = {
                                Box = _CD("Square", {Thickness = 1, Filled = false, ZIndex = 2}),
                                Fill = _CD("Square", {Thickness = 0, Filled = true, Transparency = 0.3, ZIndex = 1}),
                                Tag = _CD("Text", {Size = 13, Center = true, Font = 2, Outline = false, ZIndex = 3}),
                                Dist = _CD("Text", {Size = 13, Center = true, Font = 2, Outline = false, ZIndex = 3})
                            }
                        end
                        local esp = _ESTO[p]
                        local bSize = 6000/sPos.Z
                        local bPos = _v2(sPos.X - bSize/2, sPos.Y - bSize/2)
                        
                        esp.Box.Visible, esp.Box.Size, esp.Box.Position, esp.Box.Color = _S2._BE, _v2(bSize, bSize), bPos, _S2._C
                        esp.Fill.Visible, esp.Fill.Size, esp.Fill.Position, esp.Fill.Color = (_S2._BE and _S2._BF), esp.Box.Size, esp.Box.Position, _S2._C
                        
                        local tagStr = sleeper and "SLEEPER" or (bot and "BOT" or "PLAYER")
                        esp.Tag.Visible = _S2._IE
                        esp.Tag.Text = tagStr
                        esp.Tag.Color = _S2._C
                        esp.Tag.Position = _v2(sPos.X, sPos.Y + bSize/2 + 2)
                        
                        esp.Dist.Visible = _S2._IE
                        esp.Dist.Text = _fmt("[%dm]", _floor(dist))
                        esp.Dist.Color = _S2._C
                        esp.Dist.Position = _v2(sPos.X, sPos.Y + bSize/2 + 15)
                    else 
                        if _ESTO[p] then _REESP(p) end 
                        if _CHMC[p] then _CHMC[p].Enabled = false end
                    end
                else 
                    if _ESTO[p] then _REESP(p) end 
                    if _CHMC[p] then _CHMC[p].Enabled = false end
                end
            end
        end
    else 
        for p, _ in pairs(_ESTO) do _REESP(p) end 
        for p, h in pairs(_CHMC) do h.Enabled = false end 
    end

    for i = #_R_CACH, 1, -1 do
        local res = _R_CACH[i]
        if not res.part or not res.part.Parent or not res.model or not res.model.Parent then
            _RERESP(res.part)
            _rem(_R_CACH, i)
        else
            local enabled = (res.type == "Stone" and _S2._StoneESP) or (res.type == "Iron" and _S2._IronESP) or (res.type == "Nitrate" and _S2._NitrateESP)
            if enabled then
                local dist = (cPos - res.part.Position).Magnitude
                if dist <= 1000 then 
                    local sPos, onS = _CA:WorldToViewportPoint(res.part.Position)
                    if onS then
                        if not _RSTO[res.part] then _RSTO[res.part] = _CD("Text", {Size = 13, Center = true, Font = 2, Color = res.color, Outline = false, ZIndex = 1}) end
                        _RSTO[res.part].Visible, _RSTO[res.part].Text = true, _fmt("%s [%dm]", res.type, _floor(dist))
                        _RSTO[res.part].Position = _v2(sPos.X, sPos.Y)
                        if _S2._OC then
                            if not _RCHC[res.part] or _RCHC[res.part].Parent ~= res.model then
                                if _RCHC[res.part] then _RCHC[res.part]:Destroy() end
                                local h = Instance.new("Highlight")
                                h.FillTransparency, h.OutlineTransparency, h.DepthMode, h.Parent = 0.5, 1, Enum.HighlightDepthMode.AlwaysOnTop, res.model
                                _RCHC[res.part] = h
                            end
                            _RCHC[res.part].Enabled, _RCHC[res.part].FillColor = true, res.color
                        elseif _RCHC[res.part] then _RCHC[res.part].Enabled = false end
                    else 
                        if _RSTO[res.part] then _RSTO[res.part].Visible = false end 
                    end
                else 
                    if _RSTO[res.part] then _RSTO[res.part].Visible = false end 
                    if _RCHC[res.part] then _RCHC[res.part].Enabled = false end
                end
            else 
                if _RSTO[res.part] then _RSTO[res.part].Visible = false end 
                if _RCHC[res.part] then _RCHC[res.part].Enabled = false end
            end
        end
    end

    for i = 1, #_P_CACH do
        local obj = _P_CACH[i]
        local part = _GAP(obj)
        if part then
            local sleeper, bot = _f2(obj), _f1(obj)
            local sPos, onS = _CA:WorldToViewportPoint(part.Position)
            local screenPos = _v2(sPos.X, sPos.Y)
            local inFOV = onS and (screenPos - mPos).Magnitude < _S1._FS
            local canExpand = _S1._A and _S1._HA and inFOV and not (_S1._SC and sleeper) and not (_S1._IB and bot)
            if canExpand and _S1._HWC then canExpand = _f3(part) end
            if canExpand then
                if not _OSZ[part] then 
                    _OSZ[part] = part.Size 
                    _OCOL[part] = {Color = part.Color, Trans = part.Transparency} 
                    _OCC[part] = part.CanCollide 
                end
                part.Size, part.Transparency, part.Color, part.CanCollide = _v3(_S1._HS, _S1._HS, _S1._HS), _S1._HT, _S1._HC, _S1._HCC
            elseif _OSZ[part] then
                part.Size, part.Color, part.Transparency, part.CanCollide = _OSZ[part], _OCOL[part].Color, _OCOL[part].Trans, _OCC[part]
                _OSZ[part], _OCOL[part], _OCC[part] = nil, nil, nil
            end
        end
    end

    if _S1._A and _UI:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        if _LCKT then
            local part = _GAP(_LCKT)
            if _LCKT.Parent and part and (cPos - part.Position).Magnitude <= 1000 then
                local sPos, onS = _CA:WorldToViewportPoint(part.Position)
                if onS then
                    local screenPos = _v2(sPos.X, sPos.Y)
                    if (screenPos - mPos).Magnitude < _S1._FS * 1.5 then
                        if not _S1._WC or _f3(part) then 
                            target = screenPos 
                        end
                    else 
                        _LCKT = nil 
                    end
                else 
                    _LCKT = nil 
                end
            else 
                _LCKT = nil 
            end
        end
        if not _LCKT then
            local minMag = _S1._FS
            for i = 1, #_P_CACH do
                local p = _P_CACH[i]
                local part = _GAP(p)
                if part and (cPos - part.Position).Magnitude <= 1000 and not (_S1._SC and _f2(p)) and not (_S1._IB and _f1(p)) then
                    local sPos, onS = _CA:WorldToViewportPoint(part.Position)
                    if onS then
                        local screenPos = _v2(sPos.X, sPos.Y)
                        local mag = (screenPos - mPos).Magnitude
                        if mag < minMag then 
                            if not _S1._WC or _f3(part) then 
                                minMag, target, _LCKT = mag, screenPos, p 
                            end
                        end
                    end
                end
            end
        end
        if target then 
            _mmr((target.X - mPos.X) / _S1._SM, (target.Y - mPos.Y) / _S1._SM) 
        end
    else 
        _LCKT = nil 
    end
end))

_UI.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then 
        window.key = Enum.KeyCode.RightShift
        return 
    end
    if not processed then
        if input.KeyCode == _S1._B then 
            aimbotToggle:set(not _S1._A)
        elseif input.KeyCode == _S2._HB_B then 
            hitboxToggle:set(not _S1._HA)
        elseif input.KeyCode == _S2._FBB then 
            fullbrightToggle:set(not _S2._FB)
        elseif input.KeyCode == _S2._B then 
            playerEspToggle:set(not _S2._PE)
        end
    end
end))
