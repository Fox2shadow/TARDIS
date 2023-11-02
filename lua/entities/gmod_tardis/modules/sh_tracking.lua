-- Tracking

local MaxTrackingDistance = 1000

TARDIS:AddKeyBind("tracking",{
    name="Tracking",
    section="Teleport",
    func=function(self,down,ply)
        local pilot = self:GetData("pilot")
        if self:GetData("teleport") or self:GetData("vortex") then return end
        if SERVER then
            if ply==pilot and down then
                ply:SetTardisData("tracking-bind-down", true)
            end
            if ply==pilot and (not down) and ply:GetTardisData("tracking-bind-down",false) then
                local _,_,ent=self:GetThirdPersonTrace(ply,ply:GetTardisData("viewang"))
                if IsValid(ent) then
                    self:SetTracking(ent, ply)
                else
                    self:SetTracking(nil, ply)
                end
            end
            if not down and ply:GetTardisData("tracking-bind-down",false) then
                ply:SetTardisData("tracking-bind-down", nil)
            end
        else
            if ply==pilot and down then
                self:SetData("tracking-trace",true)
            else
                self:SetData("tracking-trace",false)
                self:SetData("tracking-ent",nil)
            end
        end
    end,
    key=KEY_X,
    exterior=true
})

if SERVER then
    function ENT:GetTracking()
        return self:GetData("tracking-ent")
    end

    function ENT:SetTracking(ent,ply)
        local wasTrackingEnt = self:GetData("tracking-ent")
        local wasTracking = IsValid(wasTrackingEnt)
        local isTracking = IsValid(ent)
        local valid = true
        if isTracking then 
            local wasFlying = self:GetFlight()
            if not wasFlying then
                local success = self:SetFlight(true)
                if not success then
                    if IsValid(ply) then
                        TARDIS:ErrorMessage(ply, "Controls.Tracking.FlightFail")
                    end
                    valid = false
                end
            elseif ent.TardisPart or ent.TardisInterior or (ent:IsPlayer() and IsValid(TARDIS:GetInteriorEnt(ent))) then
                if IsValid(ply) then
                    TARDIS:ErrorMessage(ply, "Controls.Tracking.InteriorFail")
                end
                valid = false
            elseif ent == self then
                if IsValid(ply) then
                    TARDIS:ErrorMessage(ply, "Controls.Tracking.SelfFail")
                end
                valid = false
            elseif ent:GetPos():Distance(self:GetPos()) > MaxTrackingDistance then
                if IsValid(ply) then
                    TARDIS:ErrorMessage(ply, "Controls.Tracking.DistanceFail")
                end
                valid = false
            end
            if not valid then
                return false
            end
            if not wasTracking then
                self:SetData("tracking-wasflight", wasFlying)
            end
        end
        
        self:SetData("tracking-ent",ent)
        if IsValid(ent) and ent ~= wasTrackingEnt then
            self:SetData("tracking-offset-pos", ent:WorldToLocal(self:GetPos()))
            self:SetData("tracking-offset-yaw", 0)
        end

        if not isTracking then
            if wasTracking and (not self:GetData("tracking-wasflight")) then
                self:SetFlight(false)
            end
            self:SetData("tracking-wasflight", nil)
            self:SetData("tracking-offset-pos", nil)
            self:SetData("tracking-offset-yaw", nil)
        end

        if IsValid(ply) then
            if wasTracking ~= isTracking then
                TARDIS:StatusMessage(ply, "Controls.Tracking.Status", IsValid(ent))
            end
            if isTracking then
                if wasTrackingEnt ~= ent then
                    local name = ent.PrintName or (isfunction(ent.Name) and ent:Name()) or ent.Name or ent:GetModel() or ent:GetClass()
                    TARDIS:Message(ply, "%s %s", "Controls.Tracking.Target", name)
                else 
                    TARDIS:Message(ply, "Controls.Tracking.SameTarget")
                end
            end
        end
        return true
    end

    ENT:AddHook("HandleE2", "tracking", function(self, name, e2, ...)
        local args = {...}
        if name == "Track" and (args[1] == e2.player or TARDIS:CheckPP(e2.player, self)) then
            local ent = args[1]
            local success = self:SetTracking(ent, e2.player)
            return success and 1 or 0
        end
    end)

    ENT:AddHook("HandleE2", "tracking_get", function(self, name, e2)
        if name == "GetTracking" then
            return self:GetTracking() or NULL
        end
    end)

    ENT:AddHook("FlightToggled", "tracking", function(self, on)
        if not on then
            self:SetTracking(nil, self:GetData("pilot"))
        end
    end)

    ENT:AddHook("PhysicsUpdate", "tracking", function(self, ph)
        local ent = self:GetTracking()
        if ent and not IsValid(ent) then
            self:SetTracking(nil, self:GetData("pilot"))
            return
        elseif not ent then
            return
        end

        local pos = self:GetPos()
        local dist = pos:Distance(ent:GetPos())
        local pilot = self:GetData("pilot")

        if dist > MaxTrackingDistance then
            self:SetTracking(nil, pilot)
            TARDIS:ErrorMessage(pilot, "Controls.Tracking.DistanceDisable")
            return
        end

        local offset = self:GetData("tracking-offset-pos", Vector(0,0,0))
        local yawoffset = self:GetData("tracking-offset-yaw", 0)

        local tvel=ent:GetVelocity()
        local tfwd=tvel:Angle():Forward()
        local target=ent:LocalToWorld(offset)+(tfwd*tvel:Length())
        local mass=ph:GetMass()
        local vel=ph:GetVelocity()

        ph:ApplyForceCenter((target-pos)*mass)
        ph:ApplyForceCenter(-vel*mass)

        if self:GetSpinDir() == 0 then
            local cen=ph:GetMassCenter()
            local fwd=self:GetForward()
            local lev=ph:GetInertia():Length()
            local ri=self:GetRight()
            local ang=self:GetAngles()

            local a=ent:WorldToLocalAngles(ang+Angle(0,yawoffset,0))
            ph:ApplyForceOffset( ri*-a.y,cen-fwd*lev)
            ph:ApplyForceOffset(-ri*-a.y,cen+fwd*lev)
        end
    end)

    ENT:AddHook("CanControlFlight", "tracking", function(self, ply)
        if self:GetTracking() then
            local lastWarning = self:GetData("tracking-warning", 0)
            if CurTime() > lastWarning then
                self:SendMessage("tracking-pilotwarning", nil, ply)
                self:SetData("tracking-warning", CurTime()+5)
            end
            return false
        end
    end)

    ENT:AddHook("PilotChanged", "tracking", function(self, old, new)
        if IsValid(new) and self:GetTracking() then
            self:SendMessage("tracking-pilotwarning", nil, new)
        end
    end)
