-- [[ CONFIGURATION & INITIALIZATION ]]
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Bikin folder penyimpanan di Delta/Workspace jika belum ada
if not isfolder("CheckpointMaker") then
    makefolder("CheckpointMaker")
end

-- Variabel Data Temporary untuk GUI 1 (Record)
local recordedCheckpoints = {}
local currentEditingIndex = nil

-- [[ LOAD RAYFIELD UI LIBRARY ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CP Maker & Player Tools",
   LoadingTitle = "Loading System...",
   LoadingSubtitle = "by Faisal",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- [[ MEMBUAT GUI 1 (RECORDING WINDOW VIA INSTANCE) ]]
-- GUI ini dibuat manual pakai Instance supaya bisa di-minimize jadi icon dan punya layout spesifik
local CheckpointGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ContentScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local NameInput = Instance.new("TextBox")
local SaveBtn = Instance.new("TextButton")
local MergeBtn = Instance.new("TextButton")
local ExtractBtn = Instance.new("TextButton")

-- Setup Mini Icon (untuk Fitur Minimize)
local MiniIcon = Instance.new("TextButton")

CheckpointGui.Name = "CP_Recorder_Gui"
CheckpointGui.Parent = game:CoreGui
CheckpointGui.ResetOnSpawn = false

-- Styling Main Frame (GUI 1)
MainFrame.Name = "MainFrame"
MainFrame.Parent = CheckpointGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- Biar bisa digeser
MainFrame.Visible = false -- Default mati, nanti dinyalakan via Toggle Rayfield

TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(0, 250, 0, 30)
TitleLabel.Text = "CP Recorder (GUI 1)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Parent = MainFrame
MinimizeBtn.Position = UDim2.new(0.85, 0, 0, 5)
MinimizeBtn.Size = UDim2.new(0, 45, 0, 20)
MinimizeBtn.Text = "_"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Textbox Ubah Nama CP sebelum Save
NameInput.Parent = MainFrame
NameInput.Position = UDim2.new(0.05, 0, 0.1, 0)
NameInput.Size = UDim2.new(0, 200, 0, 30)
NameInput.PlaceholderText = "Nama Checkpoint..."
NameInput.Text = ""
NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Tombol Save
SaveBtn.Parent = MainFrame
SaveBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
SaveBtn.Size = UDim2.new(0, 100, 0, 30)
SaveBtn.Text = "Save CP"
SaveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Tempat List Checkpoint
ContentScroll.Parent = MainFrame
ContentScroll.Position = UDim2.new(0.05, 0, 0.2, 0)
ContentScroll.Size = UDim2.new(0, 315, 0, 230)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

UIListLayout.Parent = ContentScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Tombol Bawah (Merge & Extract)
MergeBtn.Parent = MainFrame
MergeBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
MergeBtn.Size = UDim2.new(0, 150, 0, 35)
MergeBtn.Text = "Merge All CP"
MergeBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
MergeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ExtractBtn.Parent = MainFrame
ExtractBtn.Position = UDim2.new(0.52, 0, 0.82, 0)
ExtractBtn.Size = UDim2.new(0, 150, 0, 35)
ExtractBtn.Text = "Extract File (JSON)"
ExtractBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
ExtractBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Styling Mini Icon (Saat di-minimize)
MiniIcon.Parent = CheckpointGui
MiniIcon.Position = UDim2.new(0.05, 0, 0.1, 0)
MiniIcon.Size = UDim2.new(0, 40, 0, 40)
MiniIcon.Text = "📌"
MiniIcon.TextSize = 20
MiniIcon.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
MiniIcon.Visible = false
MiniIcon.Draggable = true

-- Fungsi Minimize Toggle
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniIcon.Visible = true
end)

MiniIcon.MouseButton1Click:Connect(function()
    MiniIcon.Visible = false
    MainFrame.Visible = true
end)

--- Helper: Refresh Tampilan List CP di GUI 1
local function refreshCpList()
    for _, item in pairs(ContentScroll:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    for index, cp in ipairs(recordedCheckpoints) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 35)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        ItemFrame.Parent = ContentScroll
        
        -- Tombol Teleport (Kiri)
        local TeleBtn = Instance.new("TextButton")
        TeleBtn.Size = UDim2.new(0, 30, 1, 0)
        TeleBtn.Text = "▶️"
        TeleBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        TeleBtn.Parent = ItemFrame
        TeleBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(cp.pos))
            end
        end)
        
        -- Nama CP & Edit Posisi Trigger
        local NameBtn = Instance.new("TextButton")
        NameBtn.Size = UDim2.new(0, 150, 1, 0)
        NameBtn.Position = UDim2.new(0, 35, 0, 0)
        NameBtn.Text = cp.name .. " (Edit Pos)"
        NameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameBtn.BackgroundTransparency = 1
        NameBtn.Parent = ItemFrame
        
        -- Edit CP (Mengubah posisi save ke posisi saat ini jika diklik)
        NameBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
                cp.pos = {currentPos.X, currentPos.Y, currentPos.Z}
                Rayfield:Notify({Name = "System", Content = "Posisi " .. cp.name .. " diperbarui!", Duration = 2})
            end
        end)
        
        -- Tombol Lock / Unlock Hapus
        local LockBtn = Instance.new("TextButton")
        LockBtn.Size = UDim2.new(0, 40, 1, 0)
        LockBtn.Position = UDim2.new(0, 190, 0, 0)
        LockBtn.Text = cp.locked and "🔒" or "🔓"
        LockBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
        LockBtn.Parent = ItemFrame
        
        LockBtn.MouseButton1Click:Connect(function()
            cp.locked = not cp.locked
            LockBtn.Text = cp.locked and "🔒" or "🔓"
        end)
        
        -- Tombol Hapus (Kanan)
        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0, 40, 1, 0)
        DelBtn.Position = UDim2.new(0, 235, 0, 0)
        DelBtn.Text = "❌"
        DelBtn.BackgroundColor3 = Color3.fromRGB(192, 41, 43)
        DelBtn.Parent = ItemFrame
        
        DelBtn.MouseButton1Click:Connect(function()
            if not cp.locked then
                table.remove(recordedCheckpoints, index)
                refreshCpList()
            else
                Rayfield:Notify({Name = "Peringatan", Content = "Checkpoint dikunci! Buka dulu untuk menghapus.", Duration = 2})
            end
        end)
    end
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, #recordedCheckpoints * 40)
end

