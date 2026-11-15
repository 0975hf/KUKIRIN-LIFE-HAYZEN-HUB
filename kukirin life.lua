--[[
    ╔═══════════════════════════════════════════╗
    ║   absolute ollie — kukirin life           ║
    ║   built by olivia                         ║
    ║   discord: .gg/Kc9Ecy7uyR                ║
    ╚═══════════════════════════════════════════╝
]]

pcall(function() getgenv().__ollie_kl=true end)

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local SG=game:GetService("StarterGui")
local Camera=workspace.CurrentCamera
local LP=Players.LocalPlayer

if not LP.Character then LP.CharacterAdded:Wait() end

----------------------------------------------------------------
-- RAYFIELD UI
----------------------------------------------------------------
local Rayfield=loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local S={
    -- scooter
    AutoWheelie=false,WheelieAngle=35,
    ScooterSpeed=false,ScooterSpeedMult=2,
    AntiRagdoll=false,
    AutoBunnyHop=false,BunnyHopDelay=0.2,
    LowGravity=false,GravityMult=0.5,

    -- movement
    Speed=false,SpeedMult=2,
    InfJump=false,
    Fly=false,FlySpeed=50,
    Noclip=false,

    -- tricks
    AirSpin=false,AirSpinHeight=20,AirSpinSpeed=15,

    -- cop esp
    CopESP=false,CopCarESP=false,
    CopColor=Color3.fromRGB(255,60,60),
    CarColor=Color3.fromRGB(60,120,255),

    -- visuals
    Fullbright=false,
    Spinbot=false,SpinSpeed=10,
    Freecam=false,FreecamSpeed=1,

    -- misc
    AntiAFK=true,
}

local origGravity=workspace.Gravity

----------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------
local function alive(p)
    local c=p and p.Character
    if not c then return nil end
    local h=c:FindFirstChildOfClass("Humanoid")
    local r=c:FindFirstChild("HumanoidRootPart")
    if h and h.Health>0 and r then return c,h,r end
    return nil
end

local function ally(p)
    if not S.TeamCheck then return false end
    return p.Team and LP.Team and p.Team==LP.Team
end

local function w2s(pos)
    local v,vis=Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X,v.Y),vis
end

-- held keys for fly / freecam
local heldKeys={}
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    heldKeys[inp.KeyCode]=true
end)
UIS.InputEnded:Connect(function(inp)
    heldKeys[inp.KeyCode]=false
end)
local function keyDown(k) return heldKeys[k]==true end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
local Window=Rayfield:CreateWindow({
    Name="Kukirin Life | .gg/Kc9Ecy7uyR",
    Icon=0,
    LoadingTitle="ollie",
    LoadingSubtitle="built by olivia",
    Theme="Custom",
    CustomTheme={
        TextFont="GothamBold",
        TextColor=Color3.fromRGB(240,240,255),
        Background=Color3.fromRGB(15,10,25),
        Topbar=Color3.fromRGB(20,14,35),
        Shadow=Color3.fromRGB(10,6,18),
        NotificationBackground=Color3.fromRGB(25,18,40),
        NotificationActionsBackground=Color3.fromRGB(200,180,255),
        TabBackground=Color3.fromRGB(25,18,42),
        TabStroke=Color3.fromRGB(60,40,100),
        TabBackgroundSelected=Color3.fromRGB(50,30,85),
        TabTextColor=Color3.fromRGB(200,180,255),
        SelectedTabTextColor=Color3.fromRGB(255,255,255),
        ElementBackground=Color3.fromRGB(30,22,50),
        ElementBackgroundHover=Color3.fromRGB(40,28,65),
        SecondaryElementBackground=Color3.fromRGB(35,25,55),
        ElementStroke=Color3.fromRGB(60,40,100),
        SecondaryElementStroke=Color3.fromRGB(50,35,85),
        SliderBackground=Color3.fromRGB(120,60,200),
        SliderProgress=Color3.fromRGB(170,85,255),
        SliderStroke=Color3.fromRGB(100,50,180),
        ToggleBackground=Color3.fromRGB(35,25,55),
        ToggleEnabled=Color3.fromRGB(170,85,255),
        ToggleDisabled=Color3.fromRGB(60,40,100),
        ToggleEnabledStroke=Color3.fromRGB(130,65,200),
        ToggleDisabledStroke=Color3.fromRGB(50,35,80),
        ToggleEnabledOuterStroke=Color3.fromRGB(100,50,170),
        ToggleDisabledOuterStroke=Color3.fromRGB(45,30,70),
        InputBackground=Color3.fromRGB(25,18,40),
        InputStroke=Color3.fromRGB(60,40,100),
        PlaceholderColor=Color3.fromRGB(140,120,180)
    }
})

