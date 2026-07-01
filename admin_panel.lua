--=====================================================================
--  HYPERION PANEL  (executor GUI) — card layout, paste into any executor
--  Toggle panel with RIGHT-CONTROL.
--=====================================================================
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local HttpService=game:GetService("HttpService")
local TP=game:GetService("TeleportService")
local LP=Players.LocalPlayer

if _G.__ADMIN then
    pcall(function() _G.__ADMIN.gui:Destroy() end)
    pcall(function() if _G.__ADMIN.hud then _G.__ADMIN.hud:Destroy() end end)
    pcall(function() if _G.__ADMIN.esp then _G.__ADMIN.esp:Destroy() end end)
    pcall(function() for _,d in ipairs(_G.__ADMIN.draw or {}) do pcall(function() d:Remove() end) end end)
    for _,c in ipairs(_G.__ADMIN.conns) do pcall(function() c:Disconnect() end) end
end
local STATE={conns={}, draw={}}
_G.__ADMIN=STATE
local function track(c) table.insert(STATE.conns,c) return c end
local function getHRP() local ch=LP.Character return ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid") end
local function make(cl,pr,pa) local o=Instance.new(cl) for k,v in pairs(pr) do o[k]=v end if pa then o.Parent=pa end return o end

local PANEL=Color3.fromRGB(18,18,22)
local CARD=Color3.fromRGB(28,29,35)
local ROW=Color3.fromRGB(38,40,48)
local ACCENT=Color3.fromRGB(82,140,255)
local OFF=Color3.fromRGB(58,60,68)
local TXT=Color3.fromRGB(236,237,242)
local SUB=Color3.fromRGB(140,143,153)
local WHITE=Color3.fromRGB(245,246,250)

local parentGui=(gethui and gethui()) or game:GetService("CoreGui")
local gui=make("ScreenGui",{Name="Panel", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
STATE.gui=gui
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
gui.Parent=parentGui

-- HUD (fov circle + crosshair), separate inset-ignoring layer
local hud=make("ScreenGui",{Name="HUD", IgnoreGuiInset=true, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parentGui)
STATE.hud=hud
pcall(function() if syn and syn.protect_gui then syn.protect_gui(hud) end end)
local fovCircle=make("Frame",{Size=UDim2.fromOffset(240,240), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Visible=false},hud)
make("UICorner",{CornerRadius=UDim.new(1,0)},fovCircle)
make("UIStroke",{Thickness=1.5, Color=ACCENT, Transparency=0.15},fovCircle)
local cross=make("Frame",{Size=UDim2.fromOffset(14,14), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Visible=false},hud)
make("Frame",{Size=UDim2.fromOffset(2,14), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=WHITE, BorderSizePixel=0},cross)
make("Frame",{Size=UDim2.fromOffset(14,2), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=WHITE, BorderSizePixel=0},cross)

local main=make("Frame",{Size=UDim2.fromOffset(900,470), Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=PANEL, BorderSizePixel=0},gui)
make("UICorner",{CornerRadius=UDim.new(0,12)},main)
make("UIStroke",{Color=Color3.fromRGB(45,47,55), Thickness=1},main)

local bar=make("Frame",{Size=UDim2.new(1,0,0,36), BackgroundColor3=PANEL, BorderSizePixel=0},main)
make("UICorner",{CornerRadius=UDim.new(0,12)},bar)
make("TextLabel",{Size=UDim2.new(1,-100,1,0), Position=UDim2.fromOffset(16,0), BackgroundTransparency=1,
    Text="◆  HYPERION", TextColor3=TXT, Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left},bar)
make("TextLabel",{Size=UDim2.fromOffset(120,14), Position=UDim2.new(1,-160,0.5,-7), BackgroundTransparency=1,
    Text="RightCtrl to toggle", TextColor3=SUB, Font=Enum.Font.Gotham, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right},bar)
do local drag,ds,sp
    track(bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=main.Position end end))
    track(UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end))
    track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end))
end
local closeB=make("TextButton",{Size=UDim2.fromOffset(26,26), Position=UDim2.new(1,-32,0,5), BackgroundColor3=Color3.fromRGB(200,70,70),
    Text="✕", TextColor3=WHITE, Font=Enum.Font.GothamBold, TextSize=13},bar)
