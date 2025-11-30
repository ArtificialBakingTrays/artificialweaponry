include("shared.lua")

--local spritemat = Material("sprites/light_glow02_add")
--local MdlColor = Color(255, 255, 255)
--local size = 64

function ENT:Draw()
	self:DrawModel()
--	render.PushFilterMin(TEXFILTER.POINT)
--render.PushFilterMag(TEXFILTER.POINT)
--		render.SetMaterial(spritemat)
--		render.DrawSprite(self:GetPos(), size, size, MdlColor)
--	render.PopFilterMag()
--	render.PopFilterMin()
end