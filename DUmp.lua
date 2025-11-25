-- AutomaticPetCreatorAndFollower - Полностью автономный скрипт.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- !!! 1. КОНФИГУРАЦИЯ ПИТОМЦА !!!
local PET_NAME = "AutoSpawnedPet" -- Имя, которое будет дано создаваемому питомцу
local PET_SIZE = 1.5              -- Размер питомца (диаметр шара)
local PET_COLOR = Color3.fromRGB(255, 192, 203) -- Розовый (Pusheen color)

-- !!! 2. НАСТРОЙКИ СЛЕДОВАНИЯ !!!
local DISTANCE_OFFSET = 7       -- Расстояние от игрока
local HEIGHT_OFFSET = 2         -- Высота над игроком
local FOLLOW_SPEED = 0.2        -- Скорость/плавность следования
local ATTACH_SIDE = "RightVector" -- Сторона, с которой пупсик будет находиться

local activePets = {}

--------------------------------------------------------------------------------
-- 🧱 ФУНКЦИИ СОЗДАНИЯ МОДЕЛИ
--------------------------------------------------------------------------------

-- Функция создания базовой модели (шар)
local function createBasicPetModel()
    local petModel = Instance.new("Model")
    petModel.Name = PET_NAME
    
    local rootPart = Instance.new("Part")
    rootPart.Name = "RootPart" -- Имя корневой части, по которой будем двигать
    rootPart.Shape = Enum.PartType.Ball
    rootPart.Size = Vector3.new(PET_SIZE, PET_SIZE, PET_SIZE)
    rootPart.BrickColor = BrickColor.new(PET_COLOR)
    
    -- Настройки физики для следования
    rootPart.CanCollide = false
    rootPart.Massless = true
    rootPart.Anchored = true
    
    rootPart.Parent = petModel
    
    local bodyColor = Instance.new("Color3Value")
    bodyColor.Name = "BodyColor"
    bodyColor.Value = PET_COLOR
    bodyColor.Parent = petModel
    
    -- Устанавливаем корневую часть
    petModel:SetPrimaryPartCFrame(rootPart.CFrame)
    
    return petModel, rootPart
end

--------------------------------------------------------------------------------
-- 🟢 ФУНКЦИИ УПРАВЛЕНИЯ ПИТОМЦЕМ
--------------------------------------------------------------------------------

-- Функция спавна питомца
local function spawnPet(player)
    if activePets[player] then
        return -- Питомец уже есть
    end

    local petModel, rootPart = createBasicPetModel()
    
    -- Размещаем питомца в мире
    petModel.Parent = workspace
    
    -- Сохраняем данные об активном питомце
    activePets[player] = {
        Pet = petModel,
        Root = rootPart
    }
    
    print(player.Name .. " успешно вызвал мини-пупсика (автоматически созданного).")
end

-- Функция удаления питомца
local function despawnPet(player)
    if activePets[player] then
        activePets[player].Pet:Destroy()
        activePets[player] = nil
        print(player.Name .. "'s мини-пупсик удален.")
    end
end

--------------------------------------------------------------------------------
-- 🏃 ЦИКЛ СЛЕДОВАНИЯ (Heartbeat)
--------------------------------------------------------------------------------

-- Функция, которая выполняется каждый кадр для плавного следования
local function onHeartbeat()
    for player, petData in pairs(activePets) do
        local character = player.Character
        local root = petData.Root
        
        -- Проверяем, существует ли персонаж
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            local playerRoot = character.HumanoidRootPart
            
            -- Вычисляем смещение
            local offsetVector = playerRoot.CFrame[ATTACH_SIDE] * DISTANCE_OFFSET
            
            -- Вычисляем целевую позицию
            local targetPosition = playerRoot.Position + offsetVector + Vector3.new(0, HEIGHT_OFFSET, 0)
            
            -- Плавное перемещение (Lerp)
            local newPosition = root.Position:Lerp(targetPosition, FOLLOW_SPEED)
            
            -- Применяем позицию
            root.CFrame = CFrame.new(newPosition)
            
            -- Поворачиваем пупсика в сторону игрока (шар не вращается, но это хорошая практика)
            local lookAtPosition = playerRoot.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            root.CFrame = CFrame.new(newPosition, lookAtPosition)
            
        else
            -- Если персонаж не найден, удаляем питомца
            despawnPet(player)
        end
    end
end

--------------------------------------------------------------------------------
-- 🚀 ЗАПУСК СКРИПТА
--------------------------------------------------------------------------------

-- Спавним питомца, как только игрок появляется
Players.PlayerAdded:Connect(function(player)
    -- Ждем, пока персонаж появится в первый раз
    local function onCharacterAdded()
        spawnPet(player)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end)

-- Удаляем питомца, когда игрок выходит
Players.PlayerRemoving:Connect(despawnPet)

-- Запускаем цикл следования
RunService.Heartbeat:Connect(onHeartbeat)
