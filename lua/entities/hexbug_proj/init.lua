AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- THANK YOU LOKA FOR HELPING ME PORT THIS NIGHTMARE FROM THE SWEP CODE

function ENT:Initialize()
	self:SetModel("models/gibs/shield_scanner_gib4.mdl")
	self:SetModelScale(0.25)
	self:SetMaterial("model_color")
	self:SetColor(Color(198, 255, 106))

	self.IsTraysProjectile = true
	self.IsAvailable = true

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere(3.5, SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()

	if not phys:IsValid() then self:Remove() return end

	phys:SetBuoyancyRatio(0)
	phys:SetMass(5)
	phys:EnableGravity(false)
	self.trailObj = util.SpriteTrail(self, 0, Color(166, 255, 106), false, 0.2, 0, 0.2, 1, "trails/smoke")
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

	self:Fire( "Kill", "", 12.5 )

	if phys:IsValid() then phys:Wake() end
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end

	if (self.NextHit or 0) > CurTime() then return end

	if not IsValid(enthit) then
		if self.HadApplied then 
			self:Remove()
			self:EmitSound( "artiwepsv2/splathit1.mp3", 100, math.random(170, 185), 0.3, 6 )
		end return 
	end

	if enthit == self:GetOwner() then return end
	if enthit.IsTraysProjectile then return end

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then return end
		self:Remove()

		data.HitEntity:TakeDamage(14, self:GetOwner())
		self.NextHit = CurTime() + 0.3
		self:EmitSound( "tray_sounds/hexhit.mp3", 100, math.random(100, 105), 1, 6 )
	end
end

function ENT:Think()
	local dt = FrameTime()
	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then return end

	if self.NoDrag then return end
	phys:ApplyForceCenter( -phys:GetVelocity() * dt * phys:GetMass() * 70 )
end

function ENT:BugTrailSize(startSize, endSize)
	self.trailObj:SetKeyValue("startwidth", startSize)
	self.trailObj:SetKeyValue("endwidth", endSize)
end


function ENT:OnTakeDamage(dmginfo)
    self:Remove()
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetScale(0.1)

	util.Effect("cball_explode", effectdata, true, true)
	self:EmitSound( "npc/vort/vort_explode1.wav", 100, 120 + math.random(0, 15), 1, 1 )
end
