SWEP.PrintName = "Luck O' The Draw"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "I gamble with my life. Reload to roll the dices, Dices determine weapon stats."
SWEP.IconOverride = "vgui/weaponvgui/placehold_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15
SWEP.Category = "Artificial Weaponry"

SWEP.Primary.ClipSize = total
SWEP.Primary.DefaultClip = total
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Deploy() --Features Lokacode cus 3 line if statements
	self:EmitSound( "artiwepsv2/letsgogambling.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
end

local bronze1 = 0
local bronze2 = 0
local bronze3 = 0
local silver1 = 0
local silver2 = 0
local gold = 0

--========Reload Mechanics========
function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end

	self:SetDTFloat( 0, CurTime() + 0.7 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
	DiceRollMechanic()
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	self:SetClip1( total )
	self:SetDTFloat( 0, 0 )

	if total > 23 then
		self:EmitSound( "artiwepsv2/cha-ching.mp3", 75, 100, 1, 1)
	end
	if total < 23 then
		self:EmitSound( "artiwepsv2/aw_dangit.mp3", 75, 100, 1, 1)
	end
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end


function DiceRollMechanic()
	bronze1 = math.random(0, 3)
	bronze2 = math.random(1, 4)
	bronze3 = math.random(0, 4)
	silver1 = math.random(3, 8)
	silver2 = math.random(4, 7)
	gold = math.random(7, 12)

	total = bronze1 + bronze2 + bronze3 + silver1 + silver2 + gold
end
--========Reload Mechanics========




function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	if self:Clip1() <= 20 then gundmg = total / 4 end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire( CurTime() + 0.062 )

	self:EmitSound( "artiwepsv2/subzero_standard.mp3", 75, 170, 1, 1 )
end