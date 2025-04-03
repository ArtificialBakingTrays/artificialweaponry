AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(229, 255, 136)

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetModelScale(0.5)

	self.IsTraysProjectile = true

	local SSize = 17.5
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 7.5 )
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end

	local DMG = 8
	local ExplDMG = 25

	if not IsValid(enthit) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 85, ExplDMG )
		self:EmitSound( "tray_sounds/slingfirework.mp3", 100, math.random(95, 105), 1, 6 )
		self:Remove()

		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		util.Effect("GlassImpact", effectdata, true, true)
		return
	end

	if enthit.IsTraysProjectile then return end

	self.NextHit = CurTime() + 0.1
	data.HitEntity:TakeDamage(DMG, self:GetOwner())
	self:EmitSound( "tray_sounds/slingfirework.mp3", 100, math.random(105, 115), 1, 6 )
end