-- gradient wallpaper injection
pcall(function()
    task.delay(2,function()
        local gui=LP:FindFirstChild("PlayerGui") or (gethui and gethui())
        if not gui then return end
        for _,d in ipairs(gui:GetDescendants()) do
            if d:IsA("Frame") and d.BackgroundColor3==Color3.fromRGB(15,10,25) and d.AbsoluteSize.X>200 then
                pcall(function()
                    local g=Instance.new("UIGradient")
                    g.Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,Color3.fromRGB(30,12,55)),
                        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(12,5,25)),
                        ColorSequenceKeypoint.new(1,Color3.fromRGB(30,12,55))
                    })
                    g.Rotation=45;g.Parent=d
                end)
                break
            end
        end
    end)
end)

----------------------------------------------------------------
-- SCOOTER TAB
----------------------------------------------------------------
local ST=Window:CreateTab("Scooter",4483362458)

ST:CreateSection("Wheelie")
ST:CreateToggle({Name="Auto Wheelie",CurrentValue=false,Flag="awh",Callback=function(v) S.AutoWheelie=v end})
ST:CreateSlider({Name="Wheelie Angle",Range={10,60},Increment=5,Suffix="°",CurrentValue=35,Flag="whang",Callback=function(v) S.WheelieAngle=v end})

ST:CreateSection("Speed")
ST:CreateToggle({Name="Scooter Speed Mod",CurrentValue=false,Flag="ssp",Callback=function(v) S.ScooterSpeed=v end})
ST:CreateSlider({Name="Speed Multiplier",Range={1,10},Increment=0.5,Suffix="x",CurrentValue=2,Flag="sspm",Callback=function(v) S.ScooterSpeedMult=v end})

ST:CreateSection("Tricks")
ST:CreateToggle({Name="Air Spin",CurrentValue=false,Flag="aspin",Callback=function(v) S.AirSpin=v end})
ST:CreateSlider({Name="Spin Height",Range={5,50},Increment=5,Suffix="studs",CurrentValue=20,Flag="asph",Callback=function(v) S.AirSpinHeight=v end})
ST:CreateSlider({Name="Spin Speed",Range={5,40},Increment=1,Suffix="",CurrentValue=15,Flag="asps",Callback=function(v) S.AirSpinSpeed=v end})

ST:CreateSection("Physics")
ST:CreateToggle({Name="Anti Ragdoll",CurrentValue=false,Flag="arag",Callback=function(v) S.AntiRagdoll=v end})
ST:CreateToggle({Name="Auto Bunny Hop",CurrentValue=false,Flag="abh",Callback=function(v) S.AutoBunnyHop=v end})
ST:CreateSlider({Name="Hop Delay",Range={0.05,0.5},Increment=0.05,Suffix="s",CurrentValue=0.2,Flag="bhd",Callback=function(v) S.BunnyHopDelay=v end})
ST:CreateToggle({Name="Low Gravity",CurrentValue=false,Flag="lgrav",Callback=function(v)
    S.LowGravity=v
    workspace.Gravity=v and (origGravity*S.GravityMult) or origGravity
end})
ST:CreateSlider({Name="Gravity %",Range={10,100},Increment=5,Suffix="%",CurrentValue=50,Flag="gravp",Callback=function(v)
    S.GravityMult=v/100
    if S.LowGravity then workspace.Gravity=origGravity*S.GravityMult end
end})

