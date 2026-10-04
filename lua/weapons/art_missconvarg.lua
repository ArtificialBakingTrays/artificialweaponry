local RanID = math.random(-100, 100)
SWEP.PrintName = "MISSINGID: " .. RanID
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "//:DataNotPresent:LeftoverDataPreserved/End[]"
SWEP.Category = GetWeaponPack()
SWEP.IconOverride = "vgui/weaponvgui/missing_generi.png"
--Not supposed to be a available for everyone

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = false
SWEP.ViewModel	= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.DrawAmmo = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:SetMode( bool ) self:SetDTBool( 0, bool ) end
function SWEP:GetFireMode() return self:GetDTBool( 0 ) end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:Reload() return end

local sndLUT = {
	[1] = {
		snd = "artiwepsv3/missinsoundfire.mp3",
		pitchMin = 100,
		pitchMax = 115
	},
	[2] = {
		snd = "artiwepsv3/missingdatafire2.mp3",
		pitchMin = 100,
		pitchMax = 115
	}
}

function SWEP:MainFireMode()
	self:SetNextPrimaryFire( CurTime() + 0.186 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	local random = math.random(math.random( 1, 2 ))

	local sndEntry = sndLUT[random]
	local sndFile = sndEntry.snd
	self:EmitSound( sndFile, 100, math.random( sndEntry.pitchMin, sndEntry.pitchMax ), 1, CHAN_STATIC )
	self:EmitSound( "artiwepsv2/nucleoshoot.mp3", 100, math.random( sndEntry.pitchMin, sndEntry.pitchMax ), 1, CHAN_STATIC )

	ArtiwepsProjectile( "sh_missingdat", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles() + Angle( 90, 0, 0 ), self:GetOwner():GetAimVector(), 3000, true )
end


function SWEP:BlastFireMode()
	self:SetNextPrimaryFire( CurTime() + 0.92 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( "artiwepsv3/missingblast.mp3", 100, 100, 6, CHAN_STATIC )
	self:EmitSound( "artiwepsv3/staticfire.mp3", 100, math.random(90, 110), 1, CHAN_STATIC )

	local shots = math.random( 7, 14 )
	local spread = 0.08

	for i = 1, shots do
		local dir = (self:GetOwner():GetAimVector() + VectorRand() * spread):GetNormalized()

		ArtiwepsProjectile( "sh_missingdat", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles() + Angle( 90, 0, 0 ), dir, 700, true )
	end
end


function SWEP:PrimaryAttack()
	if self:GetFireMode() then
		self:MainFireMode()
	else
		self:BlastFireMode()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.5 )
	self:SetMode( not self:GetFireMode() )
end


--============================[ Fancy Rendering Shit ]============================--

local col1 = Color(255, 151, 91)
local col2 = Color(125, 110, 149)
local col3 = Color(255, 255, 246)

local speed = 0.5 -- higher = faster

function GetFadeColour()
	local bsmath = (math.sin(CurTime() * speed) + 1) / 2

	local col
	if bsmath < 0.5 then
		local frac = t * 2
		col = Color( Lerp(frac, col1.r, col2.r), Lerp(frac, col1.g, col2.g), Lerp(frac, col1.b, col2.b) )
	else
		local frac = (t - 0.5) * 2 col = Color( Lerp(frac, col2.r, col3.r), Lerp(frac, col2.g, col3.g), Lerp(frac, col2.b, col3.b) )
	end
	return col
end


SWEP.UseHands = false

function SWEP:DrawWorldModel( flags )
	local col = GetFadeColour()

	local multip = 20

	render.SetColorModulation( (col.r / 255) * multip, (col.g / 255) * multip, (col.b / 255) * multip)
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	local col = GetFadeColour()

	local multip = 20

	render.SetColorModulation( (col.r / 255) * multip, (col.g / 255) * multip, (col.b / 255) * multip)
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end