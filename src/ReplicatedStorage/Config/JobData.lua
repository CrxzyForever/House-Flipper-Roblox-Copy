--[[
	JobData.lua
	Job/mission definitions - tasks clients email you to complete.
	Location: ReplicatedStorage/Config/JobData
]]

local Enums = require(script.Parent.Parent.Shared.Enums)

local JobData = {}

-- Each job has:
--   id: unique identifier
--   client: name of the person requesting the job
--   subject: email subject line
--   description: email body text
--   reward: full completion reward
--   tasks: list of tasks to complete
--   unlocksTool: tool unlocked upon completion (optional)
--   prerequisite: job ID that must be completed first (optional)
--   houseTemplate: which house template to use for this job

JobData.Jobs = {
	-- ============ TUTORIAL / STARTER JOBS ============
	{
		id = "tutorial_cleanup",
		client = "Real Estate Agency",
		subject = "Welcome Aboard - First Assignment!",
		description = "Welcome to the team! We have a small apartment that needs a basic cleanup. Pick up the trash and clean the stains to get started.",
		reward = 500,
		tasks = {
			{type = Enums.TaskType.Clean, description = "Pick up all trash", target = "trash", count = 10},
			{type = Enums.TaskType.Clean, description = "Clean all stains", target = "stains", count = 8},
		},
		unlocksTool = nil, -- Broom is already starting tool
		prerequisite = nil,
	},
	{
		id = "amaranth_walls",
		client = "Sarah Mitchell",
		subject = "Amaranth Walls - Paint Job Needed",
		description = "Hi! I just moved into my new place but the walls are absolutely dreadful. Could you paint them a nice amaranth color? Oh, and there's some trash left by the previous owners.",
		reward = 800,
		tasks = {
			{type = Enums.TaskType.Clean, description = "Clean up the apartment", target = "trash", count = 5},
			{type = Enums.TaskType.Clean, description = "Remove stains", target = "stains", count = 3},
			{type = Enums.TaskType.Paint, description = "Paint all walls amaranth", target = "walls", count = 12},
		},
		unlocksTool = Enums.ToolType.PaintRoller,
		prerequisite = "tutorial_cleanup",
	},
	{
		id = "extra_bathroom",
		client = "Mike Anderson",
		subject = "Necessary Extra Bathroom",
		description = "My family is growing and we desperately need an extra bathroom. Could you tile the walls and floor, and install the fixtures?",
		reward = 1200,
		tasks = {
			{type = Enums.TaskType.Tile, description = "Tile bathroom walls", target = "walls", count = 8},
			{type = Enums.TaskType.Tile, description = "Tile bathroom floor", target = "floor", count = 6},
			{type = Enums.TaskType.Install, description = "Install toilet", target = "toilet", count = 1},
			{type = Enums.TaskType.Install, description = "Install sink", target = "sink", count = 1},
			{type = Enums.TaskType.Install, description = "Install shower", target = "shower", count = 1},
		},
		unlocksTool = Enums.ToolType.TilingTool,
		prerequisite = "amaranth_walls",
	},

	-- ============ MID-GAME JOBS ============
	{
		id = "additional_walls",
		client = "Thomas Johnson",
		subject = "Additional Walls - Room Dividers",
		description = "I have this huge open space and I need it divided into separate rooms. Could you build some walls and maybe knock down that ugly one in the hallway?",
		reward = 1500,
		tasks = {
			{type = Enums.TaskType.Build, description = "Build dividing walls", target = "walls", count = 4},
			{type = Enums.TaskType.Demolish, description = "Demolish the hallway wall", target = "walls", count = 1},
			{type = Enums.TaskType.Paint, description = "Paint new walls", target = "walls", count = 8},
		},
		unlocksTool = Enums.ToolType.Sledgehammer, -- Also unlocks WallBuilder
		prerequisite = "extra_bathroom",
	},
	{
		id = "first_installation",
		client = "Emma Williams",
		subject = "New Appliances Installation",
		description = "I just bought a bunch of new appliances but I can't install them myself. Could you install my radiators, kitchen sink, and washing machine?",
		reward = 1000,
		tasks = {
			{type = Enums.TaskType.Install, description = "Install kitchen sink", target = "kitchen_sink", count = 1},
			{type = Enums.TaskType.Install, description = "Install 3 radiators", target = "radiator", count = 3},
			{type = Enums.TaskType.Install, description = "Install washing machine", target = "washing_machine", count = 1},
		},
		unlocksTool = Enums.ToolType.InstallationTool,
		prerequisite = "tutorial_cleanup",
	},
	{
		id = "full_renovation_small",
		client = "David Chen",
		subject = "Complete Makeover - Small Apartment",
		description = "I inherited this small apartment from my grandmother. It needs everything: cleaning, painting, new tiles, and some furniture. Can you handle it?",
		reward = 2500,
		tasks = {
			{type = Enums.TaskType.Clean, description = "Clean entire apartment", target = "trash", count = 20},
			{type = Enums.TaskType.Clean, description = "Remove all stains", target = "stains", count = 15},
			{type = Enums.TaskType.Paint, description = "Paint all rooms", target = "walls", count = 20},
			{type = Enums.TaskType.Tile, description = "Tile kitchen and bathroom", target = "walls", count = 10},
			{type = Enums.TaskType.Furnish, description = "Furnish the bedroom", target = "bedroom", count = 3},
			{type = Enums.TaskType.Furnish, description = "Furnish the kitchen", target = "kitchen", count = 3},
		},
		unlocksTool = nil,
		prerequisite = "additional_walls",
	},

	-- ============ ADVANCED JOBS ============
	{
		id = "luxury_remodel",
		client = "Victoria Sterling",
		subject = "Luxury Remodel - Spare No Expense",
		description = "I want my home to scream luxury. Marble tiles, fresh paint in sophisticated colors, top-of-the-line furniture. Money is no object.",
		reward = 5000,
		tasks = {
			{type = Enums.TaskType.Demolish, description = "Remove old walls", target = "walls", count = 2},
			{type = Enums.TaskType.Build, description = "Build new room layout", target = "walls", count = 3},
			{type = Enums.TaskType.Paint, description = "Paint all walls", target = "walls", count = 25},
			{type = Enums.TaskType.Tile, description = "Install marble tiles", target = "floor", count = 15},
			{type = Enums.TaskType.Install, description = "Install luxury fixtures", target = "fixtures", count = 5},
			{type = Enums.TaskType.Furnish, description = "Furnish with luxury items", target = "luxury", count = 10},
		},
		unlocksTool = nil,
		prerequisite = "full_renovation_small",
	},
	{
		id = "office_conversion",
		client = "Robert Blake",
		subject = "Home Office Conversion",
		description = "I'm working from home now and need a proper office setup. Convert one of my spare rooms into a professional home office.",
		reward = 2000,
		tasks = {
			{type = Enums.TaskType.Clean, description = "Clean the room", target = "trash", count = 8},
			{type = Enums.TaskType.Paint, description = "Paint office walls", target = "walls", count = 6},
			{type = Enums.TaskType.Furnish, description = "Set up desk and chair", target = "office", count = 2},
			{type = Enums.TaskType.Furnish, description = "Add bookshelves and cabinet", target = "office", count = 3},
			{type = Enums.TaskType.Install, description = "Install AC unit", target = "ac", count = 1},
		},
		unlocksTool = nil,
		prerequisite = "first_installation",
	},
	{
		id = "family_renovation",
		client = "The Garcia Family",
		subject = "Family Home Renovation",
		description = "Our family of five needs more space and a fresh look. We need multiple bedrooms, a proper kitchen, and a cozy living room. Help!",
		reward = 4000,
		tasks = {
			{type = Enums.TaskType.Clean, description = "Clean entire house", target = "trash", count = 30},
			{type = Enums.TaskType.Clean, description = "Remove all stains", target = "stains", count = 20},
			{type = Enums.TaskType.Build, description = "Build additional bedroom wall", target = "walls", count = 2},
			{type = Enums.TaskType.Paint, description = "Paint all rooms", target = "walls", count = 30},
			{type = Enums.TaskType.Tile, description = "Tile kitchen and bathrooms", target = "walls", count = 12},
			{type = Enums.TaskType.Furnish, description = "Furnish 3 bedrooms", target = "bedroom", count = 9},
			{type = Enums.TaskType.Furnish, description = "Furnish kitchen", target = "kitchen", count = 4},
			{type = Enums.TaskType.Furnish, description = "Furnish living room", target = "livingroom", count = 3},
		},
		unlocksTool = nil,
		prerequisite = "full_renovation_small",
	},
	{
		id = "window_specialist",
		client = "Clara Thompson",
		subject = "Crystal Clear Windows",
		description = "I run a B&B and all the windows need a thorough cleaning. Some walls need plastering too. Can you make it sparkle?",
		reward = 1800,
		tasks = {
			{type = Enums.TaskType.CleanWindows, description = "Clean all windows", target = "windows", count = 12},
			{type = Enums.TaskType.Plaster, description = "Plaster damaged walls", target = "walls", count = 6},
			{type = Enums.TaskType.Paint, description = "Paint repaired walls", target = "walls", count = 6},
		},
		unlocksTool = nil, -- Window cleaner and plaster unlock contextually
		prerequisite = "amaranth_walls",
	},
	{
		id = "demolition_expert",
		client = "Jack Morrison",
		subject = "Tear It All Down",
		description = "I want a complete open-plan layout. Knock down every non-load-bearing wall and make it one big space. Then we'll rebuild from scratch.",
		reward = 3500,
		tasks = {
			{type = Enums.TaskType.Demolish, description = "Demolish interior walls", target = "walls", count = 6},
			{type = Enums.TaskType.Clean, description = "Clean up debris", target = "trash", count = 25},
			{type = Enums.TaskType.Build, description = "Build new layout", target = "walls", count = 5},
			{type = Enums.TaskType.Plaster, description = "Plaster new walls", target = "walls", count = 10},
			{type = Enums.TaskType.Paint, description = "Paint everything", target = "walls", count = 20},
		},
		unlocksTool = nil,
		prerequisite = "additional_walls",
	},
}

-- Helper: get job by ID
function JobData.getById(id)
	for _, job in ipairs(JobData.Jobs) do
		if job.id == id then
			return job
		end
	end
	return nil
end

-- Helper: get available jobs (prerequisites met)
function JobData.getAvailableJobs(completedJobIds)
	local available = {}
	for _, job in ipairs(JobData.Jobs) do
		-- Skip already completed
		local alreadyDone = false
		for _, completedId in ipairs(completedJobIds) do
			if completedId == job.id then
				alreadyDone = true
				break
			end
		end

		if not alreadyDone then
			-- Check prerequisite
			if job.prerequisite == nil then
				table.insert(available, job)
			else
				for _, completedId in ipairs(completedJobIds) do
					if completedId == job.prerequisite then
						table.insert(available, job)
						break
					end
				end
			end
		end
	end
	return available
end

return JobData
