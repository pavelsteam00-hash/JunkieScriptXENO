local _wait, _spawn = task.wait, task.spawn
local _floor, _clamp = math.floor, math.clamp
local _rand = math.random
local _ins, _rem = table.insert, table.remove
local _v2, _v3 = Vector2.new, Vector3.new
local _c3 = Color3.fromRGB
local _c3hsv = Color3.fromHSV
local _fmt = string.format

local _RS = game:GetService("RunService")
local _PL = game:GetService("Players")
local _WS = game:GetService("Workspace")
local _UI = game:GetService("UserInputService")
local _LT = game:GetService("Lighting")
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

local _PR_C = {
    _c3(255, 255, 255),
    _c3(180, 120, 255),
    _c3(0, 255, 200),
    _c3(255, 200, 0),
    _c3(255, 50, 50)
}

local _S1 = {
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

local _S2 = {
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

local _S3 = {
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

local function _NOT(t, tx)
    local p = _S3._AC
    for _, o in ipairs(_NOTIF) do
        o._A = false
        pcall(function() 
            for _, obj in ipairs(o._ob) do 
                obj.Visible = false 
                obj:Remove() 
            end 
        end)
    end
    _NOTIF = {}
    local n = {_A = true, _ob = {}}
    _ins(_NOTIF, n)
    
    _spawn(function()
        local s = _CA.ViewportSize
        local nW, nH = 280, 70
        local tP = _v2(s.X - 300, s.Y - 100)
        local sP = _v2(s.X + 50, s.Y - 100)
        
        local bg = _drw("Square")
        bg.Size = _v2(nW, nH)
        bg.Color = _S3._BC
        bg.Filled = true
        bg.ZIndex = 30000
        bg.Visible = true
        bg.Transparency = 0
        
        local ln = _drw("Square")
        ln.Size = _v2(4, nH)
        ln.Color = p
        ln.Filled = true
        ln.ZIndex = 30001
        ln.Visible = true
        
        local tL = _drw("Text")
        tL.Text = t:upper()
        tL.Size = 18
        tL.Font = 2
        tL.Color = p
        tL.ZIndex = 30002
        tL.Visible = true
        tL.Outline = true
        
        local bL = _drw("Text")
        bL.Text = tx:upper()
        bL.Size = 15
        bL.Font = 2
        bL.Color = _c3(255, 255, 255)
        bL.ZIndex = 30002
        bL.Visible = true
        bL.Outline = true
        
        n._ob = {bg, ln, tL, bL}
        local f = 30
        for i = 1, f do
            if not n._A then break end
            local tm = i / f
            local e = 1 - (1 - tm)^3
            local cP = sP:Lerp(tP, e)
            bg.Position = cP
            ln.Position = cP
            tL.Position = cP + _v2(15, 10)
            bL.Position = cP + _v2(15, 35)
            for _, o in ipairs(n._ob) do o.Transparency = tm end
            _RS.RenderStepped:Wait()
        end
        _wait(3)
        for i = f, 1, -1 do
            if not n._A then break end
            local tm = i / f
            local e = 1 - (1 - tm)^3
            local cP = sP:Lerp(tP, e)
            bg.Position = cP
            ln.Position = cP
            for _, o in ipairs(n._ob) do o.Transparency = tm end
            _RS.RenderStepped:Wait()
        end
        if n._A then for _, o in ipairs(n._ob) do o:Remove() end end
    end)
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

local _FLNS = {}
for i = 1, 32 do
    _FLNS[i] = _CD("Line", {Thickness = 1, Transparency = 0.5, Visible = false, ZIndex = 999})
end

local function _U_FLNS(p, r, c, v)
    for i = 1, 32 do
        local l = _FLNS[i]
        if v then
            local a = (i/32) * math.pi * 2
            local na = ((i+1)/32) * math.pi * 2
            l.From = p + _v2(math.cos(a)*r, math.sin(a)*r)
            l.To = p + _v2(math.cos(na)*r, math.sin(na)*r)
            l.Color = c
        end
        l.Visible = v
    end
end

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

local function _SYNC()
    for col, elements in pairs(_S3._MC) do
        for i = 1, #elements do
            local el = elements[i]
            if el.type == "toggle" then
                local s = false
                if el.name == "Aimbot Master" then s = _S1._A
                elseif el.name == "Player ESP" then s = _S2._PE
                elseif el.name == "Chams ESP" then s = _S2._CE
                elseif el.name == "Hitbox Expander" then s = _S1._HA
                elseif el.name == "FOV Scanner" then s = _S1._FSC
                elseif el.name == "FullBright" then s = _S2._FB
                elseif el.name == "Ore Chams" then s = _S2._OC
                elseif el.name == "Wall Check" then s = _S1._WC
                elseif el.name == "Ignore Sleepers" then s = _S1._SC
                elseif el.name == "Ignore Bots" then s = _S1._IB
                elseif el.name == "Show FOV" then s = _S1._SF
                elseif el.name == "Hitbox Wallcheck" then s = _S1._HWC
                elseif el.name == "CanCollide Hitbox" then s = _S1._HCC
                elseif el.name == "Box ESP" then s = _S2._BE
                elseif el.name == "Box Filled" then s = _S2._BF
                elseif el.name == "Info ESP" then s = _S2._IE
                elseif el.name == "Hide Sleepers" then s = _S2._SE
                elseif el.name == "Hide Bots" then s = _S2._NE
                elseif el.name == "Stone ESP" then s = _S2._StoneESP
                elseif el.name == "Iron ESP" then s = _S2._IronESP
                elseif el.name == "Nitrate ESP" then s = _S2._NitrateESP end
                el.state = s
                el.bg.Color = el.state and _S3._AC or _c3(40, 40, 45)
                if el.cpBox then el.cpBox.Color = el.getColor() end
            end
        end
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

_spawn(function()
    _MF = _CD("Square", { Size = _mD, Color = _S3._BC, Filled = true, Visible = false, ZIndex = 10 })
    _BL = _CD("Square", { Size = _mD, Color = _S3._BrC, Filled = false, Thickness = 1, Visible = false, ZIndex = 11 })
    _HAC = _CD("Square", { Size = _v2(_mD.X, 2), Color = _S3._AC, Filled = true, Visible = false, ZIndex = 15 })
    _HDR = _CD("Square", { Size = _v2(_mD.X, 35), Color = _S3._BC, Filled = true, Visible = false, ZIndex = 12 })
    
    local _TTLS = {"SILVER PRIVATE", "SILVER PRIVATE", "SILVER PRIVATE", "SILVER PRIVATE", "SILVER PRIVATE"}
    _HTL = _CD("Text", { Text = _TTLS[_rand(1,#_TTLS)], Size = 18, Center = true, Font = 2, Color = _S3._TC, Visible = false, ZIndex = 16, Outline = true })
    
    _LPANE = _CD("Square", { Size = _v2(230, 520), Color = _S3._SC, Filled = true, Visible = false, ZIndex = 12 })
    _RPANE = _CD("Square", { Size = _v2(230, 520), Color = _S3._SC, Filled = true, Visible = false, ZIndex = 12 })
    _EPANE = _CD("Square", { Size = _v2(230, 520), Color = _S3._SC, Filled = true, Visible = false, ZIndex = 12 })

    _ABG = _CD("Square", { Size = _v2(230, 25), Color = _S3._SHC, Filled = true, Visible = false, ZIndex = 13 })
    _VBG = _CD("Square", { Size = _v2(230, 25), Color = _S3._SHC, Filled = true, Visible = false, ZIndex = 13 })
    _EBG = _CD("Square", { Size = _v2(230, 25), Color = _S3._SHC, Filled = true, Visible = false, ZIndex = 13 })
    
    _L_LINE = _CD("Square", { Size = _v2(230, 2), Color = _S3._AC, Filled = true, Visible = false, ZIndex = 14 })
    _V_LINE = _CD("Square", { Size = _v2(230, 2), Color = _S3._AC, Filled = true, Visible = false, ZIndex = 14 })
    _E_LINE = _CD("Square", { Size = _v2(230, 2), Color = _S3._AC, Filled = true, Visible = false, ZIndex = 14 })

    _LAIM = _CD("Text", { Text = "AIMBOT", Size = 16, Center = true, Font = 2, Color = _S3._AC, Visible = false, ZIndex = 16, Outline = true })
    _LVIS = _CD("Text", { Text = "VISUALS", Size = 16, Center = true, Font = 2, Color = _S3._AC, Visible = false, ZIndex = 16, Outline = true })
    _LENT = _CD("Text", { Text = "ENTITY", Size = 16, Center = true, Font = 2, Color = _S3._AC, Visible = false, ZIndex = 16, Outline = true })

    local function _ADD_T(n, d, cb, col, y, bg, bs, cg, cs)
        local t = {
            type = "toggle", name = n, state = d, callback = cb,
            bg = _CD("Square", {Size = _v2(12, 12), Color = _c3(30, 30, 35), Filled = true, Visible = false, ZIndex = 16}),
            label = _CD("Text", {Text = n:upper(), Size = 13, Font = 2, Color = _S3._TC, Visible = false, ZIndex = 16, Outline = true}),
            ypos = y, column = col
        }
        if cg then t.cpBox = _CD("Square", {Size = _v2(14, 14), Color = cg(), Filled = true, Visible = false, ZIndex = 16, Thickness = 1}) t.getColor = cg t.setColor = cs end
        if bg then t.bindBox = _CD("Square", {Size = _v2(45, 14), Color = _c3(25, 25, 30), Filled = true, Visible = false, ZIndex = 16}) t.bindText = _CD("Text", {Text = "NONE", Size = 11, Center = true, Font = 2, Color = _c3(150, 150, 150), Visible = false, ZIndex = 17}) t.getBind = bg t.setBind = bs end
        _ins(_S3._MC[col], t) return t
    end

    local function _ADD_S(n, min, max, d, cb, col, y)
        local s = {
            type = "slider", name = n, min = min, max = max, value = d, callback = cb,
            label = _CD("Text", {Text = n:upper(), Size = 13, Font = 2, Color = _c3(180, 180, 180), Visible = false, ZIndex = 16, Outline = true}),
            valueText = _CD("Text", {Text = tostring(d), Size = 13, Font = 2, Color = _S3._AC, Visible = false, ZIndex = 16, Outline = true}),
            bg = _CD("Square", {Size = _v2(200, 6), Color = _c3(25, 25, 30), Filled = true, Visible = false, ZIndex = 16}),
            fill = _CD("Square", {Size = _v2(0, 6), Color = _S3._AC, Filled = true, Visible = false, ZIndex = 17}),
            ypos = y, column = col
        }
        _ins(_S3._MC[col], s)
    end

    local function _ADD_B(n, cb, col, y)
        local b = {
            type = "button", name = n, callback = cb,
            bg = _CD("Square", {Size = _v2(200, 20), Color = _c3(25, 25, 30), Filled = true, Visible = false, ZIndex = 16}),
            label = _CD("Text", {Text = n:upper(), Size = 13, Font = 2, Center = true, Color = _S3._TC, Visible = false, ZIndex = 17, Outline = true}),
            ypos = y, column = col
        }
        _ins(_S3._MC[col], b)
    end

    _ADD_T("Aimbot Master", false, function(v) _S1._A = v _NOT("AIMBOT", v and "ENABLED" or "DISABLED") end, "left", 60, function() return _S1._B end, function(k) _S1._B = k end, function() return _S1._FC end, function(c) _S1._FC = c end)
    _ADD_T("Show FOV", false, function(v) _S1._SF = v end, "left", 85)
    _ADD_T("FOV Scanner", false, function(v) _S1._FSC = v end, "left", 110)
    _ADD_T("Ignore Sleepers", false, function(v) _S1._SC = v end, "left", 135)
    _ADD_T("Ignore Bots", false, function(v) _S1._IB = v end, "left", 160)
    _ADD_T("Wall Check", false, function(v) _S1._WC = v end, "left", 185)
    _ADD_B("Target Area: Head", function(o) _S1._TA = (_S1._TA == "Head") and "Body" or "Head" o.label.Text = "TARGET AREA: " .. _S1._TA:upper() end, "left", 215)
    _ADD_S("FOV Size", 20, 200, 80, function(v) _S1._FS = v end, "left", 250)
    _ADD_S("Smoothness", 5, 20, 10, function(v) _S1._SM = v end, "left", 295)
    
    _ADD_T("Hitbox Expander", false, function(v) _S1._HA = v _NOT("HITBOX", v and "ENABLED" or "DISABLED") end, "left", 340, function() return _S2._HB_B end, function(k) _S2._HB_B = k end, function() return _S1._HC end, function(c) _S1._HC = c end)
    _ADD_T("CanCollide Hitbox", true, function(v) _S1._HCC = v end, "left", 365)
    _ADD_T("Hitbox Wallcheck", false, function(v) _S1._HWC = v end, "left", 390)
    _ADD_S("Hitbox Size", 1, 4, 2, function(v) _S1._HS = v end, "left", 420)
    _ADD_S("Hitbox Transparency", 0, 10, 5, function(v) _S1._HT = v/10 end, "left", 465)

    _ADD_T("Player ESP", false, function(v) _S2._PE = v _NOT("VISUALS", v and "ENABLED" or "DISABLED") end, "right", 60, function() return _S2._B end, function(k) _S2._B = k end, function() return _S2._C end, function(c) _S2._C = c end)
    _ADD_T("Box ESP", false, function(v) _S2._BE = v end, "right", 85)
    _ADD_T("Box Filled", false, function(v) _S2._BF = v end, "right", 110)
    _ADD_T("Info ESP", false, function(v) _S2._IE = v end, "right", 135)
    _ADD_T("Chams ESP", false, function(v) _S2._CE = v end, "right", 160)
    _ADD_T("Hide Sleepers", false, function(v) _S2._SE = v end, "right", 185)
    _ADD_T("Hide Bots", false, function(v) _S2._NE = v end, "right", 210)
    _ADD_T("FullBright", false, function(v) _S2._FB = v if not v then _LT.Ambient = _OLT.A _LT.OutdoorAmbient = _OLT.OA _LT.Brightness = _OLT.B end _NOT("LIGHTING", v and "SAFE ON" or "SAFE OFF") end, "right", 245, function() return _S2._FBB end, function(k) _S2._FBB = k end, function() return _S2._FBC end, function(c) _S2._FBC = c end)
    _ADD_S("Brightness intensity", 0, 50, 0, function(v) _S2._FBI = v end, "right", 275)

    _ADD_T("Stone ESP", false, function(v) _S2._StoneESP = v end, "entity", 60)
    _ADD_T("Iron ESP", false, function(v) _S2._IronESP = v end, "entity", 85)
    _ADD_T("Nitrate ESP", false, function(v) _S2._NitrateESP = v end, "entity", 110)
    _ADD_T("Ore Chams", false, function(v) _S2._OC = v end, "entity", 135)

    _S3._L = true
    _S3._V = true
end)

local _lastTick = tick()
_RS.RenderStepped:Connect(function()
    if not _S3._L then return end
    local _now = tick()
    local _dt = _now - _lastTick
    _lastTick = _now

    _UFB()
    
    local mPos = _UI:GetMouseLocation()
    local cPos = _CA.CFrame.Position
    
    _U_FLNS(mPos, _S1._FS, _S1._FC, _S1._A and _S1._SF)

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
                        local sP, onS = _CA:WorldToViewportPoint(part.Position)
                        if onS then
                            local mg = (_v2(sP.X, sP.Y) - mPos).Magnitude
                            if mg < _S1._FS and mg < mD then 
                                mD = mg 
                                st = part 
                            end
                        end
                    end
                end
            end
        end
        for i = 1, 32 do _FLNS[i].Color = (st and _f3(st)) and _c3(0, 255, 0) or _c3(255, 0, 0) end
    end

    if _S3._V then
        _SYNC()
        if _S3._M then _mP = mPos + _dSO end
        if _S3._DS then
            local el = _S3._DS
            local xO = (el.column == "left") and 15 or (el.column == "right" and 265 or 515)
            local p = _clamp((mPos.X - (_mP.X + xO + 15)) / 200, 0, 1)
            el.value = _floor(el.min + (el.max - el.min) * p)
            el.valueText.Text = tostring(el.value)
            el.callback(el.value)
        end
        
        _MF.Position, _MF.Visible = _mP, true
        _BL.Position, _BL.Visible = _mP, true
        _HDR.Position, _HDR.Visible = _mP, true
        _HAC.Position, _HAC.Visible = _mP, true
        _HTL.Position, _HTL.Visible = _mP + _v2(380, 10), true
        
        local y_off = 40
        local lP = _mP + _v2(15, y_off)
        local rP = _mP + _v2(265, y_off)
        local eP = _mP + _v2(515, y_off)
        
        _LPANE.Position, _LPANE.Visible = lP, true
        _RPANE.Position, _RPANE.Visible = rP, true
        _EPANE.Position, _EPANE.Visible = eP, true
        
        _ABG.Position, _ABG.Visible = lP, true
        _VBG.Position, _VBG.Visible = rP, true
        _EBG.Position, _EBG.Visible = eP, true
        
        _L_LINE.Position, _L_LINE.Visible = lP, true
        _V_LINE.Position, _V_LINE.Visible = rP, true
        _E_LINE.Position, _E_LINE.Visible = eP, true

        _LAIM.Position, _LAIM.Visible = lP + _v2(115, 5), true
        _LVIS.Position, _LVIS.Visible = rP + _v2(115, 5), true
        _LENT.Position, _LENT.Visible = eP + _v2(115, 5), true

        for col, elms in pairs(_S3._MC) do
            local xO = (col == "left") and 15 or (col == "right" and 265 or 515)
            for j = 1, #elms do
                local el = elms[j]
                local pos = _mP + _v2(xO + 15, el.ypos + 25)
                if el.type == "toggle" then
                    el.bg.Position, el.label.Position = pos + _v2(0, 1), pos + _v2(20, 0)
                    el.bg.Visible, el.label.Visible = true, true
                    local cX = pos.X + 135
                    if el.cpBox then el.cpBox.Position = _v2(cX, pos.Y) el.cpBox.Visible = true cX = cX + 20 end
                    if el.bindBox then
                        el.bindBox.Position = _v2(cX, pos.Y) el.bindBox.Visible = true
                        el.bindBox.Size = _v2(45, 14)
                        el.bindText.Position, el.bindText.Visible = el.bindBox.Position + _v2(22, 1), true
                        local b = el.getBind()
                        el.bindText.Text = (_S3._IB == el) and "..." or (b and b.Name or "NONE")
                    end
                elseif el.type == "slider" then
                    el.label.Position, el.valueText.Position = pos, pos + _v2(200 - el.valueText.TextBounds.X, 0)
                    el.bg.Position, el.fill.Position = pos + _v2(0, 18), pos + _v2(0, 18)
                    el.fill.Size = _v2(((el.value - el.min) / (el.max - el.min)) * 200, 6)
                    el.label.Visible, el.valueText.Visible, el.bg.Visible, el.fill.Visible = true, true, true, true
                elseif el.type == "button" then
                    el.bg.Position, el.label.Position = pos, pos + _v2(100, 2)
                    el.bg.Visible, el.label.Visible = true, true
                end
            end
        end
    else
        for i = 1, #_S3._UIC do local obj = _S3._UIC[i] local isF = false for k = 1, 32 do if obj == _FLNS[k] then isF = true break end end if not isF then obj.Visible = false end end
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
                                Tag = _CD("Text", {Size = 13, Center = true, Font = 2, Outline = false, ZIndex = 3}), -- УБРАНА ОБВОДКА
                                Dist = _CD("Text", {Size = 13, Center = true, Font = 2, Outline = false, ZIndex = 3}) -- УБРАНА ОБВОДКА
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
                    else if _ESTO[p] then _REESP(p) end end
                else if _ESTO[p] then _REESP(p) end if _CHMC[p] then _CHMC[p].Enabled = false end end
            end
        end
    else for p, _ in pairs(_ESTO) do _REESP(p) end for p, h in pairs(_CHMC) do h.Enabled = false end end

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
                    else if _RSTO[res.part] then _RSTO[res.part].Visible = false end end
                else 
                    if _RSTO[res.part] then _RSTO[res.part].Visible = false end 
                    if _RCHC[res.part] then _RCHC[res.part].Enabled = false end
                end
            else if _RSTO[res.part] then _RSTO[res.part].Visible = false end if _RCHC[res.part] then _RCHC[res.part].Enabled = false end end
        end
    end

    for i = 1, #_P_CACH do
        local obj = _P_CACH[i]
        local part = _GAP(obj)
        if part then
            local sleeper, bot = _f2(obj), _f1(obj)
            local sPos, onS = _CA:WorldToViewportPoint(part.Position)
            local inFOV = onS and (_v2(sPos.X, sPos.Y) - mPos).Magnitude < _S1._FS
            local canExpand = _S1._A and _S1._HA and inFOV and not (_S1._SC and sleeper) and not (_S1._IB and bot)
            if canExpand and _S1._HWC then canExpand = _f3(part) end
            if canExpand then
                if not _OSZ[part] then _OSZ[part] = part.Size _OCOL[part] = {Color = part.Color, Trans = part.Transparency} _OCC[part] = part.CanCollide end
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
                if onS and (_v2(sPos.X, sPos.Y) - mPos).Magnitude < _S1._FS * 1.5 then
                    if not _S1._WC or _f3(part) then target = sPos end
                else _LCKT = nil end
            else _LCKT = nil end
        end
        if not _LCKT then
            local minMag = _S1._FS
            for i = 1, #_P_CACH do
                local p = _P_CACH[i]
                local part = _GAP(p)
                if part and (cPos - part.Position).Magnitude <= 1000 and not (_S1._SC and _f2(p)) and not (_S1._IB and _f1(p)) then
                    local sPos, onS = _CA:WorldToViewportPoint(part.Position)
                    if onS then
                        local mag = (_v2(sPos.X, sPos.Y) - mPos).Magnitude
                        if mag < minMag then if not _S1._WC or _f3(part) then minMag, target, _LCKT = mag, sPos, p end end
                    end
                end
            end
        end
        if target then _mmr((target.X - mPos.X) / _S1._SM, (target.Y - mPos.Y) / _S1._SM) end
    else _LCKT = nil end
end)

_UI.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then _S3._V = not _S3._V return end
    if not processed then
        if input.KeyCode == _S1._B then _S1._A = not _S1._A _NOT("AIMBOT", _S1._A and "ENABLED" or "DISABLED")
        elseif input.KeyCode == _S2._HB_B then _S1._HA = not _S1._HA _NOT("HITBOX", _S1._HA and "ENABLED" or "DISABLED")
        elseif input.KeyCode == _S2._FBB then _S2._FB = not _S2._FB _NOT("LIGHTING", _S2._FB and "SAFE ON" or "SAFE OFF")
        elseif input.KeyCode == _S2._B then _S2._PE = not _S2._PE _NOT("VISUALS", _S2._PE and "ENABLED" or "DISABLED") end
    end
    if _S3._IB then if input.UserInputType == Enum.UserInputType.Keyboard then _S3._IB.setBind(input.KeyCode) _S3._IB = nil end return end
    if _S3._V and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local m = _UI:GetMouseLocation()
        if m.X > _mP.X and m.X < _mP.X + _mD.X and m.Y > _mP.Y and m.Y < _mP.Y + 35 then _S3._M = true _dSO = _mP - m end
        for col, elements in pairs(_S3._MC) do
            local xOff = (col == "left") and 15 or (col == "right" and 265 or 515)
            for j = 1, #elements do
                local el = elements[j]
                local pos = _mP + _v2(xOff + 15, el.ypos + 25)
                if el.type == "toggle" then
                    if el.cpBox and m.X > el.cpBox.Position.X and m.X < el.cpBox.Position.X + 15 and m.Y > el.cpBox.Position.Y and m.Y < el.cpBox.Position.Y + 15 then
                        local cur = el.getColor()
                        local nextIdx = 1
                        for idx, c in ipairs(_PR_C) do if c == cur then nextIdx = (idx % #_PR_C) + 1 break end end
                        el.setColor(_PR_C[nextIdx])
                        return
                    end
                    if el.bindBox and m.X > el.bindBox.Position.X and m.X < el.bindBox.Position.X + 45 and m.Y > el.bindBox.Position.Y and m.Y < el.bindBox.Position.Y + 15 then _S3._IB = el return end
                    if m.X > pos.X and m.X < pos.X + 130 and m.Y > pos.Y and m.Y < pos.Y + 15 then el.state = not el.state el.callback(el.state) return end
                elseif el.type == "slider" and m.X > pos.X and m.X < pos.X + 200 and m.Y > pos.Y + 18 and m.Y < pos.Y + 28 then _S3._DS = el
                elseif el.type == "button" and m.X > pos.X and m.X < pos.X + 200 and m.Y > pos.Y and m.Y < pos.Y + 20 then el.callback(el) end
            end
        end
    end
end)

_UI.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then _S3._M = false _S3._DS = nil end end)
