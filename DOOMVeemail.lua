--[=[
VeeMail DOOM — ULTIMATE V2
• ИСПРАВЛЕНО: 6 уникальных текстур оружий (пиксель-арт)
• ИСПРАВЛЕНО: хитбоксы врагов (больше угол + ray trace check)
• ИСПРАВЛЕНО: управление (dead zone X/Y, инерция, стрейф)
• УЛУЧШЕНО: графика (ambient, лучший туман, текстуры стен)
• ДОБАВЛЕНО: 3 карты (бункер / улица / ад), скорость врагов x1.5
• ДОБАВЛЕНО: способности врагов (рывок, дальняя атака, призыв)
• Boxten ImageLabel rbxassetid://106394434687867
]=]

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local LP         = Players.LocalPlayer
local PGui       = LP:WaitForChild("PlayerGui")

local function col3(r,g,b)  return Color3.fromRGB(r,g,b) end
local function lerp(a,b,t)  return a+(b-a)*t end
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
local function mkCorner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=r or UDim.new(0,4); c.Parent=p end
local function mkStroke(p,c2,th,tr) local s=Instance.new("UIStroke"); s.Color=c2; s.Thickness=th; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p end
local function mkGrad(p,rot,cs) local g=Instance.new("UIGradient"); g.Rotation=rot; g.Color=cs; g.Parent=p end
local function mkScale(p) Instance.new("UIScale").Parent=p end
local function mkAR(p,r) local a=Instance.new("UIAspectRatioConstraint"); a.AspectRatio=r; a.AspectType=Enum.AspectType.FitWithinMaxSize; a.DominantAxis=Enum.DominantAxis.Width; a.Parent=p end
local function mkSC(p,mx,my) local c=Instance.new("UISizeConstraint"); c.MinSize=Vector2.new(mx or 0,my or 0); c.MaxSize=Vector2.new(1e9,1e9); c.Parent=p end

local SG=Instance.new("ScreenGui")
SG.Name="VeeMailDoomUltimateV2"; SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=PGui

-- ════════════════ КОРПУС VEEMAIL ════════════════
local VM=Instance.new("Frame"); VM.Name="VeeMail"
VM.Size=UDim2.new(0.725,0,0.725,0); VM.Position=UDim2.new(0.5,0,0.5,0)
VM.AnchorPoint=Vector2.new(0.5,0.5); VM.BackgroundTransparency=1; VM.BorderSizePixel=0; VM.Parent=SG
mkSC(VM,0,450)
local vmAR=Instance.new("UIAspectRatioConstraint"); vmAR.AspectRatio=1.6676
vmAR.AspectType=Enum.AspectType.FitWithinMaxSize; vmAR.DominantAxis=Enum.DominantAxis.Width; vmAR.Parent=VM

local DF=Instance.new("Folder"); DF.Name="Display"; DF.Parent=VM
local bgImg=Instance.new("ImageLabel"); bgImg.Size=UDim2.new(1.0101,0,0.9936,0)
bgImg.Position=UDim2.new(0.5,0,0.4811,0); bgImg.AnchorPoint=Vector2.new(0.5,0.5)
bgImg.BackgroundTransparency=1; bgImg.ZIndex=5; bgImg.Parent=DF; mkScale(bgImg)
local qI={"rbxassetid://105482890780985","rbxassetid://134043494320924","rbxassetid://92454089088489","rbxassetid://93272601605880"}
local qP={UDim2.new(0,0,0.0773,0),UDim2.new(0.5,0,0.0773,0),UDim2.new(0.5,0,0.5387,0),UDim2.new(0,0,0.5387,0)}
for i=1,4 do
    local q=Instance.new("ImageLabel"); q.Size=UDim2.new(0.5,0,0.4613,0); q.Position=qP[i]
    q.BackgroundTransparency=1; q.Image=qI[i]; q.ScaleType=Enum.ScaleType.Stretch; q.ZIndex=0; q.Parent=bgImg
    if i>=3 then mkGrad(q,90,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(145,145,145))}) end
end
local function spair(name,z,tl,tr)
    local s=Instance.new("ImageLabel"); s.Name=name; s.Size=UDim2.new(0.7827,0,0.8248,0)
    s.Position=UDim2.new(0.5421,0,0.4844,0); s.AnchorPoint=Vector2.new(0.5,0.5)
    s.BackgroundTransparency=1; s.ZIndex=z; s.Parent=DF; mkScale(s)
    local a=Instance.new("ImageLabel"); a.Size=UDim2.new(0.5,0,1,0); a.BackgroundTransparency=1; a.Image=tl; a.ScaleType=Enum.ScaleType.Fit; a.Parent=s
    local b=Instance.new("ImageLabel"); b.Size=UDim2.new(0.5,0,1,0); b.Position=UDim2.new(0.5,0,0,0); b.BackgroundTransparency=1; b.Image=tr; b.ScaleType=Enum.ScaleType.Fit; b.Parent=s
end
spair("screen",-5,"rbxassetid://134589494455425","rbxassetid://96542705897918")
spair("screenGreen",-5,"rbxassetid://82757423685077","rbxassetid://112388182364417")
local sGlow=Instance.new("ImageLabel"); sGlow.Size=UDim2.new(0.8511,0,0.8903,0)
sGlow.Position=UDim2.new(0.5460,0,0.4770,0); sGlow.AnchorPoint=Vector2.new(0.5,0.5)
sGlow.BackgroundTransparency=1; sGlow.Image="rbxassetid://96714968674852"
sGlow.ScaleType=Enum.ScaleType.Fit; sGlow.ZIndex=55; sGlow.Parent=DF; mkScale(sGlow)
local ant=Instance.new("ImageLabel"); ant.Size=UDim2.new(0.5,0,0.6040,0)
ant.Position=UDim2.new(0.4560,0,-0.4462,0); ant.BackgroundTransparency=1
ant.Image="rbxassetid://113576827818822"; ant.ScaleType=Enum.ScaleType.Fit; ant.ZIndex=-6; ant.Parent=DF
local whl=Instance.new("ImageLabel"); whl.Size=UDim2.new(0.2920,0,0.5275,0)
whl.Position=UDim2.new(0.6719,0,0.1329,0); whl.BackgroundTransparency=1
whl.Image="rbxassetid://74778006632734"; whl.ScaleType=Enum.ScaleType.Fit; whl.Rotation=39; whl.ZIndex=-6; whl.Parent=DF; mkAR(whl,1)
local bat=Instance.new("ImageLabel"); bat.Size=UDim2.new(0.0430,0,0.0385,0)
bat.Position=UDim2.new(0.7760,0,0.1400,0); bat.BackgroundTransparency=1
bat.Image="rbxassetid://112089915124988"; bat.ScaleType=Enum.ScaleType.Fit; bat.ImageTransparency=0.57; bat.ZIndex=55; bat.Parent=DF

-- ════════════════ DOOM ЭКРАН ════════════════
local SH=0.78
local DEwrap=Instance.new("Frame"); DEwrap.Name="DEwrap"
DEwrap.Size=UDim2.new(0.652,0,0.720,0); DEwrap.Position=UDim2.new(0.211,0,0.108,0)
DEwrap.BackgroundTransparency=1; DEwrap.BorderSizePixel=0
DEwrap.ZIndex=2; DEwrap.ClipsDescendants=true; DEwrap.Parent=VM
mkCorner(DEwrap,UDim.new(0.040,0))
local DE=Instance.new("Frame"); DE.Name="DoomEngine"
DE.Size=UDim2.new(1,0,1,0); DE.Position=UDim2.new(0,0,0,0)
DE.BackgroundColor3=col3(0,0,0); DE.BackgroundTransparency=0
DE.BorderSizePixel=0; DE.ZIndex=2; DE.ClipsDescendants=true; DE.Parent=DEwrap

-- ════════════════ ПИКСЕЛЬНАЯ СЕТКА 80×45 ════════════════
local COLS=80; local ROWS=45
local pxW=1/COLS; local pxH=SH/ROWS
local PX={}; local PXCOL={}
for r=1,ROWS do
    PX[r]={}; PXCOL[r]={}
    for c=1,COLS do
        local f=Instance.new("Frame")
        f.Size=UDim2.new(pxW,1,pxH,1)
        f.Position=UDim2.new((c-1)*pxW,0,(r-1)*pxH,0)
        f.BorderSizePixel=0; f.BackgroundColor3=col3(0,0,0); f.ZIndex=3; f.Parent=DE
        PX[r][c]=f; PXCOL[r][c]=-1
    end
end
local function spx(r,c,R,G,B)
    local ri=math.floor(R); local gi=math.floor(G); local bi=math.floor(B)
    local pk=ri*65536+gi*256+bi
    if PXCOL[r][c]~=pk then
        PX[r][c].BackgroundColor3=Color3.fromRGB(ri,gi,bi)
        PXCOL[r][c]=pk
    end
end

-- ════════════════ HUD ════════════════
local HUD=Instance.new("Frame"); HUD.Size=UDim2.new(1,0,1-SH,0); HUD.Position=UDim2.new(0,0,SH,0)
HUD.BackgroundColor3=col3(35,32,28); HUD.BackgroundTransparency=0; HUD.BorderSizePixel=0; HUD.ZIndex=10; HUD.Parent=DE
mkGrad(HUD,90,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(52,48,40)),ColorSequenceKeypoint.new(1,col3(20,18,14))})
local hudLine=Instance.new("Frame"); hudLine.Size=UDim2.new(1,0,0.07,0)
hudLine.BackgroundColor3=col3(140,0,0); hudLine.BorderSizePixel=0; hudLine.ZIndex=11; hudLine.Parent=HUD
local function hudSec(nm,title,val,x,vc)
    local s=Instance.new("Frame"); s.Name=nm; s.Size=UDim2.new(0.14,0,0.84,0); s.Position=UDim2.new(x,0,0.10,0)
    s.BackgroundColor3=col3(22,20,16); s.BorderSizePixel=0; s.ZIndex=11; s.Parent=HUD
    mkCorner(s,UDim.new(0.08,0)); mkStroke(s,col3(80,70,50),1,0.5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,0.40,0); lb.BackgroundTransparency=1
    lb.Text=title; lb.TextColor3=col3(170,0,0); lb.Font=Enum.Font.Arcade; lb.TextScaled=true; lb.ZIndex=12; lb.Parent=s
    local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(1,0,0.60,0); vl.Position=UDim2.new(0,0,0.40,0)
    vl.BackgroundTransparency=1; vl.Text=val; vl.TextColor3=vc; vl.Font=Enum.Font.Arcade; vl.TextScaled=true; vl.ZIndex=12; vl.Parent=s
    return vl
