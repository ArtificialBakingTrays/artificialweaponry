SWEP.PrintName = "Directed Animosity"
SWEP.Author	= "ArtificialBakingTrays" -- Shows up while hovering
SWEP.Instructions = "Slow fire rate, Increases Rate of Fire as you hold the trigger. Returns rounds on kills."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/directed_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel	= "models/weapons/c_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_irifle.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.Slot = 4

SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = nil

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end
	self.IsReloading = true

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self.IsReloading = false
	self:SetClip1( self:GetMaxClip1() )
	self:SetDTFloat( 0, 0 )
	self:SetClip2( 0 )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:SecondaryAttack() return end

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end
	if self.IsReloading then return end

	local round = math.Clamp(self:Clip2() + 1.35, 0, 300)
	self:SetClip2( round )

	local pitch = 60 + round
	local delay = math.max( 0.085 - round * .0004, .001 )
	local spred = math.max( 0.025 + round * 0.0001, 0.01 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	self:SetNextPrimaryFire( CurTime() + delay )
	self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, pitch - math.random() * 10, 0.3, 1 )

	local owner = self:GetOwner()

	--print(round)

	owner:LagCompensation( true )

	owner:FireBullets {
		Src = owner:GetShootPos(),
		Dir = owner:GetAimVector(),
		Spread = Vector( spred, spred ),
		Damage = ( self:Clip1() <= 20 ) and 12 + ((round/10)/2) or 8 + ((round/10)/2),
		Attacker = owner,

		Callback = function( att, tr, dmg )
			dmg:SetInflictor( self )
		end
	}

	owner:LagCompensation( false )
end

hook.Add( "OnNPCKilled", "art_hatred", function( npc, attacker, inflictor )
	if inflictor:IsValid() and inflictor:GetClass() == "art_hatred" then
		inflictor:SpawnProjectile( "sh_scrappickup", attacker, npc:GetPos() + Vector(0,0,50), Angle(0,0,0), _, 0 )
	end
end )

hook.Add( "PlayerDeath", "art_hatred", function( victim, inflictor )
	if inflictor:IsValid() and inflictor:GetClass() == "art_hatred" then
		local inflown = inflictor:GetOwner()
		inflictor:SpawnProjectile( "sh_scrappickup", inflown, victim:GetPos() + Vector(0,0,50), Angle(0,0,0), _, 0 )
	end
end )

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
end

local function drawCircleLine(x, y, sx, sy, itr)
	for i = 0, (itr - 1) do
		local delta = (i / itr) * (math.pi * 2)

		local deltaPrev = ((i - 1) / itr) * (math.pi * 2)


		local x1 = x + math.cos(delta) * sx
		local y1 = y + math.sin(delta) * sy

		local x2 = x + math.cos(deltaPrev) * sx
		local y2 = y + math.sin(deltaPrev) * sy

		surface.DrawLine(x1, y1, x2, y2)
	end
end

local c_White = Color(255, 255, 255)
function SWEP:DrawHUD()
	--render stuff here with surface or any drawing method, its a 2d context
	local delta = self:Clip1() / self:GetMaxClip1()

	-- set red colour
	surface.SetDrawColor(255, delta * 255, delta * 255, 128)
	render.SetColorMaterialIgnoreZ()

	local round = self:Clip2()
	local spred = math.max( 0.025 + round * 0.0001, 0.01 ) * 20

	-- draws the line circle
	drawCircleLine(ScrW() * .5, ScrH() * .5, 28 * spred, 28 * spred,  24)

	draw.SimpleText("iDELTA; " .. tostring(invDelta), "BudgetLabel", 0, 0, c_White)
end