----------------------------------------------------------------
-- SCOOTER LOGIC
----------------------------------------------------------------

-- wheelie via BodyGyro
local wheelieGyro=nil
local function updateWheelie()
    local c,h,r=alive(LP)
    if S.AutoWheelie and c and r then
        if not wheelieGyro or not wheelieGyro.Parent then
            wheelieGyro=Instance.new("BodyGyro")
            wheelieGyro.MaxTorque=Vector3.new(40000,0,40000)
            wheelieGyro.P=10000;wheelieGyro.D=500
            wheelieGyro.Parent=r
        end
        local look=r.CFrame.LookVector
        local flat=Vector3.new(look.X,0,look.Z)
        if flat.Magnitude>0.01 then flat=flat.Unit else flat=Vector3.new(0,0,-1) end
        wheelieGyro.CFrame=CFrame.lookAt(Vector3.zero,flat)*CFrame.Angles(math.rad(S.WheelieAngle),0,0)
    else
        if wheelieGyro then pcall(function() wheelieGyro:Destroy() end);wheelieGyro=nil end
    end
end

-- speed mod via WalkSpeed + velocity push (safe, won't break scooter)
local origWS=nil
local function applyScooterSpeed()
    if not S.ScooterSpeed then
        -- restore original WalkSpeed
        if origWS then
            pcall(function()
                local c,h,r=alive(LP);if h then h.WalkSpeed=origWS end
            end)
            origWS=nil
        end
        return
    end
    local c,h,r=alive(LP);if not h or not r then return end
    -- save original WalkSpeed once
    if not origWS then origWS=h.WalkSpeed end
    -- set boosted WalkSpeed
    h.WalkSpeed=origWS*S.ScooterSpeedMult
    -- velocity push for extra speed on top (kicks in when moving)
    if h.MoveDirection.Magnitude>0.1 then
        local push=h.MoveDirection.Unit*(S.ScooterSpeedMult-1)*0.6
        r.CFrame=r.CFrame+push
    end
end

-- anti ragdoll
local function antiRagdoll()
    if not S.AntiRagdoll then return end
    local c,h,r=alive(LP);if not h then return end
    pcall(function()
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        h:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
        if h:GetState()==Enum.HumanoidStateType.FallingDown or h:GetState()==Enum.HumanoidStateType.Ragdoll then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- bunny hop
local lastHop=0
local function bunnyHop()
    if not S.AutoBunnyHop or tick()-lastHop<S.BunnyHopDelay then return end
    local c,h,r=alive(LP);if not h then return end
    if h.FloorMaterial~=Enum.Material.Air then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
        lastHop=tick()
    end
end

-- air spin (lifts you up + spins)
local airSpinBP,airSpinBG=nil,nil
local airSpinAngle=0
local airSpinGroundY=nil
local function updateAirSpin(dt)
    local c,h,r=alive(LP)
    if S.AirSpin and c and r then
        -- record ground height on first enable
        if not airSpinGroundY then airSpinGroundY=r.Position.Y end

        -- BodyPosition holds you in the air
        if not airSpinBP or not airSpinBP.Parent then
            airSpinBP=Instance.new("BodyPosition")
            airSpinBP.MaxForce=Vector3.new(0,1e5,0)
            airSpinBP.D=500;airSpinBP.P=5000
            airSpinBP.Parent=r
        end
        airSpinBP.Position=Vector3.new(r.Position.X,airSpinGroundY+S.AirSpinHeight,r.Position.Z)

        -- spin via CFrame rotation
        airSpinAngle=airSpinAngle+S.AirSpinSpeed*dt*60
        if airSpinAngle>360 then airSpinAngle=airSpinAngle-360 end
        local pos=r.CFrame.Position
        r.CFrame=CFrame.new(pos)*CFrame.Angles(0,math.rad(airSpinAngle),0)
    else
        if airSpinBP then pcall(function() airSpinBP:Destroy() end);airSpinBP=nil end
        airSpinGroundY=nil;airSpinAngle=0
    end
end

----------------------------------------------------------------
-- MOVEMENT TAB
----------------------------------------------------------------
local MT=Window:CreateTab("Movement",4483362458)
MT:CreateSection("Speed")
MT:CreateToggle({Name="CFrame Speed Boost",CurrentValue=false,Flag="spd",Callback=function(v) S.Speed=v end})
MT:CreateSlider({Name="Speed Multiplier",Range={1,10},Increment=0.5,Suffix="x",CurrentValue=2,Flag="spdm",Callback=function(v) S.SpeedMult=v end})

MT:CreateSection("Jump")
MT:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="ij",Callback=function(v) S.InfJump=v end})

