include("shared.lua")

local spritemat = Material("mat_jack_gmod_shinesprite")
local ColorSprite =  Color(87, 138, 255)

function ENT:Draw()
	self:DrawModel()

	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 32, 32, ColorSprite)

		render.SetMaterial( Material( "sprites/glow04_noz" ))
		render.DrawSprite(self:GetPos(), 128, 128, Color(100, 149, 255))
	render.PopFilterMag()
	render.PopFilterMin()

	self:DrawModel()

	render.SetMaterial( Material( "particle/Particle_Ring_Wave_Additive" ))
	render.DrawSprite(self:GetPos(), 16, 16, Color(145, 224, 255))

	local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

	for i = 1, 1 do
		local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
		if ( part ) then
			part:SetColor( 146, 179, 255 )
			part:SetDieTime( 0.7 ) -- How long the particle should "live"

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