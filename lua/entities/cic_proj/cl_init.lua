include("shared.lua")

local spritemat = Material("sprites/gmdm_pickups/light")
local ColorSprite = Color(160, 160, 255)
local sparkler = Color(255, 223, 164)

function ENT:Draw()
	self:DrawModel()

	render.PushFilterMin(TEXFILTER.POINT)
	render.PushFilterMag(TEXFILTER.POINT)
		render.SetMaterial(spritemat)
		render.DrawSprite(self:GetPos(), 32, 32, sparkler)
	render.PopFilterMag()
	render.PopFilterMin()
end