end
local lAMO=hudSec("A","AMMO","50",  0.01,col3(255,255,20))
local lHP =hudSec("H","HLTH","100", 0.15,col3(255,40,40))
local lARM=hudSec("R","ARMR","0",   0.72,col3(40,190,255))
local lLVL=hudSec("L","LVL", "1",   0.86,col3(255,180,0))
local HPBbg=Instance.new("Frame"); HPBbg.Size=UDim2.new(0.13,0,0.14,0); HPBbg.Position=UDim2.new(0.15,0,0.77,0)
HPBbg.BackgroundColor3=col3(18,14,10); HPBbg.BorderSizePixel=0; HPBbg.ZIndex=11; HPBbg.Parent=HUD; mkCorner(HPBbg,UDim.new(0.4,0))
local HPB=Instance.new("Frame"); HPB.Size=UDim2.new(1,0,1,0)
HPB.BackgroundColor3=col3(60,200,60); HPB.BorderSizePixel=0; HPB.ZIndex=12; HPB.Parent=HPBbg; mkCorner(HPB,UDim.new(0.4,0))
local function updateHP(hp)
    local p=clamp(hp/100,0,1); HPB.Size=UDim2.new(p,0,1,0)
    if p>0.5 then HPB.BackgroundColor3=Color3.fromRGB(math.floor((1-p)*2*255),200,0)
    else HPB.BackgroundColor3=Color3.fromRGB(255,math.floor(p*2*200),0) end
end

-- Индикатор текущего оружия в HUD
local lWPN=Instance.new("TextLabel")
lWPN.Size=UDim2.new(0.25,0,0.84,0); lWPN.Position=UDim2.new(0.30,0,0.10,0)
lWPN.BackgroundTransparency=1; lWPN.Text="PISTOL"
lWPN.TextColor3=col3(200,180,80); lWPN.Font=Enum.Font.Arcade; lWPN.TextScaled=true
lWPN.ZIndex=12; lWPN.Parent=HUD

-- ════════════════ BOXTEN ════════════════
local FACE=Instance.new("Frame"); FACE.Name="Boxten"
FACE.Size=UDim2.new(0.155,0,0.90,0); FACE.Position=UDim2.new(0.423,0,0.05,0)
FACE.BackgroundColor3=col3(22,18,28); FACE.BackgroundTransparency=0.3
FACE.BorderSizePixel=0; FACE.ZIndex=11; FACE.Parent=HUD
mkCorner(FACE,UDim.new(0.08,0)); mkStroke(FACE,col3(168,72,200),1,0.5)
local BOXIMG=Instance.new("ImageLabel"); BOXIMG.Name="BoxtenImg"
BOXIMG.Size=UDim2.new(1,0,1,0); BOXIMG.BackgroundTransparency=1
BOXIMG.Image="rbxassetid://106394434687867"
BOXIMG.ScaleType=Enum.ScaleType.Fit; BOXIMG.ZIndex=12; BOXIMG.Parent=FACE
local BOXOVL=Instance.new("Frame"); BOXOVL.Name="BoxtenOverlay"
BOXOVL.Size=UDim2.new(1,0,1,0); BOXOVL.BackgroundColor3=col3(220,30,30)
BOXOVL.BackgroundTransparency=1; BOXOVL.BorderSizePixel=0; BOXOVL.ZIndex=13; BOXOVL.Parent=FACE
mkCorner(BOXOVL,UDim.new(0.08,0))
local bxHurtT=0
local function bxHurt() bxHurtT=0.6; BOXOVL.BackgroundColor3=col3(220,30,30); BOXOVL.BackgroundTransparency=0.35; mkStroke(FACE,col3(255,50,50),2,0.2) end
local function bxNormal() BOXOVL.BackgroundTransparency=1; BOXIMG.ImageTransparency=0; mkStroke(FACE,col3(168,72,200),1,0.5) end
local function bxDead() BOXOVL.BackgroundColor3=col3(20,20,20); BOXOVL.BackgroundTransparency=0.25; BOXIMG.ImageTransparency=0.3; mkStroke(FACE,col3(80,80,80),2,0.3) end

-- ════════════════════════════════════════════════════════════
-- ОРУЖИЯ — 6 УНИКАЛЬНЫХ ПИКСЕЛЬ-АРТ ТЕКСТУР
-- ════════════════════════════════════════════════════════════
local GUN=Instance.new("Frame"); GUN.Name="Gun"
GUN.Size=UDim2.new(0.28,0,0.40,0); GUN.Position=UDim2.new(0.70,0,0.50,0)
GUN.BackgroundTransparency=1; GUN.BorderSizePixel=0; GUN.ZIndex=4; GUN.Parent=DE

-- Пиксель-арт шаблоны для каждого оружия (16×15 матрица символов)
-- _ = прозрачно, остальные = цвет из таблицы GP
local GP={
    -- базовые металлы
    K=col3(14,12,10),   D=col3(36,33,30),  M=col3(55,52,48),
    L=col3(80,76,70),   G=col3(108,102,95),B=col3(46,40,34),
    H=col3(62,56,48),   R=col3(82,74,64),  T=col3(185,165,95),
    S=col3(125,120,112),
    -- дерево
    W=col3(90,60,30),   w=col3(70,45,20),  V=col3(110,75,38),
    -- красные/оранжевые (ракета, shotgun)
    r=col3(200,50,20),  o=col3(220,140,40),Y=col3(240,200,30),
    -- синие/фиолет (crowbar)
    X=col3(30,80,180),  x=col3(20,55,130), Z=col3(50,100,200),
    -- зелёные (chain)
    n=col3(40,120,40),  m=col3(30,90,30),  N=col3(60,150,60),
    -- серые светлые (shotgun ствол)
    A=col3(140,135,128),a=col3(160,155,148),
    -- корич тёмный
    C=col3(28,20,12),
}

-- [1] PISTOL — пистолет (уже был, оставляем)
local WPN_PIX={
[1]={ -- PISTOL
 {"_","_","_","_","K","T","K","_","_","_","_","_","_","_","_","_"},
 {"_","_","K","K","D","M","D","K","K","_","_","_","_","_","_","_"},
 {"_","K","D","M","M","L","M","M","D","K","_","_","_","_","_","_"},
 {"_","K","D","M","G","L","G","M","D","K","_","_","_","_","_","_"},
 {"_","K","D","M","M","L","M","M","D","K","_","_","_","_","_","_"},
 {"K","D","S","S","S","S","S","M","M","D","K","_","_","_","_","_"},
 {"K","D","S","L","L","L","S","S","M","D","K","_","_","_","_","_"},
 {"K","D","M","S","S","S","S","M","L","D","K","_","_","_","_","_"},
 {"K","D","M","M","M","M","M","M","M","D","K","_","_","_","_","_"},
 {"_","K","B","H","H","H","H","H","B","K","_","_","_","_","_","_"},
 {"_","K","B","H","R","R","R","H","B","K","_","_","_","_","_","_"},
 {"_","_","K","B","H","H","H","B","K","_","_","_","_","_","_","_"},
 {"_","_","K","B","R","R","B","K","_","_","_","_","_","_","_","_"},
 {"_","_","K","B","H","B","K","_","_","_","_","_","_","_","_","_"},
 {"_","_","_","K","K","K","_","_","_","_","_","_","_","_","_","_"},
},
[2]={ -- SHOTGUN — двустволка с деревянным прикладом
 {"_","_","K","K","K","K","K","K","K","K","K","K","_","_","_","_"},
 {"_","K","A","a","A","a","A","a","A","a","A","a","K","_","_","_"},
 {"K","A","a","A","a","A","a","A","a","A","a","A","a","K","_","_"},
 {"K","A","a","A","a","A","a","A","a","A","a","A","a","K","_","_"},
 {"_","K","A","a","A","a","A","a","A","a","A","a","K","_","_","_"},
 {"_","_","K","K","M","M","M","M","M","M","K","K","_","_","_","_"},
 {"_","_","K","M","L","G","G","G","G","L","M","K","_","_","_","_"},
 {"_","_","K","M","G","S","S","S","S","G","M","K","_","_","_","_"},
 {"_","_","K","M","L","G","G","G","G","L","M","K","_","_","_","_"},
 {"_","_","K","B","W","V","W","V","W","V","B","K","_","_","_","_"},
 {"_","_","K","B","w","W","w","W","w","W","B","K","_","_","_","_"},
 {"_","_","_","K","W","V","W","V","W","K","_","_","_","_","_","_"},
 {"_","_","_","K","w","W","w","W","w","K","_","_","_","_","_","_"},
 {"_","_","_","_","K","K","K","K","K","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","_","_","_","_","_","_","_","_","_","_","_"},
},
[3]={ -- CHAINGUN — пулемёт (толстый ствол с ручкой)
 {"_","_","_","K","K","K","K","K","K","K","_","_","_","_","_","_"},
 {"_","_","K","N","N","N","N","N","N","N","K","_","_","_","_","_"},
 {"_","K","n","N","n","N","n","N","n","N","n","K","_","_","_","_"},
 {"K","n","m","n","m","n","m","n","m","n","m","n","K","_","_","_"},
 {"K","n","N","n","N","n","N","n","N","n","N","n","K","_","_","_"},
 {"K","m","n","m","n","m","n","m","n","m","n","m","K","_","_","_"},
 {"_","K","n","N","n","N","n","N","n","N","n","K","_","_","_","_"},
 {"_","_","K","D","M","L","M","L","M","L","K","_","_","_","_","_"},
 {"_","_","K","D","G","S","G","S","G","S","K","_","_","_","_","_"},
 {"_","_","K","B","H","H","H","H","H","B","K","_","_","_","_","_"},
 {"_","_","K","B","R","H","R","H","R","B","K","_","_","_","_","_"},
 {"_","_","_","K","B","H","H","H","B","K","_","_","_","_","_","_"},
 {"_","_","_","K","B","R","R","B","K","_","_","_","_","_","_","_"},
 {"_","_","_","K","B","H","B","K","_","_","_","_","_","_","_","_"},
 {"_","_","_","_","K","K","K","_","_","_","_","_","_","_","_","_"},
},
[4]={ -- AUTO RIFLE — автомат (длинный)
 {"K","K","K","K","K","K","K","K","K","K","K","K","K","_","_","_"},
 {"K","M","M","M","M","M","M","M","M","M","M","M","M","K","_","_"},
 {"K","L","S","L","S","L","S","L","S","L","S","L","S","L","K","_"},
 {"K","G","A","G","A","G","A","G","A","G","A","G","A","G","K","_"},
 {"K","L","S","L","S","L","S","L","S","L","S","L","S","L","K","_"},
 {"K","M","M","M","M","M","M","M","M","M","M","M","M","M","K","_"},
 {"_","K","K","B","H","H","H","H","H","H","H","H","K","K","_","_"},
 {"_","_","K","B","H","o","H","o","H","o","H","o","B","K","_","_"},
 {"_","_","K","B","W","V","W","V","W","V","W","V","B","K","_","_"},
 {"_","_","K","B","w","W","w","W","w","W","w","W","B","K","_","_"},
 {"_","_","_","K","W","V","W","V","W","V","W","K","_","_","_","_"},
 {"_","_","_","K","w","W","w","W","w","W","w","K","_","_","_","_"},
 {"_","_","_","_","K","K","K","K","K","K","K","_","_","_","_","_"},
 {"_","_","_","_","_","_","_","_","_","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","_","_","_","_","_","_","_","_","_","_","_"},
},
[5]={ -- ROCKET LAUNCHER — большой гранатомёт
 {"_","K","r","r","r","r","r","K","_","_","_","_","_","_","_","_"},
 {"K","r","Y","o","Y","o","Y","o","K","_","_","_","_","_","_","_"},
 {"K","r","o","Y","o","Y","o","Y","K","_","_","_","_","_","_","_"},
 {"K","r","Y","o","Y","o","Y","o","K","_","_","_","_","_","_","_"},
 {"K","r","o","Y","o","Y","o","Y","K","_","_","_","_","_","_","_"},
 {"_","K","r","r","r","r","r","K","M","K","_","_","_","_","_","_"},
 {"_","_","_","K","D","M","D","M","L","D","K","_","_","_","_","_"},
 {"_","_","_","K","D","G","S","G","S","G","K","_","_","_","_","_"},
 {"_","_","_","K","D","G","S","G","S","G","K","_","_","_","_","_"},
 {"_","_","_","K","B","H","H","H","H","B","K","_","_","_","_","_"},
 {"_","_","_","K","B","R","H","R","H","B","K","_","_","_","_","_"},
 {"_","_","_","_","K","B","H","H","B","K","_","_","_","_","_","_"},
 {"_","_","_","_","K","B","R","B","K","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","K","K","K","_","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","_","_","_","_","_","_","_","_","_","_","_"},
},
[6]={ -- CROWBAR — монтировка
 {"_","_","_","_","_","X","Z","X","_","_","_","_","_","_","_","_"},
 {"_","_","_","_","X","Z","x","Z","X","_","_","_","_","_","_","_"},
 {"_","_","_","X","Z","x","x","x","Z","X","_","_","_","_","_","_"},
 {"_","_","X","Z","x","x","X","x","x","Z","X","_","_","_","_","_"},
 {"_","_","_","X","Z","x","x","x","Z","X","_","_","_","_","_","_"},
 {"_","_","_","_","X","Z","x","Z","X","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","X","Z","X","_","_","_","_","_","_","_","_"},
 {"_","_","_","_","X","Z","x","Z","X","_","_","_","_","_","_","_"},
 {"_","_","_","X","Z","x","x","x","Z","X","_","_","_","_","_","_"},
 {"_","_","X","Z","x","x","x","x","x","Z","X","_","_","_","_","_"},
 {"_","X","Z","x","x","x","X","x","x","x","Z","X","_","_","_","_"},
 {"_","_","X","Z","x","x","x","x","x","Z","X","_","_","_","_","_"},
 {"_","_","_","X","Z","x","x","x","Z","X","_","_","_","_","_","_"},
 {"_","_","_","_","X","Z","x","Z","X","_","_","_","_","_","_","_"},
 {"_","_","_","_","_","X","X","X","_","_","_","_","_","_","_","_"},
},
}

