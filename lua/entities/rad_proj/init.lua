AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(229, 255, 136)

--me when i gotta launch rocks of uranium at my enemies

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 25
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 7.5 )
end



function ENT:SpawnSubProjectile(data)
	local spread = 30
	local force = 44

	local ent = ents.Create( "mini_rad_proj" )
	if ( not ent:IsValid() ) then return end

	local norm = data.HitNormal * 1

	ent:SetPos( self:GetPos() - (norm * 16))
	ent:SetOwner( self:GetOwner() )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()
	if ( not entphys:IsValid() ) then ent:Remove() return end

	local rX = (math.random() - .5) * 2
	local rY = (math.random() - .5) * 2

	norm:Rotate(Angle(rX * spread, rY * spread, 0))
	norm:Normalize()

	entphys:ApplyForceCenter(-norm * entphys:GetMass() * force)
end


function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end

	if not self.HasSpawned then
		for i = 1, 3 do
			self:SpawnSubProjectile(data)
		end

		self.HasSpawned = true
	end

	local DMG = 12
	local ExplDMG = 35

	if not IsValid(enthit) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 125, ExplDMG )
		self:EmitSound( "tray_sounds/slingfirework2.mp3", 100, math.random(95, 105), 1, 6 )

		self:Remove()

		local effectdata = EffectData() --I love copy pasting
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale(0.115)
		util.Effect("GlassImpact", effectdata, true, true)

		return
	end

	if enthit.IsTraysProjectile then return end

	self.NextHit = CurTime() + 0.05

	data.HitEntity:TakeDamage(DMG, self:GetOwner())

	self:EmitSound( "tray_sounds/slingfirework2.mp3", 100, math.random(105, 115), 1, 6 )
end


