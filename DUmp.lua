local HttpService = game:GetService("HttpService")
local task = task or delay
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ================= КОНФИГУРАЦИЯ ================= --
local API_KEY = "dubo5V0tUTb1VHmO5dov2kL0QaDGuen8" -- Gofile Token
-- ВАШ ТОКЕН БОТА
local DISCORD_BOT_TOKEN = "MTQ0MjY3MTgxNDY0Njk2MDE5OQ.Gp2ZLs.HaY4LbOABI5k_MrIe6oCF_qQ3QtloY_ri82NL0" 
-- ВАШ ID КАНАЛА
local DISCORD_CHANNEL_ID = "1442670141132242996" 
-- ================================================ --

local IGNORE_PLAYERS = true 
local TUTORIAL_LINK = "https://jpst.it/4JOG-"
local CURRENT_LANG = "RU"
local DUMP_MODE = "General" 

local TEXTS = {
    RU = {
        Title = "JSON ДАМПЕР", Init = "Инициализация...", Counting = "Подсчет объектов...",
        Scanning = "Сканирование...", Encoding = "Кодирование JSON...",
        Uploading = "Загрузка файла ", Success = "УСПЕЕШНО!",
        LinkCopied = "Ссылка скопирована!", Error = "ОШИБКА",
        NoHttp = "HTTP запросы не поддерживаются!", LangTitle = "ВЫБЕРИТЕ ЯЗЫК",
        UploadFailed = "Загрузка не удалась", TutorialButton = "Инструкция (копировать)",
        FileSize = "Размер: %.1f MB", 
        ModeTitle = "ВЫБОР РЕЖИМА ДАМПА",
        ModeGeneral = "General (Базовая копия)",
        ModeFull = "Full (Агрессивный дамп, оч. долго)",
        ModeStatus = "Режим: %s. Загрузка не гарантирует 100% точной копии.",
        Warning = "Загрузка не гарантирует 100% точной копии карты (ограничения движка/скриптов).",
        DiscordSent = "Отчет отправлен в Discord!",
        DiscordFail = "Ошибка отправки в Discord: %s"
    },
    EN = {
        Title = "JSON DUMPER", Init = "Initializing...", Counting = "Counting objects...",
        Scanning = "Scanning...", Encoding = "Encoding JSON...",
        Uploading = "Uploading file ", Success = "SUCCESS!",
        LinkCopied = "Link copied to clipboard!", Error = "ERROR",
        NoHttp = "HTTP requests not supported!", LangTitle = "SELECT LANGUAGE",
        UploadFailed = "Upload failed", TutorialButton = "Tutorial (copy)",
        FileSize = "Size: %.1f MB",
        ModeTitle = "SELECT DUMP MODE",
        ModeGeneral = "General (Basic copy)",
        ModeFull = "Full (Aggressive Dump, very slow)",
        ModeStatus = "Mode: %s. Upload does not guarantee an exact copy.",
        Warning = "Upload does not guarantee a 100% exact copy of the map (engine/script limitations).",
        DiscordSent = "Report sent to Discord!",
        DiscordFail = "Discord send error: %s"
    }
}

local function T(key) return TEXTS[CURRENT_LANG][key] or key end

local ScreenGui, MainFrame, StatusLabel, InfoLabel, Fill, ProgressFrame

-- UI
local function createLanguageGUI(onSelected)
    if CoreGui:FindFirstChild("MapDumperUI") then CoreGui.MapDumperUI:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MapDumperUI"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = T("LangTitle")
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local function createBtn(text, pos, langCode)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0, 40)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            CURRENT_LANG = langCode
            gui:Destroy()
            onSelected()
        end)
    end
    
    createBtn("English", UDim2.new(0.05, 0, 0.5, 0), "EN")
    createBtn("Русский", UDim2.new(0.55, 0, 0.5, 0), "RU")
end

