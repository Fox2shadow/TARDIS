-- Version

ENT:AddHook("Initialize", "version", function(self)
    if CLIENT and LocalPlayer()~=self:GetCreator() then return end

    if TARDIS:IsNewVersion() then
        self:CallCommonHook("NewVersion", TARDIS:GetVersion(), TARDIS:GetLastUsedVersion())
    end

    TARDIS:SetLastUsedVersion()
end)

if CLIENT then
    ENT:AddHook("NewVersion", "version", function(self, newVersion, oldVersion)
        -- TODO
        TARDIS:Message(self:GetCreator(), "TARDIS updated from " .. TARDIS:GetVersionString(oldVersion) .. " to " .. TARDIS:GetVersionString(newVersion))
    end)
end