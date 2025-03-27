include("shared.lua")

local spritemat = Material("sprites/gmdm_pickups/light")
local ColorSprite =  Color(234, 255, 160)

function ENT:Draw()
	self:DrawModel()

	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 32, 32, ColorSprite)
	render.PopFilterMag()
	render.PopFilterMin()
end