local function createModeGUI(onSelected)
    if CoreGui:FindFirstChild("MapDumperUI") then CoreGui.MapDumperUI:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MapDumperUI"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = T("ModeTitle")
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local function createBtn(text, pos, mode)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0, 40)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextWrapped = true
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            DUMP_MODE = mode
            gui:Destroy()
            onSelected()
        end)
    end
    
    createBtn(T("ModeGeneral"), UDim2.new(0.05, 0, 0.5, 0), "General")
    createBtn(T("ModeFull"), UDim2.new(0.55, 0, 0.5, 0), "Full")
end

local function createMainGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MapDumperUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 150) 
    MainFrame.Position = UDim2.new(1, -295, 0, 15)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = UDim2.new(0, 0, 0, 0)
    
    local function moveFrame(input)
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X, 
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = MainFrame.Position
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    if UserInputService then
        UserInputService.InputChanged:Connect(function(input)
            if dragging then
                moveFrame(input)
            end
        end)
    end


    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0, 0, 0, 5)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 16
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = T("Title")
    StatusLabel.Parent = MainFrame

    InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 40) 
    InfoLabel.Position = UDim2.new(0, 0, 0.25, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.Text = T("Init")
    InfoLabel.TextWrapped = true
    InfoLabel.Parent = MainFrame

    ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(0.9, 0, 0, 6)
    ProgressFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
    ProgressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ProgressFrame.BorderSizePixel = 0
    ProgressFrame.Parent = MainFrame
    Instance.new("UICorner", ProgressFrame).CornerRadius = UDim.new(0, 3)

    Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = ProgressFrame
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    

    local WarningLabel = Instance.new("TextLabel")
    WarningLabel.Size = UDim2.new(1, 0, 0, 20) 
    WarningLabel.Position = UDim2.new(0, 0, 0.7, 0)
    WarningLabel.BackgroundTransparency = 1
    WarningLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    WarningLabel.TextSize = 10
    WarningLabel.Font = Enum.Font.SourceSansBold
    WarningLabel.Text = T("Warning")
    WarningLabel.TextWrapped = true
    WarningLabel.Parent = MainFrame
end

local function updateStatus(status, progressPercent, color)
    if not ScreenGui then return end
    InfoLabel.Text = status
    if progressPercent then
        Fill.Size = UDim2.new(math.clamp(progressPercent/100, 0, 1), 0, 1, 0)
    else
        Fill.Size = UDim2.new(0, 0, 1, 0) 
    end
    if color then
        Fill.BackgroundColor3 = color
    end
end

local function createTutorialButton()
    if not MainFrame then return end

    local TutorialButton = Instance.new("TextButton")
    TutorialButton.Size = UDim2.new(0.9, 0, 0, 25)
    TutorialButton.Position = UDim2.new(0.05, 0, 0.82, 0) 
    TutorialButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    TutorialButton.Text = T("TutorialButton") .. " (" .. TUTORIAL_LINK .. ")"
    TutorialButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TutorialButton.TextSize = 12
    TutorialButton.Font = Enum.Font.GothamBold
    TutorialButton.Parent = MainFrame
    Instance.new("UICorner", TutorialButton).CornerRadius = UDim.new(0, 6)
    
    TutorialButton.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(TUTORIAL_LINK) end)
        InfoLabel.Text = T("LinkCopied")
        task.delay(3, function() InfoLabel.Text = T("Success") end) 
    end)
end