make("UICorner",{CornerRadius=UDim.new(0,6)},closeB)
closeB.MouseButton1Click:Connect(function() gui.Enabled=false end)
track(UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then gui.Enabled=not gui.Enabled end end))

local cols=make("Frame",{Size=UDim2.new(1,-16,1,-44), Position=UDim2.fromOffset(8,40), BackgroundTransparency=1},main)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder},cols)
local function newCol()
    local c=make("ScrollingFrame",{Size=UDim2.new(0.25,-6,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarImageColor3=ROW},cols)
    make("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder},c)
    return c
end
local function card(col,title)
    local c=make("Frame",{Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=CARD, BorderSizePixel=0},col)
    make("UICorner",{CornerRadius=UDim.new(0,10)},c)
    make("UIListLayout",{Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder},c)
    make("UIPadding",{PaddingTop=UDim.new(0,11), PaddingBottom=UDim.new(0,12), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)},c)
    make("TextLabel",{Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text=title:upper(), TextColor3=SUB,
        Font=Enum.Font.GothamBold, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left},c)
    return c
end
local function pill(parent,text,default,cb)
    local st=default and true or false
    local b=make("TextButton",{Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Text="", AutoButtonColor=false},parent)
    make("TextLabel",{Size=UDim2.new(1,-46,1,0), BackgroundTransparency=1, Text=text, TextColor3=TXT, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left},b)
    local tr=make("Frame",{Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-38,0.5,-10), BackgroundColor3=st and ACCENT or OFF},b)
    make("UICorner",{CornerRadius=UDim.new(1,0)},tr)
    local knob=make("Frame",{Size=UDim2.fromOffset(16,16), Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3=WHITE},tr)
    make("UICorner",{CornerRadius=UDim.new(1,0)},knob)
    b.MouseButton1Click:Connect(function()
        st=not st
        tr.BackgroundColor3=st and ACCENT or OFF
        knob:TweenPosition(st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        pcall(cb,st)
    end)
    if default then pcall(cb,true) end
    return b
end
local function sldr(parent,text,mn,mx,def,cb)
    local h=make("Frame",{Size=UDim2.new(1,0,0,38), BackgroundTransparency=1},parent)
    make("TextLabel",{Size=UDim2.new(1,-44,0,16), BackgroundTransparency=1, Text=text, TextColor3=TXT, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left},h)
    local val=make("TextLabel",{Size=UDim2.fromOffset(42,16), Position=UDim2.new(1,-42,0,0), BackgroundTransparency=1, Text=tostring(def), TextColor3=WHITE, Font=Enum.Font.GothamBold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right},h)
    local tr=make("Frame",{Size=UDim2.new(1,0,0,5), Position=UDim2.fromOffset(0,26), BackgroundColor3=OFF},h)
    make("UICorner",{CornerRadius=UDim.new(1,0)},tr)
    local fill=make("Frame",{Size=UDim2.fromScale((def-mn)/(mx-mn),1), BackgroundColor3=ACCENT},tr)
    make("UICorner",{CornerRadius=UDim.new(1,0)},fill)
    local knob=make("Frame",{Size=UDim2.fromOffset(13,13), Position=UDim2.new((def-mn)/(mx-mn),-6,0.5,-6), BackgroundColor3=WHITE},tr)
    make("UICorner",{CornerRadius=UDim.new(1,0)},knob)
    -- transparent hit layer on top captures clicks anywhere (fill/knob no longer block them)
    local hit=make("TextButton",{Size=UDim2.new(1,0,0,22), Position=UDim2.fromOffset(0,18), BackgroundTransparency=1, Text="", AutoButtonColor=false},h)
    local drag=false
    local function set(x)
        local rel=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(mn+(mx-mn)*rel+0.5)
        fill.Size=UDim2.fromScale(rel,1); knob.Position=UDim2.new(rel,-6,0.5,-6); val.Text=tostring(v); pcall(cb,v)
    end
    track(hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; set(i.Position.X) end end))
    track(UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then set(i.Position.X) end end))
    track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end))
end
local function listbtn(parent,text,cb)
    local b=make("TextButton",{Size=UDim2.new(1,0,0,30), BackgroundColor3=ROW, Text=text, TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=13, AutoButtonColor=true},parent)
    make("UICorner",{CornerRadius=UDim.new(0,7)},b)
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end

