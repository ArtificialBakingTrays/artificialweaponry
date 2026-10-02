SWEP.PrintName = "Lethal Dose of Radiation"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Slingshot, but Pebbles of Uranium. Will bounce off of enemies, when it hits the floor: it will release mini pebbles that also do damage"
SWEP.Category = GetWeaponPack()
SWEP.IconOverride = "vgui/weaponvgui/radsling_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.WorldModel	= "models/weapons/w_pistol.mdl"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 1
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:SetScoped( bool ) self:SetDTBool( 0, bool ) end
function SWEP:GetScoped() return self:GetDTBool( 0 ) end

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
	self:SetNextPrimaryFire( CurTime() + 1.2 )

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)

	self:EmitSound( "tray_sounds/sling_reload.mp3", 75, 110, .7, 1 )
end

function SWEP:Think() --Help from zynx
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 12 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end -- No Shoot
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + 0.295 )

	self:EmitSound( "tray_sounds/slingfire.mp3", 100, math.random( 100, 105 ), 1, 1 )
	self:EmitSound( "artiwepsv2/primebop2.mp3", 100, math.random( 110, 120 ), 0.2, 6 )

	local owner = self:GetOwner()

	owner:LagCompensation( true )

	ArtiwepsProjectile("radrock_proj", owner, owner:GetShootPos(), owner:EyeAngles(), owner:GetAimVector(), 3500, true)

	owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
	self:SetScoped( not self:GetScoped() )
	self:EmitSound("weapons/sniper/sniper_zoomin.wav", 75, math.random(95, 105), 100, 6 )
end

local slingreticle = Material( "vgui/hud/sling_reticle.png", "noclamp smooth" )
local color = Color(226, 255, 121, 255)

function SWEP:DrawHUD()
	if self:GetScoped() then
	render.SetColorMaterialIgnoreZ()
	surface.SetMaterial( slingreticle )
	surface.SetDrawColor( color )
	local w = ScrW() / 2
	local h = ScrH() / 2

	local scale = 256
	local length = scale / 1.5

	surface.DrawTexturedRect(w - length / 2 + 5, h - scale / 2 + 30, length, scale)
	end
end


function SWEP:DoDrawCrosshair()
	return self:GetScoped()
end


hook.Add("OnNPCKilled", "art_radiationsling", function(npc, attacker, inflictor)
	if not IsValid(inflictor) then return end
	if inflictor:GetClass() ~= "art_radiationsling" then return end

	if math.random(0, 5) >= 3 then
		local tr = util.TraceLine({
			start = npc:GetPos() + Vector(0, 0, 10),
			endpos = npc:GetPos() - Vector(0, 0, 10000),
			filter = npc,
		})

		if tr.Hit then
			local spawnPos = tr.HitPos + tr.HitNormal * 2
			local owner = inflictor:GetOwner()
			if IsValid(owner) then
				ArtiwepsProjectile( "sh_pool", owner, spawnPos, tr.HitNormal:Angle() + Angle(90, 0, 0), 0, 0, false )
			end
		end
	end
end)

hook.Add("PlayerDeath", "art_radiationsling", function(victim, inflictor)
	if not IsValid(inflictor) then return end
	if inflictor:GetClass() ~= "art_radiationsling" then return end

	if math.random(0, 1) == 1 then
		local tr = util.TraceLine({
			start = victim:GetPos() + Vector(0, 0, 10),
			endpos = victim:GetPos() - Vector(0, 0, 10000),
			filter = victim,
		})

		if tr.Hit then
			local spawnPos = tr.HitPos + tr.HitNormal * 2
			local owner = inflictor:GetOwner()
			if IsValid(owner) then
				ArtiwepsProjectile( "sh_pool", owner, spawnPos, tr.HitNormal:Angle() + Angle(90, 0, 0), 0, 0, false )
			end
		end
	end
end)

function SWEP:SpawnProjectile( Entstring, Owner, Position, Angles )
	if CLIENT then return end
	local ent = ents.Create( Entstring )
	if ( not ent:IsValid() ) then return end

	ent:SetOwner( Owner )
	ent:SetPos( Position )
	ent:SetAngles( Angles )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	entphys:EnableMotion(false)
end
