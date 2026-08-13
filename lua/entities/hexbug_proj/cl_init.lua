include("shared.lua")

local spritemat = Material("sprites/light_glow02_add")
local ColorGreen = Color(166, 255, 106)

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		render.PushFilterMin(TEXFILTER.POINT)
		render.PushFilterMag(TEXFILTER.POINT)
			render.SetMaterial(spritemat)
			render.DrawSprite(self:GetPos(), 32, 32, ColorGreen)
		render.PopFilterMag()
		render.PopFilterMin()
	end

	function ENT:OnRemove()
		local emit = ParticleEmitter(self:GetPos())

		for i = 1, 26 do
			local part = emit:Add("particle/Particle_Glow_04_Additive", self:GetPos())

			if part then
				part:SetColor( 132, 255, 0 )
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