local AdonisCounter = {
	Active = false,
	_hooks = {},
	_client = nil,
}
local function notify(msg)
	print("[AdonisCounter] " .. msg)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "AdonisCounter",
			Text = msg,
			Duration = 4
		})
	end)
end
local function findClient()
	local gc = getgc(true)
	for _, v in ipairs(gc) do
		if type(v) == "table" then
			local ok, hasAll = pcall(function()
				return v.Anti ~= nil
					and v.Core ~= nil
					and v.Remote ~= nil
					and v.Functions ~= nil
					and v.Variables ~= nil
			end)
			if ok and hasAll then
				return v
			end
		end
	end
	return nil
end
function AdonisCounter:Enable()
	if self.Active then
		notify("Already active.")
		return
	end
	local client = findClient()
	if not client then
		notify("Could not find Adonis client table. Is Adonis loaded?")
		return
	end
	self._client = client
	local anti = client.Anti
	if anti and type(anti) == "table" then
		local origDetected = rawget(anti, "Detected")
		rawset(anti, "Detected", function(...)
		end)
		self._hooks.origDetected = origDetected
		self._hooks.anti = anti
		print("[AdonisCounter] Layer 1: Anti.Detected nulled")
	else
		print("[AdonisCounter] Layer 1: WARNING - Anti table not found")
	end
	local remote = client.Remote
	if remote and type(remote) == "table" then
		local origSend = rawget(remote, "Send")
		if origSend then
			rawset(remote, "Send", function(cmdName, ...)
				if type(cmdName) == "string" and cmdName:lower():find("detect") then
					return
				end
				return origSend(cmdName, ...)
			end)
			self._hooks.origSend = origSend
			self._hooks.remote = remote
			print("[AdonisCounter] Layer 2: Remote.Send hooked")
		else
			print("[AdonisCounter] Layer 2: WARNING - Remote.Send not found")
		end
		local origFire = rawget(remote, "Fire")
		if origFire then
			rawset(remote, "Fire", function(encryptedCmd, ...)
				local core = client.Core
				local key = core and rawget(core, "Key")
				if key and type(encryptedCmd) == "string" then
					local ok, decrypted = pcall(function()
						return remote.NewDecrypt and remote.NewDecrypt(encryptedCmd, key)
							or remote.Decrypt and remote.Decrypt(encryptedCmd, key)
							or encryptedCmd
					end)
					if ok and type(decrypted) == "string" and decrypted:lower():find("detect") then
						return
					end
				end
				return origFire(encryptedCmd, ...)
			end)
			self._hooks.origFire = origFire
			print("[AdonisCounter] Layer 3: Remote.Fire hooked")
		else
			print("[AdonisCounter] Layer 3: WARNING - Remote.Fire not found")
		end
	else
		print("[AdonisCounter] Layers 2/3: WARNING - Remote table not found")
	end
	self.Active = true
	notify("Active. All 3 bypass layers applied.")
end
function AdonisCounter:Disable()
	if not self.Active then
		notify("Not active.")
		return
	end
	if self._hooks.anti and self._hooks.origDetected ~= nil then
		rawset(self._hooks.anti, "Detected", self._hooks.origDetected)
		print("[AdonisCounter] Layer 1 restored")
	end
	if self._hooks.remote and self._hooks.origSend then
		rawset(self._hooks.remote, "Send", self._hooks.origSend)
		print("[AdonisCounter] Layer 2 restored")
	end
	if self._hooks.remote and self._hooks.origFire then
		rawset(self._hooks.remote, "Fire", self._hooks.origFire)
		print("[AdonisCounter] Layer 3 restored")
	end
	self._hooks = {}
	self._client = nil
	self.Active = false
	notify("Disabled. All hooks restored.")
end
function AdonisCounter:Toggle()
	if self.Active then
		self:Disable()
	else
		self:Enable()
	end
end
AdonisCounter:Toggle()
