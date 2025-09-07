
repeat task.wait() until game:IsLoaded()
local canload = true
local past = {}
local suc, err = pcall(function()
    local requiredfuncs = {
        http.request,
        cloneref,
        clonefunction,
        isfile,
        readfile,
        writefile,
        makefolder,
        isfolder
    }
    for i,v in next, requiredfuncs do
        if v then 
            table.insert(past, v)
        else
            canload = false
        end
    end
end)

if #past ~= 8 then
    canload = false
end

if not canload or err then print("not supported") return end

local guilib = {}
shared.night = guilib

local ts = cloneref(game:GetService("TweenService"))
local container = Instance.new("ScreenGui")
container.Parent = game:GetService("CoreGui")
local https = cloneref(game:GetService("HttpService"))
local fullyuninjected = false

local guilib = setmetatable({}, {
    __index = function(grr, monkey)
        grr[monkey] = guilib
        return grr[monkey]
    end
})

if not isfolder("Night") then
    makefolder("Night")
end
if not isfolder("Night/Config") then
    makefolder("Night/Config")
end

local rootid = game.PlaceId
pcall(function()
    local req 
    req = http.request({
        Url = "https://games.roblox.com/v1/games?universeIds="..tostring(game.GameId),
        Method = "GET"
    }).Body
    rootid = https:JSONDecode(req).data[1].rootPlaceId
end)
if not isfolder("Night/Config/"..rootid) then
    makefolder("Night/Config/"..rootid)
end

function smoothdrag(ui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        if not input or not dragStart or not startPos then return end
        if not input.Position then return end
        local delta = input.Position - dragStart
        ts:Create(ui, TweenInfo.new(0.6), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    ui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    cloneref(game:GetService("RunService")):BindToRenderStep("Drag", Enum.RenderPriority.Input.Value, function()
        if dragging then
            update(dragInput)
        end
    end)
end

if shared.nightrunning then
    print("[ Gui - Executed Successfully ]")
    return
end
shared.nightrunning = true

local setgui = clonefunction(gethui) or function() return cloneref(game:GetService("Players")).LocalPlayer:FindFirstChildOfClass("PlayerGui") end
local Notifications = Instance.new("ScreenGui")
Notifications.ResetOnSpawn = false      
Notifications.Parent = setgui()

local maingui = Instance.new("ScreenGui")
maingui.Parent = setgui()

local tabs
local Core

function guilib:Init(args)
    local Title = args.title or "frostware"

    tabs = Instance.new("Frame")
    tabs.Parent = maingui
    tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabs.BackgroundTransparency = 1.000
    tabs.Size = UDim2.new(0, 510, 0, 240) 

    Core = Instance.new("Frame")
    Core.Parent = tabs
    Core.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Core.Position = UDim2.new(0, 0, 0, 0)
    Core.Size = UDim2.new(0, 510, 0, 240) 
    smoothdrag(Core)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 18)
    UICorner.Parent = Core

    local titl = Instance.new("TextLabel")
    titl.Parent = Core
    titl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    titl.BackgroundTransparency = 1.000
    titl.Position = UDim2.new(0.045, 0, 0.075, 0)
    titl.Size = UDim2.new(0, 194, 0, 19)
    titl.Font = Enum.Font.GothamBold
    titl.Text = Title
    titl.TextColor3 = Color3.fromRGB(229, 229, 229)
    titl.TextSize = 16.000
    titl.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    titl.TextXAlignment = Enum.TextXAlignment.Left

        guilib.leftTabContainer = Instance.new("Frame")
    guilib.leftTabContainer.Name = "LeftTabContainer"
    guilib.leftTabContainer.Parent = Core
    guilib.leftTabContainer.BackgroundTransparency = 1
    guilib.leftTabContainer.Position = UDim2.new(0.055, 0, 0.27, 0)
    guilib.leftTabContainer.Size = UDim2.new(0, 200, 0, 160)

    guilib.rightTabContainer = Instance.new("Frame")
    guilib.rightTabContainer.Name = "RightTabContainer"
    guilib.rightTabContainer.Parent = Core
    guilib.rightTabContainer.BackgroundTransparency = 1
    guilib.rightTabContainer.Position = UDim2.new(0.565, 0, 0.27, 0)
    guilib.rightTabContainer.Size = UDim2.new(0, 200, 0, 160)

    guilib.UIListLayoutLeft = Instance.new("UIListLayout")
    guilib.UIListLayoutLeft.Parent = guilib.leftTabContainer
    guilib.UIListLayoutLeft.HorizontalAlignment = Enum.HorizontalAlignment.Center
    guilib.UIListLayoutLeft.SortOrder = Enum.SortOrder.LayoutOrder
    guilib.UIListLayoutLeft.Padding = UDim.new(0, 10)

    guilib.UIListLayoutRight = Instance.new("UIListLayout")
    guilib.UIListLayoutRight.Parent = guilib.rightTabContainer
    guilib.UIListLayoutRight.HorizontalAlignment = Enum.HorizontalAlignment.Center
    guilib.UIListLayoutRight.SortOrder = Enum.SortOrder.LayoutOrder
    guilib.UIListLayoutRight.Padding = UDim.new(0, 10)
end

shared.togglekey = Enum.KeyCode.V

function guilib:togglegui()
    maingui.Enabled = not maingui.Enabled
    State.Text = maingui.Enabled and "Hide" or "Show"

    if maingui.Enabled then
        if not game:GetService("Lighting"):FindFirstChild("UILocalBlur") then
            local blur = Instance.new("BlurEffect")
            blur.Name = "UILocalBlur"
            blur.Size = 15
            blur.Parent = game:GetService("Lighting")
        end
        if not container:FindFirstChild("CenterImage") then
            local centerImage = Instance.new("ImageLabel")
            centerImage.Name = "CenterImage"
            centerImage.AnchorPoint = Vector2.new(0.5, 0.5)
            centerImage.Position = UDim2.new(0.730189502, 0, 0.475565195, 0)
            centerImage.Size = UDim2.new(0.269810468, 0, 0.524434745, 0)
            centerImage.BackgroundTransparency = 1
            centerImage.Image = "rbxassetid://17663188480"
            centerImage.Parent = container
        end
    else
        local blur = game:GetService("Lighting"):FindFirstChild("UILocalBlur")
        if blur then blur:Destroy() end
        local centerImage = container:FindFirstChild("CenterImage")
        if centerImage then centerImage:Destroy() end
    end
end

local toggleguicon = {}

local container = Instance.new("ScreenGui")
container.Parent = game:GetService("CoreGui")
container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mobile_button = Instance.new("TextButton")
mobile_button.Name = "Mobile"
mobile_button.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
mobile_button.BorderSizePixel = 0
mobile_button.Position = UDim2.new(0.5, 0, -0.2, 0)
mobile_button.Size = UDim2.new(0, 122, 0, 38)
mobile_button.AutoButtonColor = false
mobile_button.Modal = true
mobile_button.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
mobile_button.Text = ""
mobile_button.TextColor3 = Color3.fromRGB(255, 255, 255)
mobile_button.TextSize = 14
mobile_button.Parent = container
mobile_button.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 13)
UICorner.Parent = mobile_button

