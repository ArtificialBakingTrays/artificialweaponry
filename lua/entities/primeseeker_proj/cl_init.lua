include("shared.lua")
local electric = Material("effects/ar2_altfire1")
local glowmat = Material("sprites/light_glow02_add")

function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(Material("sprites/tp_beam001"))
	render.DrawSprite(self:GetPos(), 24, 22, Color( 255, 255, 255))

	render.SetMaterial(glowmat)
	render.DrawSprite(self:GetPos(), 192, 192, Color(255, 94 ,94) )

	render.SetMaterial(electric)
	render.DrawSprite(self:GetPos(), 56, 56, Color(250, 179, 205) )

	render.SetMaterial(Material("particle/Particle_Ring_Wave_Additive"))
	render.DrawSprite(self:GetPos(), 36, 24, Color(255, 255, 255) )
end
