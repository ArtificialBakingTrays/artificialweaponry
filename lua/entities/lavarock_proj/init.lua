AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/rock001a.mdl")
	self:SetMaterial("models/effects/splode_sheet")
	self:SetModelScale( 0.6 )
	self:SetAngles( Angle( math.random(0, 360), math.random(0, 360), math.random(0, 360) ))

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 7.5 )
end

function ENT:PhysicsCollide(data)
	if CLIENT then return end
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end

	local ExplDMG = math.random( 3, 7 )
	local DMG = math.random( 10, 20 )

	if not IsValid(enthit) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 85, ExplDMG )
		self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
		self:EmitSound( "physics/concrete/boulder_impact_hard1.wav", 100, math.random(95, 105), 1, 6 )
		self:Remove()

		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		util.Effect("HunterDamage", effectdata, true, true)
		return
	end

	if enthit.IsTraysProjectile then return end

	self.NextHit = CurTime() + 0.1
	data.HitEntity:TakeDamage(DMG, self:GetOwner())
	self:EmitSound( "physics/concrete/boulder_impact_hard3.wav", 100, math.random(105, 115), 1, 6 )
	self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
	StatusMagmatic( data.HitEntity, 1, math.random(27, 39), self )
end