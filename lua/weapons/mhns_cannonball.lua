SWEP.PrintName = "Captain BootSector's Cannon"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Instructions	= "Bouncy Cannonball Weapon"
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/cannon_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel	= "models/weapons/w_rocket_launcher.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = false
SWEP.HoldType = "rpg"
SWEP.Slot = 2

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	local owner = self:GetOwner()
	--local ownerpos = owner:GetShootPos()
	--local forward = owner:GetAimVector()

	self:SetNextPrimaryFire( CurTime() + 0.45 )

	self:EmitSound( "buttons/lever6.wav", 100, math.random(90, 110), 0.7, 1 )
	--Weapon Sounds
	self:EmitSound( "weapons/grenade_launcher1.wav", 100, math.random(90, 110) - 30, 0.7, 6 )

	owner:LagCompensation( true )

	self:CannonLaunch()

	owner:LagCompensation( false )
end

function SWEP:SecondaryAttack() end

function SWEP:Reload()
	if self:GetDTFloat( 0 ) ~= 0 then return end
	if CurTime() < ( self:GetNextPrimaryFire() + .5 ) then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + 1.6 )
	self:SendWeaponAnim(ACT_VM_RELOAD)

	self:EmitSound( "vehicles/tank_readyfire1.wav", 75, 120, .7, 1 )
	self:EmitSound( "buttons/lever4.wav", 75, 50, .7, 6 )
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 3 )
	self:SetDTFloat(0, 0)
end

