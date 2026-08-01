AddCSLuaFile("autorun/statuses.lua")
include("autorun/statuses.lua")

SWEP.PrintName = "LostMasks"
SWEP.Author	= "ArtificialBakingTrays + zynx"
SWEP.Instructions = "A smile is only 180 degrees away from a frown."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/lostmasks_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.UseHands = false
SWEP.ViewModelFlip1 = true
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.ViewModelFOV = 54
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 3
SWEP.Secondary.DefaultClip = 3
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "PrimaryReloading" )
	self:NetworkVar( "Bool", 1, "SecondaryReloading" )

	self:NetworkVar( "Float", 0, "PrimaryReloadTime" )
	self:NetworkVar( "Float", 1, "SecondaryReloadTime" )
end

function SWEP:SendViewModelAnim( act, index, rate )
	local vm = self:GetOwner():GetViewModel( index )
	if not vm or not vm:IsValid() then return end

	local seq = vm:SelectWeightedSequence( act )
	if seq == -1 then return end

	vm:SendViewModelMatchingSequence( seq )
	vm:SetPlaybackRate( rate or 1 )
end

function SWEP:Initialize()
	self:SetHoldType( "duel" )
end

function SWEP:Deploy()
	self:SetHoldType( "duel" )

	local vm = self:GetOwner():GetViewModel( 1 )
	if vm and vm:IsValid() then
		vm:SetWeaponModel( self.ViewModel, self )
	end

	self:SendViewModelAnim( ACT_VM_DRAW, 0, 4 )
	self:SendViewModelAnim( ACT_VM_DRAW, 1, 4 )

	return true
end

function SWEP:Holster()
	local vm = self:GetOwner():GetViewModel( 1 )
	if vm and vm:IsValid() then
		vm:SetWeaponModel( self.ViewModel, nil )
	end

	return true
end

local bullet = {
	Damage = 6,
	Num = 6,
	Tracer = 0,
	Spread = Vector( .08, .08, .08 )
}

function SWEP:SharedFire( specgun )
	self:EmitSound( "artiwepsv2/exoshoot.mp3", 75, 100, nil, CHAN_STATIC )
	self:EmitSound( "artiwepsv2/exobladeslash.mp3", 75, 100, nil, CHAN_STATIC )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	local owner = self:GetOwner()

	bullet.Attacker = owner
	bullet.IgnoreEntity = owner
	bullet.Inflictor = self

	bullet.Dir = owner:GetAimVector()
	bullet.Src = owner:GetShootPos()

    local firedGun = specgun

    bullet.Callback = function( attacker, tr )
        if CLIENT then return end
        if firedGun == "right" then
            --StatusTrickle( ent, dmgown, dmgtick, ticks )
            if IsValid(tr.Entity) then StatusTrickle( tr.Entity, attacker, 4, 5 ) end
        elseif firedGun == "left" then
            if IsValid(tr.Entity) and not tr.Entity:IsOnFire() then
                tr.Entity:Ignite( 10 )
            end
        end
    end

	owner:FireBullets( bullet )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + .2 )

	self:SendViewModelAnim( ACT_VM_PRIMARYATTACK, 1, 1 )
	self:SharedFire("right")
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + .2 )

	self:SendViewModelAnim( ACT_VM_PRIMARYATTACK, 0, 1 )
	self:SharedFire("left")
end

function SWEP:Reload() return end


-- this fucking sucks i just pasted it from the colt pythons

local vec_one = Vector( 1, 1, 1 )
local vec_zero = Vector()

local gtfo = Vector( -3000, -3000, -3000 )

function SWEP:PreDrawViewModel( vm )
	for i = 0, vm:GetBoneCount() - 1 do
		if string.sub( vm:GetBoneName( i ), 1, 18 ) == "ValveBiped.Bip01_L" then
			vm:ManipulateBoneScale( i, vec_zero )
			vm:ManipulateBonePosition( i, gtfo )
		end
	end

	vm:SetupBones()
end

function SWEP:PostDrawViewModel( vm )
	for i = 0, vm:GetBoneCount() - 1 do
		if string.sub( vm:GetBoneName( i ), 1, 18 ) == "ValveBiped.Bip01_L" then
			vm:ManipulateBoneScale( i, vec_one )
			vm:ManipulateBonePosition( i, vec_zero )
		end
	end
end