AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MdlColor = Color(200, 255, 0)

--me when i gotta launch rocks of uranium at my enemies

function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetMaterial("model_color")
	self:SetColor(MdlColor)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 25
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, MdlColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	local Time = 9.5
	timer.Simple( Time, function()
		if not IsValid( self ) then return end
		self:Remove()
	end)
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if (self.NextHit or 0) > CurTime() then return end

	if not IsValid(enthit) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 125, 30 )
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

	data.HitEntity:TakeDamage(20, self:GetOwner())

	self:EmitSound( "tray_sounds/slingfirework2.mp3", 100, math.random(105, 115), 1, 6 )

end
