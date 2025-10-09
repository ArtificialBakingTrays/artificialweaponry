AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local BaseColor = Color( 248, 255, 167)

function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetMaterial("model_color")
	self:SetColor( Color(255, 255, 255 ) )
	self:SetModelScale(0.2)

	local SSize = 12
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.IsTraysProjectile = true

	local phys = self:GetPhysicsObject()
	phys:SetBuoyancyRatio(0)
	phys:EnableGravity(false)
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 4.5 )

	timer.Simple( 1.3, function()
		if not IsValid( self ) then return end
			util.BlastDamage( self, self:GetOwner(), self:GetPos(), 95, 35 )
			self:EmitSound( "tray_sounds/slingfirework2.mp3", 75, math.random( 90, 110 ), 1.2, 1 )
				self:EmitSound("legendary/elec_impact.mp3", 75, math.random( 90, 110 ), 1.2, 6)
		self:Remove()
	end)
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if enthit == self:GetOwner() then return end
	if enthit.IsTraysProjectile then return end
	self:EmitSound( "legendary/spark.mp3", 75, math.random(95, 100), 1, 6 )

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then return end
		enthit:TakeDamage( 5, self:GetOwner() )
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 0.1 )
		util.Effect("cball_explode", effectdata, true, true)
	end
end

function ENT:Think()
	local dt = FrameTime()
	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then return end
	if self.NoDrag then return end
	phys:ApplyForceCenter( -phys:GetVelocity() * dt * phys:GetMass() * 25 )
end