MT:CreateSection("Fly")
MT:CreateToggle({Name="Fly (WASD + Space/Shift)",CurrentValue=false,Flag="fly",Callback=function(v) S.Fly=v end})
MT:CreateSlider({Name="Fly Speed",Range={10,200},Increment=5,Suffix="",CurrentValue=50,Flag="flysp",Callback=function(v) S.FlySpeed=v end})

MT:CreateSection("Other")
MT:CreateToggle({Name="Noclip",CurrentValue=false,Flag="nc",Callback=function(v) S.Noclip=v end})

-- CFrame speed
local function cframeSpeed(dt)
    if not S.Speed then return end
    local c,h,r=alive(LP);if not r then return end
    local mv=h.MoveDirection
    if mv.Magnitude<0.01 then return end
    r.CFrame=r.CFrame+mv*S.SpeedMult*dt*60
end

-- infinite jump
UIS.JumpRequest:Connect(function()
    if not S.InfJump then return end
    local c,h=alive(LP);if not h then return end
    pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
end)

-- fly
local flyBV,flyBG=nil,nil
local function updateFly()
    local c,h,r=alive(LP)
    if S.Fly and c and r then
        if not flyBV or not flyBV.Parent then
            flyBV=Instance.new("BodyVelocity");flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
            flyBV.Velocity=Vector3.zero;flyBV.Parent=r
            flyBG=Instance.new("BodyGyro");flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
            flyBG.D=200;flyBG.P=10000;flyBG.Parent=r
        end
        local dir=Vector3.zero
        local cf=Camera.CFrame
        if keyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
        if keyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
        if keyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
        if keyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
        if keyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if keyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        flyBV.Velocity=dir.Magnitude>0 and dir.Unit*S.FlySpeed or Vector3.zero
        flyBG.CFrame=cf
    else
        if flyBV then pcall(function() flyBV:Destroy() end);flyBV=nil end
        if flyBG then pcall(function() flyBG:Destroy() end);flyBG=nil end
    end
end

-- noclip
local function noclip()
    if not S.Noclip then return end
    local c=LP.Character;if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end

----------------------------------------------------------------
-- ESP TAB (Cops + Cop Cars)
----------------------------------------------------------------
local ET=Window:CreateTab("ESP",4483362458)

ET:CreateSection("Cop ESP")
ET:CreateToggle({Name="Cop ESP",CurrentValue=false,Flag="cesp",Callback=function(v) S.CopESP=v end})
ET:CreateColorPicker({Name="Cop Color",Color=Color3.fromRGB(255,60,60),Flag="ccol",Callback=function(v) S.CopColor=v end})

ET:CreateSection("Cop Car ESP")
ET:CreateToggle({Name="Cop Car ESP",CurrentValue=false,Flag="caresp",Callback=function(v) S.CopCarESP=v end})
ET:CreateColorPicker({Name="Car Color",Color=Color3.fromRGB(60,120,255),Flag="carcol",Callback=function(v) S.CarColor=v end})

-- cop / car name detection
local COP_PATTERNS={"cop","police","officer","sheriff","patrol","deputy","swat","security","guard"}
local CAR_PATTERNS={"cop","police","cruiser","patrol","squad","interceptor","sheriff","swat"}