local shadowMobile = Instance.new("ImageLabel")
shadowMobile.Name = "Shadow"
shadowMobile.Parent = mobile_button
shadowMobile.AnchorPoint = Vector2.new(0.5, 0.5)
shadowMobile.BackgroundTransparency = 1.0
shadowMobile.Position = UDim2.new(0.5, 0, 0.5, 0)
shadowMobile.Size = UDim2.new(0, 144, 0, 58)
shadowMobile.ZIndex = 0
shadowMobile.Image = "rbxassetid://17183270335"
shadowMobile.ImageTransparency = 0.2

local State = Instance.new("TextLabel")
State.Name = "State"
State.Parent = mobile_button
State.AnchorPoint = Vector2.new(0.5, 0.5)
State.BackgroundTransparency = 1.0
State.Position = UDim2.new(0.646, 0, 0.5, 0)
State.Size = UDim2.new(0, 64, 0, 15)
State.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
State.Text = "Show"
State.TextColor3 = Color3.fromRGB(255, 255, 255)
State.TextScaled = true
State.TextWrapped = true
State.TextXAlignment = Enum.TextXAlignment.Left

local Icon = Instance.new("ImageLabel")
Icon.Name = "Icon"
Icon.Parent = mobile_button
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.BackgroundTransparency = 1.0
Icon.Position = UDim2.new(0.268, 0, 0.5, 0)
Icon.Size = UDim2.new(0, 15, 0, 15)
Icon.Image = "rbxassetid://10734975692"

