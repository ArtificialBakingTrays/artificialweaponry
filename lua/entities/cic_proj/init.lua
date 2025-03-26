AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(160, 160, 255)

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local SSize = 5
	local ESize = 0
	local Duration = 0.1

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "materials/trails/smoke.vmt")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end