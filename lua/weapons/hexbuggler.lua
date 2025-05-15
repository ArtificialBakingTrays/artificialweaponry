SWEP.PrintName = "Hexbuggler"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Deploy little nano rounds that float in the air with LMB, RMB to track onto a target."
SWEP.Category = "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/hexbug_generi.png"

SWEP.ViewModel	= "models/weapons/c_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawCrosshair = true
SWEP.DrawHUD = false
SWEP.DrawAmmo = true
SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.Slot = 3

--Probably has the weirdest ammo economy ever-
SWEP.Primary.ClipSize = 27
SWEP.Primary.DefaultClip = 27
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"
SWEP.Primary.Force = 75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "Battery"

function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	-- guesstimating
	local round = self.Primary.ClipSize - self:Clip1()
	local pitch = 100 + round
	local delay = 0.125 - round * 0.0025

	self:SetNextPrimaryFire( CurTime() + delay )

	self:EmitSound( "tray_sounds/hexbugfire.mp3", 100, pitch, 1, 1 )
	self:EmitSound( "physics/cardboard/cardboard_box_impact_bullet4.wav", 100, pitch + 10, 1, 6 )

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	self:DeployBugs()

	owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.7 )

	self:EmitSound("tray_sounds/nroom.mp3", 100, 100, 1, 1 )
	if CLIENT then return end

	local ownerply = self:GetOwner()

	local ownertr = ownerply:GetEyeTrace()
	local targetpos = ownertr.HitPos

	for _, v in ents.Iterator() do
		local ent = v
		if ent:GetClass() ~= "hexbug" then continue end
		if ent:GetOwner() ~= ownerply then continue end
		if ent.HadApplied then continue end

		local entphys = ent:GetPhysicsObject()

		if not IsValid(entphys) then continue end

		local entpos = ent:GetPos()

		local vecapply = targetpos - entpos

		vecapply:Normalize()

		vecapply:Mul( entphys:GetMass() * 1000 * 5)

		entphys:ApplyForceCenter(vecapply)

		ent.NoDrag = true
		ent.HadApplied = true

		ent:BugTrailSize( 4, 0.3 )

	end
end

function SWEP:Reload()
	if self:GetDTFloat(0) ~= 0 then return end
	if CurTime() < self:GetNextPrimaryFire() then return end
	if self:Clip1() == self.Primary.ClipSize then return end

	self:SetDTFloat( 0, CurTime() + 1.2 )
	self:SendWeaponAnim(ACT_VM_RELOAD)
end

function SWEP:Think() --This like fuckass prediction for timers is so like cooked- how the fuck did zynx figure this out?
	local time = self:GetDTFloat( 0 )
	if time == 0 then return end

	if time > CurTime() then return end

	self:SetClip1( 27 )
	self:SetDTFloat( 0, 0 )
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = true

	if self.Primary.ClipSize > 0 then
		self.AmmoDisplay.PrimaryClip = self:Clip1()
	end

	return self.AmmoDisplay
end

function SWEP:DeployBugs()
	if CLIENT then return end

	local ent = ents.Create( "Hexbug" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:SetOwner( owner )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 1500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end

--Hexbug my beloved
--                                                     *****,.                    
--                                                ,,,,,*********/*******/         
--                                           ,*,,,*/*********///**//**,****       
--                                     .,,,,,,,,,*,,***********/*,*/***********///
--                                ,,,,,,/,,,/,,,/(/#(***********/////****//(((((//
--                           ,,,,.,,*,,,,*/*,,,,(*,,********////****/(((((((((((( 
--                      ,,.,,,/,(,,,/,,,*,********,,**/****/***/((((((((((((      
--                 ,,,,,,,,,,,,,,,/,,,,*,,,,*************//((((((((((((#(&&@      
--              ,,***,,,,,,,,(**,,,,,,/*************//((((((((((((/@@&%(/&&%      
--       *****,*,,,*****,,*,*******************/(((((((((((((@@&%(/@@&%(/&&       
--  *********,,,,,,,,,,,,****************//((((((((((((&@%%(/@@&%(/@&&%#/(        
-- ,,,,,*,(*,,**,,,,,,.,********#(/***/((((((#((((&%#((@@&%(/@@&%#(/#(%#((        
-- ,,,,,,,,********,********///(/%##//((((((&%((@@&%#(/@@&%((&&&%#(/&  %(/.       
-- *,,.,............,,*//(((((((/##(*/(//@@@%#(/@@%%#(/@&&%#(/&&&#(/    #(/       
--    ,,.........,.,,,/((((((((/@&@@@***/#&&%#(/#& %#(/@&%(#((   ,#((    #/(      
--       ,,..,,,,....,/((/@@@&&&&&&&&@,**/&%@#(/(   #((/   #(/(   ((/(            
--         .#&,##%#%%%&&&&%%@#%%#%%%&&*,*/   ##((   ,#((    #(/(                  
--             #/&&&(/#@&&&@@@%%,      ,,*(   #(/(   ##((                         
--                    %&%&              ,,*    #(/.                               
--                                       ,*/    (((                               
--                                        **                                      