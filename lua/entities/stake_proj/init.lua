AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(98, 127, 255)

--me when i gotta launch rocks of uranium at my enemies

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 25
	local ESize = 0
	local Duration = 0.25

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/smoke")

	self:PhysicsInitSphere(3.5, SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
	self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
	self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.

	local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.

	if not phys:IsValid() then
		self:Remove()
		return
	end

	phys:SetBuoyancyRatio(0)
	phys:SetMass(5)
	phys:EnableGravity(false)
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

	if phys:IsValid() then phys:Wake() end

end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end

	local DMG = 20
	local ExplDMG = 65
	local Radius = 65

	if not IsValid(enthit) then
		util.BlastDamage( self:GetOwner(), self:GetOwner(), self:GetPos(), Radius, ExplDMG )

		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		util.Effect("WaterSurfaceExplosion", effectdata, true, true)
		self:Remove()
		return
	end

	local effectdata = EffectData() --I love copy pasting
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("WaterSurfaceExplosion", effectdata, true, true)

	util.BlastDamage( self, self:GetOwner(), self:GetPos(), Radius, ExplDMG )
	data.HitEntity:TakeDamage(DMG, self:GetOwner())
	self:Remove()

end