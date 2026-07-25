include("shared.lua")

local spritemat = Material("sprites/gmdm_pickups/light")
local ColorSprite =  Color(32, 0, 8)

function ENT:Draw()
	self:DrawModel()

	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 32, 32, ColorSprite)
	render.PopFilterMag()
	render.PopFilterMin()
end