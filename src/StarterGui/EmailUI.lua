--[[
	EmailUI.lua
	Job email system - displays available jobs in the "Jobs" tab of the Tablet.
	Players browse emails from clients and accept renovation jobs.
	Location: StarterGui/EmailUI (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JobData = require(ReplicatedStorage.Config.JobData)
local Utils = require(ReplicatedStorage.Shared.Utils)

local player = Players.LocalPlayer

local EmailUI = {}

EmailUI._selectedJob = nil
EmailUI._availableJobs = {}

function EmailUI.init(tabletUI)
	EmailUI._tabletUI = tabletUI
	task.wait(0.5)

	local jobsPage = tabletUI.getPage("Jobs")
	if not jobsPage then return end

	-- Split layout: email list on left, email detail on right
	local listFrame = Instance.new("Frame")
	listFrame.Name = "EmailList"
	listFrame.Size = UDim2.new(0.4, -5, 1, 0)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	listFrame.Parent = jobsPage

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 8)
	listCorner.Parent = listFrame

	local listScroll = Instance.new("ScrollingFrame")
	listScroll.Name = "ListScroll"
	listScroll.Size = UDim2.new(1, -8, 1, -8)
	listScroll.Position = UDim2.new(0, 4, 0, 4)
	listScroll.BackgroundTransparency = 1
	listScroll.ScrollBarThickness = 4
	listScroll.Parent = listFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = listScroll

	-- Detail panel
	local detailFrame = Instance.new("Frame")
	detailFrame.Name = "EmailDetail"
	detailFrame.Size = UDim2.new(0.6, -5, 1, 0)
	detailFrame.Position = UDim2.new(0.4, 5, 0, 0)
	detailFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	detailFrame.Parent = jobsPage

	local detailCorner = Instance.new("UICorner")
	detailCorner.CornerRadius = UDim.new(0, 8)
	detailCorner.Parent = detailFrame

	-- Detail content
	local fromLabel = Instance.new("TextLabel")
	fromLabel.Name = "FromLabel"
	fromLabel.Size = UDim2.new(1, -20, 0, 20)
	fromLabel.Position = UDim2.new(0, 10, 0, 10)
	fromLabel.BackgroundTransparency = 1
	fromLabel.Text = "From: Select an email"
	fromLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
	fromLabel.Font = Enum.Font.Gotham
	fromLabel.TextSize = 12
	fromLabel.TextXAlignment = Enum.TextXAlignment.Left
	fromLabel.Parent = detailFrame

	local subjectLabel = Instance.new("TextLabel")
	subjectLabel.Name = "SubjectLabel"
	subjectLabel.Size = UDim2.new(1, -20, 0, 25)
	subjectLabel.Position = UDim2.new(0, 10, 0, 32)
	subjectLabel.BackgroundTransparency = 1
	subjectLabel.Text = ""
	subjectLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	subjectLabel.Font = Enum.Font.GothamBold
	subjectLabel.TextSize = 16
	subjectLabel.TextXAlignment = Enum.TextXAlignment.Left
	subjectLabel.Parent = detailFrame

	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, -20, 0, 1)
	separator.Position = UDim2.new(0, 10, 0, 62)
	separator.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	separator.BorderSizePixel = 0
	separator.Parent = detailFrame

	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.Name = "BodyLabel"
	bodyLabel.Size = UDim2.new(1, -20, 0, 80)
	bodyLabel.Position = UDim2.new(0, 10, 0, 70)
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Text = ""
	bodyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	bodyLabel.Font = Enum.Font.Gotham
	bodyLabel.TextSize = 13
	bodyLabel.TextWrapped = true
	bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	bodyLabel.Parent = detailFrame

	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Name = "RewardLabel"
	rewardLabel.Size = UDim2.new(1, -20, 0, 25)
	rewardLabel.Position = UDim2.new(0, 10, 0, 155)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Text = ""
	rewardLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.TextSize = 15
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardLabel.Parent = detailFrame

	-- Tasks list in detail
	local tasksTitle = Instance.new("TextLabel")
	tasksTitle.Name = "TasksTitle"
	tasksTitle.Size = UDim2.new(1, -20, 0, 20)
	tasksTitle.Position = UDim2.new(0, 10, 0, 185)
	tasksTitle.BackgroundTransparency = 1
	tasksTitle.Text = ""
	tasksTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
	tasksTitle.Font = Enum.Font.GothamBold
	tasksTitle.TextSize = 13
	tasksTitle.TextXAlignment = Enum.TextXAlignment.Left
	tasksTitle.Parent = detailFrame

	local tasksFrame = Instance.new("Frame")
	tasksFrame.Name = "TasksFrame"
	tasksFrame.Size = UDim2.new(1, -20, 0, 120)
	tasksFrame.Position = UDim2.new(0, 10, 0, 208)
	tasksFrame.BackgroundTransparency = 1
	tasksFrame.Parent = detailFrame

	local tasksLayout = Instance.new("UIListLayout")
	tasksLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tasksLayout.Padding = UDim.new(0, 3)
	tasksLayout.Parent = tasksFrame

	-- Accept button
	local acceptBtn = Instance.new("TextButton")
	acceptBtn.Name = "AcceptButton"
	acceptBtn.Size = UDim2.new(0, 200, 0, 40)
	acceptBtn.Position = UDim2.new(0.5, -100, 1, -55)
	acceptBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
	acceptBtn.Text = "Accept Job"
	acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	acceptBtn.Font = Enum.Font.GothamBold
	acceptBtn.TextSize = 16
	acceptBtn.Visible = false
	acceptBtn.Parent = detailFrame

	local acceptCorner = Instance.new("UICorner")
	acceptCorner.CornerRadius = UDim.new(0, 8)
	acceptCorner.Parent = acceptBtn

	acceptBtn.MouseButton1Click:Connect(function()
		if EmailUI._selectedJob then
			EmailUI._acceptJob(EmailUI._selectedJob.id)
		end
	end)

	-- Store references
	EmailUI._listScroll = listScroll
	EmailUI._fromLabel = fromLabel
	EmailUI._subjectLabel = subjectLabel
	EmailUI._bodyLabel = bodyLabel
	EmailUI._rewardLabel = rewardLabel
	EmailUI._tasksTitle = tasksTitle
	EmailUI._tasksFrame = tasksFrame
	EmailUI._acceptBtn = acceptBtn

	-- Listen for job list updates
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local events = remotes:WaitForChild("Events")
	events:WaitForChild("JobListUpdated").OnClientEvent:Connect(function(jobs)
		EmailUI._availableJobs = jobs
		EmailUI._refreshEmailList()
	end)

	print("[EmailUI] Initialized")
end

function EmailUI._refreshEmailList()
	-- Clear existing emails
	for _, child in ipairs(EmailUI._listScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for i, job in ipairs(EmailUI._availableJobs) do
		local emailBtn = Instance.new("TextButton")
		emailBtn.Name = "Email_" .. job.id
		emailBtn.Size = UDim2.new(1, 0, 0, 55)
		emailBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		emailBtn.AutoButtonColor = true
		emailBtn.LayoutOrder = i
		emailBtn.Parent = EmailUI._listScroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = emailBtn

		-- Sender name
		local sender = Instance.new("TextLabel")
		sender.Size = UDim2.new(1, -10, 0, 18)
		sender.Position = UDim2.new(0, 8, 0, 4)
		sender.BackgroundTransparency = 1
		sender.Text = job.client
		sender.TextColor3 = Color3.fromRGB(255, 255, 255)
		sender.Font = Enum.Font.GothamBold
		sender.TextSize = 12
		sender.TextXAlignment = Enum.TextXAlignment.Left
		sender.Parent = emailBtn

		-- Subject preview
		local subject = Instance.new("TextLabel")
		subject.Size = UDim2.new(1, -10, 0, 16)
		subject.Position = UDim2.new(0, 8, 0, 22)
		subject.BackgroundTransparency = 1
		subject.Text = job.subject
		subject.TextColor3 = Color3.fromRGB(180, 180, 200)
		subject.Font = Enum.Font.Gotham
		subject.TextSize = 11
		subject.TextXAlignment = Enum.TextXAlignment.Left
		subject.TextTruncate = Enum.TextTruncate.AtEnd
		subject.Parent = emailBtn

		-- Reward preview
		local reward = Instance.new("TextLabel")
		reward.Size = UDim2.new(1, -10, 0, 14)
		reward.Position = UDim2.new(0, 8, 0, 38)
		reward.BackgroundTransparency = 1
		reward.Text = Utils.formatMoney(job.reward)
		reward.TextColor3 = Color3.fromRGB(100, 255, 100)
		reward.Font = Enum.Font.Gotham
		reward.TextSize = 11
		reward.TextXAlignment = Enum.TextXAlignment.Left
		reward.Parent = emailBtn

		emailBtn.MouseButton1Click:Connect(function()
			EmailUI._selectJob(job)
		end)
	end
end

function EmailUI._selectJob(job)
	EmailUI._selectedJob = job

	EmailUI._fromLabel.Text = "From: " .. job.client
	EmailUI._subjectLabel.Text = job.subject
	EmailUI._bodyLabel.Text = job.description
	EmailUI._rewardLabel.Text = "Reward: " .. Utils.formatMoney(job.reward)
	EmailUI._tasksTitle.Text = "Tasks:"
	EmailUI._acceptBtn.Visible = true

	-- Clear and populate tasks
	for _, child in ipairs(EmailUI._tasksFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	for i, taskInfo in ipairs(job.tasks) do
		local taskLabel = Instance.new("TextLabel")
		taskLabel.Size = UDim2.new(1, 0, 0, 18)
		taskLabel.BackgroundTransparency = 1
		taskLabel.Text = "  - " .. taskInfo.description .. " (x" .. taskInfo.count .. ")"
		taskLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		taskLabel.Font = Enum.Font.Gotham
		taskLabel.TextSize = 12
		taskLabel.TextXAlignment = Enum.TextXAlignment.Left
		taskLabel.LayoutOrder = i
		taskLabel.Parent = EmailUI._tasksFrame
	end

	-- Show if this job unlocks a tool
	if job.unlocksTool then
		local ToolConfig = require(ReplicatedStorage.Config.ToolConfig)
		local toolDef = ToolConfig.Tools[job.unlocksTool]
		if toolDef then
			local unlockLabel = Instance.new("TextLabel")
			unlockLabel.Size = UDim2.new(1, 0, 0, 18)
			unlockLabel.BackgroundTransparency = 1
			unlockLabel.Text = "  Unlocks: " .. toolDef.displayName
			unlockLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
			unlockLabel.Font = Enum.Font.GothamBold
			unlockLabel.TextSize = 12
			unlockLabel.TextXAlignment = Enum.TextXAlignment.Left
			unlockLabel.LayoutOrder = 100
			unlockLabel.Parent = EmailUI._tasksFrame
		end
	end
end

function EmailUI._acceptJob(jobId)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local events = remotes:FindFirstChild("Events")
		if events then
			local acceptEvent = events:FindFirstChild("AcceptJob")
			if acceptEvent then
				acceptEvent:FireServer(jobId)
			end
		end
	end

	-- Close tablet
	if EmailUI._tabletUI then
		EmailUI._tabletUI.close()
	end
end

return EmailUI