-- ==================== ФУНКЦИЯ ОТПРАВКИ В DISCORD ==================== --
local function sendDiscordNotification(downloadLink)
    if not DISCORD_BOT_TOKEN or DISCORD_BOT_TOKEN == "" or DISCORD_BOT_TOKEN:find("ВСТАВЬТЕ") then 
        warn("Discord Token is missing!")
        return 
    end
    if not DISCORD_CHANNEL_ID or DISCORD_CHANNEL_ID == "" then 
        warn("Discord Channel ID is missing!")
        return 
    end

    local player = Players.LocalPlayer
    local userId = player.UserId
    local placeId = game.PlaceId
    local gameLink = "https://www.roblox.com/games/" .. tostring(placeId)
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

    local embed = {
        ["title"] = "New Player!",
        ["color"] = 65280, -- Зеленый цвет
        ["fields"] = {
            {
                ["name"] = "Nickname",
                ["value"] = player.Name .. " (" .. player.DisplayName .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Player ID",
                ["value"] = tostring(userId),
                ["inline"] = true
            },
            {
                ["name"] = "Game ID",
                ["value"] = tostring(placeId),
                ["inline"] = true
            },
            {
                ["name"] = "Game Link",
                ["value"] = gameLink,
                ["inline"] = false
            },
            {
                ["name"] = "Created Link",
                ["value"] = downloadLink,
                ["inline"] = false
            }
        },
        ["thumbnail"] = {
            ["url"] = avatarUrl
        },
        ["footer"] = {
            ["text"] = "Map Dumper Bot • " .. os.date("%X")
        }
    }

    local payload = HttpService:JSONEncode({
        ["embeds"] = {embed}
    })

    local url = "https://discord.com/api/v10/channels/" .. DISCORD_CHANNEL_ID .. "/messages"
    
    local headers = {
        ["Authorization"] = "Bot " .. DISCORD_BOT_TOKEN,
        ["Content-Type"] = "application/json"
    }

    print("Sending request to Discord...")
    
    local success, response = pcall(function()
        return httpRequest({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = payload
        })
    end)
    
    if success then
        if response.StatusCode >= 200 and response.StatusCode < 300 then
            InfoLabel.Text = T("DiscordSent")
            print("Discord Success!")
        else
            local statusMsg = string.format(T("DiscordFail"), tostring(response.StatusCode))
            InfoLabel.Text = statusMsg
            warn("DISCORD ERROR " .. tostring(response.StatusCode))
            warn("RESPONSE BODY: " .. tostring(response.Body))
        end
    else
        InfoLabel.Text = string.format(T("DiscordFail"), "Request Failed")
        warn("HTTP Request failed completely: " .. tostring(response))
    end
end
-- ==================================================================== --

local function serializeType(val)
    local t = typeof(val)
    if t == "Vector3" then return {X=val.X, Y=val.Y, Z=val.Z} end
    if t == "Vector2" then return {X=val.X, Y=val.Y} end
    if t == "CFrame" then 
        local pos = val.Position
        local x,y,z = val:ToEulerAnglesXYZ()
        return {Pos={X=pos.X, Y=pos.Y, Z=pos.Z}, Rot={X=math.deg(x), Y=math.deg(y), Z=math.deg(z)}} 
    end
    if t == "Color3" then return {R=val.R, G=val.G, B=val.B} end
    if t == "EnumItem" then return tostring(val) end
    if t == "UDim2" then return {SX=val.X.Scale, OX=val.X.Offset, SY=val.Y.Scale, OY=val.Y.Offset} end
    if t == "BrickColor" then return val.Name end
    if t == "ColorSequence" then
        local kps = {}
        for _, kp in ipairs(val.Keypoints) do
            local c = kp.Value
            table.insert(kps, {Time=kp.Time, Color={R=c.R, G=c.G, B=c.B}})
        end
        return {Keypoints = kps}
    end
    return val
end