function SWEP:CannonLaunch()
	--ALOT OF THIS SECTION IS BASED ON LOKA CODE. Creds to him for letting me learn from this :D
	if ( CLIENT ) then return end

	local ent = ents.Create( "prop_physics" )

	if ( not ent:IsValid() ) then return end

	--Appearance of Cannon
	ent:SetModel("models/XQM/Rails/gumball_1.mdl")
	ent:SetMaterial("models/flesh")
	ent:SetColor(Color(0, 0, 0))

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	local hullSize = 8
	local trmins = Vector(-hullSize, -hullSize, -hullSize)
	local trmax = Vector(hullSize, hullSize, hullSize)
	local tr = util.TraceHull({
		start = ownerpos,
		endpos = ownerpos + aimvec * 16,
		filter = self:GetOwner(),
		mins = trmins,
		maxs = trmax,
	})

	ent:SetPos( tr.HitPos + tr.HitNormal * 8)
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:SetOwner( owner )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	entphys:SetBuoyancyRatio(0)
	entphys:SetMass(250)
	entphys:SetMaterial("gmod_bouncy")

	local Tsize = 35

	util.SpriteTrail(ent, 0, Color(35, 35, 35), false, Tsize, 1, 0.2, 1 / ( Tsize + 1 ) * 0.5, "trails/smoke")

	entphys:EnableGravity(true)

	entphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG) --Thank you zynx for superball fix :pray:
	aimvec:Mul( 2500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

	entphys:Wake()

	ent:AddCallback("PhysicsCollide", function(enthit, data)
		if ( not ent:IsValid() ) then return end

		if (ent.NextHit or 0) > CurTime() then return end

		ent:EmitSound( "physics/metal/metal_barrel_impact_hard7.wav", 100, math.random(90, 110), 0.7, 1 )

		if not IsValid(data.HitEntity) then return end

		if data.HitSpeed:Length() > 60 then
			if not IsValid(ent) then
				return
			end

			data.HitEntity:TakeDamage(30, owner)
			ent.NextHit = CurTime() + 0.1
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

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end--YAARRRGGGHHHH


-- ZYNX STUFF HERE
-- Im so glad i aint the one to do all of this :pray: -Trays
function SWEP:GetCSModel()
	local mdl = self.CSModel
	if not mdl or not mdl:IsValid() then
		mdl = ClientsideModel( "models/props_phx/cannon.mdl" )
		mdl:SetNoDraw( true )
		mdl:SetModelScale( .2 )

		self.CSModel = mdl
	end

	return mdl
end

function SWEP:OnRemove()
	local mdl = self.CSModel
	if mdl and mdl:IsValid() then
		mdl:Remove()
	end
end

local cannon_vm_pos, cannon_vm_ang = Vector( 0, -9.5, 2 ), Angle( -90, 90, 180 )
function SWEP:DrawVMCannon( vm )
	local mdl = self:GetCSModel()

	local index = vm:LookupBone "base"
	if not index then return end

	local matrix = vm:GetBoneMatrix( index )
	if not matrix then return end

	local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

	local lpos, lang = LocalToWorld( cannon_vm_pos, cannon_vm_ang, pos, ang )
	mdl:SetPos( lpos )
	mdl:SetAngles( lang )

	mdl:SetupBones()
	mdl:DrawModel()
end

function SWEP:PreDrawViewModel( vm )
	self:DrawVMCannon( vm )
end

local cannon_wm_pos, cannon_wm_ang = Vector(), Angle( 0, 0, 180 )
function SWEP:DrawWorldModel( flags )
	if not self:GetOwner():IsValid() then
		local mdl = self:GetCSModel()

		mdl:SetPos( self:GetPos() )
		mdl:SetAngles( self:GetAngles() )

		mdl:SetupBones()
		mdl:DrawModel()

		return
	end

	self:SetupBones()

	local matrix = self:GetBoneMatrix( 0 )
	if not matrix then return end

	local mdl = self:GetCSModel()
	local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

	local lpos, lang = LocalToWorld( cannon_wm_pos, cannon_wm_ang, pos, ang )
	mdl:SetPos( lpos )
	mdl:SetAngles( lang )

	mdl:SetupBones()
	mdl:DrawModel()
end

--[[
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%-%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%@@@@@@@@@@@@@@@@@@%%-----=%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#--##%%@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%@@@@@@@@@@@@@@%-----%%%%%#-----@@@@@@@@@@@@@@@@@@@@@@@@@@%#----##%%@@@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%@@@@@@@@@@@@%---%@@@@@@@@@@@@%---%@@@@@@@@@@@@@@@@@@@@@@@%%*----=#%%%@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%@@@@@@@@@@@---@@@+---------=@@@%--=@@@@@@@@@@@@@@@@@@@@@@%%#------*#%%%@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%#@@@@@@@@@--%@@---%@@@@@@@%---%@@--=@@@@@@@@@@@@@@@@@@@@@@%%#-------*#%%%%@@@@@@@@@@@@@@@@%%%%%
%%%%%#@@@@@@@@--%@@--%@@@=----%@@%--%@%--%@@@@@@@@@@@@@@@@@@@%%%%#*---------*##%%%%%%%%@@@@@@@@%%%%%
%%%%%#@@@@@@@@--@@--#@@%--%@@%--@@%--@@%--@@@@@@@@@@@@@%%%%####**+------------------=***#######%%%%%
%%%%%#@@@@@@@@-%@@--%@%-#@@@@@@@@@%--@@%--@@@@@@@@@@@@%#---------------------------------------%%%%%
%%%%%#@@@@@@@@-%@@--@@%-%@@@@@@@@@%--@@%--@@@@@@@@@@@@#%%##########***+---------+*#############%%%%%
%%%%%#@@@@@@@@--@@--%@@--@@@@@@@@%--%@@%-%@@@@@@@@@@@@@@@@%%%%%%%%%%%##+-------*#%%@@@@@@@@@@@@%%%%%
%%%%%#@@@@@@@@%-#@%--%@@=--%%%%#---%@@%--@@@@@@@@@@@@@@@@@@@@@%%#--#%%#*------*#%@@@@@@@@@@@@@@%%%%%
%%%%%#@@@@@@@@@+-%@%---@@@%#----%@@@@%--@@@@@@@@@@@@@@@@@@@@@@%#--+*##*+-----*%%@@@@@@@@@@@@@@@%%%%%
%%%%%%@@@@@@@@@@+--@@%---%@@@@@@@@@%--%@@@@@@@@@@@@@@@@@@@@@@@%%=-----------#%%@@@@@@@@@@@@@@@@%%%%%
%%%%%%@@@@@@@@@@@@---%@%+----------%@@@@@@@@@@@@@@@@@@@@@@@@@@@%%#-------+#%%@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@#--=%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%###%%%%@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@%#------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@@@@%%%%####**#####%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@%%##=---------------=##%%%@@@@@@@@@@@@@@@@@@@@@@@%%%=%%@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@%%#----=####%%%%%####----*#%%%@@@@@@@@@@@@@@@@@@%%%##--%%@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@%#---+##%%%%@@@@@@%%%%%##----##%%%@@@@@@@@@@@@%%%%##---*%%@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@%%-*#%%@@@@@@@@@@@@@@@@%%##----###%%%%%%%%%%%%###=---+#%%@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@%%%@@@@@@@@@@@@@@@@@@@@@%%%#+-----*########*------#%%%@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%##*------------+##%%%%@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
]]--