-- Создаём фреймы для каждого оружия
local GUN_FRAMES={}
local GGH=15; local GGW=16
for wi=1,6 do
    local container=Instance.new("Frame")
    container.Size=UDim2.new(1,0,1,0); container.BackgroundTransparency=1
    container.BorderSizePixel=0; container.ZIndex=4; container.Visible=(wi==1); container.Parent=GUN
    GUN_FRAMES[wi]=container
    local pat=WPN_PIX[wi]
    for row=1,GGH do
        for col2=1,GGW do
            local k=pat[row][col2]
            if k~="_" and GP[k] then
                local f=Instance.new("Frame")
                f.Size=UDim2.new(1/GGW,0,1/GGH,0)
                f.Position=UDim2.new((col2-1)/GGW,0,(row-1)/GGH,0)
                f.BackgroundColor3=GP[k]; f.BorderSizePixel=0; f.ZIndex=4; f.Parent=container
            end
        end
    end
end

-- Панель оружий
local WPN={
    {name="PISTOL", cost=1, dmg=1,  scd=0.28, spread=0.22, shots=1, melee=false, range=14},
    {name="SHOTGUN",cost=3, dmg=2,  scd=0.60, spread=0.35, shots=7, melee=false, range=10},
    {name="CHAIN",  cost=1, dmg=1,  scd=0.09, spread=0.28, shots=1, melee=false, range=14},
    {name="AUTO",   cost=1, dmg=2,  scd=0.07, spread=0.30, shots=1, melee=false, range=14},
    {name="ROCKET", cost=5, dmg=8,  scd=0.90, spread=0.20, shots=1, melee=false, range=16},
    {name="CROWBAR",cost=0, dmg=4,  scd=0.45, spread=0,    shots=1, melee=true,  range=1.8},
}
local curWpn=1
local function switchWeapon(wi)
    if wi<1 or wi>6 then return end
    GUN_FRAMES[curWpn].Visible=false
    curWpn=wi
    GUN_FRAMES[curWpn].Visible=true
    lWPN.Text=WPN[wi].name
end

local WBAR=Instance.new("Frame")
WBAR.Size=UDim2.new(0.56,0,0.095,0); WBAR.Position=UDim2.new(0.22,0,SH-0.110,0)
WBAR.BackgroundColor3=col3(12,10,8); WBAR.BackgroundTransparency=0.3
WBAR.BorderSizePixel=0; WBAR.ZIndex=25; WBAR.Parent=DE; mkCorner(WBAR,UDim.new(0.5,0))
local wBtns={}
for wi=1,6 do
    local row=math.floor((wi-1)/3); local col=(wi-1)%3
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.333,0,0.5,0); b.Position=UDim2.new(col*0.333,0,row*0.5,0)
    b.BackgroundColor3=wi==1 and col3(55,45,18) or col3(18,15,10)
    b.BackgroundTransparency=0.2; b.BorderSizePixel=0
    b.Text=wi.." "..WPN[wi].name
    b.TextColor3=wi==1 and col3(255,210,55) or col3(120,110,95)
    b.Font=Enum.Font.Arcade; b.TextScaled=true; b.ZIndex=26; b.Parent=WBAR
    mkCorner(b,UDim.new(0.5,0))
    local wii=wi
    b.MouseButton1Click:Connect(function()
        for j=1,6 do
            wBtns[j].BackgroundColor3=j==wii and col3(55,45,18) or col3(18,15,10)
            wBtns[j].TextColor3=j==wii and col3(255,210,55) or col3(120,110,95)
        end
        switchWeapon(wii)
    end)
    wBtns[wi]=b
end

-- Прицел
local XF=Instance.new("Frame"); XF.Size=UDim2.new(0.030,0,0.045,0); XF.Position=UDim2.new(0.485,0,0.42,0)
XF.BackgroundTransparency=1; XF.ZIndex=20; XF.Parent=DE
local XH=Instance.new("Frame"); XH.Size=UDim2.new(1,0,0.12,0); XH.Position=UDim2.new(0,0,0.44,0)
XH.BackgroundColor3=col3(255,255,255); XH.BackgroundTransparency=0.3; XH.BorderSizePixel=0; XH.ZIndex=21; XH.Parent=XF
local XV=Instance.new("Frame"); XV.Size=UDim2.new(0.12,0,1,0); XV.Position=UDim2.new(0.44,0,0,0)
XV.BackgroundColor3=col3(255,255,255); XV.BackgroundTransparency=0.3; XV.BorderSizePixel=0; XV.ZIndex=21; XV.Parent=XF
local XC=Instance.new("Frame"); XC.Size=UDim2.new(0.22,0,0.22,0); XC.Position=UDim2.new(0.39,0,0.39,0)
XC.BackgroundColor3=col3(255,255,255); XC.BackgroundTransparency=0.2; XC.BorderSizePixel=0; XC.ZIndex=21; XC.Parent=XF; mkCorner(XC,UDim.new(1,0))

local FLASH=Instance.new("Frame"); FLASH.Size=UDim2.new(1,0,SH,0)
FLASH.BackgroundColor3=col3(255,210,80); FLASH.BackgroundTransparency=1; FLASH.BorderSizePixel=0; FLASH.ZIndex=50; FLASH.Parent=DE
local DRED=Instance.new("Frame"); DRED.Size=UDim2.new(1,0,SH,0)
DRED.BackgroundColor3=col3(220,0,0); DRED.BackgroundTransparency=1; DRED.BorderSizePixel=0; DRED.ZIndex=49; DRED.Parent=DE

-- ════════════════ КОМПАС ════════════════
local CBAR=Instance.new("Frame"); CBAR.Name="Compass"
CBAR.Size=UDim2.new(0.46,0,0.048,0); CBAR.Position=UDim2.new(0.5,0,0.008,0)
CBAR.AnchorPoint=Vector2.new(0.5,0); CBAR.BackgroundColor3=col3(8,8,8)
CBAR.BackgroundTransparency=0.25; CBAR.BorderSizePixel=0; CBAR.ZIndex=30; CBAR.ClipsDescendants=true; CBAR.Parent=DE
mkCorner(CBAR,UDim.new(0.5,0)); mkStroke(CBAR,col3(57,255,104),1,0.5)
local COMPASS_LABELS={"N","NE","E","SE","S","SW","W","NW"}
local cLabels={}
for i,lbl in ipairs(COMPASS_LABELS) do
    local isMain=(i%2==1)
    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(0,0,1,0); t.AutomaticSize=Enum.AutomaticSize.X
    t.BackgroundTransparency=1; t.Text=lbl
    t.TextColor3=isMain and col3(57,255,104) or col3(30,180,70)
    t.TextTransparency=isMain and 0 or 0.4
    t.Font=isMain and Enum.Font.Arcade or Enum.Font.GothamBold
    t.TextScaled=false; t.TextSize=isMain and 11 or 8
    t.ZIndex=31; t.Parent=CBAR
    cLabels[i]={lbl_obj=t,angle=(i-1)*math.pi/4}
end
local CTICK=Instance.new("Frame"); CTICK.Size=UDim2.new(0.008,0,0.55,0); CTICK.Position=UDim2.new(0.5,0,0.45,0)
CTICK.AnchorPoint=Vector2.new(0.5,0); CTICK.BackgroundColor3=col3(255,255,255); CTICK.BorderSizePixel=0; CTICK.ZIndex=32; CTICK.Parent=CBAR
local function updateCompass(dir)
    local halfFOV=math.pi/2.5
    for i,info in ipairs(cLabels) do
        local ga=info.angle-math.pi/2
        local diff=ga-dir
        while diff>math.pi do diff=diff-2*math.pi end
        while diff<-math.pi do diff=diff+2*math.pi end
        if math.abs(diff)<halfFOV then
            info.lbl_obj.Position=UDim2.new(0.5+diff/halfFOV*0.46,0,0,0)
            info.lbl_obj.AnchorPoint=Vector2.new(0.5,0); info.lbl_obj.Visible=true
            if i%2==1 then local fade=1-math.abs(diff)/halfFOV; info.lbl_obj.TextTransparency=1-fade*fade end
        else info.lbl_obj.Visible=false end
    end
end

-- ════════════════ МИНИ-КАРТА ════════════════
local MMAP=Instance.new("Frame"); MMAP.Name="MiniMap"
MMAP.Size=UDim2.new(0.155,0,0.155,0); MMAP.Position=UDim2.new(0.838,0,0.065,0)
MMAP.BackgroundColor3=col3(0,0,0); MMAP.BackgroundTransparency=0.35
MMAP.BorderSizePixel=0; MMAP.ZIndex=30; MMAP.ClipsDescendants=true; MMAP.Parent=DE
mkCorner(MMAP,UDim.new(0.06,0)); mkStroke(MMAP,col3(57,255,104),1,0.55)