mobile_button.MouseButton1Click:Connect(function()
    guilib:togglegui()
end)

table.insert(toggleguicon, game:GetService("UserInputService").InputBegan:Connect(function(input, isTyping)
    if isTyping then return end
    if input.KeyCode == shared.togglekey and maingui then
        guilib:togglegui()
    end
end))

local Uninjected = false
function guilib:uninject()
    Uninjected = true
    task.wait(0.4)
    guilib = nil

    if container then container:Destroy() end
    for _, v in ipairs(toggleguicon) do
        v:Disconnect()
    end
    table.clear(toggleguicon)

    if maingui then maingui:Destroy() end
    if Notifications then Notifications:Destroy() end

    local blur = game:GetService("Lighting"):FindFirstChild("UILocalBlur")
    if blur then blur:Destroy() end

    local centerImage = container:FindFirstChild("CenterImage")
    if centerImage then centerImage:Destroy() end

    shared.nightrunning = false
    shared.night = nil
    fullyuninjected = true
end

local tabcount = 0
local firsttab = nil  

function guilib:NewTab(args)
    local Name = args.name or "Tab"
    local Icon = args.icon or nil
    local Callback = args.callback or function(State) end
    local Side = args.side or "left" 

    local tabParent = Side == "right" and guilib.rightTabContainer or guilib.leftTabContainer

    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Name = "ButtonHolderHolder"
    ButtonHolder.Parent = tabParent
    ButtonHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonHolder.Size = UDim2.new(0, 180, 0, 38)

    local stroke = Instance.new("UIStroke", ButtonHolder)
    stroke.Color = Color3.fromRGB(45,45,45)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local UICorner_3 = Instance.new("UICorner")
    UICorner_3.CornerRadius = UDim.new(0, 12)
    UICorner_3.Parent = ButtonHolder

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = ButtonHolder
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    ContentFrame.Position = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout")
    layout.Parent = ContentFrame
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 8)

    local Icon_2
    if Icon and Icon ~= 0 then
        Icon_2 = Instance.new("ImageLabel")
        Icon_2.Name = "Icon"
        Icon_2.Parent = ContentFrame
        Icon_2.BackgroundTransparency = 1
        Icon_2.ImageColor3 = Color3.fromRGB(66,66,66)
        Icon_2.Size = UDim2.new(0, 20, 0, 20)
        Icon_2.Image = Icon

        local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
        UIAspectRatioConstraint_2.Parent = Icon_2
    end

    local TextLabel_2 = Instance.new("TextLabel")
    TextLabel_2.Parent = ContentFrame
    TextLabel_2.BackgroundTransparency = 1
    TextLabel_2.Size = UDim2.new(1, -28, 1, 0)
    TextLabel_2.Font = Enum.Font.GothamBold
    TextLabel_2.Text = Name
    TextLabel_2.TextColor3 = Color3.fromRGB(66,66,66)
    TextLabel_2.TextSize = 14
    TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

    local Toggle_2 = Instance.new("TextButton")
    Toggle_2.Name = "Toggle"
    Toggle_2.Parent = ButtonHolder
    Toggle_2.BackgroundTransparency = 1
    Toggle_2.Size = UDim2.new(1, 0, 1, 0)
    Toggle_2.Text = ""

    local UIGradient_2 = Instance.new("UIGradient")
    UIGradient_2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(27, 28, 28)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
    }  
    UIGradient_2.Offset = Vector2.new(0.785, -0.344)
    UIGradient_2.Rotation = -71
    UIGradient_2.Parent = ButtonHolder

    local State = false
    Toggle_2.MouseButton1Click:Connect(function()
        State = not State

        if State then
            ts:Create(UIGradient_2, TweenInfo.new(0.7), {Offset = Vector2.new(0.486, -0.344)}):Play()
            ts:Create(TextLabel_2, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(229, 229, 229)}):Play()
            if Icon_2 then
                ts:Create(Icon_2, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(229, 229, 229)}):Play()
            end
        else
            ts:Create(UIGradient_2, TweenInfo.new(0.7), {Offset = Vector2.new(0.7486, -0.344)}):Play()
            ts:Create(TextLabel_2, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(66, 66, 66)}):Play()
            if Icon_2 then
                ts:Create(Icon_2, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(66, 66, 66)}):Play()
            end
        end

        Callback(State)
    end)

    return ButtonHolder
end

return guilib
