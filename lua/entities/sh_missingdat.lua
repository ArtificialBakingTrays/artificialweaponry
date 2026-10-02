AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Meat Skull Harassment Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = GetWeaponPack()
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for the Meatgrinder"
ENT.Spawnable = true


--Color(255, 151, 91)
--Color(125, 110, 149)

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetModelScale( 0 )

		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
		self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self.IsTraysProjectile = true

		local SSize = 10
		local ESize = 0
		local Duration = 0.15
		local TrailCl = Color( 125, 110, 149 )

		util.SpriteTrail(self, 0, TrailCl, false, SSize, ESize, Duration, 1, "particle/beam_smoke_01")

		local phys = self:GetPhysicsObject()
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:SetMaterial("gmod_bouncy")
		phys:SetBuoyancyRatio(0)
		phys:SetMass(25)
		if phys:IsValid() then phys:Wake() end

		self:Fire( "Kill", "", 12.5 )
	end

	function ENT:PhysicsCollide(data)
		local enthit = data.HitEntity
		if ( not self:IsValid() ) then return end
		if enthit == self:GetOwner() then return end
		if enthit.IsTraysProjectile then return end

		self.BounceTotal = (self.BounceTotal or 0) + 1
		if self.BounceTotal >= 3 then
			self:Remove()
			return
		end

		if not IsValid(enthit) then
				self:EmitSound("artiwepsv3/staticfire2.mp3", 100, math.random(90, 110), 1, 1 )
				self:EmitSound("artiwepsv3/staticfire.mp3", 100, math.random(90, 110), 1, 6 )
				--self:Remove()
			return
		end

		if data.HitSpeed:Length() > 60 then
			if not IsValid(self) then return end
			self:CheckNearby( 125, 35 )
			self:Remove()

			enthit:TakeDamage( 7 + math.random(1, 36), self:GetOwner() )
			StatusMisplaceData( enthit, 30 )

			self:EmitSound("artiwepsv3/staticfire2.mp3", 100, math.random(90, 110), 1, 1 )
			self:EmitSound("artiwepsv3/staticfire.mp3", 100, math.random(90, 110), 1, 6 )
		end
	end
end

if CLIENT then
	local spritemat = Material("sprites/light_glow02_add")
	local ColorSprite =  Color(125, 110, 149)

	function ENT:Draw()
		self:DrawModel()

		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 64, 64, Color(73, 50, 111))

		render.PushFilterMin(TEXFILTER.POINT)
		render.PushFilterMag(TEXFILTER.POINT)
			render.SetMaterial(Material("materials/pngtexts/halftone_dotty.png"))
			render.DrawSprite(self:GetPos(), 16, 16, Color(255,255,255))

			render.SetMaterial(Material("materials/pngtexts/darkstar.png"))
			render.DrawSprite(self:GetPos(), 16, 16, ColorSprite)
		render.PopFilterMag()
		render.PopFilterMin()
	end

	function ENT:OnRemove()
		local emit = ParticleEmitter(self:GetPos())

		for i = 1, 100 do
			local part = emit:Add("sprites/light_ignorez", self:GetPos())
			if part then
				part:SetColor( 73, 50, 111 )
				part:SetDieTime( 0.3 )
				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )
				part:SetStartSize( 3.5 )
				part:SetEndSize( 20 )
				part:SetGravity(Vector( 0, 0, 250 ))
				part:SetVelocity( VectorRand() * 150 )
			end
		end
		emit:Finish()

		local emit2 = ParticleEmitter(self:GetPos())

		for i = 1, 100 do
			local part = emit2:Add("sprites/light_ignorez", self:GetPos())
			if part then
				part:SetColor( 125, 110, 149 )
				part:SetDieTime( 0.1 )
				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )
				part:SetStartSize( 3.5 )
				part:SetEndSize( 20 )
				part:SetGravity(Vector( 0, 0, 250 ))
				part:SetVelocity( VectorRand() * 150 )
			end
		end
		emit2:Finish()
	end
end