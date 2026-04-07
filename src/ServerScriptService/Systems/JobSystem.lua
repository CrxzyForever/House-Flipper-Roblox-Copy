--[[
	JobSystem.lua
	Handles job assignment, progress tracking, completion, and rewards.
	Location: ServerScriptService/Systems/JobSystem
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JobData = require(ReplicatedStorage.Config.JobData)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local ToolConfig = require(ReplicatedStorage.Config.ToolConfig)
local RemoteManager = require(script.Parent.Parent.Core.RemoteManager)
local PlayerDataManager = require(script.Parent.Parent.Core.PlayerDataManager)

local JobSystem = {}

-- Track active jobs per player: {[userId] = {jobId, progress = {taskIndex = count}}}
JobSystem._activeJobs = {}

function JobSystem.init()
	-- Listen for job acceptance
	local acceptJobEvent = RemoteManager.getEvent("AcceptJob")
	if acceptJobEvent then
		acceptJobEvent.OnServerEvent:Connect(function(player, jobId)
			JobSystem.acceptJob(player, jobId)
		end)
	end

	-- Listen for task completion reports from client
	local taskProgressEvent = RemoteManager.getEvent("JobTaskProgress")
	if taskProgressEvent then
		taskProgressEvent.OnServerEvent:Connect(function(player, taskIndex, incrementAmount)
			JobSystem.updateTaskProgress(player, taskIndex, incrementAmount)
		end)
	end

	-- Setup remote function for available jobs
	local getJobsFunc = RemoteManager.getFunction("GetAvailableJobs")
	if getJobsFunc then
		getJobsFunc.OnServerInvoke = function(player)
			local data = PlayerDataManager.getData(player)
			if data then
				return JobData.getAvailableJobs(data.completedJobs)
			end
			return {}
		end
	end

	print("[JobSystem] Initialized")
end

function JobSystem.acceptJob(player, jobId)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	-- Check if player already has an active job
	if data.currentJobId then
		local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
		if notifyEvent then
			notifyEvent:FireClient(player, "You already have an active job! Complete or abandon it first.")
		end
		return
	end

	-- Verify job is available
	local job = JobData.getById(jobId)
	if not job then return end

	-- Check prerequisites
	if job.prerequisite then
		local prereqMet = false
		for _, completedId in ipairs(data.completedJobs) do
			if completedId == job.prerequisite then
				prereqMet = true
				break
			end
		end
		if not prereqMet then
			local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
			if notifyEvent then
				notifyEvent:FireClient(player, "You need to complete a prerequisite job first!")
			end
			return
		end
	end

	-- Initialize job progress
	local progress = {}
	for i = 1, #job.tasks do
		progress[i] = 0
	end

	data.currentJobId = jobId
	data.currentJobProgress = progress

	local userId = tostring(player.UserId)
	JobSystem._activeJobs[userId] = {
		jobId = jobId,
		progress = progress,
	}

	-- Notify client
	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, "Job accepted: " .. job.subject)
	end

	print("[JobSystem] " .. player.Name .. " accepted job: " .. jobId)
end

function JobSystem.updateTaskProgress(player, taskIndex, incrementAmount)
	local data = PlayerDataManager.getData(player)
	if not data or not data.currentJobId then return end

	local job = JobData.getById(data.currentJobId)
	if not job then return end

	local task = job.tasks[taskIndex]
	if not task then return end

	-- Update progress
	incrementAmount = incrementAmount or 1
	data.currentJobProgress[taskIndex] = math.min(
		(data.currentJobProgress[taskIndex] or 0) + incrementAmount,
		task.count
	)

	-- Check if all tasks are complete
	local allComplete = true
	local totalTasks = 0
	local completedTasks = 0

	for i, jobTask in ipairs(job.tasks) do
		totalTasks = totalTasks + jobTask.count
		local prog = data.currentJobProgress[i] or 0
		completedTasks = completedTasks + prog
		if prog < jobTask.count then
			allComplete = false
		end
	end

	-- Calculate completion percentage
	local completionPercent = completedTasks / totalTasks

	if allComplete then
		JobSystem.completeJob(player, job, 1.0)
	elseif completionPercent >= GameConfig.JOB_PARTIAL_COMPLETION then
		-- Notify player they can complete for partial pay
		local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
		if notifyEvent then
			notifyEvent:FireClient(player, string.format(
				"Job %.0f%% complete! You can finish for full pay or submit now for partial pay.",
				completionPercent * 100
			))
		end
	end
end

function JobSystem.completeJob(player, job, completionPercent)
	local data = PlayerDataManager.getData(player)
	if not data then return end

	-- Calculate reward
	local reward = job.reward
	if completionPercent < 1.0 then
		reward = math.floor(reward * GameConfig.JOB_PARTIAL_PAY_MULTIPLIER)
	end

	-- Apply negotiation perk bonus
	local negotiationBonus = 0
	if data.perks.Negotiation and data.perks.Negotiation.job_bonus then
		local level = data.perks.Negotiation.job_bonus
		negotiationBonus = GameConfig.NEGOTIATION_JOB_BONUS[level + 1] or 0
	end
	reward = math.floor(reward * (1 + negotiationBonus))

	-- Give money
	PlayerDataManager.addMoney(player, reward)

	-- Mark job as completed
	PlayerDataManager.completeJob(player, job.id)

	-- Unlock tool if applicable
	if job.unlocksTool then
		local unlocked = PlayerDataManager.unlockTool(player, job.unlocksTool)
		if unlocked then
			local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
			if notifyEvent then
				local toolInfo = ToolConfig.Tools[job.unlocksTool]
				local toolName = toolInfo and toolInfo.displayName or job.unlocksTool
				notifyEvent:FireClient(player, "New tool unlocked: " .. toolName .. "!")
			end
		end
	end

	-- Clean up active job tracking
	local userId = tostring(player.UserId)
	JobSystem._activeJobs[userId] = nil

	-- Notify client
	local moneyEvent = RemoteManager.getEvent("MoneyChanged")
	if moneyEvent then
		moneyEvent:FireClient(player, data.money)
	end

	local notifyEvent = RemoteManager.getEvent("NotifyPlayer")
	if notifyEvent then
		notifyEvent:FireClient(player, string.format("Job completed! Earned $%d", reward))
	end

	-- Refresh available jobs
	local jobListEvent = RemoteManager.getEvent("JobListUpdated")
	if jobListEvent then
		local availableJobs = JobData.getAvailableJobs(data.completedJobs)
		jobListEvent:FireClient(player, availableJobs)
	end

	print("[JobSystem] " .. player.Name .. " completed job: " .. job.id .. " for $" .. reward)
end

return JobSystem
