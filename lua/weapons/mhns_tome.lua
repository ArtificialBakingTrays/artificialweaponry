SWEP.PrintName = "BookWyrm's Tome of the Risen"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "ArtificialBakingTrays"
SWEP.Instructions	= "A book that raises Sunless fools, and cursed on primary attacks."
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/tome_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel	= "models/weapons/w_medkit.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.Slot = 3

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:PrimaryAttack() --Cursing Rounds
	local time = 0.05
	local Vol = 0.6

	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 135, 165 ), Vol, 1 )
	self:EmitSound( "artiwepsv2/tombfire_2.mp3", 100, math.random( 95, 105 ), Vol, 6 )

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	self:DeployCurse()

	timer.Simple( time, function()
		self:DeployCurse()
		self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 135, 165 ), Vol, 1 )
		self:EmitSound( "artiwepsv2/tombfire_2.mp3", 100, math.random( 95, 105 ), Vol, 6 )
	end)

	owner:LagCompensation( false )

end

function SWEP:DeployCurse()
	if CLIENT then return end

	local ent = ents.Create( "tome_proj" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:SetOwner( owner )
	ent:SetGravity( 0 )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 1500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end

function SWEP:SecondaryAttack()	--Will summon Sunless Fool
	if self.HasSpawnedNpc == true then return end
	self:SetNextSecondaryFire( CurTime() + 1)
	self:EmitSound( "artiwepsv2/magicsummoningnoise.mp3", 100, math.random( 95, 105 ), 1.5, 1 )

	self:GetOwner():LagCompensation( true )
	self:SpawnFool()
	self.HasSpawnedNpc = true
	self:GetOwner():LagCompensation( false )
end

function SWEP:Think()
	self:CheckIfAlive()
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = false

	return self.AmmoDisplay
end

function SWEP:SpawnFool()
	if CLIENT then return end

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local owneraimdir = owner:GetAimVector()
	local PinkVoid = Color(255, 0, 75)
	local SSize = 50
	local ESize = 0
	local Duration = 0.5

	local ent = ents.Create( "npc_fastzombie" )
	ent:SetPos( ownerpos + owneraimdir * 64 )
	ent:SetOwner( owner )

	ent:AddEntityRelationship( ent:GetOwner(), D_LI, 100 )
	ent:Spawn()

	util.SpriteTrail( ent, 2, PinkVoid, false, SSize, ESize, Duration, 1, "trails/laser" )
	ent:SetHealth( ent:GetMaxHealth() + 250 )
	ent:SetBodygroup( 1, 0 )
	ent:SetColor(Color(25, 25, 25))
	ent:SetMaterial("models/ihvtest/arm")

	self.NPCSpawned = ent
	self.IsTraysProjectile = true
	ent.IsCoolNPC = true

	ent:Fire( "Kill", "", 40.5 )
end

function SWEP:CheckIfAlive()
	if CLIENT then return end

	if not IsValid(self.NPCSpawned) then
		self.HasSpawnedNpc = false
		return false
	end
	return true
end

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( target, dmginfo )
	local npcattack = dmginfo:GetAttacker()
	if not npcattack.IsCoolNPC then return end

	local ScaleDmg = 15
	if target.IsCursed == true then
		ScaleDmg = 30
	elseif target.IsCursed == false then
		ScaleDmg = 15
	end

	dmginfo:ScaleDamage( ScaleDmg )
	dmginfo:SetAttacker( npcattack:GetOwner() )
end )

hook.Add("player_hurt", "player_hurt_example", function( victim )
	if CLIENT then return end
	if victim:IsNPC() then return end
	attacker = victim:GetAttacker()

	victim.IsCursed = true
	local time2 = 1.5
	timer.Simple(time2, function()
		victim.IsCursed = false

	end)
end)


--[[
Transmission: From BookWyrm

Our religion is a lie, the 'truth' is a lie.
We need to forsake our god of suffering if we must persist on with our existance.
Please Madware, for our sake; We need to abandon the god before we are made redundant.
We both know he has found greater apprentices than us, it is only a matter of time.

This message remains unread by its Recipient.
]]--
