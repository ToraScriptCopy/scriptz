-- AutomaticPetFollower - Скрипт, который спавнит и заставляет пупсика следовать за игроком.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- !!! 1. КОНФИГУРАЦИЯ !!!
local PET_MODEL_NAME = "MiniPusheen" -- Имя вашей модели питомца в ReplicatedStorage
local ROOT_PART_NAME = "RootPart"    -- Имя главной части в модели питомца, которую мы будем двигать

-- !!! 2. НАСТРОЙКИ СЛЕДОВАНИЯ !!!
local DISTANCE_OFFSET = 7       -- Расстояние, на котором пупсик будет бегать от игрока (чем больше, тем дальше)
local HEIGHT_OFFSET = 2         -- Высота над HumanoidRootPart игрока
local FOLLOW_SPEED = 0.2        -- Скорость/плавность следования (0.1 - медленно, 1.0 - моментально)
local ATTACH_SIDE = "RightVector" -- Сторона, с которой пупсик будет находиться относительно игрока ("RightVector" или "LookVector")

-- !!! 3. ПОЛУЧЕНИЕ МОДЕЛИ !!!
local PetModel = ReplicatedStorage:WaitForChild(PET_MODEL_NAME)
if not PetModel:IsA("Model") then
    warn("Ошибка: '" .. PET_MODEL_NAME .. "' не является Model или не найдена в ReplicatedStorage!")
    return
end

local activePets = {}

--------------------------------------------------------------------------------
-- 🟢 ФУНКЦИИ УПРАВЛЕНИЯ ПИТОМЦЕМ
--------------------------------------------------------------------------------

-- Функция спавна питомца
local function spawnPet(player)
    if activePets[player] then
        return -- Питомец уже есть
    end

    local petClone = PetModel:Clone()
    petClone.Parent = workspace
    
    local rootPart = petClone:FindFirstChild(ROOT_PART_NAME)
    if not rootPart then
        warn("Модель питомца '" .. PET_MODEL_NAME .. "' не имеет части с именем '" .. ROOT_PART_NAME .. "'!")
        petClone:Destroy()
        return
    end

    -- Настраиваем RootPart для правильного движения
    rootPart.CanCollide = false
    rootPart.Massless = true
    rootPart.Anchored = true -- Якорь для контроля через CFrame
    
    -- Сохраняем данные об активном питомце
    activePets[player] = {
        Pet = petClone,
        Root = rootPart
    }
    
    print(player.Name .. " успешно вызвал мини-пупсика.")
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
local function onHeartbeat(deltaTime)
    for player, petData in pairs(activePets) do
        local character = player.Character
        local root = petData.Root
        
        -- Проверяем, существует ли персонаж и его корневая часть (HumanoidRootPart)
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            local playerRoot = character.HumanoidRootPart
            
            -- Вычисляем вектор смещения (справа или спереди от игрока)
            local offsetVector = playerRoot.CFrame[ATTACH_SIDE] * DISTANCE_OFFSET
            
            -- Вычисляем целевую позицию (рядом с игроком, немного выше)
            local targetPosition = playerRoot.Position + offsetVector + Vector3.new(0, HEIGHT_OFFSET, 0)
            
            -- Плавное перемещение (Lerp)
            local newPosition = root.Position:Lerp(targetPosition, FOLLOW_SPEED)
            
            -- Применяем позицию
            root.CFrame = CFrame.new(newPosition)
            
            -- Поворачиваем пупсика в сторону игрока, чтобы он "смотрел" на него
            local lookAtPosition = playerRoot.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            root.CFrame = CFrame.new(newPosition, lookAtPosition)
            
        else
            -- Если персонаж не найден (игрок умер или вышел), удаляем питомца
            despawnPet(player)
        end
    end
end

--------------------------------------------------------------------------------
-- 🚀 ЗАПУСК СКРИПТА
--------------------------------------------------------------------------------

-- Спавним питомца, как только игрок появляется
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait() -- Ждем, пока загрузится персонаж игрока
    spawnPet(player)
end)

-- Удаляем питомца, когда игрок выходит
Players.PlayerRemoving:Connect(despawnPet)

-- Запускаем цикл следования
RunService.Heartbeat:Connect(onHeartbeat)
