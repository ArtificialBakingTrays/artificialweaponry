SWEP.PrintName = "The Slabshot"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Also known as: The Slopshot, Dexter's own design, a charged sniper rifle that packs an explosive punch."
SWEP.Category = "Artificial Weaponry"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	if self:Clip1() <= 0 then return end
	if self.ChargeStart then return end

	self:EmitSound( "tray_sounds/chargebegin.mp3", 75, 105 )

	self.ChargeStart = CurTime()
end

function SWEP:ChargeAttack( charge )
	if self:Clip1() <= 0 then return end
	if charge > 1 then charge = 1 end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.65 )

	self:EmitSound( "tray_sounds/basicfire.mp3", 75, math.random(100.5, 105.5), 0.7, 1 )
	self:EmitSound( "npc/sniper/echo1.wav", 75, math.random(105.5, 110), 0.7, 6 )

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	self:FireBullets{
		Src = owner:GetShootPos(),
		Dir = owner:GetAimVector(),
		Spread = Vector( 0, 0 ),
		Attacker = owner,
		Num = 1,
		Damage = 40 + charge * 200,
	}

	owner:LagCompensation( false )
end

function SWEP:Reload()
	if ( not self:HasAmmo() ) or ( CurTime() < self:GetNextPrimaryFire() ) then return end

	if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
		self:DefaultReload( ACT_VM_RELOAD )
		self:EmitSound("tray_sounds/reloadonce.mp3", 100 )

		self.EnDis = false
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end

	self.EnDis = not self.EnDis
end

function SWEP:TranslateFOV( fov )
	self.LastFOV = fov

	if self.EnDis then
		return 25
	end
end

function SWEP:AdjustMouseSensitivity()
	if self.EnDis then
		return 25 / self.LastFOV
	end
end

function SWEP:Think()
	if not IsFirstTimePredicted() then return end

	local start = self.ChargeStart
	if not start then return end

	local owner = self:GetOwner()
	if not owner:KeyDown( IN_ATTACK ) then
		self.ChargeStart = nil
		self:ChargeAttack( CurTime() - start )
	end
end

local function drawCircle(x, y, sx, sy, itr)
	for i = 0, (itr - 1) do
	local delta = (i / itr) * (math.pi * 2)

	local deltaPrev = ((i - 1) / itr) * (math.pi * 2)


	local x1 = x + math.cos(delta) * sx
	local y1 = y + math.sin(delta) * sy

	local x2 = x + math.cos(deltaPrev) * sx
	local y2 = y + math.sin(deltaPrev) * sy

	surface.DrawLine(x1, y1, x2, y2)
	end
end

local c_Start = Color(255, 255, 255)
local c_plyclr = Color(0, 0, 0)

local function lerpColorVarArg(t, a, b)
	return Lerp(t, a.r, b.r), Lerp(t, a.g, b.g), Lerp(t, a.b, b.b)
end

function SWEP:DrawHUD()
	local delta = 0
	if self.ChargeStart then
		delta = CurTime() - self.ChargeStart
		delta = math.min(delta, 1)
	end

	local PlyClr = self:GetOwner():GetWeaponColor()
	c_plyclr:SetUnpacked(PlyClr[1] * 255, PlyClr[2] * 255, PlyClr[3] * 255, 255)

	local r, g, b = lerpColorVarArg(delta, c_Start, c_plyclr)
	surface.SetDrawColor(c_plyclr)
	render.SetColorMaterialIgnoreZ()

	drawCircle(ScrW() * .5, ScrH() * .5, 5.5, 5.5,  24)

	draw.SimpleText("iDELTA; " .. tostring(invDelta), "BudgetLabel", 0, 0, c_White)

--Attempting to draw the hud for scoping in
	local scope = surface.GetTextureID("vgui/hud/xbox_reticle")

	if self.EnDis == true then
		local w = ScrW() / 2
		local h = ScrH() / 2

		surface.SetTexture(scope)
		surface.SetDrawColor(r, g, b, 255)

		surface.DrawTexturedRectRotated(w, h, w / 4, w / 4, 0)

	end
end