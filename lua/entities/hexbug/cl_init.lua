include("shared.lua")

local spritemat = Material("sprites/light_glow02_add")
local ColorGreen = Color(166, 255, 106)

function ENT:Draw()
	self:DrawModel()
	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 32, 32, ColorGreen)
	render.PopFilterMag()
	render.PopFilterMin()
end
