AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "BoreasRain Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = GetWeaponPack()
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Boreas' Draw"
ENT.Spawnable = true


if SERVER then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetModelScale( 0.5 )
		self:SetMaterial("model_color")
		self:SetColor(Color(247, 255, 239))

		self:EmitSound("artiwepsv3/boreascloudsummon.mp3", 100, math.random(95, 105), 0.5, CHAN_AUTO )
		self:EmitSound("artiwepsv3/wind_amb.mp3", 100, math.random(95, 105), 0.5, CHAN_AUTO )

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

		self:Fire( "Kill", "", 16 )
	end

	function ENT:Think()
		self:RainArrow()

		self:NextThink(CurTime())
		return true
	end

	function ENT:RainArrow()
		local Delay = 0.08
		if CurTime() < (self.SpawnNext or 0) then return end
		self.SpawnNext = CurTime() + Delay

		--ArtiwepsProjectile( Entstring, Owner, Position, Angles, AimVec, Boost, Gravity )
		ArtiwepsProjectile( "sh_boreasarrow", self:GetOwner(), self:GetPos() + Vector(math.random(-90, 90), math.random(-90, 90), 0), Angle(90,0,0), 0, 0, true )
	end

	function ENT:PhysicsCollide(data) return end
end

local ranCldLut = {
	[1] = {
		Str = "particle/smokesprites_0001",
	},
	[2] = {
		Str = "particle/smokesprites_0005",
	},
	[3] = {
		Str = "particle/smokesprites_0009",
	},
	[4] = {
		Str = "particle/smokesprites_0012",
	}
}

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		render.SetMaterial(Material("materials/pngtexts/halftone_dotty.png"))
		render.DrawSprite(self:GetPos(), 164 * 4, 164 * 4, Color(255, 255, 255, 195) )
	end

	function ENT:DoParticlesIfWeShould()
		-- if the time to do the next particle is in the future, we don't add more
		if (self._nextPart or 0) > CurTime() then return end
		local random = math.floor(math.random( 1, 4 ))
		local sndEntry = ranCldLut[random]
		local emitter = ParticleEmitter(self:GetPos())
		local randompos = 60
		local dietime = 4

		self._nextPart = CurTime() + 0.1

		for i = 1, 7 do
			local part = emitter:Add( sndEntry.Str, self:GetPos() + Vector( math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)), math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)),  math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)))) -- Create a new particle at pos
			--Longest one line of code ever
			--Color(39, 104, 164)
			if ( part ) then
				part:SetColor( 39, 104, 164 )
				part:SetDieTime( dietime )

				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )

				part:SetStartSize( math.random(10, 30) * 5)
				part:SetEndSize( 0 )

				part:SetGravity( Vector( 0, 0, 0 ) )
				part:SetVelocity( VectorRand() * 5 )
			end
		end

		local emit2 = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

		for i = 1, 6 do
			local part = emit2:Add( "effects/halftonegradient", self:GetPos() + Vector( math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)), math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)),  math.random(-randompos + math.random(-50, 50), randompos + math.random(-50, 50)))) -- Create a new particle at pos
			--Longest one line of code ever

			if ( part ) then
				part:SetColor( 39, 104, 164 )
				part:SetDieTime( dietime )

				part:SetStartAlpha( 52 )
				part:SetEndAlpha( 0 )

				part:SetStartSize( math.random(10, 30) * 5)
				part:SetEndSize( 0 )

				part:SetGravity( Vector( 0, 0, 0 ) )
				part:SetVelocity( VectorRand() * 5 )
			end
		end
		emit2:Finish()
		emitter:Finish()
	end

	function ENT:Think()
	self:DoParticlesIfWeShould()
	-- other stuff
	end
end