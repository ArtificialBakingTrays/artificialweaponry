SWEP.PrintName = "Atomiprimed Glassbreaker"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Incase you need to Pack-A-Punch."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/primed_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.ViewModel	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.DrawAmmo = true
SWEP.AccurateCrosshair = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.BobScale = 1.15

SWEP.Primary.ClipSize = 35
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 160

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.UseHands = false
function SWEP:DrawWorldModel( flags )
	render.SetColorModulation( 30, 0, 1)
		render.SuppressEngineLighting( true )
			self:DrawModel( flags )
		render.SuppressEngineLighting( false )
	render.SetColorModulation( 1, 1, 1 )
end

function SWEP:PreDrawViewModel( vm )
	render.SetColorModulation( 30, 0, 1 ) -- the glow
	render.SuppressEngineLighting( true ) -- disable lighting
end

function SWEP:PostDrawViewModel( _, _, ply )
	render.SuppressEngineLighting( false ) -- re enable lighting
	render.SetColorModulation( 1, 1, 1 ) -- reset the glow

	if IsValid( ply ) then ply:GetHands():DrawModel() end
end

--Custom Projectile Spawning Func
--Now updated to work for MANY projectiles at once.
function SWEP:SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool, Gravity )
	if CLIENT then return end
	local ent = ents.Create( Entstring )
	if ( not ent:IsValid() ) then return end

	ent:SetOwner( Owner )
	ent:SetPos( Position )
	ent:SetAngles( Angles )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

    entphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	entphys:EnableGravity( Gravity )
	if ( not entphys:IsValid() ) then ent:Remove() return end

	if VelBool == 1 then
		if AimVec == nil then return end

		if AimVec != nil then
			local Speed = 2000
			AimVec:Mul( Speed * entphys:GetMass() )
			entphys:ApplyForceCenter( AimVec )
		end
	end 
end

--================================Reload Section================================--
function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if IsReloading == true then return end
	if self:Clip1() == self.Primary.ClipSize then return end
    self:EmitSound( "artiwepsv2/cooling.mp3", 100, math.random(105, 115), 0.7, 1 )
	local IsReloading = true

	timer.Simple( CurTime() + 1.2, function() IsReloading = false end)

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think()
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 35 )
	self:SetDTFloat( 0, 0 )
end

--================================Primary Fire Section================================--
function SWEP:PrimaryAttack()
    if self:Clip1() == 0 then return end
	if IsReloading == true then return end
    self:TakePrimaryAmmo( 1 )
    self:SetNextPrimaryFire( CurTime() + 0.055)
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

    --SpawnProjectile( Entstring, Owner, Position, Angles, AimVec, VelBool, Gravity )
	self:SpawnProjectile( "primepellet_proj", self:GetOwner(), self:GetOwner():GetShootPos(), self:GetOwner():EyeAngles() + Angle( 90, 0, 0 ), self:GetOwner():GetAimVector(), 1, false )

    self:EmitSound( "artiwepsv2/primebop.mp3", 100, 110, 0.7, 1 )
	self:EmitSound( "artiwepsv2/primebop2.mp3", 100, 110, 0.7, 6 )
end


hook.Add( "PlayerDeath", "art_prime", function( victim, inflictor )
	if inflictor:IsValid() and inflictor:GetClass() == "art_prime" then
		inflictor:SetClip2( inflictor:Clip2() + 1 )

		if inflictor:Clip2() >= 2 then
			victim:EmitSound( "artiwepsv2/AstralSlash3.mp3", 100, 100, 1, 6 )
			inflictor:SetClip2(0)
		inflictor:SpawnProjectile( "primeseeker_proj", inflictor:GetOwner(), victim:GetPos() + Vector(0, 0, 30), Angle(0, math.random(0, 360), 0), nil, 1, false)
		end
	end
end)


hook.Add( "OnNPCKilled", "art_prime", function( npc, attacker, inflictor )
	if inflictor:IsValid() and inflictor:GetClass() == "art_prime" then
		inflictor:SetClip2( inflictor:Clip2() + 1 )

		if inflictor:Clip2() >= 2 then
			npc:EmitSound( "artiwepsv2/AstralSlash3.mp3", 100, 100, 1, 6 )
			inflictor:SetClip2(0)
		inflictor:SpawnProjectile( "primeseeker", inflictor:GetOwner(), npc:GetPos() + Vector(0, 0, 30), Angle(0, math.random(0, 360), 0), nil, 1, false)
		end
	end
end )