-- ================= COLUMN 1: AIMBOT + CAMERA =================
local c1=newCol()
local aimc=card(c1,"Aimbot")
local aim={on=false, hold=true, head=true, team=false, wall=false, sticky=false, fov=120, smooth=5, showfov=true}
local aiming,curT=false,nil
pill(aimc,"Aimbot enabled",false,function(v) aim.on=v; if not v then curT=nil end end)
pill(aimc,"Hold RMB to aim",true,function(v) aim.hold=v end)
pill(aimc,"Target head",true,function(v) aim.head=v end)
pill(aimc,"Team check",false,function(v) aim.team=v end)
pill(aimc,"Wall check",false,function(v) aim.wall=v end)
pill(aimc,"Sticky target",false,function(v) aim.sticky=v end)
pill(aimc,"Show FOV circle",true,function(v) aim.showfov=v end)
sldr(aimc,"Aim FOV",40,400,120,function(v) aim.fov=v end)
sldr(aimc,"Smoothness",1,25,5,function(v) aim.smooth=v end)
local camc=card(c1,"Camera")
sldr(camc,"Field of view",40,120,70,function(v) Workspace.CurrentCamera.FieldOfView=v end)
local function visible(part)
    local cam=Workspace.CurrentCamera
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={LP.Character, part.Parent}
    return Workspace:Raycast(cam.CFrame.Position, part.Position-cam.CFrame.Position, rp)==nil
end
local function vT(plr)
    local ch=plr and plr.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local part=ch and ch:FindFirstChild(aim.head and "Head" or "HumanoidRootPart")
    if hum and hum.Health>0 and part then return part end
end
local function pick()
    local cam=Workspace.CurrentCamera
    local m=LP:GetMouse(); local mp=Vector2.new(m.X,m.Y)
    local best,bd=nil,aim.fov
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and not (aim.team and plr.Team==LP.Team) then
            local part=vT(plr)
            if part then local sp,on=cam:WorldToViewportPoint(part.Position)
                if on then local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude if d<bd and (not aim.wall or visible(part)) then best,bd=plr,d end end end
        end
    end
    return best
end
track(UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aiming=true end end))
track(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aiming=false end end))
track(RunService.RenderStepped:Connect(function(dt)
    fovCircle.Visible=aim.on and aim.showfov
    if fovCircle.Visible then fovCircle.Size=UDim2.fromOffset(aim.fov*2,aim.fov*2) local ml=UIS:GetMouseLocation() fovCircle.Position=UDim2.fromOffset(ml.X,ml.Y) end
    if aim.on and (aiming or not aim.hold) then
        if not (aim.sticky and curT and vT(curT)) then curT=pick() end
        local part=curT and vT(curT)
        if part then local cam=Workspace.CurrentCamera
            cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,part.Position), math.clamp((1/aim.smooth)*(dt*60),0,1))
        else curT=nil end
    else curT=nil end
end))

