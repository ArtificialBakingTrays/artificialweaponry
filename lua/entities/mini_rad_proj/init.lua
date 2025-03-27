AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(200, 255, 0)

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local SSize = 25
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end
	if not IsValid(enthit) then
		self:EmitSound( "tray_sounds/slingfirework.mp3", 100, 100, 1, 6 )
		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale(0.1)

		util.Effect("cball_explode", effectdata, true, true)

		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 250, 45 )

		self:Remove()
		return
	end
end