else
    hook.Add("PostDrawTranslucentRenderables", "tardis-tracking", function()
        local ext=TARDIS:GetExteriorEnt()
        if not IsValid(ext) then return end
    
        if not ext:GetData("tracking-trace") then return end
    
        local pos,ang,ent=ext:GetThirdPersonTrace(LocalPlayer(),LocalPlayer():EyeAngles())
    
        local fw=ang:Forward()
        local bk=fw*-1
        local ri=ang:Right()
        local le=ri*-1
    
        ext:SetData("tracking-ent",ent)
        if not IsValid(ent) then
            local size=10
            local col=Color(255,0,0)
            render.DrawLine(pos,pos+(fw*size),col)
            render.DrawLine(pos,pos+(bk*size),col)
            render.DrawLine(pos,pos+(ri*size),col)
            render.DrawLine(pos,pos+(le*size),col)
        end
    end)

    hook.Add("PreDrawHalos", "tardis-tracking", function()
        local ext=TARDIS:GetExteriorEnt()
        if not IsValid(ext) then return end
    
        local ent = ext:GetData("tracking-ent")
        if not IsValid(ent) then return end
    
        local dist = ent:GetPos():Distance(ext:GetPos())
        halo.Add({ent},dist > MaxTrackingDistance and Color(255,0,0) or Color(0,255,0),1,1,1,true,true)
    end)

    ENT:OnMessage("tracking-pilotwarning", function(self)
        local keyName = input.GetKeyName(TARDIS:GetBindKey("tracking"))
        TARDIS:Message(LocalPlayer(), "Controls.Tracking.PilotWarning", string.upper(keyName))
    end)
end