-- Logika Tombol Save CP Baru
SaveBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local p = LocalPlayer.Character.HumanoidRootPart.Position
        local cpName = NameInput.Text ~= "" and NameInput.Text or ("CP " .. (#recordedCheckpoints + 1))
        
        table.insert(recordedCheckpoints, {
            name = cpName,
            pos = {p.X, p.Y, p.Z},
            locked = false
        })
        NameInput.Text = ""
        refreshCpList()
    end
end)

-- Merge CP (Menyusun urutan) & Extract File JSON
ExtractBtn.MouseButton1Click:Connect(function()
    if #recordedCheckpoints == 0 then return end
    local filename = "CheckpointMaker/merged_cp_" .. os.time() .. ".json"
    local dataString = HttpService:JSONEncode(recordedCheckpoints)
    writefile(filename, dataString)
    Rayfield:Notify({Name = "Success", Content = "File diekstrak ke: " .. filename, Duration = 3})
end)

-- Hapus Semua CP (Tombol Tambahan di GUI 1)
local ClearAllBtn = Instance.new("TextButton")
ClearAllBtn.Parent = MainFrame
ClearAllBtn.Position = UDim2.new(0.05, 0, 0.73, 0)
ClearAllBtn.Size = UDim2.new(0, 315, 0, 25)
ClearAllBtn.Text = "Hapus Semua CP yang tidak Terkunci"
ClearAllBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
ClearAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearAllBtn.MouseButton1Click:Connect(function()
    for i = #recordedCheckpoints, 1, -1 do
        if not recordedCheckpoints[i].locked then
            table.remove(recordedCheckpoints, i)
        end
    end
    refreshCpList()
end)


-- [[ RAYFIELD MENU TAB 1: RECORD ]]
local RecordTab = Window:CreateTab("Record", 4483362458)

RecordTab:CreateToggle({
   Name = "Aktifkan GUI 1 (Recorder)",
   CurrentValue = false,
   Callback = function(Value)
      MainFrame.Visible = Value
      if not Value then MiniIcon.Visible = false end
   end,
})


-- [[ RAYFIELD MENU TAB 2: LOAD & PLAYER ]]
local LoadTab = Window:CreateTab("Load & Run", 4483362458)

local targetFile = ""
local loopActive = false
local tpCooldown = 1000 -- dalam milidetik (1 detik default)
local runStatus = false

-- Ambil List File JSON dari Workspace
local function getJsonFiles()
    local files = listfiles("CheckpointMaker")
    local list = {}
    for _, f in pairs(files) do
        if f:sub(-5) == ".json" then
            table.insert(list, f)
        end
    end
    return list
end

local FileDropdown = LoadTab:CreateDropdown({
   Name = "Pilih File CP",
   Options = getJsonFiles(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
      targetFile = Option[1]
   end,
})

LoadTab:CreateButton({
   Name = "Refresh Daftar File",
   Callback = function()
       FileDropdown:Refresh(getJsonFiles(), {""})
   end,
})

LoadTab:CreateInput({
   Name = "Cooldown TP (Milidetik)",
   PlaceholderText = "1000 = 1 detik",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then tpCooldown = num end
   end,
})

LoadTab:CreateToggle({
   Name = "Looping Playback",
   CurrentValue = false,
   Callback = function(Value)
      loopActive = Value
   end,
})

LoadTab:CreateButton({
   Name = "Hapus File CP Terpilih",
   Callback = function()
       if targetFile ~= "" and isfile(targetFile) then
           delfile(targetFile)
           targetFile = ""
           FileDropdown:Refresh(getJsonFiles(), {""})
           Rayfield:Notify({Name = "Deleted", Content = "File berhasil dihapus.", Duration = 2})
       end
   end,
})

-- Layout Play/Stop Mengambang (Toggle Show/Hide)
local FloatControlGui = Instance.new("ScreenGui")
local ControlFrame = Instance.new("Frame")
local StartBtn = Instance.new("TextButton")
local StopBtn = Instance.new("TextButton")

FloatControlGui.Name = "FloatControl"
FloatControlGui.Parent = game:CoreGui

ControlFrame.Size = UDim2.new(0, 200, 0, 50)
ControlFrame.Position = UDim2.new(0.4, 0, 0.05, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlFrame.Active = true
ControlFrame.Draggable = true
ControlFrame.Visible = false
ControlFrame.Parent = FloatControlGui

StartBtn.Size = UDim2.new(0, 95, 1, 0)
StartBtn.Text = "PLAY"
StartBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Parent = ControlFrame

StopBtn.Size = UDim2.new(0, 95, 1, 0)
StopBtn.Position = UDim2.new(0, 105, 0, 0)
StopBtn.Text = "STOP"
StopBtn.BackgroundColor3 = Color3.fromRGB(192, 41, 43)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Parent = ControlFrame

LoadTab:CreateToggle({
   Name = "Tampilkan Tombol Play/Stop Melayang",
   CurrentValue = false,
   Callback = function(Value)
      ControlFrame.Visible = Value
   end,
})

-- LOGIKA JALANNYA CP PLAYER TELEPORT
local function runTeleportation()
    if targetFile == "" or not isfile(targetFile) then return end
    local rawData = readfile(targetFile)
    local cpData = HttpService:JSONDecode(rawData)
    
    runStatus = true
    
    repeat
        for _, cp in ipairs(cpData) do
            if not runStatus then break end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(unpack(cp.pos))
            end
            task.wait(tpCooldown / 1000)
        end
    until not loopActive or not runStatus
end

StartBtn.MouseButton1Click:Connect(function()
    if not runStatus then
        task.spawn(runTeleportation)
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    runStatus = false
end)


-- [[ RAYFIELD MENU TAB 3: PLAYER FEATURES ]]
local PlayerTab = Window:CreateTab("Player Features", 4483362458)

-- 1. Invisible Semi Transparan
local invisibleActive = false
PlayerTab:CreateToggle({
   Name = "Semi-Transparan Invisible",
   CurrentValue = false,
   Callback = function(Value)
      invisibleActive = Value
      local char = LocalPlayer.Character
      if char then
          for _, part in pairs(char:GetDescendants()) do
              if part:IsA("BasePart") or part:IsA("Decal") then
                  if part.Name ~= "HumanoidRootPart" then
                      -- Mengubah transparansi di client (POV kamu masih kelihatan dikit)
                      part.LocalTransparencyModifier = Value and 0.7 or 0
                  end
              end
          end
      end
   end,
})

-- 2. ESP Player
local espActive = false
PlayerTab:CreateToggle({
   Name = "ESP Player",
   CurrentValue = false,
   Callback = function(Value)
       espActive = Value
       if Value then
           task.spawn(function()
               while espActive do
                   for _, p in pairs(Players:GetPlayers()) do
                       if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not p.Character:FindFirstChild("ESPHighlight") then
                           local highlight = Instance.new("Highlight")
                           highlight.Name = "ESPHighlight"
                           highlight.FillColor = Color3.fromRGB(255, 0, 0)
                           highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                           highlight.FillTransparency = 0.5
                           highlight.Parent = p.Character
                       end
                   end
                   task.wait(2)
               end
           end)
       else
           for _, p in pairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                   p.Character.ESPHighlight:Destroy()
               end
           end
       end
   end,
})

-- 3. Fly Script Manual
local flying = false
local flySpeed = 50
local cstand
local uis = game:GetService("UserInputService")

PlayerTab:CreateToggle({
   Name = "Fly (Terbang)",
   CurrentValue = false,
   Callback = function(Value)
      flying = Value
      local char = LocalPlayer.Character
      local hrp = char and char:FindFirstChild("HumanoidRootPart")
      if not hrp then return end
      
      if flying then
          local bv = Instance.new("BodyVelocity", hrp)
          bv.Name = "FlyBV"
          bv.MaxForce = Vector3.new(4e4, 4e4, 4e4)
          bv.Velocity = Vector3.zero
          
          task.spawn(function()
              while flying and hrp and bv.Parent do
                  local cam = workspace.CurrentCamera.CFrame
                  local moveDirection = Vector3.zero
                  
                  if uis:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cam.LookVector end
                  if uis:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cam.LookVector end
                  if uis:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cam.RightVector end
                  if uis:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cam.RightVector end
                  
                  bv.Velocity = moveDirection.Unit * flySpeed
                  if moveDirection == Vector3.zero then bv.Velocity = Vector3.zero end
                  task.wait()
              end
              if bv then bv:Destroy() end
          end)
      else
          if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Fly Speed",
   Min = 10,
   Max = 200,
   CurrentValue = 50,
   Flag = "SliderFly",
   Callback = function(Value)
      flySpeed = Value
   end,
})

-- 4. Anti AFK
PlayerTab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = true, -- Default nyala biar aman
   Callback = function(Value)
      if Value then
          local vu = game:GetService("VirtualUser")
          LocalPlayer.Idled:Connect(function()
              vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
              task.wait(1)
              vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
          end)
      end
   end,
})
