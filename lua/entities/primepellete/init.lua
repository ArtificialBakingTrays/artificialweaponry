AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local BaseColor = Color( 255, 113, 172)

function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetModelScale( 0.75 )
	self:SetMaterial("model_color")
	self:SetColor( Color(255, 228, 228) )

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.4, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 12
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	phys:SetBuoyancyRatio(0)
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 12.5 )
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if enthit == self:GetOwner() then return end
	if enthit.IsTraysProjectile then return end
	self:EmitSound( "legendary/spark.mp3", 75, math.random(95, 100), 1, 6 )

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
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 0.1 )
		util.Effect("cball_explode", effectdata, true, true)
		enthit:TakeDamage( 13, self:GetOwner() )
		self:Remove()
	end
end