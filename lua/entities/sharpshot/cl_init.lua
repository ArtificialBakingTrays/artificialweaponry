include("shared.lua")

local spritemat = Material("particle/Particle_Ring_Wave_Additive")
local electric = Material("effects/ar2_altfire1")
local glowmat = Material("sprites/light_glow02_add")
local BaseColor = Color( 240, 255, 140)

function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(spritemat)
	render.DrawSprite(self:GetPos(), 48, 48, BaseColor)

	render.SetMaterial(glowmat)
	render.DrawSprite(self:GetPos(), 192, 192, BaseColor )

	render.SetMaterial(electric)
	render.DrawSprite(self:GetPos(), 56, 56, BaseColor )

	local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

	for i = 1, 1 do
		local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-10, 10), math.random(-10, 10), math.random(-10, 10 ) ))
		if ( part ) then
			part:SetColor( 240, 255, 140 )
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