-- ================= COLUMN 2: MOVEMENT + COMBAT =================
local c2=newCol()
local mvc=card(c2,"Movement")
local flySpeed,flying,flyBV,flyBG=50,false,nil,nil
local function stopFly() flying=false if flyBV then flyBV:Destroy() flyBV=nil end if flyBG then flyBG:Destroy() flyBG=nil end local _,h=getHRP() if h then h.PlatformStand=false end local hrp=getHRP() if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end end
local function startFly() local hrp,h=getHRP() if not hrp then return end flying=true if h then h.PlatformStand=true end flyBV=make("BodyVelocity",{Velocity=Vector3.zero,MaxForce=Vector3.one*9e9,P=1250},hrp) flyBG=make("BodyGyro",{MaxTorque=Vector3.one*9e9,P=1000,CFrame=hrp.CFrame},hrp) end
pill(mvc,"Fly",false,function(v) if v then startFly() else stopFly() end end)
track(RunService.RenderStepped:Connect(function()
    if flying and flyBV and flyBV.Parent and flyBG and flyBG.Parent then
        local cam=Workspace.CurrentCamera local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d-=Vector3.new(0,1,0) end
        if d.Magnitude>0 then d=d.Unit end
        flyBV.Velocity=d*flySpeed; flyBG.CFrame=cam.CFrame
    elseif flying then startFly() end
end))
local noclip=false
pill(mvc,"Noclip",false,function(v) noclip=v end)
track(RunService.Stepped:Connect(function() if noclip and LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end end))
local infJump=false
pill(mvc,"Infinite jump",false,function(v) infJump=v end)
track(UIS.JumpRequest:Connect(function() if infJump then local _,h=getHRP() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))
local platOn,platBV=false,nil
local function newPlatBV(hrp) return make("BodyVelocity",{Velocity=Vector3.zero,MaxForce=Vector3.one*9e9,P=1250},hrp) end
pill(mvc,"Platform float (E/Q)",false,function(v)
    if v then local hrp=getHRP() if not hrp then return end platOn=true platBV=newPlatBV(hrp)
    else platOn=false if platBV then platBV:Destroy() platBV=nil end local hrp=getHRP() if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end end
end)
track(RunService.RenderStepped:Connect(function()
    if not platOn then return end
    local hrp,h=getHRP() if not hrp then return end
    if not (platBV and platBV.Parent) then platBV=newPlatBV(hrp) end
    local sp=(h and h.WalkSpeed) or 16
    local cam=Workspace.CurrentCamera
    local look=cam.CFrame.LookVector look=Vector3.new(look.X,0,look.Z) if look.Magnitude>0 then look=look.Unit end
    local right=cam.CFrame.RightVector right=Vector3.new(right.X,0,right.Z) if right.Magnitude>0 then right=right.Unit end
    local mv=Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then mv+=look end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv-=look end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv-=right end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv+=right end
    if mv.Magnitude>0 then mv=mv.Unit*sp end
    local vy=0 if UIS:IsKeyDown(Enum.KeyCode.E) then vy=sp end if UIS:IsKeyDown(Enum.KeyCode.Q) then vy=-sp end
    platBV.Velocity=Vector3.new(mv.X,vy,mv.Z)
end))
sldr(mvc,"Fly speed",10,300,50,function(v) flySpeed=v end)
sldr(mvc,"Walk speed",16,350,16,function(v) local _,h=getHRP() if h then h.WalkSpeed=v end end)
sldr(mvc,"Jump power",50,500,50,function(v) local _,h=getHRP() if h then h.UseJumpPower=true; h.JumpPower=v end end)
local cbt=card(c2,"Combat")
local antiFling=false
pill(cbt,"Anti-fling",false,function(v) antiFling=v end)
track(RunService.Stepped:Connect(function() if antiFling then local hrp=getHRP() if hrp then hrp.AssemblyAngularVelocity=Vector3.zero if hrp.AssemblyLinearVelocity.Magnitude>180 then hrp.AssemblyLinearVelocity=Vector3.zero end end end end))
local spin=false
pill(cbt,"Fling (spin)",false,function(v) spin=v end)
track(RunService.Heartbeat:Connect(function() if spin then local hrp=getHRP() if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(40),0) end end end))
local antiafkConn=nil
pill(cbt,"Anti-AFK",false,function(v)
    if v then local vu=game:GetService("VirtualUser") antiafkConn=track(LP.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end))
    elseif antiafkConn then antiafkConn:Disconnect() antiafkConn=nil end
end)
local wcd=card(c2,"World")
local frozenParts={}
local function isTowerPart(p) return p:IsA("BasePart") and (p.Name=="JengaPart" or p:FindFirstAncestor("Tower")~=nil) end
pill(wcd,"Freeze All (Tower/Jenga)",false,function(v)
    if v then
        frozenParts={}
        for _,p in ipairs(Workspace:GetDescendants()) do
            if not p.Anchored and isTowerPart(p) then p.Anchored=true table.insert(frozenParts,p) end
        end
    else
        for _,p in ipairs(frozenParts) do if p and p.Parent then p.Anchored=false end end
        frozenParts={}
    end
end)

