AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(255, 231, 125)

--me when i gotta fire curses at my homies

function ENT:Initialize()
	self:SetModel("models/hunter/misc/sphere025x025.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)
	self:SetModelScale( 0.6 )

	self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.IsTraysProjectile = true

	local SSize = 40
	local ESize = 0
	local Duration = 0.25

	util.SpriteTrail( self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/laser" )

	self:PhysicsInitSphere(3.5, SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
	self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
	self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.

	local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.

	if not phys:IsValid() then
		self:Remove()
		return
	end

	phys:SetBuoyancyRatio(0)
	phys:EnableGravity(false)
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 7.5 )
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end
	if enthit == self:GetOwner() then return end
	if enthit.IsTraysProjectile then return end
	self:EmitSound( "npc/antlion/foot2.wav", 100, math.random(95, 140), 1, 6 )

	if not IsValid(enthit) then
			local effectdata = EffectData() --I love copy pasting
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetScale(0.1)
			util.Effect("cball_explode", effectdata, true, true)

			self:Remove()
		return
	end

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then return end
		self.NextHit = CurTime() + 0.3
		self:Remove()

		data.HitEntity:TakeDamage(12, self:GetOwner())

		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale(0.1)
		util.Effect("cball_explode", effectdata, true, true)
	end
end
