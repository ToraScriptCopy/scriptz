--[[
    *** АФФИГЕННЫЙ ЛОКАЛЬНЫЙ СКРИПТ-СИМУЛЯТОР ***
    
    Скрипт создает:
    1. Интерфейс (Счетчик, Кнопку клика, Кнопки улучшений).
    2. Логику игры (Заработок, Покупка, Пассивный доход).
    
    ВАЖНО: Добавьте этот код в LocalScript, который находится 
           внутри ScreenGui, который называется 'SimulatorGUI' 
           (в StarterGui).
--]]

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GUI = PlayerGui:WaitForChild("SimulatorGUI")
local RunService = game:GetService("RunService")

-- ## 1. Переменные Игры (Состояние) ##
local Data = {
    Cash = 0,
    ClickPower = 1,
    PassiveRate = 0,
}

local Upgrades = {
    ClickPowerUpgrade = {
        CurrentLevel = 0,
        BaseCost = 10,
        CostMultiplier = 1.5,
        EffectPerLevel = 1, -- Увеличивает ClickPower на 1
    },
    PassiveRateUpgrade = {
        CurrentLevel = 0,
        BaseCost = 50,
        CostMultiplier = 2,
        EffectPerLevel = 1, -- Увеличивает PassiveRate на 1 в секунду
    }
}

-- ## 2. Функции Логики ##

-- Вычисление текущей стоимости улучшения
local function getUpgradeCost(upgradeName)
    local upgrade = Upgrades[upgradeName]
    return math.floor(upgrade.BaseCost * (upgrade.CostMultiplier ^ upgrade.CurrentLevel))
end

-- Обновление статистики игрока после покупки
local function applyUpgradeEffect(upgradeName)
    local upgrade = Upgrades[upgradeName]
    upgrade.CurrentLevel = upgrade.CurrentLevel + 1
    
    if upgradeName == "ClickPowerUpgrade" then
        Data.ClickPower = Data.ClickPower + upgrade.EffectPerLevel
    elseif upgradeName == "PassiveRateUpgrade" then
        Data.PassiveRate = Data.PassiveRate + upgrade.EffectPerLevel
    end
end

-- Обработка клика
local function handleCashClick()
    Data.Cash = Data.Cash + Data.ClickPower
end

-- ## 3. Функции Интерфейса (Самосоздание) ##

local UI = {} -- Таблица для хранения созданных UI-элементов

-- Функция для создания базовой кнопки
local function createButton(name, position, size, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = GUI
    btn.Size = size or UDim2.new(0.2, 0, 0.1, 0)
    btn.Position = position
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.BackgroundColor3 = Color3.new(0.1, 0.5, 0.1) -- Темно-зеленый
    return btn
end

-- Функция для создания базового текстового поля
local function createLabel(name, position, size, text)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Parent = GUI
    lbl.Size = size or UDim2.new(0.3, 0, 0.05, 0)
    lbl.Position = position
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 24
    lbl.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3) -- Серый фон
    return lbl
end

-- Создание всех UI-элементов
local function setupUI()
    -- Создаем Главный Счетчик
    UI.CashLabel = createLabel(
        "CashLabel",
        UDim2.new(0.5, -150, 0.05, 0), -- Центр сверху
        UDim2.new(0.3, 0, 0.05, 0),
        "Монеты: 0"
    )
    UI.CashLabel.AnchorPoint = Vector2.new(0.5, 0)
    
    -- Создаем Кнопку Клика
    UI.ClickButton = createButton(
        "ClickButton",
        UDim2.new(0.5, -100, 0.3, 0), -- Центр
        UDim2.new(0.2, 20, 0.1, 0),
        "Кликни! (+1)"
    )
    UI.ClickButton.AnchorPoint = Vector2.new(0.5, 0)
    UI.ClickButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    
    -- Создаем Кнопку Улучшения Кликовой Силы
    UI.ClickUpgradeButton = createButton(
        "ClickUpgradeButton",
        UDim2.new(0.1, 0, 0.6, 0), -- Левая сторона
        UDim2.new(0.3, 0, 0.1, 0),
        "Купить Клик: 10 Монет"
    )
    UI.ClickUpgradeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.5) -- Синий
    
    -- Создаем Кнопку Улучшения Пассивного Дохода
    UI.PassiveUpgradeButton = createButton(
        "PassiveUpgradeButton",
        UDim2.new(0.6, 0, 0.6, 0), -- Правая сторона
        UDim2.new(0.3, 0, 0.1, 0),
        "Купить Пассив: 50 Монет"
    )
    UI.PassiveUpgradeButton.BackgroundColor3 = Color3.new(0.5, 0.1, 0.1) -- Красный
    
    -- Создаем Главный Статус
    UI.StatusLabel = createLabel(
        "StatusLabel",
        UDim2.new(0.5, -150, 0.2, 0),
        UDim2.new(0.3, 100, 0.05, 0),
        "Мощность: 1 | Пассив: 0"
    )
    UI.StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
