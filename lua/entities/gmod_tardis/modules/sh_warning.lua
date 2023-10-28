if SERVER then
    ENT:AddHook("Initialize","warning-init", function(self)
        self:SetData("health-warning", false, true)
    end)

    function ENT:GetWarning()
        return self:GetData("health-warning", false)
    end

    function ENT:ToggleWarning()
        return self:SetWarning(not self:GetWarning())
    end

    function ENT:SetWarning(on)
        self:SetData("health-warning", on, true)
        self:CallCommonHook("HealthWarningToggled", on)
    end

    function ENT:UpdateWarning()
        if (self:CallCommonHook("ShouldWarningBeEnabled") == true) ~= self:GetWarning() then
            self:ToggleWarning()
        end
    end

    ENT:AddHook("OnHealthChange", "warning", function(self)
        self:UpdateWarning()
    end)

    ENT:AddHook("HealthWarningToggled", "client", function(self, on)
        self:SendMessage("health_warning_toggled", {on})
    end)
else

    ENT:OnMessage("health_warning_toggled", function(self, data, ply)
        self:CallCommonHook("HealthWarningToggled", data[1])
    end)

end
