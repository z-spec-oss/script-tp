-- ==========================================-- SCRIPT TP & CHECKPOINT MAKER (RAYFIELD + CUSTOM RECORD GUI)-- ==========================================
-- Pastikan folder penyimpanan ada di folder Workspace Executorif not isfolder("CP_Record_Data") then
    makefolder("CP_Record_Data")end
-- Variabel Global / Statelocal HttpService = game:GetService("HttpService")local Players = game:GetService("Players")local LocalPlayer = Players.LocalPlayerlocal TweenService = game:GetService("TweenService")local RunService = game:GetService("RunService")
local Checkpoints = {} -- Menyimpan data CP sementara {name, pos, locked}local LoadedCPs = {}   -- Menyimpan data CP yang dimuat dari filelocal TeleportLoop = falselocal CooldownTP = 1.0 -- Default 1 detiklocal FlySpeed = 50local Flying = false
-- Memuat Pustaka Utama Rayfieldlocal Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()
local Window = Rayfield:CreateWindow({
   Name = "CP Maker & Teleport Hub",
   LoadingTitle = "Memuat Fitur...",
   LoadingSubtitle = "oleh z-spec-oss",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})
-- ==========================================-- MEMBUAT GUI 1 (CUSTOM RECORD WINDOW) VIA CORE_GUI-- ==========================================local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CP_Record_Gui1"
ScreenGui.ResetOnSpawn = false-- Proteksi agar tidak terdeteksi game biasa (jargon fungsi umum executor)
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")end)
-- Main Frame GUI 1local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true -- Agar bisa digeser-geser di layar
MainFrame.Parent = ScreenGui
-- Efek Pojok Melengkung GUI 1local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame
-- Judul GUI 1local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 240, 0, 40)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GUI 1: Record CP"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame
-- Tombol Minimize GUI 1local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -40, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
-- Icon kecil saat Di-minimizelocal MinIcon = Instance.new("TextButton")
MinIcon.Size = UDim2.new(0, 50, 0, 50)
MinIcon.Position = UDim2.new(0.02, 0, 0.5, 0)
MinIcon.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MinIcon.Text = "REC"
MinIcon.Font = Enum.Font.SourceSansBold
MinIcon.TextSize = 14
MinIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MinIcon.Visible = false
MinIcon.Parent = ScreenGui
Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(0, 25)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinIcon.Visible = trueend)
MinIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinIcon.Visible = falseend)
-- Textbox Ubah Nama CP Barulocal NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 300, 0, 35)
NameInput.Position = UDim2.new(0, 10, 0, 45)
NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
NameInput.Text = "Nama_CP_Anda"
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.Parent = MainFrame
Instance.new("UICorner", NameInput).CornerRadius = UDim.new(0, 6)
-- Kontainer Scrolling List CPlocal ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0, 300, 0, 220)
ScrollList.Position = UDim2.new(0, 10, 0, 90)
ScrollList.BackgroundTransparency = 1
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.Parent = MainFrame
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollList
-- Fungsi Refresh Tampilan Daftar Checkpoint di GUI 1local function RefreshList()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for i, cp in ipairs(Checkpoints) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 40)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        ItemFrame.Parent = ScrollList
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)
        
        -- Tombol Teleport (Kiri)
        local TeleBtn = Instance.new("TextButton")
        TeleBtn.Size = UDim2.new(0, 30, 1, 0)
        TeleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        TeleBtn.Text = "▶"
        TeleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TeleBtn.Parent = ItemFrame
        TeleBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(cp.pos[1], cp.pos[2], cp.pos[3])
            end
        end)
        
        -- Nama CP
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0, 140, 1, 0)
        NameLbl.Position = UDim2.new(0, 35, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = tostring(i) .. ". " .. cp.name
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.Parent = ItemFrame
        
        -- Tombol Edit Posisi (Ubah koordinat ke posisi saat ini)
        local EditPosBtn = Instance.new("TextButton")
        EditPosBtn.Size = UDim2.new(0, 40, 0, 30)
        EditPosBtn.Position = UDim2.new(0, 180, 0, 5)
        EditPosBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
        EditPosBtn.Text = "Edit"
        EditPosBtn.TextSize = 11
        EditPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        EditPosBtn.Parent = ItemFrame
        EditPosBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local p = LocalPlayer.Character.HumanoidRootPart.Position
                cp.pos = {p.X, p.Y, p.Z}
                Rayfield:Notify({Title="Berhasil", Content="Posisi CP " .. cp.name .. " diperbarui!"})
            end
        end)

        -- Tombol Lock (Gembok agar tidak terhapus)
        local LockBtn = Instance.new("TextButton")
        LockBtn.Size = UDim2.new(0, 30, 0, 30)
        LockBtn.Position = UDim2.new(0, 225, 0, 5)
        LockBtn.BackgroundColor3 = cp.locked and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(100, 100, 100)
        LockBtn.Text = cp.locked and "🔒" or "🔓"
        LockBtn.Parent = ItemFrame
        LockBtn.MouseButton1Click:Connect(function()
            cp.locked = not cp.locked
            RefreshList()
        end)
        
        -- Tombol Hapus Individual
        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0, 30, 0, 30)
        DelBtn.Position = UDim2.new(0, 260, 0, 5)
        DelBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        DelBtn.Text = "X"
        DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DelBtn.Parent = ItemFrame
        DelBtn.MouseButton1Click:Connect(function()
            if not cp.locked then
                table.remove(Checkpoints, i)
                RefreshList()
            else
                Rayfield:Notify({Title="Gagal", Content="CP ini dikunci!"})
            end
        end)
    end
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)end
-- Tombol Aksi Bawah (Save, Delete All, Merge/Extract)local SaveCPBtn = Instance.new("TextButton")
SaveCPBtn.Size = UDim2.new(0, 140, 0, 35)
SaveCPBtn.Position = UDim2.new(0, 10, 0, 320)
SaveCPBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
SaveCPBtn.Text = "+ Save Position"
SaveCPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveCPBtn.Parent = MainFrame

SaveCPBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        table.insert(Checkpoints, {
            name = NameInput.Text,
            pos = {pos.X, pos.Y, pos.Z},
            locked = false
        })
        RefreshList()
    endend)
local DelAllBtn = Instance.new("TextButton")
DelAllBtn.Size = UDim2.new(0, 140, 0, 35)
DelAllBtn.Position = UDim2.new(0, 170, 0, 320)
DelAllBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
DelAllBtn.Text = "🗑 Delete All Unlocked"
DelAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DelAllBtn.Parent = MainFrame

DelAllBtn.MouseButton1Click:Connect(function()
    for i = #Checkpoints, 1, -1 do
        if not Checkpoints[i].locked then
            table.remove(Checkpoints, i)
        end
    end
    RefreshList()end)
-- Tombol Merged & Extract File JSONlocal ExtractBtn = Instance.new("TextButton")
ExtractBtn.Size = UDim2.new(0, 300, 0, 30)
ExtractBtn.Position = UDim2.new(0, 10, 0, 360)
ExtractBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
ExtractBtn.Text = "📦 Merge & Extract File (Save JSON)"
ExtractBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtractBtn.Parent = MainFrame

ExtractBtn.MouseButton1Click:Connect(function()
    if #Checkpoints == 0 then
        Rayfield:Notify({Title="Eror", Content="Tidak ada CP yang bisa di-extract!"})
        return
    end

local filename = "CP_Record_Data/" .. NameInput.Text .. ".json"
local dataString = HttpService:JSONEncode(Checkpoints)
writefile(filename, dataString)
Rayfield:Notify({Title="Sukses", Content="File tersimpan sebagai: " .. NameInput.Text .. ".json"})
end)
-- ==========================================
-- LAYOUT FLOATING PLAY/STOP (DI LUAR RAYFIELD)
-- ==========================================
local FloatGui = Instance.new("Frame")
FloatGui.Name = "FloatingControl"
FloatGui.Size = UDim2.new(0, 160, 0, 45)
FloatGui.Position = UDim2.new(0.5, -80, 0.05, 0)
FloatGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatGui.Visible = false
FloatGui.Active = true
FloatGui.Draggable = true
FloatGui.Parent = ScreenGui
Instance.new("UICorner", FloatGui).CornerRadius = UDim.new(0, 6)
local FloatPlay = Instance.new("TextButton")
FloatPlay.Size = UDim2.new(0, 70, 0, 35)
FloatPlay.Position = UDim2.new(0, 5, 0, 5)
FloatPlay.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
FloatPlay.Text = "PLAY"
FloatPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatPlay.Font = Enum.Font.SourceSansBold
FloatPlay.Parent = FloatGui
local FloatStop = Instance.new("TextButton")
FloatStop.Size = UDim2.new(0, 70, 0, 35)
FloatStop.Position = UDim2.new(0, 85, 0, 5)
FloatStop.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
FloatStop.Text = "STOP"
FloatStop.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatStop.Font = Enum.Font.SourceSansBold
FloatStop.Parent = FloatGui
-- ==========================================
-- RAYFIELD TAB 1: RECORD & MAKER
-- ==========================================
local RecordTab = Window:CreateTab("Record", 4483362458)
RecordTab:CreateToggle({
Name = "Aktifkan GUI 1 (Checkpoint Maker)",
CurrentValue = false,
Flag = "Toggle_Gui1",
Callback = function(Value)
MainFrame.Visible = Value
if not Value then MinIcon.Visible = false end
end,
})
-- ==========================================
-- RAYFIELD TAB 2: LOAD & AUTOMATION
-- ==========================================
local LoadTab = Window:CreateTab("Load CP", 4483362458)
local SelectedFile = ""
local FileDropdown
-- Fungsi mendata ulang file JSON yang ada di folder workspace
local function GetFiles()
local files = listfiles("CP_Record_Data")
local cleanNames = {}
for _, f in pairs(files) do
local name = f:match("([^/\]+)$")
table.insert(cleanNames, name)
end
return cleanNames
end
FileDropdown = LoadTab:CreateDropdown({
Name = "Pilih File CP JSON",
Options = GetFiles(),
CurrentOption = "",
MultipleOptions = false,
Flag = "DropdownFiles",
Callback = function(Option)
SelectedFile = Option[1]
end,
})
LoadTab:CreateButton({
Name = "🔄 Refresh Daftar File",
Callback = function()
FileDropdown:Refresh(GetFiles(), true)
end,
})
LoadTab:CreateButton({
Name = "📂 Load Checkpoints Pilihan",
Callback = function()
if SelectedFile == "" then
Rayfield:Notify({Title="Eror", Content="Pilih file terlebih dahulu!"})
return
end
local path = "CP_Record_Data/" .. SelectedFile
if isfile(path) then
LoadedCPs = HttpService:JSONDecode(readfile(path))
Rayfield:Notify({Title="Berhasil", Content="Memuat " .. #LoadedCPs .. " titik Checkpoint."})
end
end,
})
LoadTab:CreateTextBox({
Name = "Cooldown Teleport (Detik/Milidetik)",
DefaultXPlayer = "1.0",
PlaceholderText = "Contoh: 0.5 atau 2",
RemoveTextAfterFocusLost = false,
Callback = function(Text)
local num = tonumber(Text)
if num then CooldownTP = num end
end,
})
LoadTab:CreateToggle({
Name = "Loop Teleportation (Mengulang otomatis)",
CurrentValue = false,
Flag = "LoopTP",
Callback = function(Value)
TeleportLoop = Value
end,
})
LoadTab:CreateToggle({
Name = "Tampilkan Widget Floating PLAY/STOP",
CurrentValue = false,
Flag = "ShowWidget",
Callback = function(Value)
FloatGui.Visible = Value
end,
})
-- Fungsi Inti Eksekusi Sequence Jalur Teleportasi
local function StartSequence()
if #LoadedCPs == 0 then
Rayfield:Notify({Title="Gagal", Content="Data CP kosong! Load file dulu."})
return
end
_G.RunningCP = true
task.spawn(function()
while _G.RunningCP do
for idx, cp in ipairs(LoadedCPs) do
if not _G.RunningCP then break end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(cp.pos[1], cp.pos, cp.pos)
end
task.wait(CooldownTP)
end
if not TeleportLoop then
_G.RunningCP = false
break
end
end
end)
end
local function StopSequence()
_G.RunningCP = false
end
FloatPlay.MouseButton1Click:Connect(StartSequence)
FloatStop.MouseButton1Click:Connect(StopSequence)
LoadTab:CreateButton({
Name = "🗑 Hapus File Terpilih Tersebut",
Callback = function()
if SelectedFile ~= "" and isfile("CP_Record_Data/" .. SelectedFile) then
delfile("CP_Record_Data/" .. SelectedFile)
FileDropdown:Refresh(GetFiles(), true)
LoadedCPs = {}
Rayfield:Notify({Title="Terhapus", Content="File " .. SelectedFile .. " berhasil dibuang."})
end
end,
})
-- ==========================================
-- RAYFIELD TAB 3: FITUR PLAYER
-- ==========================================
local PlayerTab = Window:CreateTab("Player", 4483362458)
-- 1. Semi Invisible
local InvisibleActive = false
PlayerTab:CreateToggle({
Name = "Invisible (Semi-Transparan)",
CurrentValue = false,
Flag = "Invis",
Callback = function(Value)
InvisibleActive = Value
task.spawn(function()
while InvisibleActive and task.wait(1) do
pcall(function()
for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
if part:IsA("BasePart") or part:IsA("Decal") then
if part.Name ~= "HumanoidRootPart" then
part.Transparency = 0.7 -- Transparan di POV kita & orang lain
end
end
end
end)
end
end)
end,
})
-- 2. ESP Players
local ESPActive = false
local function CreateESP(ply)
if ply == LocalPlayer then return end
local function Apply()
local char = ply.Character or ply.CharacterAdded:Wait()
local box = char:FindFirstChild("HighlightESP") or Instance.new("Highlight")
box.Name = "HighlightESP"
box.FillColor = Color3.fromRGB(255, 0, 0)
box.OutlineColor = Color3.fromRGB(255, 255, 255)
box.FillTransparency = 0.5
box.Parent = char
end
ply.CharacterAdded:Connect(Apply)
if ply.Character then Apply() end
end
PlayerTab:CreateToggle({
Name = "ESP Player",
CurrentValue = false,
Flag = "ESP",
Callback = function(Value)
ESPActive = Value
if Value then
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
else
for _, p in pairs(Players:GetPlayers()) do
if p.Character and p.Character:FindFirstChild("HighlightESP") then
p.Character.HighlightESP:Destroy()
end
end
end
end,
})
-- 3. Fly Mode
PlayerTab:CreateToggle({
Name = "Fly (Terbang)",
CurrentValue = false,
Flag = "FlyToggle",
Callback = function(Value)
Flying = Value
if Flying then
local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local bv = Instance.new("BodyVelocity", hrp)
bv.Velocity = Vector3.new(0,0,0)
bv.MaxForce = Vector3.new(1,1,1) * 9e9
task.spawn(function()
while Flying do
RunService.RenderStepped:Wait()
local moveDirection = Vector3.new()
local uis = game:GetService("UserInputService")
if uis:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
if uis:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
if uis:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
if uis:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
bv.Velocity = moveDirection.Unit * FlySpeed
if moveDirection == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
end
bv:Destroy()
end)
end
end,
})
PlayerTab:CreateSlider({
Name = "Kecepatan Terbang (Fly Speed)",
Min = 10, Max = 200, DefaultValue = 50,
Color = Color3.fromRGB(0, 120, 255),
Callback = function(Value)
FlySpeed = Value
end,
})
-- 4. Anti-AFK
PlayerTab:CreateToggle({
Name = "Anti AFK Kick",
CurrentValue = false,
Flag = "AntiAFK",
Callback = function(Value)
if Value then
local vu = game:GetService("VirtualUser")
_G.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(1)
vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
else
if _G.AntiAFKConnection then
_G.AntiAFKConnection:Disconnect()
end
end
end,
})