local function isCopName(name)
    local n=name:lower()
    for _,p in ipairs(COP_PATTERNS) do if n:find(p,1,true) then return true end end
    return false
end
local function isCopCarName(name)
    local n=name:lower()
    for _,p in ipairs(CAR_PATTERNS) do if n:find(p,1,true) then return true end end
    return false
end

-- cop ESP cache (NPC + player cops)
local copCache={}
local function cleanCop(obj)
    local e=copCache[obj];if not e then return end
    pcall(function() if e.hl then e.hl:Destroy() end end)
    pcall(function() if e.bb then e.bb:Destroy() end end)
    copCache[obj]=nil
end

local function applyCopESP(model,label)
    if not copCache[model] then copCache[model]={hl=nil,bb=nil,nl=nil,dl=nil} end
    local e=copCache[model]

    -- highlight
    if not e.hl or not e.hl.Parent then
        e.hl=Instance.new("Highlight")
        e.hl.FillColor=S.CopColor;e.hl.FillTransparency=0.4
        e.hl.OutlineColor=S.CopColor;e.hl.OutlineTransparency=0
        e.hl.Adornee=model;e.hl.Parent=model
    end
    e.hl.FillColor=S.CopColor;e.hl.OutlineColor=S.CopColor

    -- billboard
    local head=model:FindFirstChild("Head") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if head then
        if not e.bb or not e.bb.Parent then
            e.bb=Instance.new("BillboardGui")
            e.bb.Size=UDim2.new(0,200,0,50)
            e.bb.StudsOffset=Vector3.new(0,3,0)
            e.bb.AlwaysOnTop=true;e.bb.Adornee=head;e.bb.Parent=head

            e.nl=Instance.new("TextLabel");e.nl.Size=UDim2.new(1,0,0.5,0)
            e.nl.Position=UDim2.new(0,0,0,0);e.nl.BackgroundTransparency=1
            e.nl.TextColor3=S.CopColor;e.nl.TextStrokeTransparency=0.3
            e.nl.Font=Enum.Font.GothamBold;e.nl.TextScaled=true;e.nl.Parent=e.bb

            e.dl=Instance.new("TextLabel");e.dl.Size=UDim2.new(1,0,0.5,0)
            e.dl.Position=UDim2.new(0,0,0.5,0);e.dl.BackgroundTransparency=1
            e.dl.TextColor3=Color3.fromRGB(200,200,200);e.dl.TextStrokeTransparency=0.3
            e.dl.Font=Enum.Font.Gotham;e.dl.TextScaled=true;e.dl.Parent=e.bb
        end
        e.nl.TextColor3=S.CopColor
        e.nl.Text=label

        local mc,mh,mr=alive(LP)
        local refPart=model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or head
        if mc and mr and refPart then
            e.dl.Text="["..math.floor((refPart.Position-mr.Position).Magnitude).."m]"
        end
    end
end

-- cop car ESP cache
local carCache={}
local function cleanCar(obj)
    local e=carCache[obj];if not e then return end
    pcall(function() if e.hl then e.hl:Destroy() end end)
    pcall(function() if e.bb then e.bb:Destroy() end end)
    carCache[obj]=nil
end

local function applyCarESP(model)
    if not carCache[model] then carCache[model]={hl=nil,bb=nil,nl=nil,dl=nil} end
    local e=carCache[model]

    if not e.hl or not e.hl.Parent then
        e.hl=Instance.new("Highlight")
        e.hl.FillColor=S.CarColor;e.hl.FillTransparency=0.4
        e.hl.OutlineColor=S.CarColor;e.hl.OutlineTransparency=0
        e.hl.Adornee=model;e.hl.Parent=model
    end
    e.hl.FillColor=S.CarColor;e.hl.OutlineColor=S.CarColor

    local refPart=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if refPart then
        if not e.bb or not e.bb.Parent then
            e.bb=Instance.new("BillboardGui")
            e.bb.Size=UDim2.new(0,200,0,50)
            e.bb.StudsOffset=Vector3.new(0,5,0)
            e.bb.AlwaysOnTop=true;e.bb.Adornee=refPart;e.bb.Parent=refPart

            e.nl=Instance.new("TextLabel");e.nl.Size=UDim2.new(1,0,0.5,0)
            e.nl.Position=UDim2.new(0,0,0,0);e.nl.BackgroundTransparency=1
            e.nl.TextColor3=S.CarColor;e.nl.TextStrokeTransparency=0.3
            e.nl.Font=Enum.Font.GothamBold;e.nl.TextScaled=true;e.nl.Parent=e.bb

            e.dl=Instance.new("TextLabel");e.dl.Size=UDim2.new(1,0,0.5,0)
            e.dl.Position=UDim2.new(0,0,0.5,0);e.dl.BackgroundTransparency=1
            e.dl.TextColor3=Color3.fromRGB(200,200,200);e.dl.TextStrokeTransparency=0.3
            e.dl.Font=Enum.Font.Gotham;e.dl.TextScaled=true;e.dl.Parent=e.bb
        end
        e.nl.TextColor3=S.CarColor
        e.nl.Text="COP CAR"

        local mc,mh,mr=alive(LP)
        if mc and mr then
            e.dl.Text="["..math.floor((refPart.Position-mr.Position).Magnitude).."m]"
        end
    end
end

-- main ESP update
local lastESPScan=0
local copModels,carModels={},{}

local function scanForCopsAndCars()
    copModels={};carModels={}
    -- scan players on cop/police teams
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local isCop=false
        if p.Team and isCopName(p.Team.Name) then isCop=true end
        if isCop then
            local c=p.Character;if c then table.insert(copModels,{model=c,label="COP: "..p.DisplayName}) end
        end
    end
    -- scan workspace for NPC cops and cop cars
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            -- cop NPC: has Humanoid + cop-like name
            if isCopName(obj.Name) and obj:FindFirstChildOfClass("Humanoid") then
                -- make sure it's not a player character
                local isPlayer=false
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Character==obj then isPlayer=true;break end
                end
                if not isPlayer then
                    table.insert(copModels,{model=obj,label="COP: "..obj.Name})
                end
            end
            -- cop car: cop-like name + has VehicleSeat or big model, no Humanoid
            if isCopCarName(obj.Name) and not obj:FindFirstChildOfClass("Humanoid") then
                local hasSeat=obj:FindFirstChildWhichIsA("VehicleSeat") or obj:FindFirstChildWhichIsA("Seat")
                local hasParts=false
                for _,d in ipairs(obj:GetChildren()) do
                    if d:IsA("BasePart") then hasParts=true;break end
                end
                if hasSeat or hasParts then
                    table.insert(carModels,obj)
                end
            end
        end
    end
end

local function updateESP()
    -- rescan every 2 seconds
    if tick()-lastESPScan>2 then scanForCopsAndCars();lastESPScan=tick() end

    -- cop ESP
    if S.CopESP then
        local activeModels={}
        for _,entry in ipairs(copModels) do
            if entry.model and entry.model.Parent then
                activeModels[entry.model]=true
                applyCopESP(entry.model,entry.label)
            end
        end
        -- clean removed cops
        for obj,_ in pairs(copCache) do
            if not activeModels[obj] then cleanCop(obj) end
        end
    else
        for obj,_ in pairs(copCache) do cleanCop(obj) end
    end

    -- cop car ESP
    if S.CopCarESP then
        local activeCars={}
        for _,model in ipairs(carModels) do
            if model and model.Parent then
                activeCars[model]=true
                applyCarESP(model)
            end
        end
        for obj,_ in pairs(carCache) do
            if not activeCars[obj] then cleanCar(obj) end
        end
    else
        for obj,_ in pairs(carCache) do cleanCar(obj) end
    end
end

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
local TT=Window:CreateTab("Teleport",4483362458)
TT:CreateSection("Players")