--================================ALT FIRE Section================================--
function SWEP:SecondaryAttack()
	if ActiveTether == 1 then return end
	ActiveTether = 1
	local timedelay = 0.5

	self:DeployTether( timedelay )
	timer.Simple( timedelay + 0.3, function() ActiveTether = 0 end)

	local SFXRAN = math.floor(math.random(1, 3))
	if SFXRAN == 1 then self:EmitSound( "artiwepsv2/AstralSlash1.mp3", 100, 100, 1, 6 ) end
	if SFXRAN == 2 then self:EmitSound( "artiwepsv2/AstralSlash2.mp3", 100, 100, 1, 6 ) end
	if SFXRAN == 3 then self:EmitSound( "artiwepsv2/AstralSlash3.mp3", 100, 100, 1, 6 ) end

	self:EmitSound( "sparkbound/cast.mp3", 100, 110 + math.floor(math.random(0, 15)), 1, 1 )
end

function SWEP:DeployTether( Time )
	if CLIENT then return end
	local ent = ents.Create( "prop_physics" )
	if ( not ent:IsValid() ) then return end

	ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	ent:SetModelScale( 0.05 )
	ent:SetMaterial("model_color")
	ent:SetColor(Color(255, 0, 0))

	local TSIZE = 10 * 2
	util.SpriteTrail(ent, 0, Color(255, 17, 68), false, TSIZE, 0, 0.25, 1, "trails/laser")
--util.SpriteTrail( Entity, attachmentID, color, boolean, startWidth, endWidth, lifetime, textureRes, string texture )

	local ownerpos = self:GetOwner():GetShootPos()
	local ownereyes = self:GetOwner():EyeAngles()
	local aimvec = self:GetOwner():GetAimVector()

	ent:SetOwner( self:GetOwner() )
	ent:SetPos( ownerpos )
	ent:SetAngles( ownereyes )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if( not entphys:IsValid() ) then ent:Remove() return end

    entphys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	entphys:EnableGravity( true )
	
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	entphys:SetBuoyancyRatio(0)
	entphys:SetMass(250)
	entphys:SetMaterial("gmod_bouncy")

	local Speed = 1000
	aimvec:Mul( Speed * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

	timer.Simple( Time, function()
		entphys:EnableMotion( false )
		ent:EmitSound( "artiwepsv2/exoshoot.mp3", 100, 110 + math.floor(math.random(0, 15)), 1, 1 )
		ent:EmitSound( "artiwepsv2/plasmaexplosion.mp3", 100, 105, 1, 1 )

		self:GetOwner():SetPos( ent:GetPos() )
		self:CheckNearby()
		ent:Remove()
	end)
end

function SWEP:CheckNearby()
	local rad = 160
	local selfPos = self:GetPos()

	for k, v in ents.Iterator() do
		if not v then continue end
		if not IsValid(v) then continue end
		if v == self:GetOwner() then continue end

		local classGet = v:GetClass()

		local doPass = false
		if classGet == "player" then doPass = true end
		if string.sub(classGet, 1, 4) == "npc_" then doPass = true end
		if not doPass then continue end
		if v:Health() <= 0 then continue end

		local entPos = v:GetPos()
		local dist = entPos:Distance( selfPos )
		if dist > rad then continue end

		v:TakeDamage( 35, self:GetOwner(), self )
	end
end





--================================Fancy Rendering Section================================--
local reticle = Material( "vgui/hud/preticle.png", "noclamp smooth" )
function SWEP:DrawHUD()
	if CLIENT then
		local h = ScrH()
		local w = ScrW()

		surface.SetMaterial(reticle)
		surface.SetDrawColor(Color(255,0,76, 255))
		surface.DrawTexturedRectRotated( w / 2, (h / 2) - 20, (w / 2) / 6, (w / 2) / 6, 0 )

		draw.SimpleText("Ammo: " .. self:Clip1(), "HudDefault", w * .53, h * .45, Color(255, 255, 255) )
		draw.SimpleText("Ammo2: " .. self:Clip2(), "HudDefault", w * .53, h * .43, Color(255, 255, 255) )

		if ActiveTether == 1 then
			draw.SimpleText("Tether: No", "HudDefault", w * .53, h * .47, Color(255, 255, 255) )
		else
			draw.SimpleText("Tether: Yes", "HudDefault", w * .53, h * .47, Color(255, 255, 255) )
		end
	end
end

local bannedLUT = {
	--["CHudHealth"]    = true,
	["CHudAmmo"]      = true,
	["CHudCrosshair"] = true,
	--["CHudBattery"]	  = true,
}

function SWEP:HUDShouldDraw(element)
	if bannedLUT[element] then return false end
	return true
end

function SWEP:Deploy()
	ActiveTether = 0
	if not self.isEquipped then return end
end

function SWEP:Holster()
	if CLIENT then return end
	self.isEquipped = false
	return true
end