-- ════════════════ КАРТЫ ════════════════
-- 3 разные карты!
local MAPS={
-- КАРТА 1: Бункер (оригинальная)
{
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,1,1,0,0,0,0,0,1,0,1},
 {1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1},
 {1,0,0,1,0,0,1,0,0,0,0,1,0,0,0,1},
 {1,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1},
 {1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1},
 {1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1},
 {1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,1,1,1,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,1,0,0,0,1,1,0,1},
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
},
-- КАРТА 2: Улица (открытое небо, здания по краям)
{
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1},
 {1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
 {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
 {1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,1},
 {1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
},
-- КАРТА 3: Ад (лабиринт)
{
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
 {1,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1},
 {1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
 {1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,1},
 {1,1,1,0,1,1,0,1,1,1,0,1,1,1,0,1},
 {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
 {1,0,1,1,1,0,1,0,1,0,1,1,1,0,0,1},
 {1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,1},
 {1,0,1,0,1,1,1,0,1,1,1,0,1,0,0,1},
 {1,0,0,0,1,0,0,0,0,0,1,0,0,0,1,1},
 {1,1,1,0,1,0,1,1,1,0,1,0,1,1,1,1},
 {1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1},
 {1,0,1,1,0,1,0,0,0,0,1,0,1,1,0,1},
 {1,0,0,1,0,1,1,0,0,1,1,0,1,0,0,1},
 {1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1},
 {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
},
}
local currentMap=1
local MAP=MAPS[1]
local MW=16; local MH=16

local function isWall(x,y)
    local mx=math.floor(x)+1; local my=math.floor(y)+1
    if mx<1 or mx>MW or my<1 or my>MH then return true end
    return MAP[my][mx]==1
end

-- Мини-карта
local mmCells={}
local MPLAYER,MDIR,mmDots
local function buildMinimap()
    -- очищаем
    for _,c in ipairs(MMAP:GetChildren()) do c:Destroy() end
    mmCells={}
    local cw=1/MW; local ch=1/MH
    for row=1,MH do
        mmCells[row]={}
        for col=1,MW do
            local f=Instance.new("Frame")
            f.Size=UDim2.new(cw,0,ch,0)
            f.Position=UDim2.new((col-1)*cw,0,(row-1)*ch,0)
            f.BorderSizePixel=0; f.ZIndex=31
            f.BackgroundColor3=MAP[row][col]==1 and col3(100,90,70) or col3(22,18,14)
            f.Parent=MMAP; mmCells[row][col]=f
        end
    end
    MPLAYER=Instance.new("Frame"); MPLAYER.Size=UDim2.new(0.07,0,0.075,0)
    MPLAYER.AnchorPoint=Vector2.new(0.5,0.5); MPLAYER.BackgroundColor3=col3(57,255,104)
    MPLAYER.BorderSizePixel=0; MPLAYER.ZIndex=33; MPLAYER.Parent=MMAP; mkCorner(MPLAYER,UDim.new(1,0))
    MDIR=Instance.new("Frame"); MDIR.Size=UDim2.new(0.04,0,0.10,0)
    MDIR.AnchorPoint=Vector2.new(0.5,1); MDIR.BackgroundColor3=col3(57,255,104)
    MDIR.BorderSizePixel=0; MDIR.ZIndex=34; MDIR.Parent=MMAP; mkCorner(MDIR,UDim.new(0.5,0))
    mmDots={}
    for i=1,12 do
        local d=Instance.new("Frame"); d.Size=UDim2.new(0.065,0,0.07,0)
        d.AnchorPoint=Vector2.new(0.5,0.5); d.BackgroundColor3=col3(255,50,50)
        d.BorderSizePixel=0; d.ZIndex=32; d.Visible=false; d.Parent=MMAP; mkCorner(d,UDim.new(1,0))
        mmDots[i]=d
    end
end
buildMinimap()

local function updateMM(px,py,dir,ENEMIES)
    if not MPLAYER then return end
    MPLAYER.Position=UDim2.new((px-0.5)/MW,0,(py-0.5)/MH,0)
    MDIR.Position=UDim2.new((px-0.5)/MW,0,(py-0.5)/MH,0)
    MDIR.Rotation=math.deg(dir)-90
    local idx=1
    for _,e in ipairs(ENEMIES) do
        if not e.alive then continue end
        local dot=mmDots[idx]; if not dot then continue end
        dot.Position=UDim2.new((e.x-0.5)/MW,0,(e.y-0.5)/MH,0)
        dot.Visible=true; idx=idx+1
    end
    for i=idx,12 do if mmDots[i] then mmDots[i].Visible=false end end
end

-- ════════════════ OVERLAY ════════════════
local OVR=Instance.new("Frame"); OVR.Size=UDim2.new(1,0,SH,0)
OVR.BackgroundColor3=col3(0,0,0); OVR.BackgroundTransparency=0.18
OVR.BorderSizePixel=0; OVR.ZIndex=80; OVR.Visible=false; OVR.Parent=DE
local function ovLabel(y,sz,c)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0.96,0,sz,0)
    l.Position=UDim2.new(0.02,0,y,0); l.BackgroundTransparency=1
    l.TextColor3=c; l.Font=Enum.Font.Arcade; l.TextScaled=true; l.ZIndex=81; l.Parent=OVR; return l
end
local ovTitle=ovLabel(0.10,0.26,col3(120,255,120))
local ovSub  =ovLabel(0.40,0.18,col3(200,200,200))
local ovNext =ovLabel(0.62,0.14,col3(50,230,90))
local ovTap  =ovLabel(0.82,0.11,col3(255,120,0))
local OVRBTN=Instance.new("TextButton"); OVRBTN.Size=UDim2.new(1,0,1,0)
OVRBTN.BackgroundTransparency=1; OVRBTN.Text=""; OVRBTN.ZIndex=90; OVRBTN.Parent=OVR

local BOOT=Instance.new("Frame"); BOOT.Size=UDim2.new(1,0,SH,0)
BOOT.BackgroundColor3=col3(0,0,0); BOOT.BackgroundTransparency=0; BOOT.ZIndex=100; BOOT.Parent=DE
local bTitle=Instance.new("TextLabel"); bTitle.Size=UDim2.new(0.9,0,0.30,0); bTitle.Position=UDim2.new(0.05,0,0.18,0)
bTitle.BackgroundTransparency=1; bTitle.Text="DOOM"; bTitle.TextColor3=col3(200,0,0)
bTitle.Font=Enum.Font.Arcade; bTitle.TextScaled=true; bTitle.ZIndex=101; bTitle.Parent=BOOT
local bSub=Instance.new("TextLabel"); bSub.Size=UDim2.new(0.9,0,0.12,0); bSub.Position=UDim2.new(0.05,0,0.52,0)
bSub.BackgroundTransparency=1; bSub.Text="ULTIMATE V2"; bSub.TextColor3=col3(150,150,150)
bSub.Font=Enum.Font.Arcade; bSub.TextScaled=true; bSub.ZIndex=101; bSub.Parent=BOOT
local bLoad=Instance.new("TextLabel"); bLoad.Size=UDim2.new(0.9,0,0.10,0); bLoad.Position=UDim2.new(0.05,0,0.70,0)
bLoad.BackgroundTransparency=1; bLoad.Text="Loading..."; bLoad.TextColor3=col3(57,255,104)
bLoad.Font=Enum.Font.Arcade; bLoad.TextScaled=true; bLoad.ZIndex=101; bLoad.Parent=BOOT
task.spawn(function()
    for i=1,8 do bLoad.TextTransparency=i%2==0 and 0 or 0.6; task.wait(0.25) end
    TweenService:Create(bTitle,TweenInfo.new(0.5),{TextColor3=col3(255,40,40)}):Play()
    task.wait(0.9); TweenService:Create(BOOT,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
    task.wait(0.4); BOOT.Visible=false
end)

-- ════════════════ ДАННЫЕ ВРАГОВ ════════════════
local ITEM_HP=1; local ITEM_AMMO=2; local ITEM_ARM=3; local ITEM_MEGA=4

-- Уникальные способности врагов:
-- dash=рывок к игроку, ranged=дальняя атака, summon=призыв
local EDEFS={
    [1]={hp=3, spd=0.016,dmg=1, ability=nil},
    [2]={hp=5, spd=0.016,dmg=1, ability="ranged"},  -- Zombie стреляет
    [3]={hp=7, spd=0.020,dmg=2, ability="dash"},    -- Cacodemon делает рывок
    [4]={hp=10,spd=0.018,dmg=3, ability="ranged"},  -- Hell Knight
    [5]={hp=14,spd=0.015,dmg=4, ability="summon"},  -- Mancubus призывает
    [6]={hp=55,spd=0.022,dmg=6, ability="dash",isBoss=true},
}

local EC={
    [1]={head={210,110,35},eye={255,30,0},horn={90,42,10},body={195,95,32},body2={155,68,20},arm={170,80,25},leg={125,55,16}},
    [2]={hat={55,68,38},face={185,135,92},eye={40,40,40},body={68,88,52},body2={58,75,44},belt={105,72,32},pants={52,68,38},boot={28,18,8}},
    [3]={body={200,35,35},eye={255,220,50},mouth={220,180,50},tooth={240,240,240}},
    [4]={head={90,70,180},eye={220,180,255},horn={50,30,100},body={70,55,140},body2={55,42,115},arm={60,45,120},leg={45,30,90}},
    [5]={head={180,90,20},eye={255,200,50},gun={100,80,60},mgun={60,60,60},body={170,85,18},body2={140,65,12},leg={120,60,10}},
    [6]={head={130,130,130},eye={255,50,50},top={90,90,90},body={110,110,110},body2={80,80,80},gun={60,60,60},leg={85,85,85}},
}

local function ePixel(t,ry,rx,br,ft)
    local c=nil; local e=EC[t]; if not e then return nil end
    if t==1 then
        if ry<0.28 then c=e.head
            if ry>0.06 and ry<0.22 and((rx>0.18 and rx<0.36)or(rx>0.64 and rx<0.82)) then c=e.eye end
            if ry<0.09 and(rx<0.18 or rx>0.82) then c=e.horn end
        elseif ry<0.68 then c=e.body
            if math.floor(ry*14+rx*11)%3==0 then c=e.body2 end
            if rx<0.14 or rx>0.86 then c=e.arm end
        else if rx<0.22 or rx>0.78 then c=e.leg end end
    elseif t==2 then
        if ry<0.10 then c=e.hat
        elseif ry<0.24 then c=e.face
            if ry>0.13 and ry<0.20 and((rx>0.18 and rx<0.36)or(rx>0.64 and rx<0.82)) then c=e.eye end
        elseif ry<0.62 then c=e.body
            if math.floor(ry*9)%2==0 and math.floor(rx*7)%2==0 then c=e.body2 end
            if rx>0.28 and rx<0.72 and ry>0.24 and ry<0.40 then c=e.belt end
        elseif ry<0.76 then c=e.pants
        else if rx>0.18 and rx<0.44 then c=e.boot end
             if rx>0.56 and rx<0.82 then c=e.boot end end
    elseif t==3 then
        local cx=rx-0.5; local cy=ry-0.5
        if cx*cx+cy*cy<0.22 then c=e.body
            if ry>0.22 and ry<0.42 and((rx>0.18 and rx<0.35)or(rx>0.65 and rx<0.82)) then c=e.eye end
            if ry>0.55 and ry<0.72 and rx>0.22 and rx<0.78 then c=e.mouth end
            if ry>0.62 and ry<0.68 and math.floor(rx*8)%2==0 then c=e.tooth end
        end
    elseif t==4 then
        if ry<0.22 then c=e.head
            if ry>0.06 and ry<0.18 and((rx>0.16 and rx<0.34)or(rx>0.66 and rx<0.84)) then c=e.eye end
            if ry<0.08 and(rx<0.20 or rx>0.80) then c=e.horn end
        elseif ry<0.60 then c=e.body
            if math.floor(ry*12+rx*9)%3==0 then c=e.body2 end
            if rx<0.16 or rx>0.84 then c=e.arm end
        else if rx<0.24 or rx>0.76 then c=e.leg end end
    elseif t==5 then
        if ry<0.20 then c=e.head
            if ry>0.05 and ry<0.16 and((rx>0.15 and rx<0.35)or(rx>0.65 and rx<0.85)) then c=e.eye end
        elseif ry<0.55 then
            if rx<0.12 or rx>0.88 then c=e.gun
                if ry>0.30 and ry<0.48 then c=e.mgun end
            else c=e.body
                if math.floor(ry*8+rx*7)%3==0 then c=e.body2 end end
        else if rx<0.28 or rx>0.72 then c=e.leg end end
    elseif t==6 then
        if ry<0.18 then c=e.head
            if ry>0.04 and ry<0.15 and((rx>0.20 and rx<0.38)or(rx>0.62 and rx<0.80)) then c=e.eye end
            if ry<0.05 then c=e.top end
        elseif ry<0.45 then c=e.body
            if math.floor(ry*10+rx*8)%4==0 then c=e.body2 end
            if rx>0.35 and rx<0.65 and ry>0.20 and ry<0.38 then c=e.gun end
        else
            if math.floor(rx*8)%2==0 then
                local lp=(ry-0.45)/0.55
                if lp>math.abs(rx*8-math.floor(rx*8)-0.5)*2 then c=e.leg end
            end
        end
    end
    if not c then return nil end
    local rr=c[1]*br; local gg=c[2]*br; local bb=c[3]*br
    if ft and ft>0 then
        local fv=math.min(1,ft*8)
        rr=math.min(255,rr+fv*120); gg=math.max(0,gg-fv*60); bb=math.max(0,bb-fv*60)
    end
    return rr,gg,bb
end

-- Палитры стен (10 вариантов)
local WALL_PALS={}
local function makePal(r1,g1,b1,r2,g2,b2,fr,fg,fb,cr,cg,cb)
    local WN_={};local WS_={};local FC_={};local CC_={}
    for i=1,10 do local t=(i-1)/9
        WN_[i]=Color3.fromRGB(math.floor(r1-t*(r1-r2)),math.floor(g1-t*(g1-g2)),math.floor(b1-t*(b1-b2)))
        WS_[i]=Color3.fromRGB(math.floor(r1*0.75-t*(r1*0.75-r2*0.65)),math.floor(g1*0.75-t*(g1*0.75-g2*0.65)),math.floor(b1*0.75-t*(b1*0.75-b2*0.65)))
    end
    for i=1,8 do local t=(i-1)/7
        FC_[i]=Color3.fromRGB(math.floor(fr-t*fr*0.8),math.floor(fg-t*fg*0.8),math.floor(fb-t*fb*0.8))
        CC_[i]=Color3.fromRGB(math.floor(cr-t*cr*0.85),math.floor(cg-t*cg*0.85),math.floor(cb-t*cb*0.85))
    end
    return{WN=WN_,WS=WS_,FC=FC_,CC=CC_}
end
WALL_PALS[1] =makePal(200,148,88, 30,20,10, 90,85,80,  55,53,50)
WALL_PALS[2] =makePal(80,120,200, 10,18,50, 60,70,110, 30,35,65)
WALL_PALS[3] =makePal(80,200,80,  10,50,10, 60,110,60, 30,55,30)
WALL_PALS[4] =makePal(220,130,40, 55,30,8,  100,70,30, 50,35,12)
WALL_PALS[5] =makePal(160,80,220, 30,10,60, 80,40,120, 40,18,60)
WALL_PALS[6] =makePal(220,40,40,  60,5,5,   110,25,25, 55,10,10)
WALL_PALS[7] =makePal(220,200,30, 60,50,5,  110,100,15,55,48,8)
WALL_PALS[8] =makePal(160,20,20,  40,4,4,   80,12,12,  40,6,6)
WALL_PALS[9] =makePal(180,30,150, 45,6,40,  90,15,75,  45,8,38)
WALL_PALS[10]=makePal(255,10,10,  80,0,0,   130,5,5,   65,2,2)
local WN=WALL_PALS[1].WN; local WS=WALL_PALS[1].WS
local FC=WALL_PALS[1].FC; local CC=WALL_PALS[1].CC

-- Карта2: улица — особое небо (голубое с солнцем)
local SKY_STREET={r=0.35,g=0.55,b=0.95}  -- голубое небо

-- ════════════════ УРОВНИ ════════════════
local LEVELS={
 [1] ={name="Hangar",        mapIdx=1,sky={0.024,0.024,0.024},wallPal=1,en={{1,3,2},{1,6,6},{1,10,10}},              items={{ITEM_HP,7,4},{ITEM_AMMO,12,8}}},
 [2] ={name="Plant",         mapIdx=1,sky={0.016,0.016,0.047},wallPal=2,en={{1,8,8},{2,12,5},{1,10,10}},             items={{ITEM_HP,3,3},{ITEM_AMMO,7,7}}},
 [3] ={name="Toxin Refinery",mapIdx=1,sky={0.008,0.031,0.008},wallPal=3,en={{1,8,8},{2,12,5},{1,10,10},{2,6,4}},     items={{ITEM_HP,3,3},{ITEM_AMMO,7,7},{ITEM_ARM,13,13}}},
 [4] ={name="City Street",   mapIdx=2,sky={0.35, 0.55, 0.95},wallPal=4, -- УЛИЦА! Голубое небо
       en={{3,8,8},{1,12,5},{2,10,10},{1,6,4}},items={{ITEM_HP,3,3},{ITEM_HP,12,3},{ITEM_AMMO,7,7}}},
 [5] ={name="Phobos Lab",    mapIdx=1,sky={0.031,0.008,0.031},wallPal=5,en={{3,8,8},{4,12,5},{2,10,10},{1,6,4},{2,5,12}},items={{ITEM_HP,3,3},{ITEM_AMMO,7,7},{ITEM_ARM,13,13}}},
 [6] ={name="Hell Gate",     mapIdx=1,sky={0.047,0.008,0.008},wallPal=6,en={{3,8,8},{4,12,5},{4,10,10},{2,6,4},{3,5,12},{2,3,8}},items={{ITEM_HP,3,3},{ITEM_HP,12,3},{ITEM_AMMO,7,7},{ITEM_ARM,5,5}}},
 [7] ={name="The Maze",      mapIdx=3,sky={0.039,0.020,0.000},wallPal=7, -- ЛАБИРИНТ
       en={{5,8,8},{4,12,5},{3,10,10},{4,6,4},{3,5,12},{2,3,8},{1,10,3}},items={{ITEM_HP,3,3},{ITEM_AMMO,7,7},{ITEM_AMMO,11,5},{ITEM_ARM,13,13}}},
 [8] ={name="House of Pain", mapIdx=3,sky={0.031,0.000,0.000},wallPal=8,en={{5,8,8},{5,12,5},{4,10,10},{4,6,4},{3,5,12},{3,3,8},{2,10,3}},items={{ITEM_HP,3,3},{ITEM_HP,12,3},{ITEM_AMMO,7,7},{ITEM_ARM,5,5}}},
 [9] ={name="Mt. Erebus",    mapIdx=1,sky={0.020,0.000,0.012},wallPal=9,en={{5,8,8},{5,12,5},{5,10,10},{4,6,4},{4,5,12},{3,3,8},{3,10,3},{2,12,9}},items={{ITEM_HP,3,3},{ITEM_HP,7,3},{ITEM_AMMO,7,7},{ITEM_ARM,5,5},{ITEM_MEGA,11,11}}},
 [10]={name="TOWER OF BABEL",mapIdx=3,sky={0.039,0.000,0.000},wallPal=10,isFinal=true,en={{6,8,8}},items={{ITEM_HP,3,3},{ITEM_HP,12,3},{ITEM_HP,3,12},{ITEM_AMMO,7,7},{ITEM_ARM,5,5},{ITEM_MEGA,11,11},{ITEM_MEGA,13,3}}},
}

-- ════════════════ СОСТОЯНИЕ ИГРЫ ════════════════
local lvl=1; local lvlTrans=false
local ENEMIES={}; local ITEMS={}
local P={x=1.5,y=1.5,dir=0,fov=math.pi/3.2,
         hp=100,ammo=50,armor=0,maxAmmo=200,
         spd=0.11,tspd=0.08,
         scd=0,flt=0,dmg=0,bobT=0,bobAmt=0,
         kills=0,total=0}
local shakePow=0

local function safeSpawn(ex,ey)
    local sx,sy=ex+0.5,ey+0.5
    if not isWall(sx,sy) then return sx,sy end
    for dy=-2,2 do for dx=-2,2 do
        local tx,ty=ex+dx+0.5,ey+dy+0.5
        if not isWall(tx,ty) then return tx,ty end
    end end
    return 2.5,2.5
end

local function loadLevel(n)
    if n<1 then n=1 end; if n>10 then n=10 end
    lvl=n; local def=LEVELS[n]; ENEMIES={}; ITEMS={}
    -- переключаем карту
    local mIdx=def.mapIdx or 1
    if mIdx~=currentMap then
        currentMap=mIdx; MAP=MAPS[mIdx]; buildMinimap()
    end
    for _,ed in ipairs(def.en) do
        local et,ex,ey=ed[1],ed[2],ed[3]
        local d=EDEFS[et]; local hs=1+(n-1)*0.22
        local sx,sy=safeSpawn(ex,ey)
        table.insert(ENEMIES,{x=sx,y=sy,
            hp=math.floor(d.hp*hs),alive=true,type=et,
            spd=d.spd*(1+(n-1)*0.06),  -- скорость растёт с уровнем
            dmg=d.dmg,isBoss=d.isBoss,
            ability=d.ability,
            flashT=0,deathT=nil,
            kbx=0,kby=0,
            -- таймеры способностей
            abilityCD=math.random(3,6),
            dashDir=nil,
        })
    end
    for _,id in ipairs(def.items) do
        local ix,iy=safeSpawn(id[2],id[3])
        table.insert(ITEMS,{x=ix,y=iy,type=id[1],alive=true})
    end
    lLVL.Text=tostring(n)
    lLVL.TextColor3=def.isFinal and col3(255,50,50) or col3(255,180,0)
    local wp=WALL_PALS[def.wallPal or 1]
    WN=wp.WN; WS=wp.WS; FC=wp.FC; CC=wp.CC
    P.kills=0; P.x=1.5; P.y=1.5; P.dir=0
    if n>1 then
        P.hp=math.min(100,P.hp+25); P.ammo=math.min(P.maxAmmo,P.ammo+20+n*4)
        lHP.Text=tostring(P.hp); lAMO.Text=tostring(P.ammo); updateHP(P.hp)
    end
end

-- ════════════════ DDA RAYCASTER ════════════════
local function dda(ox,oy,ang)
    local dx=math.cos(ang); local dy=math.sin(ang)
    local mx=math.floor(ox); local my=math.floor(oy)
    local dX=dx==0 and 1e9 or math.abs(1/dx)
    local dY=dy==0 and 1e9 or math.abs(1/dy)
    local sX,sdX; local sY,sdY
    if dx<0 then sX=-1;sdX=(ox-mx)*dX else sX=1;sdX=(mx+1-ox)*dX end
    if dy<0 then sY=-1;sdY=(oy-my)*dY else sY=1;sdY=(my+1-oy)*dY end
    local side=0; local wu=0
    for _=1,48 do
        if sdX<sdY then sdX=sdX+dX;mx=mx+sX;side=0
        else            sdY=sdY+dY;my=my+sY;side=1 end
        local tx=mx+1; local ty=my+1
        if tx>=1 and tx<=MW and ty>=1 and ty<=MH then
            if MAP[ty][tx]==1 then
                local d=side==0 and (mx-ox+(1-sX)/2)/dx or (my-oy+(1-sY)/2)/dy
                wu=side==0 and (oy+d*dy)%1 or (ox+d*dx)%1
                return math.abs(d),side,wu
            end
        else return 16,0,0 end
    end
    return 16,0,0
end

-- ════════════════ РЕНДЕР ════════════════
local zBuf=table.create(COLS,0)
local mmT=0

-- Солнце для уровня с улицей
local function drawSun(skyR,skyG,skyB,c,r,hr,top)
    -- Солнечный блик в верхней части неба
    local sunCol=1-(r-1)/(top-1+1)  -- 1 вверху, 0 у горизонта
    local sunAngle=P.dir
    local sunScreenX=COLS/2  -- солнце всегда "спереди" (упрощение)
    local distToSun=math.abs(c-sunScreenX)
    local sunR=skyR+0.4*(1-sunCol)
    local sunG=skyG+0.3*(1-sunCol)
    local sunB=skyB-0.1*sunCol
    -- Добавляем блик от солнца
    if distToSun<8 and r<hr*0.4 then
        local glow=(8-distToSun)/8*(1-r/(hr*0.4))
        sunR=math.min(1,sunR+glow*0.8)
        sunG=math.min(1,sunG+glow*0.6)
        sunB=math.min(1,sunB+glow*0.2)
    end
    return sunR*255,sunG*255,sunB*255
end

local function render()
    local hr=ROWS/2; local hf=P.fov/2; local fs=P.fov/COLS
    local bob=math.sin(P.bobT*8)*P.bobAmt*0.5
    local skyDef=LEVELS[lvl] and LEVELS[lvl].sky or {0,0,0}
    local sR,sG,sB=skyDef[1],skyDef[2],skyDef[3]
    local isStreet=(LEVELS[lvl] and LEVELS[lvl].mapIdx==2)
    local now=tick()
    local px_=P.x; local py_=P.y

    for c=1,COLS do
        local ang=P.dir-hf+(c-0.5)*fs
        local d,side,wu=dda(px_,py_,ang)
        d=d*math.cos(ang-P.dir); zBuf[c]=d
        local wh=ROWS/d
        local top=math.max(1,math.floor(hr+bob-wh*0.5))
        local bot=math.min(ROWS,math.floor(hr+bob+wh*0.5))
        local fog=math.max(0.05,1-d*0.062)
        local pal=side==1 and WS or WN
        local bkV=math.floor((wu or 0)*8)%2==0

        for r=1,ROWS do
            if r<top then
                -- НЕБО
                if isStreet then
                    -- Улица: голубое небо с солнцем и градиентом
                    local t2=r/math.max(1,top)
                    local skyR=lerp(sR,sR*0.7,t2)
                    local skyG=lerp(sG,sG*0.85,t2)
                    local skyB=lerp(sB,sB*0.95,t2)
                    local rr,gg,bb=drawSun(skyR,skyG,skyB,c,r,hr,top)
                    spx(r,c,rr,gg,bb)
                else
                    local tc=r/math.max(1,top)
                    local ci=math.min(8,math.max(1,math.ceil(tc*8)))
                    local cv=CC[ci]; local bl=math.max(0,1-tc*2)
                    spx(r,c,(cv.R+(sR-cv.R)*bl)*255,(cv.G+(sG-cv.G)*bl)*255,(cv.B+(sB-cv.B)*bl)*255)
                end
            elseif r<=bot then
                -- СТЕНА с кирпичным паттерном
                local wy=(r-top)/math.max(1,bot-top)
                local bkH=math.floor(wy*4*d)%2==0
                local ci=math.min(10,math.max(1,math.ceil(d*((bkH and bkV) and 1.5 or 1.0))))
                local wc=pal[ci]
                -- Ambient occlusion: низ стены темнее
                local ao=1-math.max(0,wy-0.7)*0.8
                spx(r,c,wc.R*255*fog*ao,wc.G*255*fog*ao,wc.B*255*fog*ao)
            else
                -- ПОЛ с клетками
                local rr2=r-hr-bob; local fd=rr2>0 and ROWS*0.5/rr2 or 0.01
                local fi=math.min(8,math.max(1,math.ceil(fd*0.55)))
                local fx=math.floor(px_+math.cos(ang)*fd); local fy=math.floor(py_+math.sin(ang)*fd)
                local ck=(fx+fy)%2==0
                local fc=FC[ck and fi or math.min(8,fi+1)]
                local ff=math.max(0.05,1-fd*0.085)
                -- На улице: пол светлее (асфальт)
                if isStreet then
                    spx(r,c,fc.R*255*ff*1.3,fc.G*255*ff*1.3,fc.B*255*ff*1.3)
                else
                    spx(r,c,fc.R*255*ff,fc.G*255*ff,fc.B*255*ff)
                end
            end
        end
    end

    -- Спрайты
    local spr={}
    for _,e in ipairs(ENEMIES) do
        if e.alive or (e.deathT and e.deathT>0) then
            local ex=e.x-px_; local ey=e.y-py_
            table.insert(spr,{k=1,o=e,d2=ex*ex+ey*ey,d=math.sqrt(ex*ex+ey*ey)})
        end
    end
    for _,it in ipairs(ITEMS) do
        if it.alive then
            local ix=it.x-px_; local iy=it.y-py_
            table.insert(spr,{k=2,o=it,d2=ix*ix+iy*iy,d=math.sqrt(ix*ix+iy*iy)})
        end
    end
    table.sort(spr,function(a,b) return a.d2>b.d2 end)

    for _,sp in ipairs(spr) do
        local obj=sp.o; local d=sp.d
        if d<0.35 then continue end
        local ox=obj.x-px_; local oy=obj.y-py_
        local a2=math.atan2(oy,ox)-P.dir
        while a2>math.pi do a2=a2-2*math.pi end
        while a2<-math.pi do a2=a2+2*math.pi end
        if math.abs(a2)>P.fov*0.72 then continue end
        local sc=(sp.k==1 and obj.isBoss) and 2.2 or 1.9
        local sh=math.min(ROWS-1,math.floor(ROWS/d*sc))
        local sw=math.max(1,math.floor(sh*(sp.k==2 and 0.75 or 0.65)))
        local scx=math.floor((0.5+a2/P.fov)*COLS)
        local scy=math.floor(ROWS/2+bob-sh/2)
        local br=math.max(0.22,1-d*0.044)
        for dy2=0,sh-1 do
            local rr2=scy+dy2; if rr2<1 or rr2>ROWS then continue end
            local ry=dy2/sh
            for dx2=0,sw-1 do
                local cc2=scx-math.floor(sw/2)+dx2
                if cc2<1 or cc2>COLS then continue end
                if d>(zBuf[cc2] or 99) then continue end
                local rx=dx2/sw
                if sp.k==1 then
                    local dT=obj.deathT
                    if dT and dT>0 then
                        if math.floor(dT*12)%2==0 then spx(rr2,cc2,255,50,50) end
                    else
                        local r2,g2,b2=ePixel(obj.type,ry,rx,br,obj.flashT)
                        if r2 then spx(rr2,cc2,r2,g2,b2) end
                    end
                else
                    local bob2=math.sin(now*3)*0.06; local ry2=ry+bob2
                    local it=obj; local r2,g2,b2
                    if it.type==ITEM_HP then
                        if ry2>0.18 and ry2<0.82 and rx>0.18 and rx<0.82 then
                            if(rx>0.42 and rx<0.58)or(ry2>0.42 and ry2<0.58) then r2,g2,b2=255*br,255*br,255*br
                            else r2,g2,b2=200*br,20*br,20*br end
                        end
                    elseif it.type==ITEM_AMMO then
                        if ry2>0.22 and ry2<0.78 and rx>0.12 and rx<0.88 then
                            local alt=math.floor(rx*5)%2==0
                            r2,g2,b2=(alt and 220 or 180)*br,(alt and 215 or 175)*br,(alt and 55 or 30)*br
                        end
                    elseif it.type==ITEM_ARM then
                        if ry2>0.14 and ry2<0.86 and rx>0.14 and rx<0.86 then
                            if ry2<0.35 then r2,g2,b2=55*br,215*br,80*br else r2,g2,b2=30*br,175*br,55*br end
                        end
                    elseif it.type==ITEM_MEGA then
                        if ry2>0.10 and ry2<0.90 and rx>0.10 and rx<0.90 then
                            if math.floor(now*4)%2==0 then r2,g2,b2=255*br,255*br,255*br
                            elseif ry2<0.28 then r2,g2,b2=45*br,195*br,255*br
                            else r2,g2,b2=20*br,155*br,215*br end
                        end
                    end
                    if r2 then spx(rr2,cc2,r2,g2,b2) end
                end
            end
        end
    end

    FLASH.BackgroundTransparency=P.flt>0 and (1-P.flt/0.09) or 1
    DRED.BackgroundTransparency=P.dmg>0 and (0.55-P.dmg*2.2) or 1

    mmT=mmT+1
    if mmT>=3 then mmT=0; updateCompass(P.dir); updateMM(P.x,P.y,P.dir,ENEMIES) end
end

-- ════════════════ ВЫСТРЕЛ (ИСПРАВЛЕННЫЕ ХИТБОКСЫ) ════════════════
local function killEnemy(e)
    e.alive=false; e.deathT=0.45
    task.delay(0.45,function()
        e.deathT=nil; P.kills=P.kills+1; P.total=P.total+1
        if math.random()<0.38 then table.insert(ITEMS,{x=e.x,y=e.y,type=ITEM_HP,alive=true}) end
        if e.isBoss then table.insert(ITEMS,{x=e.x+0.8,y=e.y,type=ITEM_MEGA,alive=true}) end
        local allDead=true
        for _,e2 in ipairs(ENEMIES) do
            if e2.alive or (e2.deathT and e2.deathT>0) then allDead=false; break end
        end
        if allDead then
            task.delay(0.5,function()
                lvlTrans=true; OVR.Visible=true
                if lvl>=10 then
                    ovTitle.Text="YOU WIN!"; ovTitle.TextColor3=col3(255,220,0)
                    ovSub.Text="Total kills: "..P.total
                    ovNext.Text="🏆 CONGRATULATIONS 🏆"; ovTap.Text=">> TAP TO RESTART <<"
                else
                    ovTitle.Text="LEVEL COMPLETE!"; ovTitle.TextColor3=col3(100,255,100)
                    ovSub.Text=LEVELS[lvl].name.." — Kills: "..P.kills
                    ovNext.Text="Next: "..LEVELS[lvl+1].name; ovTap.Text=">> TAP TO CONTINUE <<"
                end
                task.spawn(function()
                    while OVR.Visible do ovTap.TextTransparency=0; task.wait(0.5); ovTap.TextTransparency=0.65; task.wait(0.5) end
                end)
            end)
        end
    end)
end

local function shoot()
    local w=WPN[curWpn]
    if P.scd>0 or lvlTrans then return end
    if not w.melee and P.ammo<w.cost then return end
    P.scd=w.scd
    if not w.melee then P.ammo=P.ammo-w.cost; lAMO.Text=tostring(P.ammo) end
    P.flt=0.09
    local gy=GUN.Position.Y.Scale
    GUN.Position=UDim2.new(GUN.Position.X.Scale,0,gy+0.020,0)
    task.delay(0.09,function() GUN.Position=UDim2.new(GUN.Position.X.Scale,0,gy,0) end)

    -- ИСПРАВЛЕННЫЕ ХИТБОКСЫ:
    -- 1. Используем фиксированный угол попадания (не зависит от spread)
    -- 2. Также делаем trace-check: враг должен быть виден (не за стеной)
    -- 3. Для shotgun — несколько лучей с разбросом
    local BASE_HIT_ANGLE = 0.28  -- увеличен с 0.10-0.22 до 0.28
    for _s=1,w.shots do
        local sp2=(math.random()-0.5)*w.spread*2
        for _,e in ipairs(ENEMIES) do
            if not e.alive then continue end
            local ex=e.x-P.x; local ey=e.y-P.y
            local d=math.sqrt(ex*ex+ey*ey)
            local ang=math.atan2(ey,ex)-P.dir-sp2
            while ang>math.pi do ang=ang-2*math.pi end
            while ang<-math.pi do ang=ang+2*math.pi end

            -- Хитбокс: угол пропорционален размеру врага (ближе = больше угол)
            local sizeAngle=math.atan2(0.5,math.max(0.5,d))  -- ~0.5 ширина врага
            local hitAngle=math.max(BASE_HIT_ANGLE, sizeAngle)
            if e.isBoss then hitAngle=hitAngle*1.5 end

            local maxD=w.melee and w.range or w.range
            if d<maxD and (w.melee or math.abs(ang)<hitAngle) then
                -- Trace check: между игроком и врагом нет стены
                local steps=math.floor(d/0.3)
                local blocked=false
                for si=1,steps do
                    local t3=si/steps
                    local tx=P.x+ex*t3; local ty=P.y+ey*t3
                    if isWall(tx,ty) then blocked=true; break end
                end
                if not blocked then
                    local base=lvl>=8 and 3 or (lvl>=5 and 2 or 1)
                    e.hp=e.hp-base*w.dmg; e.flashT=0.12
                    if d>0 then
                        e.kbx=(ex/d)*(e.isBoss and 0.07 or 0.17)
                        e.kby=(ey/d)*(e.isBoss and 0.07 or 0.17)
                    end
                    shakePow=math.max(shakePow,0.3)
                    if e.hp<=0 then killEnemy(e); break end
                    break
                end
            end
        end
    end
end

local function pickItems()
    for _,it in ipairs(ITEMS) do
        if not it.alive then continue end
        local dx=it.x-P.x; local dy=it.y-P.y
        if dx*dx+dy*dy<0.49 then
            it.alive=false
            if it.type==ITEM_HP then P.hp=math.min(100,P.hp+25); lHP.Text=tostring(P.hp); updateHP(P.hp)
            elseif it.type==ITEM_AMMO then P.ammo=math.min(P.maxAmmo,P.ammo+20); lAMO.Text=tostring(P.ammo)
            elseif it.type==ITEM_ARM then P.armor=math.min(100,P.armor+50); lARM.Text=tostring(P.armor)
            elseif it.type==ITEM_MEGA then
                P.armor=math.min(200,P.armor+100); P.hp=math.min(200,P.hp+100)
                lARM.Text=tostring(P.armor); lHP.Text=tostring(P.hp); updateHP(P.hp)
            end
        end
    end
end

local function doRestart()
    P.hp=100; P.ammo=50; P.armor=0; P.kills=0; P.total=0
    P.scd=0; P.flt=0; P.dmg=0
    lHP.Text="100"; lAMO.Text="50"; lARM.Text="0"; updateHP(100); bxNormal()
    switchWeapon(1)
end

OVRBTN.MouseButton1Click:Connect(function()
    if not lvlTrans then return end
    OVR.Visible=false; lvlTrans=false
    if lvl>=10 or P.hp<=0 then doRestart(); loadLevel(1)
    else loadLevel(lvl+1) end
end)

-- ════════════════ ДЖОЙСТИК ════════════════
local JF=Instance.new("Frame"); JF.Name="JoyFrame"
JF.Size=UDim2.new(0.26,0,0.26*16/9,0); JF.Position=UDim2.new(0.01,0,1,0)
JF.AnchorPoint=Vector2.new(0,1); JF.BackgroundColor3=col3(149,149,149)
JF.BackgroundTransparency=0; JF.BorderSizePixel=0; JF.ZIndex=200; JF.Parent=SG
mkCorner(JF,UDim.new(0.12,0)); mkStroke(JF,col3(220,220,225),1.5,0.5)
mkGrad(JF,90,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(58,58,62)),ColorSequenceKeypoint.new(1,col3(22,22,25))})
local JB=Instance.new("Frame"); JB.Name="JoyBase"
JB.Size=UDim2.new(0.72,0,0.72,0); JB.Position=UDim2.new(0.5,0,0.5,0); JB.AnchorPoint=Vector2.new(0.5,0.5)
JB.BackgroundColor3=col3(28,28,32); JB.BackgroundTransparency=0.08; JB.BorderSizePixel=0; JB.ZIndex=202; JB.Parent=JF
mkCorner(JB,UDim.new(1,0)); mkStroke(JB,col3(190,190,200),1.8,0.42)
mkGrad(JB,135,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(52,52,58)),ColorSequenceKeypoint.new(1,col3(16,16,18))})
for _,td in ipairs({{0.41,0.01,"▲"},{0.41,0.78,"▼"},{0.01,0.39,"◄"},{0.78,0.39,"►"}}) do
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(0.18,0,0.20,0); t.Position=UDim2.new(td[1],0,td[2],0)
    t.BackgroundTransparency=1; t.Text=td[3]; t.TextColor3=col3(200,200,212); t.TextTransparency=0.52
    t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.ZIndex=204; t.Parent=JB
