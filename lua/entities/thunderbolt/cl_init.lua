include("shared.lua")

local spritemat = Material("particle/Particle_Ring_Sharp")
local electric = Material("effects/ar2_altfire1")
local glowmat = Material("sprites/light_glow02_add")
local BaseColor = Color( 255, 255, 0)


function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(spritemat)
	render.DrawSprite(self:GetPos(), 24, 24, Color( 248, 255, 167))

	render.SetMaterial(glowmat)
	render.DrawSprite(self:GetPos(), 96, 96, BaseColor )

	render.SetMaterial(electric)
	render.DrawSprite(self:GetPos(), 36, 36, BaseColor )

	local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

	for i = 1, 1 do
		local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-5, 5), math.random(-5, 5), math.random(-5, 5) ) ) -- Create a new particle at pos
		if ( part ) then
			part:SetColor( 255, 255, 0 )
			part:SetDieTime( 0.1 ) -- How long the particle should "live"

			part:SetStartAlpha( 255 ) -- Starting alpha of the particle
			part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

			part:SetStartSize( 5 ) -- Starting size
			part:SetEndSize( 0 ) -- Size when removed

			part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
			part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
		end
	end
	emitter:Finish()
end