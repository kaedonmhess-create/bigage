--=====================================================================
--  ADMIN PANEL  (executor GUI)  — portable, paste into any executor
--  Tabs: Movement | Players | Aimbot | Trolling | Teleport | Misc | Scripts
--=====================================================================
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local Workspace     = game:GetService("Workspace")
local Lighting      = game:GetService("Lighting")
local LocalPlayer   = Players.LocalPlayer

-- ---- teardown any previous instance ---------------------------------
if _G.__ADMIN then
    pcall(function() _G.__ADMIN.gui:Destroy() end)
    pcall(function() if _G.__ADMIN.hud then _G.__ADMIN.hud:Destroy() end end)
    for _,c in ipairs(_G.__ADMIN.conns) do pcall(function() c:Disconnect() end) end
end
local STATE = { conns = {} }
_G.__ADMIN = STATE
local function track(c) table.insert(STATE.conns, c); return c end

-- ---- helpers --------------------------------------------------------
local function getHRP()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
end
local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

-- palette
local BG,BG2,ACCENT = Color3.fromRGB(24,24,30),Color3.fromRGB(32,32,40),Color3.fromRGB(120,90,255)
local ONCOL,TXT,SUB = Color3.fromRGB(70,200,120),Color3.fromRGB(235,235,240),Color3.fromRGB(150,150,165)
local OFFCOL = Color3.fromRGB(90,90,100)

-- ---- root gui -------------------------------------------------------
local gui = make("ScreenGui", {Name="AdminPanel", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
STATE.gui = gui
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
gui.Parent = parentGui

local main = make("Frame", {Size=UDim2.fromOffset(560,360), Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=BG, BorderSizePixel=0}, gui)
make("UICorner",{CornerRadius=UDim.new(0,10)},main)

-- title bar (draggable)
local bar = make("Frame",{Size=UDim2.new(1,0,0,38), BackgroundColor3=BG2, BorderSizePixel=0}, main)
make("UICorner",{CornerRadius=UDim.new(0,10)},bar)
make("TextLabel",{Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(14,0), BackgroundTransparency=1,
    Font=Enum.Font.GothamBold, Text="ADMIN PANEL", TextColor3=TXT, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left}, bar)
do
    local dragging, ds, sp
    track(bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; ds=i.Position; sp=main.Position end
    end))
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds; main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X, sp.Y.Scale,sp.Y.Offset+d.Y) end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end))
end

-- close / minimize
local minimized=false
local body
local closeBtn = make("TextButton",{Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-34,0,5),
    BackgroundColor3=Color3.fromRGB(200,70,70), Text="X", TextColor3=TXT, Font=Enum.Font.GothamBold, TextSize=14}, bar)
make("UICorner",{CornerRadius=UDim.new(0,6)},closeBtn)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled=false end)
local minBtn = make("TextButton",{Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-66,0,5),
    BackgroundColor3=BG, Text="_", TextColor3=TXT, Font=Enum.Font.GothamBold, TextSize=14}, bar)
make("UICorner",{CornerRadius=UDim.new(0,6)},minBtn)
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized; body.Visible=not minimized
    main.Size = minimized and UDim2.fromOffset(560,38) or UDim2.fromOffset(560,360)
end)

body = make("Frame",{Size=UDim2.new(1,0,1,-38), Position=UDim2.fromOffset(0,38), BackgroundTransparency=1}, main)
local side = make("Frame",{Size=UDim2.new(0,140,1,-12), Position=UDim2.fromOffset(8,6), BackgroundColor3=BG2, BorderSizePixel=0}, body)
make("UICorner",{CornerRadius=UDim.new(0,8)},side)
make("UIListLayout",{Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center},side)
make("UIPadding",{PaddingTop=UDim.new(0,8)},side)
local content = make("Frame",{Size=UDim2.new(1,-164,1,-12), Position=UDim2.fromOffset(156,6), BackgroundColor3=BG2, BorderSizePixel=0}, body)
make("UICorner",{CornerRadius=UDim.new(0,8)},content)

