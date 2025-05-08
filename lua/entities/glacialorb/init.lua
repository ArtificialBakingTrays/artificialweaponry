AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--bouncing gibs of fun

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 5
	local ESize = 0
	local Duration = 0.15
	local TrailCl = Color(74, 126, 223)

	util.SpriteTrail(self, 0, TrailCl, false, SSize, ESize, Duration, 1, "trails/smoke")

	local phys = self:GetPhysicsObject()
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	phys:SetBuoyancyRatio( 0 )
	phys:SetMass( 1 )
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 15 )
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if not enthit:IsPlayer() then return end

	StatusGlacialBonus( enthit, 14, 40)

	local effectdata = EffectData() --I love copy pasting
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("GlassImpact", effectdata, true, true)
end

