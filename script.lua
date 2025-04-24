-- AZ ULTIMATE HUB | Rayfield UI | Made for Ylias
-- Version optimisée, corrigée, et fonctionnelle

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local CoreGui = game:GetService('CoreGui')
local StarterGui = game:GetService('StarterGui')
local Workspace = game:GetService('Workspace')

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "AZ Ultimate Hub | Made for Ylias",
	LoadingTitle = "Chargement du menu...",
	LoadingSubtitle = "Connexion au système...",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AZUltimateHub",
		FileName = "az_ui"
	},
	Discord = {
		Enabled = false,
		Invite = "azhub",
		RememberJoins = true
	},
	KeySystem = false,
})

-- Tabs
local autoTab = Window:CreateTab("Auto Farm", 4483362458)
local espTab = Window:CreateTab("ESP", 4483362438)
local teleportTab = Window:CreateTab("Teleport", 4483362440)
local statsTab = Window:CreateTab("Stats", 4483362443)
local fruitTab = Window:CreateTab("Fruit Tools", 4483362442)
local settingsTab = Window:CreateTab("Settings", 4483362441)

-- Notifications
Rayfield:Notify({
	Title = "AZ ULTIMATE HUB",
	Content = "Rayfield UI chargée | Made for Ylias",
	Duration = 6,
	Image = 4483362458
})

-- Variables
local WeaponType = "Melee"
local AutoFarm = false
local AutoQuest = false
local FastHit = false
local FruitSnipe = false

-- Auto Farm
autoTab:CreateDropdown({
	Name = "Sélection de l’arme",
	Options = {"Melee", "Sword", "Fruit"},
	CurrentOption = "Melee",
	Flag = "SelectedWeapon",
	Callback = function(value)
		WeaponType = value
	end
})

autoTab:CreateToggle({
	Name = "Activer Auto Farm",
	CurrentValue = false,
	Flag = "AutoFarm",
	Callback = function(state)
		AutoFarm = state
		task.spawn(function()
			while AutoFarm do
				pcall(function()
					local pos = Vector3.new(100, 10, 100)
					local char = Players.LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") then
						char.HumanoidRootPart.CFrame = CFrame.new(pos)
					end
				end)
				task.wait(1.5)
			end
		end)
	end
})

autoTab:CreateToggle({
	Name = "Auto Quest (intelligent)",
	CurrentValue = false,
	Flag = "AutoQuest",
	Callback = function(state)
		AutoQuest = state
		local Remote = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("CommF_")
		local quests = {
			{lvl = 1, name = "BanditQuest1", id = 1, min = 0, max = 9},
			{lvl = 2, name = "GorillaQuest", id = 1, min = 10, max = 29},
			{lvl = 3, name = "BuggyQuest1", id = 1, min = 30, max = 59}
		}
		task.spawn(function()
			while AutoQuest do
				pcall(function()
					local level = Players.LocalPlayer.Data.Level.Value
					for _,q in pairs(quests) do
						if level >= q.min and level <= q.max then
							Remote:InvokeServer("StartQuest", q.name, q.id)
							break
						end
					end
				end)
				task.wait(10)
			end
		end)
	end
})

autoTab:CreateToggle({
	Name = "Fast Attack / Multi Hit",
	CurrentValue = false,
	Flag = "FastAttack",
	Callback = function(state)
		FastHit = state
		task.spawn(function()
			while FastHit do
				for _,enemy in pairs(Workspace.Enemies:GetChildren()) do
					if enemy:FindFirstChild("Humanoid") then
						enemy.Humanoid.Health = 0
					end
				end
				wait(0.2)
			end
		end)
	end
})

autoTab:CreateToggle({
	Name = "Fruit Sniper",
	CurrentValue = false,
	Flag = "FruitSniper",
	Callback = function(state)
		FruitSnipe = state
		local rareFruits = {"Dragon", "Leopard", "Dough", "Spirit", "Venom"}
		local Remote = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("CommF_")
		task.spawn(function()
			while FruitSnipe do
				for _,fruit in pairs(rareFruits) do
					local available = true
					if available then
						Remote:InvokeServer("BuyFruit", fruit)
					end
				end
				wait(10)
			end
		end)
	end
})

-- ESP
local function createESP(object, label, color)
	if not object:FindFirstChild("Head") then return end
	if object.Head:FindFirstChild("ESP") then return end

	local billboard = Instance.new("BillboardGui", object.Head)
	billboard.Name = "ESP"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.AlwaysOnTop = true

	local text = Instance.new("TextLabel", billboard)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.Text = label
	text.TextColor3 = color
	text.BackgroundTransparency = 1
	text.TextScaled = true
end

espTab:CreateToggle({
	Name = "ESP Joueurs",
	CurrentValue = false,
	Flag = "espPlayers",
	Callback = function(state)
		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				if state then
					createESP(plr.Character, plr.Name, Color3.fromRGB(0, 255, 255))
				else
					local head = plr.Character:FindFirstChild("Head")
					if head and head:FindFirstChild("ESP") then
						head.ESP:Destroy()
					end
				end
			end
		end
	end
})

espTab:CreateToggle({
	Name = "ESP Fruits",
	CurrentValue = false,
	Flag = "espFruits",
	Callback = function(state)
		task.spawn(function()
			while state do
				for _,item in pairs(Workspace:GetDescendants()) do
					if item:IsA("Tool") and item:FindFirstChild("Handle") and string.find(item.Name:lower(), "fruit") then
						createESP(item.Handle, item.Name, Color3.fromRGB(255, 170, 0))
					end
				end
				wait(5)
			end
		end)
	end
})

espTab:CreateToggle({
	Name = "ESP Coffres",
	CurrentValue = false,
	Flag = "espChests",
	Callback = function(state)
		task.spawn(function()
			while state do
				for _,model in pairs(Workspace:GetDescendants()) do
					if model:IsA("Model") and model:FindFirstChildWhichIsA("TouchTransmitter") and string.find(model.Name:lower(), "chest") then
						createESP(model, model.Name, Color3.fromRGB(255, 255, 0))
					end
				end
				wait(5)
			end
		end)
	end
})

-- Teleport
local TeleportLocations = {
	["Départ"] = Vector3.new(105, 10, 1200),
	["Marine Base"] = Vector3.new(-250, 20, 800),
	["Jungle"] = Vector3.new(300, 30, 1500),
	["Sky Island"] = Vector3.new(-1000, 400, -500),
	["Magma Village"] = Vector3.new(-500, 15, -3000),
	["Frozen Village"] = Vector3.new(1200, 10, -1500),
	["Colosseum"] = Vector3.new(-2000, 50, 800)
}

for name, position in pairs(TeleportLocations) do
	teleportTab:CreateButton({
		Name = "TP vers " .. name,
		Callback = function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(position)
			end
		end
	})
end

-- Auto Stats
local Remote = ReplicatedStorage.Remotes:FindFirstChild("CommF_") or {}

local function upgradeStat(stat)
	task.spawn(function()
		while _G["Auto"..stat] do
			pcall(function()
				Remote:InvokeServer("AddPoint", stat, 1)
			end)
			wait(1)
		end
	end)
end

for _,stat in ipairs({"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}) do
	statsTab:CreateToggle({
		Name = "Auto " .. stat,
		CurrentValue = false,
		Flag = "Auto"..stat,
		Callback = function(state)
			_G["Auto"..stat] = state
			if state then upgradeStat(stat) end
		end
	})
end

-- Settings
settingsTab:CreateButton({
	Name = "Rejoindre la partie",
	Callback = function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer
