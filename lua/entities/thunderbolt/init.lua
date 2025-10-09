AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local BaseColor = Color( 251, 255, 167)


function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetMaterial("model_color")
	self:SetColor( BaseColor )

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	--local SSize = 25
	--local ESize = 0
	--local Duration = 0.15

	--util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	phys:SetBuoyancyRatio(0)
	phys:EnableGravity(false)
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
			self:CheckNearby()
			self:Remove()
		return
	end

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then return end
		self:Remove()

		enthit:TakeDamage( 45, self:GetOwner() )

		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 0.1 )
		util.Effect("cball_explode", effectdata, true, true)
	end
end

function ENT:CheckNearby()
	local rad = 40
	local selfPos = self:GetPos()

	for k, v in ents.Iterator() do
		if not v then continue end
		if not IsValid(v) then continue end
		if v == self:GetOwner() then continue end

		local classGet = v:GetClass()

		local doPass = false
		if classGet == "player" then doPass = true end

		if string.sub(classGet, 1, 4) == "npc_" then doPass = true end

		if not doPass then continue end

		if v:Health() <= 0 then continue end

		local entPos = v:GetPos()

		local dist = entPos:Distance( selfPos )
		if dist > rad then continue end

		v:TakeDamage( 10, self:GetOwner(), self )
	end
end