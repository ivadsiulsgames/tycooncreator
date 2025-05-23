--[=[
	@class GitHubService
]=]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GitHubService = {}
GitHubService.ServiceName = "GitHubService"

function GitHubService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal

	task.spawn(function()
		local function getLatestRelease(owner, repo, token)
			local url = string.format("https://api.github.com/repos/%s/%s/releases/latest", owner, repo)
			local headers = {
				["Accept"] = "application/vnd.github+json",
				["Authorization"] = "Bearer " .. token,
			}

			local success, response = pcall(function()
				return HttpService:RequestAsync({
					Url = url,
					Method = "GET",
					Headers = headers,
				})
			end)

			if success and response.StatusCode == 200 then
				local data = HttpService:JSONDecode(response.Body)
				return {
					ReleaseVersion = data.tag_name,
				}
			else
				warn(
					`[GitHub]: Failed to fetch latest release:{response and response.StatusMessage or "Unknown error"}`
				)
				return nil
			end
		end

		local owner = "ivadsiulsgames"
		local repo = "tycooncreator"
		local token = "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"

		local latestRelease = getLatestRelease(owner, repo, token)
		if latestRelease then
			ReplicatedStorage.VersionName.Value = latestRelease.ReleaseVersion
		end
	end)
end

return GitHubService