-- ---- tab / widget builders -----------------------------------------
local pages, tabBtns = {}, {}
local function newPage(name)
    local p = make("ScrollingFrame",{Name=name, Size=UDim2.new(1,-12,1,-12), Position=UDim2.fromOffset(6,6),
        BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ScrollBarThickness=4,
        CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarImageColor3=ACCENT}, content)
    make("UIListLayout",{Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder},p)
    pages[name]=p
    local b = make("TextButton",{Size=UDim2.new(1,-12,0,32), BackgroundColor3=BG, Text=name,
        TextColor3=SUB, Font=Enum.Font.GothamMedium, TextSize=13, AutoButtonColor=false}, side)
    make("UICorner",{CornerRadius=UDim.new(0,6)},b)
    tabBtns[name]=b
    b.MouseButton1Click:Connect(function()
        for n,pg in pairs(pages) do pg.Visible=(n==name) end
        for n,bb in pairs(tabBtns) do bb.BackgroundColor3=(n==name) and ACCENT or BG; bb.TextColor3=(n==name) and TXT or SUB end
    end)
    return p
end
local function label(parent, text, order)
    return make("TextLabel",{LayoutOrder=order or 0, Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, Text=text,
        TextColor3=SUB, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, parent)
end
local function button(parent, text, cb, order)
    local b = make("TextButton",{LayoutOrder=order or 0, Size=UDim2.new(1,0,0,32), BackgroundColor3=BG, Text=text,
        TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=13, AutoButtonColor=true}, parent)
    make("UICorner",{CornerRadius=UDim.new(0,6)},b)
    b.MouseButton1Click:Connect(function() pcall(cb) end); return b
end
local function toggle(parent, text, cb, order)
    local on=false
    local b = make("TextButton",{LayoutOrder=order or 0, Size=UDim2.new(1,0,0,32), BackgroundColor3=BG, Text="  "..text,
        TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=true}, parent)
    make("UICorner",{CornerRadius=UDim.new(0,6)},b)
    local dot = make("Frame",{Size=UDim2.fromOffset(16,16), Position=UDim2.new(1,-26,0.5,-8), BackgroundColor3=OFFCOL}, b)
    make("UICorner",{CornerRadius=UDim.new(1,0)},dot)
    b.MouseButton1Click:Connect(function() on=not on; dot.BackgroundColor3=on and ONCOL or OFFCOL; pcall(cb, on) end)
    return b
end
local function slider(parent, text, minv, maxv, default, cb)
    local holder = make("Frame",{Size=UDim2.new(1,0,0,44), BackgroundColor3=BG, BorderSizePixel=0}, parent)
    make("UICorner",{CornerRadius=UDim.new(0,6)},holder)
    local lbl = make("TextLabel",{Size=UDim2.new(1,-12,0,20), Position=UDim2.fromOffset(8,2), BackgroundTransparency=1,
        Text=text.."  ["..default.."]", TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, holder)
    local track_ = make("Frame",{Size=UDim2.new(1,-16,0,6), Position=UDim2.fromOffset(8,28), BackgroundColor3=Color3.fromRGB(60,60,70), BorderSizePixel=0}, holder)
    make("UICorner",{CornerRadius=UDim.new(1,0)},track_)
    local fill = make("Frame",{Size=UDim2.fromScale((default-minv)/(maxv-minv),1), BackgroundColor3=ACCENT, BorderSizePixel=0}, track_)
    make("UICorner",{CornerRadius=UDim.new(1,0)},fill)
    local dragging=false
    local function set(x)
        local rel=math.clamp((x-track_.AbsolutePosition.X)/track_.AbsoluteSize.X,0,1)
        local val=math.floor(minv+(maxv-minv)*rel+0.5)
        fill.Size=UDim2.fromScale(rel,1); lbl.Text=text.."  ["..val.."]"; pcall(cb,val)
    end
    track(track_.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; set(i.Position.X) end
    end))
    track(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then set(i.Position.X) end
    end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end))
