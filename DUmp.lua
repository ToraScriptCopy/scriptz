-- LocalScript, поместить в StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- !!! КОНФИГУРАЦИЯ !!!
local PET_SCALE = 0.35      -- Во сколько раз уменьшить игрока (0.35 = 35% от оригинала)
local FOLLOW_OFFSET = Vector3.new(4, -1, 7) -- Позиция питомца относительно камеры/игрока (X, Y, Z)
local FOLLOW_SPEED = 0.15   -- Скорость/плавность следования (0.1 - плавнее)

local targetPlayer = nil    -- Игрок, который станет питомцем
local originalScales = {}   -- Для сохранения оригинальных размеров питомца

--------------------------------------------------------------------------------
-- 🟢 ФУНКЦИИ УПРАВЛЕНИЯ
--------------------------------------------------------------------------------

-- Функция для выбора случайного игрока
local function selectRandomPet()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        -- Исключаем себя из списка возможных питомцев
        if player ~= LocalPlayer and player.Character then
            table.insert(playerList, player)
        end
    end

    if #playerList > 0 then
        local randomIndex = math.random(1, #playerList)
        return playerList[randomIndex]
    else
        return nil
    end
end

-- Функция масштабирования персонажа
local function setCharacterScale(character, scaleFactor)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            -- Масштабируем части тела
            child.Scale = scaleFactor
        end
        if child:IsA("Accessory") then
            -- Масштабируем аксессуары, если они используют Handle
            if child:FindFirstChild("Handle") and child.Handle:IsA("BasePart") then
                child.Handle.Scale = scaleFactor
            end
        end
        -- Мадаем и масштабируем Humanoid's RigType
        if child:IsA("Humanoid") then
            local desc = child:GetAppliedDescription()
            desc.Scale = scaleFactor
            child:ApplyDescription(desc)
        end
    end
end

-- Инициализация и подготовка питомца
local function initializePet(newTargetPlayer)
    if targetPlayer then
        -- Сбросить предыдущего питомца, если он был
        resetPet()
    end
    
    targetPlayer = newTargetPlayer
    local character = targetPlayer.Character
    
    if character and character:FindFirstChildOfClass("Humanoid") then
        print("Новый питомец: " .. targetPlayer.Name)
        
        -- Локально сохраняем оригинальные размеры
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                originalScales[part] = part.Scale
            end
        end
        
        -- Применяем масштаб
        setCharacterScale(character, PET_SCALE)
        
        -- Отключаем физику для клиента, чтобы управлять через CFrame
        character:SetAttribute("Massless", true)
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = true
                part.CanCollide = false
            end
        end
    else
        warn("Ошибка: не удалось подготовить персонажа для " .. targetPlayer.Name)
        targetPlayer = nil
    end
end

-- Сброс масштаба и состояния питомца
local function resetPet()
    if targetPlayer and targetPlayer.Character then
        local character = targetPlayer.Character
        
        -- Сброс масштаба
        setCharacterScale(character, 1 / PET_SCALE) -- Сброс до 1.0
        
        -- Сброс физики
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
            end
        end
    end
    targetPlayer = nil
    originalScales = {}
end

--------------------------------------------------------------------------------
-- 🏃 ЦИКЛ СЛЕДОВАНИЯ (RenderStepped)
--------------------------------------------------------------------------------

local function onRenderStepped()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local petRoot = targetPlayer.Character.HumanoidRootPart
    
    -- Вычисляем целевую позицию относительно камеры (чтобы питомец всегда был рядом с экраном)
    local targetCFrame = Camera.CFrame * CFrame.new(FOLLOW_OFFSET)
    
    -- Плавное перемещение (Lerp)
    local newCFrame = petRoot.CFrame:Lerp(targetCFrame, FOLLOW_SPEED)
    
    -- Применяем позицию. Важно использовать CFrame для локального управления
    petRoot.CFrame = newCFrame
    
    -- Опционально: поворачиваем питомца так, чтобы он смотрел на игрока
    local lookAtPos = LocalPlayer.Character.HumanoidRootPart.Position
    petRoot.CFrame = CFrame.new(newCFrame.p, lookAtPos)
end

--------------------------------------------------------------------------------
-- 🚀 ЗАПУСК СКРИПТА
--------------------------------------------------------------------------------

-- Выбираем случайного питомца после загрузки персонажа
LocalPlayer.CharacterAdded:Wait()

-- Ждем короткое время, чтобы другие игроки успели загрузиться
task.wait(2) 

local randomPet = selectRandomPet()

if randomPet then
    initializePet(randomPet)
    -- Запускаем цикл следования, который должен быть в LocalScript
    RunService.RenderStepped:Connect(onRenderStepped)
else
    print("Не найден другой игрок для выбора в качестве питомца.")
end

-- Сброс, когда игрок выходит/игра заканчивается (на всякий случай)
game:BindToClose(resetPet)
