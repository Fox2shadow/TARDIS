-- Adds matching interior door

if SERVER then
	util.AddNetworkString("TARDIS-SetupPart")
end

local overrides={
	["Draw"]={function(self)
		local int=self:GetNetEnt("interior")
		local ext=self:GetNetEnt("exterior")
		if IsValid(int) and IsValid(ext) then
			if (int:CallHook("ShouldDraw")~=false) or (ext:DoorOpen() and self.ClientDrawOverride and LocalPlayer():GetPos():Distance(ext:GetPos())<1000) or self.ExteriorPart then -- TODO: Improve
				return self.o["Draw"](self)
			end
		end
	end, CLIENT},
	["Initialize"]={function(self)
		net.Start("TARDIS-SetupPart")
			net.WriteEntity(self)
		net.SendToServer()
		return self.o["Initialize"](self)
	end, CLIENT},
	["Think"]={function(self)
		local int=self:GetNetEnt("interior")
		local ext=self:GetNetEnt("exterior")
		if IsValid(int) and IsValid(ext) then
			if (int:CallHook("ShouldThink")~=false) or (ext:DoorOpen() and self.ClientThinkOverride and LocalPlayer():GetPos():Distance(ext:GetPos())<1000) or self.ExteriorPart then -- TODO: Improve
				return self.o["Think"](self)
			end
		end
	end, CLIENT},
	["Use"]={function(self,a,...)
		if (not self.NoStrictUse) and IsValid(a) and a:IsPlayer() then
			if a:GetEyeTraceNoCursor().Entity==self then
				return self.o["Use"](self,a,...)
			end
		else
			return self.o["Use"](self,a,...)
		end
	end, SERVER or CLIENT},
}

function SetupOverrides(e)
	local name=e.ClassName
	e.o={}
	for k,v in pairs(overrides) do
		local o=scripted_ents.GetMember(name, k)
		if o and v[2] then
			e.o[k] = o
			e[k] = v[1]
		end
	end
	scripted_ents.Register(e,name)
end

local parts={}

function ENT:GetPart(id)
	return self.parts[id] or NULL
end

local overridequeue={}
postinit=postinit or false -- local vars cannot stay on autorefresh
function ENT:AddPart(e)
	e.Base = "gmod_tardis_part"	
	local name="gmod_tardis_part_"..e.ID
	scripted_ents.Register(e,name)
	if postinit then
		SetupOverrides(e)
	else
		table.insert(overridequeue,e)
	end
	parts[e.ID]=name
end

hook.Add("InitPostEntity", "tardisi-parts", function() 
	for k,v in pairs(overridequeue) do
		SetupOverrides(v)
	end
	overridequeue={}
	postinit=true
end)

local function AutoSetup(e)
	e:SetModel(e.Model)
	e:PhysicsInit( SOLID_VPHYSICS )
	e:SetMoveType( MOVETYPE_VPHYSICS )
	e:SetSolid( SOLID_VPHYSICS )
	e:SetRenderMode( RENDERMODE_TRANSALPHA )
	e:SetUseType( SIMPLE_USE )
	
	e.phys = e:GetPhysicsObject()
	if (e.phys:IsValid()) then
		e.phys:EnableMotion(e.Motion or false)
	end
	
	if not e.Collision then
		e:SetCollisionGroup( COLLISION_GROUP_WORLD ) -- Still works with USE, TODO: Find better way if possible (for performance reasons)
	end
end

if SERVER then
	ENT:AddHook("Initialize", "parts", function(self)
		self.parts={}
		for k,v in pairs(parts) do
			local e=ents.Create(v)
			e:SetCreator(self:GetCreator())
			if CPPI then
				e:CPPISetOwner(self:GetCreator())
			end
			e.interior=self
			e.exterior=self.exterior
			e:SetNetVar("interior",self)
			e:SetNetVar("exterior",self.exterior)
			if e.AutoSetup then
				AutoSetup(e)
			end
			e:Spawn()
			e:Activate()
			self:DeleteOnRemove(e)
			self.parts[k]=e
		end
	end)
	net.Receive("TARDIS-SetupPart", function(_,ply)
		local e=net.ReadEntity()
		if e.ID then
			net.Start("TARDIS-SetupPart")
				net.WriteEntity(e)
				net.WriteString(e.ID)
			net.Send(ply)
		end
	end)
else
	ENT:AddHook("Initialize", "parts", function(self)
		self.parts={}
	end)
	net.Receive("TARDIS-SetupPart", function(ply)
		local e=net.ReadEntity()
		local name=net.ReadString()
		local int=e:GetNetEnt("interior")
		if IsValid(int) then
			int.parts[name]=e
		end
	end)
end

-- Loads parts
local folder = "entities/gmod_tardis_part/parts/"
local parts = file.Find( folder.."*.lua", "LUA" )
for _, plugin in ipairs( parts ) do
	if ( SERVER ) then
		AddCSLuaFile( folder..plugin )
	end
	include( folder..plugin )
end