end

--=====================================================================
-- 1: MOVEMENT  (Flight, Noclip, speed sliders)
--=====================================================================
local mv = newPage("Movement")
label(mv,"FLIGHT & CLIP")
local flySpeed, flying, flyBV, flyBG = 50, false, nil, nil
local function killMomentum()
    local hrp=getHRP()
    if hrp then hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end
end
local function stopFly()
    flying=false
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
    local _,hum=getHRP(); if hum then hum.PlatformStand=false end
    killMomentum(); task.defer(killMomentum)     -- no coasting when disabled
end
local function startFly()
    local hrp,hum=getHRP(); if not hrp then return end
    flying=true
    if hum then hum.PlatformStand=true end
    flyBV=make("BodyVelocity",{Velocity=Vector3.zero, MaxForce=Vector3.one*9e9, P=1250},hrp)
    flyBG=make("BodyGyro",{MaxTorque=Vector3.one*9e9, P=1000, CFrame=hrp.CFrame},hrp)
end
toggle(mv,"Flight", function(on) if on then startFly() else stopFly() end end)
track(RunService.RenderStepped:Connect(function()
    if flying and flyBV and flyBV.Parent and flyBG and flyBG.Parent then
        local cam=Workspace.CurrentCamera
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        flyBV.Velocity=dir*flySpeed; flyBG.CFrame=cam.CFrame
    elseif flying and not (flyBV and flyBV.Parent) then
        startFly()                                -- rebuild if a body got stripped
    end
end))
local noclip=false
toggle(mv,"Noclip", function(on) noclip=on end)
track(RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end
end))
label(mv,"SPEEDS")
slider(mv,"Fly Speed",10,300,50,function(v) flySpeed=v end)
slider(mv,"Walk Speed",16,350,16,function(v) local _,hum=getHRP(); if hum then hum.WalkSpeed=v end end)
slider(mv,"Jump Power",50,500,50,function(v) local _,hum=getHRP(); if hum then hum.UseJumpPower=true; hum.JumpPower=v end end)

label(mv,"PLATFORM")
-- Hover mode: WASD = walk at your own WalkSpeed, E = up, Q = down, idle = hold in place.
local platformOn, platBV = false, nil
local function newPlatBV(hrp) return make("BodyVelocity",{Velocity=Vector3.zero, MaxForce=Vector3.one*9e9, P=1250}, hrp) end
toggle(mv,"Platform Float (E up / Q down)", function(on)
    if on then
        local hrp=getHRP(); if not hrp then return end
        platformOn=true; platBV=newPlatBV(hrp)
    else
        platformOn=false
        if platBV then platBV:Destroy() platBV=nil end
        local hrp=getHRP(); if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
    end
end)
track(RunService.RenderStepped:Connect(function()
    if not platformOn then return end
    local hrp,hum=getHRP(); if not hrp then return end
    if not (platBV and platBV.Parent) then platBV=newPlatBV(hrp) end
    local speed = (hum and hum.WalkSpeed) or 16          -- keep your own speed
    local cam=Workspace.CurrentCamera
    local look=cam.CFrame.LookVector;  look=Vector3.new(look.X,0,look.Z);  if look.Magnitude>0 then look=look.Unit end
    local right=cam.CFrame.RightVector; right=Vector3.new(right.X,0,right.Z); if right.Magnitude>0 then right=right.Unit end
    local move=Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move+=look end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move-=look end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move-=right end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move+=right end
    if move.Magnitude>0 then move=move.Unit*speed end
    local vy=0
    if UIS:IsKeyDown(Enum.KeyCode.E) then vy=speed end
    if UIS:IsKeyDown(Enum.KeyCode.Q) then vy=-speed end
    platBV.Velocity=Vector3.new(move.X, vy, move.Z)     -- idle -> (0,0,0) = hover in place
end))