end

-- Обновление текста на UI
local function updateUI()
    -- Обновляем главный счетчик
    UI.CashLabel.Text = string.format("💰 Монеты: %d", Data.Cash)
    
    -- Обновляем кнопку клика
    UI.ClickButton.Text = string.format("Кликни! (+%d)", Data.ClickPower)
    
    -- Обновляем кнопку улучшения клика
    local clickCost = getUpgradeCost("ClickPowerUpgrade")
    UI.ClickUpgradeButton.Text = string.format(
        "Улучшить Клик\nУр. %d: %d Монет", 
        Upgrades.ClickPowerUpgrade.CurrentLevel + 1, 
        clickCost
    )
    
    -- Обновляем кнопку улучшения пассива
    local passiveCost = getUpgradeCost("PassiveRateUpgrade")
    UI.PassiveUpgradeButton.Text = string.format(
        "Улучшить Пассив\nУр. %d: %d Монет", 
        Upgrades.PassiveRateUpgrade.CurrentLevel + 1, 
        passiveCost
    )
    
    -- Обновляем статус
    UI.StatusLabel.Text = string.format(
        "Мощность: %d | Пассив: %d/с", 
        Data.ClickPower, 
        Data.PassiveRate
    )

    -- Делаем кнопки неактивными, если нет денег
    UI.ClickUpgradeButton.Active = (Data.Cash >= clickCost)
    UI.ClickUpgradeButton.BackgroundTransparency = (Data.Cash >= clickCost) and 0 or 0.5

    UI.PassiveUpgradeButton.Active = (Data.Cash >= passiveCost)
    UI.PassiveUpgradeButton.BackgroundTransparency = (Data.Cash >= passiveCost) and 0 or 0.5
end

-- ## 4. Обработчики Событий (Подключение Логики к UI) ##

local function connectEvents()
    -- Обработчик для кнопки клика
    UI.ClickButton.MouseButton1Click:Connect(function()
        handleCashClick()
        updateUI()
    end)
    
    -- Обработчик для улучшения кликовой силы
    UI.ClickUpgradeButton.MouseButton1Click:Connect(function()
        local cost = getUpgradeCost("ClickPowerUpgrade")
        if Data.Cash >= cost then
            Data.Cash = Data.Cash - cost
            applyUpgradeEffect("ClickPowerUpgrade")
            updateUI()
        end
    end)
    
    -- Обработчик для улучшения пассивного дохода
    UI.PassiveUpgradeButton.MouseButton1Click:Connect(function()
        local cost = getUpgradeCost("PassiveRateUpgrade")
        if Data.Cash >= cost then
            Data.Cash = Data.Cash - cost
            applyUpgradeEffect("PassiveRateUpgrade")
            updateUI()
        end
    end)
end

-- ## 5. Главный Цикл (Пассивный Доход) ##

local function runPassiveIncome()
    while true do
        -- Ждем 1 секунду
        task.wait(1) 
        
        -- Добавляем пассивный доход
        Data.Cash = Data.Cash + Data.PassiveRate
        
        -- Обновляем интерфейс
        updateUI()
    end
end

-- ## 6. Запуск Симулятора ##

setupUI()
connectEvents()
updateUI() -- Первоначальное обновление
task.spawn(runPassiveIncome)