local tpTarget=nil
local plrNames={}
local function refreshPlrList()
    plrNames={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then table.insert(plrNames,p.Name) end
    end
end
refreshPlrList()

TT:CreateDropdown({Name="Select Player",Options=plrNames,CurrentOption={""},Flag="tpt",Callback=function(v)
    tpTarget=type(v)=="table" and v[1] or v
end})

TT:CreateButton({Name="Teleport to Player",Callback=function()
    if not tpTarget then Rayfield:Notify({Title="Error",Content="Select a player first",Duration=2});return end
    local tp=Players:FindFirstChild(tpTarget)
    if not tp then Rayfield:Notify({Title="Error",Content="Player not found",Duration=2});return end
    local c,h,r=alive(tp);if not r then Rayfield:Notify({Title="Error",Content="Player is dead",Duration=2});return end
    local mc,mh,mr=alive(LP);if not mr then return end
    mr.CFrame=r.CFrame*CFrame.new(0,0,3)
    Rayfield:Notify({Title="Teleported",Content="Teleported to "..tpTarget,Duration=2})
end})

TT:CreateButton({Name="Refresh Player List",Callback=function()
    refreshPlrList()
    Rayfield:Notify({Title="Refreshed",Content=#plrNames.." players found",Duration=2})
end})

TT:CreateSection("Position")
local savedPos=nil
TT:CreateButton({Name="Save Position",Callback=function()
    local c,h,r=alive(LP);if not r then return end
    savedPos=r.CFrame
    Rayfield:Notify({Title="Saved",Content="Position saved",Duration=2})
end})
TT:CreateButton({Name="Load Position",Callback=function()
    if not savedPos then Rayfield:Notify({Title="Error",Content="No saved position",Duration=2});return end
    local c,h,r=alive(LP);if not r then return end
    r.CFrame=savedPos
    Rayfield:Notify({Title="Loaded",Content="Teleported to saved position",Duration=2})
end})

----------------------------------------------------------------
-- VISUALS TAB
----------------------------------------------------------------
local VT=Window:CreateTab("Visuals",4483362458)

VT:CreateSection("Lighting")
VT:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="fb",Callback=function(v)
    S.Fullbright=v
    if v then
        Lighting.Brightness=2;Lighting.ClockTime=14
        Lighting.FogEnd=1e6;Lighting.GlobalShadows=false
        for _,e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then e.Enabled=false end
        end
    else
        Lighting.Brightness=1;Lighting.ClockTime=14
        Lighting.FogEnd=1e4;Lighting.GlobalShadows=true
    end
end})

VT:CreateSection("Fun")
VT:CreateToggle({Name="Spinbot",CurrentValue=false,Flag="spin",Callback=function(v) S.Spinbot=v end})
VT:CreateSlider({Name="Spin Speed",Range={1,50},Increment=1,Suffix="",CurrentValue=10,Flag="spinsp",Callback=function(v) S.SpinSpeed=v end})

VT:CreateSection("Camera")
local freecamCF=Camera.CFrame
VT:CreateToggle({Name="Freecam (WASD + Space/Shift)",CurrentValue=false,Flag="fc",Callback=function(v)
    S.Freecam=v
    if v then
        freecamCF=Camera.CFrame
        Camera.CameraType=Enum.CameraType.Scriptable
    else
        Camera.CameraType=Enum.CameraType.Custom
    end
end})
VT:CreateSlider({Name="Freecam Speed",Range={0.5,5},Increment=0.5,Suffix="x",CurrentValue=1,Flag="fcsp",Callback=function(v) S.FreecamSpeed=v end})

----------------------------------------------------------------
-- MISC TAB
----------------------------------------------------------------
local MiT=Window:CreateTab("Misc",4483362458)

MiT:CreateSection("Anti")
MiT:CreateToggle({Name="Anti AFK",CurrentValue=true,Flag="aafk",Callback=function(v) S.AntiAFK=v end})

MiT:CreateSection("Performance")
MiT:CreateButton({Name="FPS Boost",Callback=function()
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Terrain") then
                v.WaterWaveSize=0;v.WaterWaveSpeed=0
                v.WaterReflectance=0;v.WaterTransparency=0
            end
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 end
            if v:IsA("MeshPart") or v:IsA("Part") then
                local plr=Players:GetPlayerFromCharacter(v.Parent) or Players:GetPlayerFromCharacter(v.Parent and v.Parent.Parent)
                if not plr then v.Material=Enum.Material.SmoothPlastic;v.Reflectance=0 end
            end
        end
    end)
    Rayfield:Notify({Title="FPS Boost",Content="Graphics lowered for performance",Duration=3})
end})

