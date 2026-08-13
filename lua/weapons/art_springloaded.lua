SWEP.PrintName = "SpringLoaded ScatterSearch"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = ""
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/springload_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 26
SWEP.Primary.DefaultClip = 26
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = nil

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

--The code I understand the least :D -Rayne

local offsetSpread = 0.035
local offsetLUT = {
	-- Top row
	[1] = Vector(-offsetSpread, offsetSpread ),
	[2] = Vector( 0			  , offsetSpread ),
	[3] = Vector( offsetSpread, offsetSpread ),

	-- Center row
	[4] = Vector(-offsetSpread, 0			 ),
	[5] = Vector( 0			  , 0			 ),
	[6] = Vector( offsetSpread, 0			 ),

	[7] = Vector(-offsetSpread, -offsetSpread),
	[8] = Vector( 0			  , -offsetSpread),
	[9] = Vector( offsetSpread, -offsetSpread),
}

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire( CurTime() + 0.256 )
	if self.isReloading == true then return end
	local owner = self:GetOwner()

	self:EmitSound( "artiwepsv2/nucleoshoot.mp3", 75, math.random(130, 140), 1, 1 )
	self:EmitSound( "tray_sounds/parasite_fire.mp3", 75, math.random(105, 110), 1, 6 )

	owner:LagCompensation( true )

	self._fireAmount = (self._fireAmount or 0) + 1

	local aimDir = owner:GetAimVector()
	local aimDirAng = aimDir:Angle()
	local aimRight = aimDirAng:Right()
	local aimUp = aimDirAng:Up()

	local realShootDir = Vector()
	for i = 1, #offsetLUT do
		local entry = offsetLUT[i] * 1
		realShootDir:Set(aimDir)

		entry:Rotate(Angle(0, self._fireAmount * 15, 0))

		local offX = entry[1]
		local offY = entry[2]

		realShootDir = realShootDir + (aimRight * offX) + (aimUp * offY)
		realShootDir:Normalize()

		owner:FireBullets({
			Src = owner:GetShootPos(),
			Dir = realShootDir,
			Damage = 9,
			Num = 1,
			Spread = Vector(0.0, 0.0),
			Attacker = owner,
			Inflictor = self,
			Force = 0,
		})
	end

	owner:LagCompensation( false )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end
	self.isReloading = true
	self:SetNextPrimaryFire( CurTime() + 1.56 )

	self:EmitSound( "tray_sounds/reload_1.mp3", 100, 105, 1, nil )
	self:EmitSound( "artiwepsv2/usesfx.wav", 100, 105, 1, 6 )

	self:SetDTFloat(0, CurTime() + .7 )
	self:SendWeaponAnim( ACT_VM_RELOAD )

	timer.Simple( 0.7, function()
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end)
end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end
	if time > CurTime() then return end

	self:SetClip1( 8 )
	self:SetDTFloat( 0, 0 )
	self.isReloading = false
end

function SWEP:Deploy() --Features Lokacode cus 3 line if statements
	self:EmitSound( "artiwepsv2/chemfire1.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
	self:EmitSound( "tray_sounds/reload_1.mp3", 100, math.random( 95, 105 ), 0.4, 1 )
	self:GetOwner():SetRunSpeed( 450 )
	self.isEquipped = true
end

function SWEP:Holster()
	if CLIENT then return end
	self.isEquipped = false
	self:GetOwner():SetRunSpeed( 400 )
	return true
end

if SERVER then
    hook.Add("KeyPress", "DoubJump", function(ply, key)
        if not IsValid(ply) then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "art_springloaded" then return end
        if key ~= IN_JUMP then return end

        if ply:OnGround() then ply.DoubJumped = false return end
        if ply.DoubJumped then return end
        ply.DoubJumped = true

        -- Give them an upward boost
        local vel = ply:GetVelocity()
		ply:EmitSound( "footsteps/gw_snow3.wav", 100, math.random(95, 105), 1, nil )
		ply:EmitSound( "artiwepsv2/chemfire2.mp3", 100, math.random(95, 105), 1, 6 )

        ply:SetVelocity(Vector( 0, 0, 300 - math.max( vel.z, 0 ) ))
    end)

    hook.Add("Think", "DoubJumpReset", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:OnGround() then ply.DoubJumped = false end
        end
    end)
end