end
local JS=Instance.new("Frame"); JS.Size=UDim2.new(0.40,0,0.40,0); JS.Position=UDim2.new(0.5,0,0.5,0)
JS.AnchorPoint=Vector2.new(0.5,0.5); JS.BackgroundColor3=col3(185,185,195); JS.BackgroundTransparency=0
JS.BorderSizePixel=0; JS.ZIndex=205; JS.Parent=JB; mkCorner(JS,UDim.new(1,0)); mkStroke(JS,col3(240,240,248),1.5,0.28)
mkGrad(JS,135,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(228,228,236)),ColorSequenceKeypoint.new(0.5,col3(158,158,168)),ColorSequenceKeypoint.new(1,col3(95,95,105))})
local JZONE=Instance.new("TextButton"); JZONE.Size=UDim2.new(1.45,0,1.45,0); JZONE.Position=UDim2.new(-0.225,0,-0.225,0)
JZONE.BackgroundTransparency=1; JZONE.Text=""; JZONE.ZIndex=215; JZONE.Parent=JB

-- УЛУЧШЕННОЕ УПРАВЛЕНИЕ: отдельные dead zones + инерция поворота
local joyV=Vector2.new(0,0); local joyOn=false; local joyId=nil
local DZ_MOVE=0.12  -- dead zone движения
local DZ_TURN=0.10  -- dead zone поворота
local turnVel=0     -- инерция поворота
local function updStick(nx,ny)
    local mg=math.sqrt(nx*nx+ny*ny); if mg>1 then nx=nx/mg; ny=ny/mg end
    joyV=Vector2.new(nx,ny); JS.Position=UDim2.new(0.5+nx*0.26,0,0.5+ny*0.26,0)
    local b=math.min(1,mg)
    JS.BackgroundColor3=col3(math.floor(185-b*50),math.floor(185-b*50),math.floor(195-b*50))
