include("shared.lua")

local spritemat = Material("mat_jack_gmod_shinesprite")
local ColorSprite =  Color(255, 89, 0)

function ENT:Draw()
	self:DrawModel()

	local TextrSZ = 640

	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), TextrSZ / 2, TextrSZ / 2, ColorSprite)

		render.SetMaterial( Material( "sprites/glow04_noz" ))
		render.DrawSprite(self:GetPos(), TextrSZ, TextrSZ, Color(255, 122, 51))
	render.PopFilterMag()
	render.PopFilterMin()

	self:DrawModel()

	render.SetMaterial(spritemat)
	render.DrawSprite(self:GetPos(), 50, 50, Color(255, 255, 243))

	local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position
	local disttocentre = 20

	for i = 1, 1 do
		local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-disttocentre, disttocentre), math.random(-disttocentre, disttocentre), math.random(-disttocentre, disttocentre)) ) -- Create a new particle at pos
		if ( part ) then
			part:SetColor( 255, 207, 51 )
			part:SetDieTime( 2 ) -- How long the particle should "live"

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