MiT:CreateSection("Server")
MiT:CreateParagraph({Title="Game",Content="Kukirin Life"})
MiT:CreateButton({Name="Rejoin Server",Callback=function()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)
    end)
end})
MiT:CreateButton({Name="Server Hop",Callback=function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
    end)
end})

MiT:CreateSection("Credits")
MiT:CreateParagraph({Title="ollie",Content="built by olivia\ndiscord: .gg/Kc9Ecy7uyR"})

----------------------------------------------------------------
-- ANTI-AFK
----------------------------------------------------------------
pcall(function()
    local vu=game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if S.AntiAFK then vu:CaptureController();vu:ClickButton2(Vector2.zero) end
    end)
end)

----------------------------------------------------------------
-- MAIN LOOPS
----------------------------------------------------------------

-- spinbot
local spinAngle=0
local function spinbot(dt)
    if not S.Spinbot then return end
    local c,h,r=alive(LP);if not r then return end
    spinAngle=spinAngle+S.SpinSpeed*dt*60
    if spinAngle>360 then spinAngle=spinAngle-360 end
    local p=r.CFrame.Position
    r.CFrame=CFrame.lookAt(p,p+CFrame.Angles(0,math.rad(spinAngle),0).LookVector)
end

-- freecam
local function freecamTick()
    if not S.Freecam or not freecamCF then return end
    local mv=Vector3.zero
    local cf=freecamCF
    local sp=S.FreecamSpeed*2
    if keyDown(Enum.KeyCode.W) then mv=mv+cf.LookVector*sp end
    if keyDown(Enum.KeyCode.S) then mv=mv-cf.LookVector*sp end
    if keyDown(Enum.KeyCode.A) then mv=mv-cf.RightVector*sp end
    if keyDown(Enum.KeyCode.D) then mv=mv+cf.RightVector*sp end
    if keyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,sp,0) end
    if keyDown(Enum.KeyCode.LeftShift) then mv=mv-Vector3.new(0,sp,0) end
    freecamCF=cf+mv;Camera.CFrame=freecamCF
end

-- RenderStep (camera priority)
RS:BindToRenderStep("OL_KL_Render",Enum.RenderPriority.Camera.Value+1,function(dt)
    if S.Freecam and freecamCF then
        freecamTick()
    end
end)

-- Heartbeat (physics + esp)
RS.Heartbeat:Connect(function(dt)
    -- scooter
    updateWheelie()
    updateAirSpin(dt)
    applyScooterSpeed()
    antiRagdoll()
    bunnyHop()

    -- movement
    cframeSpeed(dt)
    updateFly()
    noclip()

    -- visuals
    spinbot(dt)

    -- esp
    updateESP()
end)

-- respawn cleanup
LP.CharacterAdded:Connect(function(c)
    wheelieGyro=nil
    flyBV=nil;flyBG=nil
    origWS=nil
    airSpinBP=nil;airSpinGroundY=nil;airSpinAngle=0
    task.wait(0.5)
    if S.AntiRagdoll then
        local h=c:WaitForChild("Humanoid",5)
        if h then
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        end
    end
end)

----------------------------------------------------------------
-- LOADED
----------------------------------------------------------------
Rayfield:Notify({Title="ollie loaded",Content="kukirin life — built by olivia",Duration=5})