--=====================================================================
-- 2: PLAYERS  (one-click TP buttons, Refresh at bottom)
--=====================================================================
local pl = newPage("Players")
label(pl,"CLICK A PLAYER TO TELEPORT", 1)
local listFrame = make("Frame",{LayoutOrder=2, Size=UDim2.new(1,0,0,200), BackgroundColor3=BG, BorderSizePixel=0}, pl)
make("UICorner",{CornerRadius=UDim.new(0,6)},listFrame)
local listScroll = make("ScrollingFrame",{Size=UDim2.new(1,-8,1,-8), Position=UDim2.fromOffset(4,4),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarImageColor3=ACCENT}, listFrame)
make("UIListLayout",{Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.Name},listScroll)
local function tpTo(target)
    local hrp=getHRP()
    local thrp=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and thrp then hrp.CFrame=thrp.CFrame+Vector3.new(0,3,0) end
end
local function refreshPlayers()
    for _,c in ipairs(listScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then
            local row = make("TextButton",{Name=plr.Name, Size=UDim2.new(1,0,0,28), BackgroundColor3=BG2,
                Text="  TP » "..plr.DisplayName.." (@"..plr.Name..")", TextColor3=TXT, Font=Enum.Font.GothamMedium,
                TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=true}, listScroll)
            make("UICorner",{CornerRadius=UDim.new(0,5)},row)
            row.MouseButton1Click:Connect(function()
                tpTo(plr)
                row.BackgroundColor3=ACCENT
                task.delay(0.15,function() if row and row.Parent then row.BackgroundColor3=BG2 end end)
            end)
        end
    end
end
button(pl,"Refresh Players", refreshPlayers, 3)   -- LayoutOrder 3 keeps it at the bottom
refreshPlayers()
track(Players.PlayerAdded:Connect(refreshPlayers))
track(Players.PlayerRemoving:Connect(function() task.defer(refreshPlayers) end))

--=====================================================================
-- 3: AIMBOT  (locks camera to the player nearest your mouse)
--=====================================================================
local ab = newPage("Aimbot")
local aim = { enabled=false, always=false, part="Head", smooth=8, fov=120,
              team=false, wall=false, sticky=false, showFOV=true }
local aiming, curTarget = false, nil

-- FOV circle HUD (own ScreenGui so it aligns with the real cursor)
local hud = make("ScreenGui",{Name="AimHUD", IgnoreGuiInset=true, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, parentGui)
pcall(function() if syn and syn.protect_gui then syn.protect_gui(hud) end end)
STATE.hud = hud
local fovCircle = make("Frame",{Size=UDim2.fromOffset(aim.fov*2,aim.fov*2), AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundTransparency=1, Visible=false}, hud)
make("UICorner",{CornerRadius=UDim.new(1,0)},fovCircle)
make("UIStroke",{Thickness=1.5, Color=ACCENT, Transparency=0.15},fovCircle)

label(ab,"AIMBOT")
toggle(ab,"Enable (hold Right-Click)", function(on) aim.enabled=on; if not on then curTarget=nil end end)
toggle(ab,"Always Aim (no key)", function(on) aim.always=on end)
local parts = {"Head","HumanoidRootPart","UpperTorso"}
local pi = 1
local partBtn
partBtn = button(ab,"Target Part: Head", function()
    pi = pi % #parts + 1; aim.part = parts[pi]; partBtn.Text = "Target Part: "..aim.part
end)
toggle(ab,"Team Check", function(on) aim.team=on end)
toggle(ab,"Wall Check (visible only)", function(on) aim.wall=on end)
toggle(ab,"Sticky Lock (keep target)", function(on) aim.sticky=on end)
toggle(ab,"Show FOV Circle", function(on) aim.showFOV=on end)
label(ab,"SETTINGS")
slider(ab,"Smoothness",1,25,8,function(v) aim.smooth=v end)
slider(ab,"FOV",40,400,120,function(v) aim.fov=v end)
local tgtLabel = label(ab,"Target: none")

local function isVisible(part)
    local cam = Workspace.CurrentCamera
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LocalPlayer.Character, part.Parent }
    local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
    return hit == nil
end
local function validTarget(plr)
    local ch = plr and plr.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local part = ch and ch:FindFirstChild(aim.part)
    if hum and hum.Health > 0 and part then return part, hum end
end
local function pickTarget()
    local cam = Workspace.CurrentCamera
    local m = LocalPlayer:GetMouse()
    local mp = Vector2.new(m.X, m.Y)
    local best, bestD = nil, aim.fov
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not (aim.team and plr.Team == LocalPlayer.Team) then
            local part = validTarget(plr)
            if part then
                local sp, on = cam:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                    if d < bestD and (not aim.wall or isVisible(part)) then best, bestD = plr, d end
                end
            end
        end
    end
    return best
end

track(RunService.RenderStepped:Connect(function(dt)
    -- FOV circle follows the cursor
    fovCircle.Visible = aim.enabled and aim.showFOV
    if fovCircle.Visible then
        fovCircle.Size = UDim2.fromOffset(aim.fov*2, aim.fov*2)
        local ml = UIS:GetMouseLocation()
        fovCircle.Position = UDim2.fromOffset(ml.X, ml.Y)
    end
    local active = aim.enabled and (aim.always or aiming)
    if active then
        if not (aim.sticky and curTarget and validTarget(curTarget)) then curTarget = pickTarget() end
        local part = curTarget and validTarget(curTarget)
        if part then
            tgtLabel.Text = "Target: "..curTarget.Name
            local cam = Workspace.CurrentCamera
            local goal = CFrame.lookAt(cam.CFrame.Position, part.Position)
            local alpha = math.clamp((1/aim.smooth) * (dt*60), 0, 1)
            cam.CFrame = cam.CFrame:Lerp(goal, alpha)
        else
            curTarget = nil; tgtLabel.Text = "Target: none"
        end
    else
        curTarget = nil
        if tgtLabel.Text ~= "Target: none" then tgtLabel.Text = "Target: none" end
    end
end))
track(UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aiming=true end end))
track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aiming=false end end))

