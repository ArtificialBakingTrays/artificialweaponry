include("shared.lua")

local spritemat = Material("particle/Particle_Ring_Wave_Additive")

function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(spritemat)
	render.DrawSprite(self:GetPos(), 5, 5, Color(255, 255, 243))

	local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

	for i = 1, 1 do
		local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
		if ( part ) then
			part:SetColor( 255, 255, 148 )
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

	timer.Simple(1.3, function()
		if not IsValid( self ) then return end
		local emit = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position
			for i = 1, 25 do
				local part = emit:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
				if ( part ) then
					part:SetColor( 255, 255, 148 )
					part:SetDieTime( 0.25 ) -- How long the particle should "live"

					part:SetStartAlpha( 255 ) -- Starting alpha of the particle
					part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

					part:SetStartSize( 15 ) -- Starting size
					part:SetEndSize( 0 ) -- Size when removed

					part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
					part:SetVelocity( VectorRand() * 1750 ) -- Initial velocity of the particle
				end
			end
		emit:Finish()
	end)
end
