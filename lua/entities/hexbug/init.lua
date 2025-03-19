AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- THANK YOU LOKA FOR HELPING ME PORT THIS NIGHTMARE FROM THE SWEP CODE

-- Server-side initialization function for the Entity
function ENT:Initialize()
	self:SetModel("models/gibs/shield_scanner_gib4.mdl")
	self:SetModelScale(0.25)
	self:SetMaterial("model_color")
	self:SetColor(Color(35, 255, 12))

	self.IsTraysProjectile = true
	self.IsAvailable = true

	self:PhysicsInitSphere(5, SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
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

	self.trailObj = util.SpriteTrail(self, 0, Color(35, 255, 12), false, 0.2, 0, 0.2, 1, "trails/smoke")

	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG) --Thank you zynx for superball fix :pray:

	local Time = 12.5 -- TAKEN FROM CANNOBALL
	timer.Simple( Time, function()
		if not IsValid( self ) then return end
		   	self:Remove() --Eliminate yourself
	end)

	if phys:IsValid() then -- Checks if the physics object is valid.
		phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
	end
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end

	if (self.NextHit or 0) > CurTime() then return end

	if not IsValid(enthit) then
		if self.HadApplied then
			local effectdata = EffectData() --I love copy pasting
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetScale(0.1)

			util.Effect("cball_explode", effectdata, true, true)

			self:Remove()
		end
		return
	end

	if enthit == self:GetOwner() then return end

	if enthit.IsTraysProjectile then return end

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then
			return
		end

		self:Remove() --Eliminate yourself

		data.HitEntity:TakeDamage(12, self:GetOwner())
		self.NextHit = CurTime() + 0.3
		self:EmitSound( "tray_sounds/hexhit.mp3", 100, math.random(100, 105), 1, 6 )

		local effectdata = EffectData() --What the fuck does this meaaaaan
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale(0.1)
		--Oh I get it now

		util.Effect("cball_explode", effectdata, true, true)
	end
end

function ENT:Think()
	local dt = FrameTime()
	local phys = self:GetPhysicsObject()

	if not IsValid(phys) then
		return
	end

	if self.NoDrag then return end
	phys:ApplyForceCenter( -phys:GetVelocity() * dt * phys:GetMass() * 70 )
end

function ENT:BugTrailSize(startSize, endSize)
	self.trailObj:SetKeyValue("startwidth", startSize)
	self.trailObj:SetKeyValue("endwidth", endSize)
end