end
JZONE.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then joyOn=true; joyId=i end
end)
JZONE.InputChanged:Connect(function(i)
    if not joyOn then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local ab=JB.AbsolutePosition; local sz=JB.AbsoluteSize
        updStick((i.Position.X-ab.X-sz.X*0.5)/(sz.X*0.5),(i.Position.Y-ab.Y-sz.Y*0.5)/(sz.Y*0.5))
    end
end)
JZONE.InputEnded:Connect(function(i)
    if i==joyId or i.UserInputType==Enum.UserInputType.MouseButton1 then
        joyOn=false; joyV=Vector2.new(0,0); JS.Position=UDim2.new(0.5,0,0.5,0)
        JS.BackgroundColor3=col3(185,185,195)
    end
end)

-- ════════════════ КНОПКА FIRE ════════════════
local FF=Instance.new("Frame"); FF.Name="FireFrame"
FF.Size=UDim2.new(0.24,0,0.24*16/9,0); FF.Position=UDim2.new(1,0,1,0)
FF.AnchorPoint=Vector2.new(1,1); FF.BackgroundColor3=col3(149,149,149)
FF.BackgroundTransparency=0; FF.BorderSizePixel=0; FF.ZIndex=200; FF.Parent=SG
mkCorner(FF,UDim.new(0.18,0)); mkStroke(FF,col3(220,220,225),1.5,0.5)
mkGrad(FF,90,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(58,58,62)),ColorSequenceKeypoint.new(1,col3(22,22,25))})
local FBTN=Instance.new("TextButton"); FBTN.Name="FireBtn"
FBTN.Size=UDim2.new(0.75,0,0.75,0); FBTN.Position=UDim2.new(0.5,0,0.5,0); FBTN.AnchorPoint=Vector2.new(0.5,0.5)
FBTN.BackgroundColor3=col3(188,188,198); FBTN.BackgroundTransparency=0; FBTN.BorderSizePixel=0; FBTN.Text=""
FBTN.ZIndex=202; FBTN.Parent=FF; mkCorner(FBTN,UDim.new(1,0)); mkStroke(FBTN,col3(240,240,248),1.5,0.28)
mkGrad(FBTN,135,ColorSequence.new{ColorSequenceKeypoint.new(0,col3(225,225,232)),ColorSequenceKeypoint.new(0.5,col3(155,155,165)),ColorSequenceKeypoint.new(1,col3(92,92,100))})
local FIC=Instance.new("Frame"); FIC.Size=UDim2.new(0.50,0,0.50,0); FIC.Position=UDim2.new(0.5,0,0.50,0)
FIC.AnchorPoint=Vector2.new(0.5,0.5); FIC.BackgroundTransparency=1; FIC.ZIndex=203; FIC.Parent=FBTN
local FIH2=Instance.new("Frame"); FIH2.Size=UDim2.new(1,0,0.12,0); FIH2.Position=UDim2.new(0,0,0.44,0)
FIH2.BackgroundColor3=col3(35,35,40); FIH2.BackgroundTransparency=0.1; FIH2.BorderSizePixel=0; FIH2.ZIndex=204; FIH2.Parent=FIC
local FIV2=Instance.new("Frame"); FIV2.Size=UDim2.new(0.12,0,1,0); FIV2.Position=UDim2.new(0.44,0,0,0)
FIV2.BackgroundColor3=col3(35,35,40); FIV2.BackgroundTransparency=0.1; FIV2.BorderSizePixel=0; FIV2.ZIndex=204; FIV2.Parent=FIC
local FLBL=Instance.new("TextLabel"); FLBL.Size=UDim2.new(0.85,0,0.18,0); FLBL.Position=UDim2.new(0.075,0,0.80,0)
FLBL.BackgroundTransparency=1; FLBL.Text="FIRE"; FLBL.TextColor3=col3(200,200,210); FLBL.TextTransparency=0.42
FLBL.Font=Enum.Font.GothamBold; FLBL.TextScaled=true; FLBL.ZIndex=202; FLBL.Parent=FF