--=====================================================================
-- 4: TROLLING  (self troll + Push Objects)
--=====================================================================
local tr = newPage("Trolling")
label(tr,"SELF TROLL")
local spinning=false
toggle(tr,"Spin", function(on) spinning=on end)
track(RunService.Heartbeat:Connect(function()
    if spinning then local hrp=getHRP(); if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(30),0) end end
end))
button(tr,"Fling Self", function()
    local hrp=getHRP(); if hrp then hrp.AssemblyLinearVelocity=Vector3.new(math.random(-1,1),1,math.random(-1,1)).Unit*250 end
end)
button(tr,"Launch Up", function() local hrp=getHRP(); if hrp then hrp.CFrame=hrp.CFrame+Vector3.new(0,150,0) end end)
toggle(tr,"Freeze In Place", function(on) local hrp=getHRP(); if hrp then hrp.Anchored=on end end)

label(tr,"PHYSICS")
local Debris = game:GetService("Debris")
local pushOn, pushForce = false, 80
toggle(tr,"Push Objects (walk into them)", function(on) pushOn=on end)
local pushParams = OverlapParams.new()
pushParams.FilterType = Enum.RaycastFilterType.Exclude
-- Uses a short-lived BodyVelocity (a physics mover the client simulates) per part,
-- instead of setting AssemblyLinearVelocity directly which the server overrides.
track(RunService.Heartbeat:Connect(function()
    if not pushOn then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    if Vector3.new(vel.X,0,vel.Z).Magnitude < 1 then return end   -- only while moving
    pushParams.FilterDescendantsInstances = { char }
    for _,p in ipairs(Workspace:GetPartBoundsInRadius(hrp.Position, 8, pushParams)) do
        if p:IsA("BasePart") and not p.Anchored and not p:GetAttribute("__pushing") then
            local model = p:FindFirstAncestorWhichIsA("Model")
            if not (model and Players:GetPlayerFromCharacter(model)) then
                local dir = p.Position - hrp.Position
                dir = Vector3.new(dir.X, 0, dir.Z)
                dir = (dir.Magnitude > 0.05) and dir.Unit or hrp.CFrame.LookVector
                p:SetAttribute("__pushing", true)
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.one*1e6
                bv.Velocity = dir*pushForce + Vector3.new(0, 14, 0)
                bv.Parent = p
                Debris:AddItem(bv, 0.35)
                task.delay(0.4, function() if p and p.Parent then p:SetAttribute("__pushing", nil) end end)
            end
        end
    end
end))
slider(tr,"Push Force",30,250,80,function(v) pushForce=v end)

