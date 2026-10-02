AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Electricity Ball Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = GetWeaponPack()
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for the Staticurrent"
ENT.Spawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/hunter/misc/sphere025x025.mdl")
		self:SetModelScale(0.25)
		self:SetMaterial("model_color")
		self:SetColor(Color(250, 255, 214))

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
		self.trailObj = util.SpriteTrail(self, 0, Color(231, 255, 72), false, 0.2, 0, 0.2, 1, "effects/halftone_trail")
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

		self:Fire( "Kill", "", 12.5 )

		if phys:IsValid() then phys:Wake() end
	end

	function ENT:PhysicsCollide(data)
		local enthit = data.HitEntity
		if ( not self:IsValid() ) then return end
		if (self.NextHit or 0) > CurTime() then return end
		if not IsValid(enthit) then
			self:Remove()
			self:EmitSound( "artiwepsv3/shockhit.mp3", 100, math.random(90, 185), 0.3, 6 )
		end

		if enthit == self:GetOwner() then return end
		if enthit.IsTraysProjectile then return end

		if data.HitSpeed:Length() > 60 then
			if not IsValid(self) then return end
			self:Remove()

			data.HitEntity:TakeDamage(14, self:GetOwner())
			self.NextHit = CurTime() + 0.3

			local hitEntities = {}

			if IsValid(enthit) and (enthit:IsPlayer() or enthit:IsNPC()) and enthit ~= self:GetOwner() then
				self:ChainDamage( enthit, 35, hitEntities )
				self:EmitSound( "artiwepsv3/shockhit.mp3", 100, math.random(120, 135), 1, nil )
			end
			self:Remove()
		end
	end

	local radius = 150
	local dmgloss = .60
	local mindmgb4cncl = 5 	--MINIMUM DAMAGE BEFORE CANCEL -Rayne

	function ENT:ChainDamage(target, damage, hitent)
		if not IsValid(target) then return end
		if damage <= mindmgb4cncl then return end
		if hitent[target] then return end

		if target == self:GetOwner() then return end
		hitent[target] = true

		local dmg = DamageInfo()
		dmg:SetDamage(damage)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self)

		if target:IsOnFire() then dmg = dmg * 2 end

		target:TakeDamageInfo(dmg)

		local nxtdmg = damage * dmgloss
		if nxtdmg <= mindmgb4cncl then return end

		local targets = ents.FindInSphere( target:GetPos(), radius )

		local effectdata = EffectData()
		effectdata:SetOrigin( target:GetPos() )
		effectdata:SetScale(0.1)

		for _, ent in ipairs(targets) do
			if IsValid(ent) and not hitent[ent] and ent ~= self:GetOwner() and (ent:IsPlayer() or ent:IsNPC()) then
				self:ChainDamage( ent, nxtdmg, hitent )
				ent:EmitSound( "sparkbound/shock.mp3", 100, math.random(90,100), 1, 1 )
				util.Effect("cball_explode", effectdata, true, true)
			end
		end
	end
end


if CLIENT then
	local spritemat1 = Material("effects/halftonegradient")
	function ENT:Draw()
		self:DrawModel()

		render.SetMaterial(Material("sprites/glow04_noz"))
		render.DrawSprite(self:GetPos(), 16, 16, Color(221, 255, 0))

		render.PushFilterMin(TEXFILTER.POINT)
		render.PushFilterMag(TEXFILTER.POINT)
			render.SetMaterial(spritemat1)
			render.DrawSprite(self:GetPos(), 8, 8, Color(244, 255, 170))
		render.PopFilterMag()
		render.PopFilterMin()

		local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position
		local dist = 5
		for i = 1, 1 do
			local part = emitter:Add( "sprites/light_ignorez", self:GetPos() + Vector( math.random(-dist, dist), math.random(-dist, dist), math.random(-dist, dist ) ))
			if ( part ) then
				part:SetColor( 231, 255, 72 )
				part:SetDieTime( 0.1 )

				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )

				part:SetStartSize( 5 ) -- Starting size
				part:SetEndSize( 0 ) -- Size when removed

				part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
				part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
			end
		end
		emitter:Finish()
	end

	function ENT:OnRemove()
		local emit = ParticleEmitter(self:GetPos())

		for i = 1, 26 do
			local part = emit:Add("sprites/light_ignorez", self:GetPos())

			if part then
				part:SetColor( 231, 255, 72 )
				part:SetDieTime( 0.3 )
				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )
				part:SetStartSize( 1 )
				part:SetEndSize( 0 )
				part:SetGravity(Vector( 0, 0, 250 ))
				part:SetVelocity( VectorRand() * 150 )
			end
		end
		emit:Finish()
	end
end