-- ================= COLUMN 3: VISUALS + TOOLS =================
local c3=newCol()
local visc=card(c3,"Visuals")
local ESP={on=false, box=true, name=true, tracer=false, hp=true, team=false, maxd=1000}
local espF=make("Folder",{Name="__ESP"},parentGui) STATE.esp=espF
local espO={}
local function mkESP(plr)
    local o={}
    o.hl=make("Highlight",{FillTransparency=0.75, OutlineColor=Color3.fromRGB(120,180,255), FillColor=Color3.fromRGB(90,140,255), Enabled=false},espF)
    o.bb=make("BillboardGui",{Size=UDim2.fromOffset(120,34), StudsOffset=Vector3.new(0,2.6,0), AlwaysOnTop=true, Enabled=false},espF)
    o.nm=make("TextLabel",{Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=13, TextColor3=WHITE, TextStrokeTransparency=0.35},o.bb)
    o.hpbg=make("Frame",{Size=UDim2.new(0,80,0,4), Position=UDim2.new(0.5,-40,0,18), BackgroundColor3=Color3.fromRGB(0,0,0), BorderSizePixel=0},o.bb)
    make("UICorner",{CornerRadius=UDim.new(1,0)},o.hpbg)
    o.hpf=make("Frame",{Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(80,220,90), BorderSizePixel=0},o.hpbg)
    make("UICorner",{CornerRadius=UDim.new(1,0)},o.hpf)
    if Drawing then o.tr=Drawing.new("Line") o.tr.Thickness=1 o.tr.Color=Color3.fromRGB(120,180,255) o.tr.Visible=false table.insert(STATE.draw,o.tr) end
    espO[plr]=o return o
