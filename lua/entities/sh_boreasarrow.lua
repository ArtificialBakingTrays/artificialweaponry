AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Boreas Arrow Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = GetWeaponPack()
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Boreas' Draw"
ENT.Spawnable = false


if SERVER then
	function ENT:Initialize()
		--Get current position, Current pos of arrow + velocity. get the normal, from normal you get the angle
		self:SetModel("models/weapons/w_missile_closed.mdl")
		self:SetModelScale( 0.5 )
		self:SetMaterial("model_color")
		self:SetColor(Color(247, 255, 239))

		local TSIZE = 16
		util.SpriteTrail(self, 0, Color(133, 164, 255), false, TSIZE, 0, 0.2, 1, "trails/physbeam")

		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self.IsTraysProjectile = true

		local phys = self:GetPhysicsObject()
		phys:SetBuoyancyRatio(0)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:SetMass(25)

		if phys:IsValid() then phys:Wake() end

		self:Fire( "Kill", "", 12.5 )
	end

	function ENT:PhysicsCollide(data)
		local enthit = data.HitEntity
		if ( not self:IsValid() ) then return end
		if enthit == self:GetOwner() then return end
		if enthit.IsTraysProjectile then return end
		self:EmitSound( "sparkbound/chillhitproc.mp3", 75, math.random(85, 115), 0.5, 6 )

		if not IsValid(enthit) then
				local effectdata = EffectData() --I love copy pasting
				effectdata:SetOrigin( self:GetPos() )
				effectdata:SetScale(1)
				util.Effect("GlassImpact", effectdata, true, true)
				self:Remove()
			return
		end

		if data.HitSpeed:Length() > 60 then
			if not IsValid(self) then return end
			self:Remove()

			enthit:TakeDamage( 15 + ((self:GetVelocity():Length() / 10) / 2), self:GetOwner() )

			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetScale( 1 )
			util.Effect("GlassImpact", effectdata, true, true)
		end
	end
end

if CLIENT then
	function ENT:Draw()
		local glowmat = Material("addons/artificialweaponry/materials/materials/pngtexts/iceprojtext.png")

		local m = Matrix()
		local width = 1
		m:Scale(Vector(width, width, width ))
		self:EnableMatrix("RenderMultiply", m)
		self:DrawModel()

		self:DrawModel()

		local scale = 0.5

		render.SetMaterial(glowmat)
		render.DrawSprite(self:GetPos(), 24 * scale, 24 * scale, Color(246, 249, 255))

		render.SetMaterial(Material("materials/pngtexts/halftone_dotty.png"))
		render.DrawSprite(self:GetPos(), 24 * scale, 24 * scale, Color(255, 255, 255) )
	end
end