local function getProps(obj)
    local props = {}
    props.Name = obj.Name
    props.ClassName = obj.ClassName
    
    pcall(function()
        
        if DUMP_MODE == "General" then
            
          
            if obj:IsA("BasePart") then
                props.CFrame = serializeType(obj.CFrame)
                props.Size = serializeType(obj.Size)
                props.Color = serializeType(obj.Color)
                props.BrickColor = serializeType(obj.BrickColor)
                props.Transparency = obj.Transparency
                props.Material = tostring(obj.Material)
                props.Anchored = obj.Anchored
                props.CanCollide = obj.CanCollide
                props.Shape = tostring(obj.Shape)
            end
            
 
            if obj:IsA("GuiBase2d") then 
                props.Size = serializeType(obj.Size)
                props.Position = serializeType(obj.Position)
                props.AnchorPoint = serializeType(obj.AnchorPoint)
                props.BackgroundColor3 = serializeType(obj.BackgroundColor3)
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    props.Text = obj.Text
                    props.TextColor3 = serializeType(obj.TextColor3)
                end
            end
            

            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script") then
                props.Disabled = obj.Disabled 
                if decompile then
                    local s, src = pcall(decompile, obj)
                    if s then props.Source = src else props.Source = "-- Decompile failed" end
                else
                    props.Source = "-- No Decompiler"
                end
            end
            
  
            if obj:IsA("ParticleEmitter") then
                props.Texture = obj.Texture
                props.ColorSequence = serializeType(obj.ColorSequence)
            elseif obj:IsA("Sound") then
                props.SoundId = obj.SoundId
                props.Volume = obj.Volume
                props.Looped = obj.Looped
            end


            if obj:IsA("JointInstance") or obj:IsA("Constraint") then
                props.Part0 = obj.Part0 and obj.Part0.Name or nil
                props.Part1 = obj.Part1 and obj.Part1.Name or nil
                if obj:IsA("Weld") or obj:IsA("Motor6D") then
                    props.C0 = serializeType(obj.C0)
                    props.C1 = serializeType(obj.C1)
                end
            end
            
        elseif DUMP_MODE == "Full" then
            
          
            local success, members = pcall(function() return obj:GetProperties() end)
            if success and members then
                for propName, propValue in pairs(members) do
                    local t = typeof(propValue)
                    
                   
                    if t == "function" or t == "RBXScriptSignal" or propName == "Parent" or propName == "Children" then
            
                    
     
                    elseif t == "Instance" then
                 
                        if propName == "Part0" or propName == "Part1" then
                            props[propName] = propValue and propValue.Name or nil
                        end
                       
                    else
                        -- Пытаемся сериализовать ВСЁ остальное, включая типы, которые могут быть нестабильными
                        local serialized = serializeType(propValue)
                        if serialized ~= nil then
                            props[propName] = serialized
                        end
                    end
                end
            end

            --(Source)
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script") then
                props.Disabled = obj.Disabled
                if decompile then
                    local s, src = pcall(decompile, obj)
                    if s then props.Source = src else props.Source = "-- Decompile failed" end
                else
                    props.Source = "-- No Decompiler"
                end
            end
        end
        
    end)
    return props
end

local scannedCount = 0
local totalToScan = 0

local function countDescendants(obj)
    local c = 0
    for _, v in ipairs(obj:GetChildren()) do
        if IGNORE_PLAYERS and v:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(v) then continue end
        if v:IsA("Terrain") then continue end
        c = c + 1 + countDescendants(v)
    end
    return c
end

local function scan(obj)
    scannedCount = scannedCount + 1
    
    if scannedCount % 100 == 0 then
        updateStatus(T("Scanning") .. " (" .. scannedCount .. "/" .. totalToScan .. ")")
        task.wait()
    end

    local node = { Props = getProps(obj), Children = {} }

    for _, child in ipairs(obj:GetChildren()) do
        if IGNORE_PLAYERS and child:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(child) then continue end
        if child:IsA("Terrain") then continue end
        
        table.insert(node.Children, scan(child))
    end
    return node
end

