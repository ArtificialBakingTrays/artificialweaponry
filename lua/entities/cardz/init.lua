AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--bouncing gibs of fun

function ENT:Initialize()
	self:SetModel("balloon_star.mdl")

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 5
	local ESize = 0
	local Duration = 0.15
	local TrailCl = Color(255, 122, 92)

	util.SpriteTrail(self, 0, TrailCl, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	phys:SetBuoyancyRatio( 0 )
	phys:SetMass( 1 )
	if phys:IsValid() then phys:Wake() end

end

function ENT:PhysicsCollide(data)

end

