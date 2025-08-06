SWEP.PrintName = "Luck O' The Draw"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "I gamble with my life. Reload to roll the dices, Dices determine weapon stats."
SWEP.IconOverride = "vgui/weaponvgui/placehold_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

local bronze1 = 0
local bronze2 = 0
local bronze3 = 0
local silver1 = 0
local silver2 = 0
local gold = 0

local total = 0

function SWEP:Deploy()
	self:SetClip1( 1 )
	self:EmitSound( "artiwepsv2/letsgogambling.mp3", 100, 100, 0.4, 1 )

	return true
end

--========Reload Mechanics========
function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	local ReloTime = 0.2

	if self:Clip1() == total then ReloTime = 0.2 end
	if self:Clip1() ~= total then ReloTime = 0.8 end

	self:SetDTFloat( 0, CurTime() + ReloTime )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:ReloadMechanic()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end
	print(total)
	if total ~= 29 then self:SetClip1( total ) end
	self:SetDTFloat( 0, 0 )
	self:DiceRollMechanic()
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	self:ReloadMechanic()
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end


function SWEP:DiceRollMechanic()
	bronze1 = math.floor(util.SharedRandom( "bronze1", 0, 3 ))
	bronze2 = math.floor(util.SharedRandom( "bronze2", 1, 4 ))
	bronze3 = math.floor(util.SharedRandom( "bronze2", 1, 4 ))
	silver1 = math.floor(util.SharedRandom( "silver1", 3, 9 ))
	silver2 = math.floor(util.SharedRandom( "silver1", 4, 8 ))
	gold = math.floor(util.SharedRandom( "gold", 7, 12 ))

	total = bronze1 + bronze2 + bronze3 + silver1 + silver2 + gold

	if total <= 29 then
		if total == 23 then return end
		self:EmitSound( "artiwepsv2/cha-ching.mp3", 75, math.random(95, 105), 1, 6)
	end
	if total < 23 then
		self:EmitSound( "artiwepsv2/aw_dangit.mp3", 75, 100, 1, 6)
	end
	if total >= 30 then
		self:EmitSound( "artiwepsv2/bigwin.mp3", 75, 130, 1, 6)
		self:SetClip1( total * 2 )
	end
end
--========Reload Mechanics========



function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	if self:Clip1() <= 20 then gundmg = total / 4 end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire( CurTime() + 0.062 )

	self:EmitSound( "artiwepsv2/subzero_standard.mp3", 75, 170, 1, 1 )

	local bullets = {
		Src = self:GetOwner():GetShootPos(),
		Dir = self:GetOwner():GetAimVector(),
		Spread = 0 + ( total / 1000 ),
		Attacker = self:GetOwner(),
		Callback = function( att, tr, dmg ) dmg:SetInflictor( self ) end,
		Damage = total / 2
	}
	self:GetOwner():LagCompensation( true )

	self:GetOwner():FireBullets( bullets)

	self:GetOwner():LagCompensation( false )
end