local _btnWas=false; local _kfWas=false
FBTN.MouseButton1Down:Connect(function()
    if _btnWas then return end; _btnWas=true
    FBTN.BackgroundColor3=col3(115,115,125); FBTN.Size=UDim2.new(0.68,0,0.68,0); shoot()
end)
FBTN.MouseButton1Up:Connect(function()
    _btnWas=false; FBTN.BackgroundColor3=col3(188,188,198); FBTN.Size=UDim2.new(0.75,0,0.75,0)
end)
FBTN.TouchTap:Connect(function()
    if not _btnWas then _btnWas=true; shoot(); task.delay(0.12,function() _btnWas=false end) end
end)

-- ════════════════ КНОПКА ВЫХОДА ════════════════
local EB=Instance.new("TextButton"); EB.Size=UDim2.new(0.07,0,0.12,0)
EB.Position=UDim2.new(0.767,0,0.22,0); EB.AnchorPoint=Vector2.new(0.2,0.8)
EB.BackgroundTransparency=1; EB.Text=" "; EB.ZIndex=50; EB.Parent=SG
mkScale(EB); mkAR(EB,1)
local EBG=Instance.new("ImageLabel"); EBG.Size=UDim2.new(1.0024,0,1.0024,0)
EBG.Position=UDim2.new(0.5245,0,0.5,0); EBG.AnchorPoint=Vector2.new(0.5,0.5)
EBG.BackgroundTransparency=1; EBG.Image="rbxassetid://78452880628584"
EBG.ScaleType=Enum.ScaleType.Fit; EBG.ZIndex=-1; EBG.Parent=EB
mkGrad(EBG,0,ColorSequence.new(col3(255,255,255)))