--=====================================================================
-- 4: TELEPORT
--=====================================================================
local tp = newPage("Teleport")
label(tp,"POSITION")
local saved=nil
button(tp,"Save Position", function() local hrp=getHRP(); if hrp then saved=hrp.CFrame end end)
button(tp,"Load Position", function() local hrp=getHRP(); if hrp and saved then hrp.CFrame=saved end end)
button(tp,"Teleport To Spawn", function()
    local hrp=getHRP(); local sp=Workspace:FindFirstChildWhichIsA("SpawnLocation",true)
    if hrp and sp then hrp.CFrame=sp.CFrame+Vector3.new(0,4,0) end
end)
button(tp,"Teleport Forward (camera)", function()
    local hrp=getHRP(); local cam=Workspace.CurrentCamera
    if hrp then hrp.CFrame=CFrame.new(cam.CFrame.Position+cam.CFrame.LookVector*40) end
end)

--=====================================================================
-- 5: MISC
--=====================================================================
local ms = newPage("Misc")
label(ms,"UTILITY")
local fb=nil
toggle(ms,"Fullbright", function(on)
    if on then
        fb={Lighting.Brightness,Lighting.ClockTime,Lighting.FogEnd,Lighting.Ambient}
        Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.Ambient=Color3.fromRGB(180,180,180)
    elseif fb then Lighting.Brightness,Lighting.ClockTime,Lighting.FogEnd,Lighting.Ambient=fb[1],fb[2],fb[3],fb[4] end
end)
local antiafk=nil
toggle(ms,"Anti-AFK", function(on)
    if on then
        local vu=game:GetService("VirtualUser")
        antiafk=track(LocalPlayer.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end))
    elseif antiafk then antiafk:Disconnect() end
