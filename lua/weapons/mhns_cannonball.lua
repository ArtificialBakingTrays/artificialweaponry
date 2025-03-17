SWEP.PrintName = "Captain BootSector's Cannon"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "Not Needed"
SWEP.Instructions	= "Bouncy Cannonball Weapon"
SWEP.Category 		= "MHNS Exclusives"

util.PrecacheSound("physics/metal/metal_barrel_impact_hard7.wav")
util.PrecacheSound("buttons/lever6.wav")
util.PrecacheSound("weapons/grenade_launcher1.wav")

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel	= "models/weapons/w_rocket_launcher.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "rpg"
SWEP.Slot = 2


SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	local owner = self:GetOwner()
	--local ownerpos = owner:GetShootPos()
	--local forward = owner:GetAimVector()

	self:SetNextPrimaryFire( CurTime() + 2.45 )

	local pitch = math.random(90, 110)

	self:EmitSound( "buttons/lever6.wav", 100, pitch - 5, 0.7, 1 )
	--Weapon Sounds
	self:EmitSound( "weapons/grenade_launcher1.wav", 100, pitch - 30, 0.7, 6 )

	owner:LagCompensation( true )

	self:CannonLaunch()

	owner:LagCompensation( false )
end

function SWEP:SecondaryAttack() end

function SWEP:CannonLaunch()
	--ALOT OF THIS SECTION IS BASED ON LOKA CODE. Creds to him for letting me learn from this :D
	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )

	if ( not ent:IsValid() ) then return end

	--Appearance of Cannon
	ent:SetModel("models/XQM/Rails/gumball_1.mdl")
	ent:SetMaterial("models/props_buildings/destroyedbuilldingwall01a")
	ent:SetColor(Color(41, 41, 41))

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, 10) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:Spawn()
	ent:SetOwner( owner )

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	entphys:SetBuoyancyRatio(0)
	entphys:SetMass(250)
	entphys:SetMaterial("gmod_bouncy")

	local Tsize = 35

	util.SpriteTrail(ent, 0, Color(55, 55, 55), false, Tsize, 1, 0.2, 1 / ( Tsize + 1 ) * 0.5, "trails/smoke")

	entphys:EnableGravity(true)

	entphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG) --Thank you zynx for superball fix :pray:
	aimvec:Mul( 2500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

	entphys:Wake()

	ent:AddCallback("PhysicsCollide", function(enthit, data)
		if ( not ent:IsValid() ) then return end

		if (ent.NextHit or 0) > CurTime() then return end

		local pitch = math.random(90, 110)
		ent:EmitSound( "physics/metal/metal_barrel_impact_hard7.wav", 100, pitch - 15, 0.7, 1 )

		if not IsValid(data.HitEntity) then return end

		if data.HitSpeed:Length() > 60 then
			if not IsValid(ent) then
				return
			end

			data.HitEntity:TakeDamage(50, owner)
			ent.NextHit = CurTime() + 0.3
		end

	end)

	local Time = 2.25

	--Detonating!
	timer.Simple( Time, function()
		if not IsValid( ent ) then return end

		ent:Remove() --Eliminate yourself

		util.BlastDamage( ent, ent:GetOwner(), ent:GetPos(), 250, 85 )

		local effectdata = EffectData() --What the fuck does this meaaaaan
		effectdata:SetOrigin( ent:GetPos() )
		--Oh I get it now

		if ent:WaterLevel() == 0 then
			util.Effect("Explosion", effectdata, true, true)
		else
			util.Effect("WaterSurfaceExplosion", effectdata, true, true)
		end --Tempted to remove this water part...
	end)

end