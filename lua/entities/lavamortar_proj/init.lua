AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/rockcliff01j.mdl")
	self:SetMaterial("materials/models/effects/splode_sheet.vmt")
	self:SetColor(Color(255, 122, 51))
	self:SetModelScale( 0.525 )
	self:SetAngles( Angle( 0, math.random(0, 360), 180 ))

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	util.SpriteTrail(self, 0, Color(255, 223, 160), true, 100, 0, 0.8, 1, "materials/sprites/physbeama.vmt")

	self:EmitSound("artiwepsv2/comicalfalling.mp3", 75, 100, 1, 6)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 12.5 )
end

function ENT:PhysicsCollide(data)
	if CLIENT then return end
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end

	local ExplDMG = math.random( 200, 350 )
	local DMG = 1000

	if not IsValid(enthit) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 260, ExplDMG )
		self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
		self:EmitSound( "artiwepsv2/rockblast.mp3", 100, math.random(70, 80), 1, 6 )
		self:Remove()

		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		util.Effect("HunterDamage", effectdata, true, true)
		self:StopSound("artiwepsv2/comicalfalling.mp3")
		return
	end

	if enthit.IsTraysProjectile then return end

	self.NextHit = CurTime() + 0.1
	data.HitEntity:TakeDamage(DMG, self:GetOwner())
	self:EmitSound( "physics/concrete/boulder_impact_hard3.wav", 100, math.random(95, 105), 1, 6 )
	self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(70, 80), 1, 1 )
end