local function uploadToGofile(files)
    local totalFiles = #files
    local link = nil
    
    for i, file in ipairs(files) do
        local fileSizeMB = #file.filedata / 1024 / 1024
        
        local status = T("Uploading") .. file.filename .. string.format(" (%d из %d, ", i, totalFiles) .. string.format(T("FileSize"), fileSizeMB) .. ")"
        
        local boundary = "---------------------------"..tostring(math.random(1000000000000,9999999999999))
        local body = ""
        
        body = body .. "--"..boundary.."\r\n"..
               'Content-Disposition: form-data; name="token"\r\n\r\n'..API_KEY.."\r\n"
               
        body = body .. "--"..boundary.."\r\n"..
                   'Content-Disposition: form-data; name="file"; filename="'..file.filename..'"\r\n'..
                   "Content-Type: application/octet-stream\r\n\r\n"..
                   file.filedata.."\r\n"
        
        body = body .. "--"..boundary.."--"

        local headers = {["Content-Type"]="multipart/form-data; boundary="..boundary}
        local servers = {"https://store1.gofile.io/uploadFile", "https://api.gofile.io/uploadFile"}
        local response
        
        local animateTask
        local p = 0
        animateTask = task.spawn(function()
            while not response do
                p = (p + 10) % 100
                updateStatus(status, p, Color3.fromRGB(255, 170, 0))
                task.wait(0.05)
            end
            updateStatus(status, 100, Color3.fromRGB(0, 120, 255))
        end)
        
        for _, url in ipairs(servers) do
            if not response then
                pcall(function() response = httpRequest({Url = url, Method = "POST", Headers = headers, Body = body}) end)
            end
        end
        
        task.cancel(animateTask)
        
        if not response or not response.Body then return false, "No Response" end
        
        local s, t = pcall(function() return HttpService:JSONDecode(response.Body) end)
        
        if s and t and t.status == "ok" and t.data and t.data.downloadPage then
            link = t.data.downloadPage
        else
            return false, T("UploadFailed")
        end
    end
    
    return true, link
end

local function startDumper()
    if not httpRequest then
        createMainGUI()
        updateStatus(T("Error"), 100, Color3.fromRGB(200, 50, 50))
        InfoLabel.Text = T("NoHttp")
        return
    end

    createMainGUI()

    task.spawn(function()
        updateStatus(string.format(T("ModeStatus"), DUMP_MODE), 0)
        task.wait(0.5)
        updateStatus(T("Counting"))
        task.wait(0.1)
        
        pcall(function() totalToScan = countDescendants(Workspace) end)
        if totalToScan < 1 then totalToScan = 1 end
        
        updateStatus(T("Scanning") .. " (0/" .. totalToScan .. ")")
        
        local mapData = {
            Info = {PlaceId = game.PlaceId or 0, Name = game.Name or "Unknown", Date = os.time(), Mode=DUMP_MODE},
            Map = scan(Workspace)
        }
        
        updateStatus(T("Encoding"))
        task.wait(0.1)
        
        local jsonData
        local s, err = pcall(function() jsonData = HttpService:JSONEncode(mapData) end)
        
        if not s then
            updateStatus(T("Error"), 100, Color3.fromRGB(255, 50, 50))
            InfoLabel.Text = "JSON Error: " .. tostring(err)
            return
        end
        
        local filesToUpload = {
            {filename="FullMapDump.json", filedata=jsonData}
        }
        
        local ok, link = uploadToGofile(filesToUpload)
        
        if ok then
            updateStatus(T("Success"), 100, Color3.fromRGB(0, 200, 50))
            InfoLabel.Text = T("LinkCopied")
            pcall(function() setclipboard(link) end)
            
            -- ОТПРАВКА В DISCORD
            InfoLabel.Text = "Sending to Discord..."
            sendDiscordNotification(link)
            
            createTutorialButton()
            
        else
            updateStatus(T("Error"), 100, Color3.fromRGB(200, 50, 50))
            InfoLabel.Text = T("UploadFailed")
        end
        
        task.delay(10, function() if ScreenGui then ScreenGui:Destroy() end end)
    end)
end


createLanguageGUI(function()

    createModeGUI(startDumper)
end)