end
pill(visc,"ESP enabled",false,function(v) ESP.on=v end)
pill(visc,"Boxes",true,function(v) ESP.box=v end)
pill(visc,"Names + distance",true,function(v) ESP.name=v end)
pill(visc,"Tracers",false,function(v) ESP.tracer=v end)
pill(visc,"Health bars",true,function(v) ESP.hp=v end)
pill(visc,"Team check",false,function(v) ESP.team=v end)
sldr(visc,"ESP max distance",100,5000,1000,function(v) ESP.maxd=v end)
local fbSaved=nil
pill(visc,"Fullbright",false,function(v)
    if v then fbSaved={Lighting.Brightness,Lighting.ClockTime,Lighting.Ambient,Lighting.OutdoorAmbient}
        Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.Ambient=Color3.fromRGB(180,180,180) Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
    elseif fbSaved then Lighting.Brightness,Lighting.ClockTime,Lighting.Ambient,Lighting.OutdoorAmbient=fbSaved[1],fbSaved[2],fbSaved[3],fbSaved[4] end
end)
local fogSaved=nil
pill(visc,"No fog",false,function(v)
    if v then fogSaved={Lighting.FogEnd,Lighting.FogStart} Lighting.FogEnd=1e6 Lighting.FogStart=1e6
    elseif fogSaved then Lighting.FogEnd,Lighting.FogStart=fogSaved[1],fogSaved[2] end
end)
local crossOn=false
pill(visc,"Crosshair",false,function(v) crossOn=v cross.Visible=v end)
track(RunService.RenderStepped:Connect(function()
    local cam=Workspace.CurrentCamera
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local o=espO[plr] or mkESP(plr)
            local ch=plr.Character
            local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            local hum=ch and ch:FindFirstChildOfClass("Humanoid")
            local dist=hrp and (cam.CFrame.Position-hrp.Position).Magnitude or 1e9
            local show=ESP.on and hrp and hum and hum.Health>0 and dist<=ESP.maxd and not (ESP.team and plr.Team==LP.Team)
            if show then
                o.hl.Adornee=ESP.box and ch or nil o.hl.Enabled=ESP.box
                local head=ch:FindFirstChild("Head") or hrp
                o.bb.Adornee=(ESP.name or ESP.hp) and head or nil o.bb.Enabled=(ESP.name or ESP.hp)
                o.nm.Visible=ESP.name
                if ESP.name then o.nm.Text=plr.Name.."  ["..math.floor(dist).."]" end
                o.hpbg.Visible=ESP.hp
                if ESP.hp then local r=math.clamp(hum.Health/hum.MaxHealth,0,1) o.hpf.Size=UDim2.fromScale(r,1) o.hpf.BackgroundColor3=Color3.fromRGB(math.floor(220*(1-r)),math.floor(200*r+40),70) end
                if o.tr then if ESP.tracer then local sp,on=cam:WorldToViewportPoint(hrp.Position) if on then o.tr.Visible=true o.tr.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y) o.tr.To=Vector2.new(sp.X,sp.Y) else o.tr.Visible=false end else o.tr.Visible=false end end
            else o.hl.Enabled=false o.bb.Enabled=false if o.tr then o.tr.Visible=false end end
        end
    end
end))
track(Players.PlayerRemoving:Connect(function(plr) local o=espO[plr] if o then pcall(function() o.hl:Destroy() end) pcall(function() o.bb:Destroy() end) if o.tr then pcall(function() o.tr:Remove() end) end espO[plr]=nil end end))
local tlc=card(c3,"Tools")
listbtn(tlc,"Infinite Yield",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
listbtn(tlc,"Dex Explorer",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
listbtn(tlc,"Simple Spy",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() end)
listbtn(tlc,"Hydroxide",function()
    local u="https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/"
    local function imp(p) return loadstring(game:HttpGet(u..p..".lua"),p..".lua")() end
    imp("init") imp("ui/main")
end)

-- ================= COLUMN 4: PLAYERS + UTILITY =================
local c4=newCol()
local plc=card(c4,"Players")
local listF=make("Frame",{Size=UDim2.new(1,0,0,168), BackgroundColor3=PANEL, BorderSizePixel=0},plc)
make("UICorner",{CornerRadius=UDim.new(0,7)},listF)
local listS=make("ScrollingFrame",{Size=UDim2.new(1,-6,1,-6), Position=UDim2.fromOffset(3,3), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarImageColor3=ROW},listF)
make("UIListLayout",{Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.Name},listS)
local function refreshP()
    for _,c in ipairs(listS:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then
        local r=make("TextButton",{Name=plr.Name, Size=UDim2.new(1,0,0,26), BackgroundColor3=ROW, Text="  "..plr.DisplayName, TextColor3=TXT, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=true},listS)
        make("UICorner",{CornerRadius=UDim.new(0,6)},r)
        r.MouseButton1Click:Connect(function() local hrp=getHRP() local t=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") if hrp and t then hrp.CFrame=t.CFrame+Vector3.new(0,3,0) end end)
    end end
end
listbtn(plc,"Refresh players",refreshP)
refreshP()
track(Players.PlayerAdded:Connect(refreshP))
track(Players.PlayerRemoving:Connect(function() task.defer(refreshP) end))
local specOn,specIdx=false,1
local specBtn
pill(plc,"Spectate",false,function(v)
    specOn=v local cam=Workspace.CurrentCamera
    if not v then local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then cam.CameraSubject=h end end
end)
local function applySpec()
    local others={} for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(others,p) end end
    if #others==0 then return end
    specIdx=((specIdx-1)%#others)+1
    local p=others[specIdx]
    local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if h then Workspace.CurrentCamera.CameraSubject=h end
    if specBtn then specBtn.Text="  Next › "..p.Name end
end
specBtn=listbtn(plc,"Next player",function() if specOn then specIdx=specIdx+1 applySpec() end end)
local utl=card(c4,"Utility")
local savedPos=nil
listbtn(utl,"Save position",function() local hrp=getHRP() if hrp then savedPos=hrp.CFrame end end)
listbtn(utl,"Load position",function() local hrp=getHRP() if hrp and savedPos then hrp.CFrame=savedPos end end)
listbtn(utl,"Teleport to Spawn",function() local hrp=getHRP() local s=Workspace:FindFirstChildWhichIsA("SpawnLocation",true) if hrp and s then hrp.CFrame=s.CFrame+Vector3.new(0,4,0) end end)
listbtn(utl,"Reset Character",function() local _,h=getHRP() if h then h.Health=0 end end)
listbtn(utl,"Server Hop",function()
    local ok,body=pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") end)
    if not ok then return end
    local ok2,data=pcall(function() return HttpService:JSONDecode(body) end)
    if not ok2 or not data.data then return end
    for _,s in ipairs(data.data) do
        if s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers then
            pcall(function() TP:TeleportToPlaceInstance(game.PlaceId, s.id, LP) end) return
        end
    end
end)
listbtn(utl,"Copy Job ID",function() local f=(setclipboard or toclipboard or (syn and syn.write_clipboard)) if f then pcall(f, game.JobId) end end)
listbtn(utl,"Rejoin Server",function() TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)

track(LP.CharacterAdded:Connect(function() flying=false flyBV=nil flyBG=nil platOn=false platBV=nil end))
print("[Panel] HYPERION loaded (expanded)")