end)
button(ms,"Reset Character", function() local _,hum=getHRP(); if hum then hum.Health=0 end end)
button(ms,"Rejoin Server", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
label(ms,"Made for "..LocalPlayer.Name)

--=====================================================================
-- 7: SCRIPTS  (script hub + remote spy)
--=====================================================================
local sc = newPage("Scripts")
label(sc,"SCRIPT HUB")
button(sc,"Load Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

label(sc,"REMOTE SPY")
-- Loads SimpleSpy (full remote spy GUI) just like the IY loader above.
button(sc,"Load Remote Spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
end)

label(sc,"SCRIPT SEARCH")
-- Search ScriptBlox by game name; each result has an Execute button that runs the script.
local HttpService = game:GetService("HttpService")
local searchRow = make("Frame",{Size=UDim2.new(1,0,0,32), BackgroundColor3=BG, BorderSizePixel=0}, sc)
make("UICorner",{CornerRadius=UDim.new(0,6)},searchRow)
local box = make("TextBox",{Size=UDim2.new(1,-72,1,-6), Position=UDim2.fromOffset(6,3), BackgroundColor3=BG2,
    Text="", PlaceholderText="search a game…", TextColor3=TXT, PlaceholderColor3=SUB, ClearTextOnFocus=false,
    Font=Enum.Font.GothamMedium, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left}, searchRow)
make("UICorner",{CornerRadius=UDim.new(0,5)},box)
make("UIPadding",{PaddingLeft=UDim.new(0,8)},box)
local searchBtn = make("TextButton",{Size=UDim2.fromOffset(60,26), Position=UDim2.new(1,-64,0.5,-13),
    BackgroundColor3=ACCENT, Text="Search", TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=12, AutoButtonColor=true}, searchRow)
make("UICorner",{CornerRadius=UDim.new(0,5)},searchBtn)
local resFrame = make("Frame",{Size=UDim2.new(1,0,0,190), BackgroundColor3=BG, BorderSizePixel=0}, sc)
make("UICorner",{CornerRadius=UDim.new(0,6)},resFrame)
local resScroll = make("ScrollingFrame",{Size=UDim2.new(1,-8,1,-8), Position=UDim2.fromOffset(4,4),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarImageColor3=ACCENT}, resFrame)
make("UIListLayout",{Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder},resScroll)
local function clearRes() for _,c in ipairs(resScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end end
local function status(t) clearRes(); make("TextLabel",{Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=t,
    TextColor3=SUB, Font=Enum.Font.Gotham, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, resScroll) end
local function runCode(code)
    if type(code)~="string" or #code==0 then return false end
    local fn = loadstring(code); if not fn then return false end
    task.spawn(fn); return true
end
local searching=false
local function doSearch()
    local q=box.Text
    if #q==0 or searching then return end
    searching=true; status("Searching…")
    task.spawn(function()
        local url="https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(q)  -- no mode filter = any script
        local ok,body=pcall(function() return game:HttpGet(url) end)
        local ok2,data = ok and pcall(function() return HttpService:JSONDecode(body) end)
        local list = ok2 and data and data.result and data.result.scripts
        if not list then status("Request failed / no results"); searching=false; return end
        if #list==0 then status("No scripts found for '"..q.."'"); searching=false; return end
        clearRes()
        for i=1,math.min(#list,25) do
            local s=list[i]
            local code=s.script
            local slug=s.slug
            local row=make("Frame",{Size=UDim2.new(1,-4,0,44), BackgroundColor3=BG2, BorderSizePixel=0, LayoutOrder=i}, resScroll)
            make("UICorner",{CornerRadius=UDim.new(0,5)},row)
            make("TextLabel",{Size=UDim2.new(1,-74,1,-6), Position=UDim2.fromOffset(8,3), BackgroundTransparency=1,
                RichText=true, TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=12,
                Text=tostring(s.title or "Untitled").."\n<font color='#8a8a99'>"..tostring((s.game and s.game.name) or "?").."</font>",
                TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center,
                TextTruncate=Enum.TextTruncate.AtEnd}, row)
            local ex=make("TextButton",{Size=UDim2.fromOffset(60,28), Position=UDim2.new(1,-66,0.5,-14),
                BackgroundColor3=ACCENT, Text="Execute", TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=11, AutoButtonColor=true}, row)
            make("UICorner",{CornerRadius=UDim.new(0,5)},ex)
            ex.MouseButton1Click:Connect(function()
                local c=code
                if (type(c)~="string" or #c==0) and slug then
                    local ok3,b2=pcall(function() return game:HttpGet("https://scriptblox.com/api/script/"..slug) end)
                    if ok3 then local ok4,d2=pcall(function() return HttpService:JSONDecode(b2) end)
                        if ok4 and d2 and d2.script then c=(type(d2.script)=="table" and d2.script.script) or d2.script end end
                end
                ex.Text = runCode(c) and "Ran" or "Failed"
                task.delay(1.2,function() if ex and ex.Parent then ex.Text="Execute" end end)
            end)
        end
        searching=false
    end)
end
searchBtn.MouseButton1Click:Connect(doSearch)
box.FocusLost:Connect(function(enter) if enter then doSearch() end end)

-- ---- open first tab & respawn handling ------------------------------
tabBtns["Movement"].BackgroundColor3=ACCENT
tabBtns["Movement"].TextColor3=TXT
pages["Movement"].Visible=true
track(LocalPlayer.CharacterAdded:Connect(function() flying=false; flyBV=nil; flyBG=nil end))
print("[AdminPanel] loaded")