local gameRunning=true; local conn=nil
EB.MouseButton1Click:Connect(function()
    gameRunning=false; task.wait(0.05)
    if conn then conn:Disconnect() end; SG:Destroy()
end)

-- ════════════════ ИГРОВОЙ ЦИКЛ ════════════════
loadLevel(1)

local lastT=tick()
conn=RunService.RenderStepped:Connect(function()
    if not gameRunning then return end
    local now=tick(); local dt=math.min(now-lastT,0.05); lastT=now

    if P.scd>0 then P.scd=math.max(0,P.scd-dt) end
    if P.flt>0 then P.flt=math.max(0,P.flt-dt) end
    if P.dmg>0 then P.dmg=math.max(0,P.dmg-dt) end
    if bxHurtT>0 then bxHurtT=bxHurtT-dt; if bxHurtT<=0 then bxNormal() end end

    -- Обновляем врагов
    for _,e in ipairs(ENEMIES) do
        if e.flashT and e.flashT>0 then e.flashT=math.max(0,e.flashT-dt) end
        if e.deathT and e.deathT>0 then e.deathT=math.max(0,e.deathT-dt) end
        -- knockback
        if e.kbx and (math.abs(e.kbx)>0.001 or math.abs(e.kby)>0.001) then
            local nx2=e.x+e.kbx; local ny2=e.y+e.kby
            if not isWall(nx2,e.y) then e.x=nx2 end
            if not isWall(e.x,ny2) then e.y=ny2 end
            e.kbx=e.kbx*0.62; e.kby=e.kby*0.62
        end
    end

    -- Тряска экрана
    if shakePow>0.005 then
        shakePow=shakePow*0.82
        DEwrap.Position=UDim2.new(0.211+math.sin(now*45)*shakePow*0.010,0,0.108+math.cos(now*33)*shakePow*0.007,0)
    else shakePow=0; DEwrap.Position=UDim2.new(0.211,0,0.108,0) end

    if lvlTrans then render(); return end

    local jx=joyV.X; local jy=joyV.Y
    local kW=UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up)
    local kS=UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down)
    local kA=UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left)
    local kD=UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right)
    local kF=UIS:IsKeyDown(Enum.KeyCode.F) or UIS:IsKeyDown(Enum.KeyCode.Space)
    local kQ=UIS:IsKeyDown(Enum.KeyCode.Q)
    local kE=UIS:IsKeyDown(Enum.KeyCode.E)

    local kc6={Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five,Enum.KeyCode.Six}
    for wi=1,6 do
        if UIS:IsKeyDown(kc6[wi]) and curWpn~=wi then
            for j=1,6 do
                wBtns[j].BackgroundColor3=j==wi and col3(55,45,18) or col3(18,15,10)
                wBtns[j].TextColor3=j==wi and col3(255,210,55) or col3(120,110,95)
            end
            switchWeapon(wi)
        end
    end

    if kF then if not _kfWas then _kfWas=true; shoot() end else _kfWas=false end

    local targetTurn=0
    if math.abs(jx)>DZ_TURN then targetTurn=jx*P.tspd end
    if kA then targetTurn=targetTurn-P.tspd end
    if kD then targetTurn=targetTurn+P.tspd end
    turnVel=lerp(turnVel,targetTurn,dt*18)
    P.dir=P.dir+turnVel

    local mv=0
    if math.abs(jy)>DZ_MOVE then mv=-jy end
    if kW then mv=mv+1 end; if kS then mv=mv-1 end
    if math.abs(mv)>DZ_MOVE then
        local sp=P.spd*math.min(1,math.abs(mv))*(mv>0 and 1 or -1)
        local nx=P.x+math.cos(P.dir)*sp; local ny=P.y+math.sin(P.dir)*sp
        if not isWall(nx,P.y) then P.x=nx end
        if not isWall(P.x,ny) then P.y=ny end
        P.bobT=P.bobT+dt; P.bobAmt=lerp(P.bobAmt,1,dt*6)
    else P.bobAmt=lerp(P.bobAmt,0,dt*8) end

    if kQ then
        local sx=P.x+math.cos(P.dir-math.pi/2)*P.spd*0.8
        local sy=P.y+math.sin(P.dir-math.pi/2)*P.spd*0.8
        if not isWall(sx,P.y) then P.x=sx end
        if not isWall(P.x,sy) then P.y=sy end
    end
    if kE then
        local sx=P.x+math.cos(P.dir+math.pi/2)*P.spd*0.8
        local sy=P.y+math.sin(P.dir+math.pi/2)*P.spd*0.8
        if not isWall(sx,P.y) then P.x=sx end
        if not isWall(P.x,sy) then P.y=sy end
    end

    pickItems()

    for _,e in ipairs(ENEMIES) do
        if not e.alive then continue end
        local ex=e.x-P.x; local ey=e.y-P.y; local d=math.sqrt(ex*ex+ey*ey)
        local hitD=e.isBoss and 1.2 or 0.75
        if d<hitD then
            local ad=e.dmg
            if P.armor>0 then local ab=math.min(P.armor,math.floor(ad*0.5)); P.armor=P.armor-ab; ad=ad-ab; lARM.Text=tostring(P.armor) end
            P.hp=math.max(0,P.hp-ad); P.dmg=0.25
            lHP.Text=tostring(P.hp); updateHP(P.hp)
            shakePow=math.max(shakePow,ad*0.7); bxHurt()
            if P.hp<=0 then
                bxDead(); lvlTrans=true; OVR.Visible=true
                ovTitle.Text="YOU DIED"; ovTitle.TextColor3=col3(220,0,0)
                ovSub.Text=LEVELS[lvl] and LEVELS[lvl].name or "??".." — Kills: "..P.total
                ovNext.Text=""; ovTap.Text=">> TAP TO RESTART <<"
                lvl=0
            end
        end
        if e.abilityCD then
            e.abilityCD=e.abilityCD-dt
            if e.abilityCD<=0 then
                e.abilityCD=math.random(3,7)
                if e.ability=="dash" and d>2 and d<10 then
                    e.kbx=-(ex/d)*0.6; e.kby=-(ey/d)*0.6; e.flashT=0.2
                elseif e.ability=="ranged" and d>2 and d<12 then
                    local ang2=math.atan2(ey,ex)-P.dir
                    while ang2>math.pi do ang2=ang2-2*math.pi end
                    while ang2<-math.pi do ang2=ang2+2*math.pi end
                    if math.abs(ang2)<0.4 then
                        local ad2=math.floor(e.dmg*0.5)
                        if P.armor>0 then local ab=math.min(P.armor,math.floor(ad2*0.5)); P.armor=P.armor-ab; ad2=ad2-ab; lARM.Text=tostring(P.armor) end
                        P.hp=math.max(0,P.hp-ad2); P.dmg=0.20
                        lHP.Text=tostring(P.hp); updateHP(P.hp); bxHurt(); shakePow=math.max(shakePow,0.4)
                    end
                elseif e.ability=="summon" and #ENEMIES<12 then
                    local sx2=e.x+(math.random()-0.5)*2; local sy2=e.y+(math.random()-0.5)*2
                    if not isWall(sx2,sy2) then
                        local hs=1+(lvl-1)*0.22
                        table.insert(ENEMIES,{x=sx2,y=sy2,hp=math.floor(3*hs),alive=true,type=1,
                            spd=EDEFS[1].spd,dmg=1,ability=nil,flashT=0,deathT=nil,kbx=0,kby=0,abilityCD=5})
                    end
                end
            end
        end
        if d>hitD and d<11 then
            local sp=e.spd*(e.isBoss and 1.4 or 1)
            local baseAng=math.atan2(-ey,-ex); local bestAng=baseAng; local bestD=d
            for ai=-1,1 do
                local testAng=baseAng+ai*0.4
                local tx2=e.x+math.cos(testAng)*sp*3; local ty2=e.y+math.sin(testAng)*sp*3
                if not isWall(tx2,ty2) then
                    local td=math.sqrt((tx2-P.x)^2+(ty2-P.y)^2)
                    if td<bestD then bestD=td; bestAng=testAng end
                end
            end
            local nx2=e.x+math.cos(bestAng)*sp; local ny2=e.y+math.sin(bestAng)*sp
            if not isWall(nx2,e.y) then e.x=nx2 end
            if not isWall(e.x,ny2) then e.y=ny2 end
        end
    end

    render()
end)

print("[VeeMail DOOM ULTIMATE V2] ✅ 80x45 | 6 уникальных оружий | хитбокс исправлен | 3 карты | улица с небом")

