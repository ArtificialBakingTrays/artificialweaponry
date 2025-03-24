--util.PrecacheSound("")


--DO NOT REMOVE THESE CREDITS
--[=====================]

--Coded by ArtificialBakingTrays

--Helpers:
	--Lokachop <3

--[=====================]

SWEP.PrintName = "Hexbuggler"
SWEP.Author	= "ArtificialBakingTrays"
SWEP.Instructions = "Deploy little nano rounds that float in the air with LMB, RMB to track onto a target."
SWEP.Category = "Artificial Weaponry"

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
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Force = 75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Initialize()
	self.Pitch = 100
	self.ROF = 0.125
end


function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )

	if IsFirstTimePredicted() then
		self.Pitch = self.Pitch + 1
		self.ROF = self.ROF - 0.0025
	end

	local owner = self:GetOwner()

	self:SetNextPrimaryFire( CurTime() + self.ROF )

	self:EmitSound( "tray_sounds/hexbugfire.mp3", 100, self.Pitch, 1, 1 )
	self:EmitSound( "physics/cardboard/cardboard_box_impact_bullet4.wav", 100, self.Pitch + 10, 1, 6 )

	owner:LagCompensation(true)

	self:DeployBugs()

	owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.7 )

	self:EmitSound("tray_sounds/nroom.mp3", 100, 100, 1, 1 )
	if CLIENT then return end

	local ownerply = self:GetOwner()

	local ownertr = ownerply:GetEyeTrace()
	local targetpos = ownertr.HitPos

	for k, v in ipairs(ents.GetAll()) do
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
	if ( not self:HasAmmo() ) or ( CurTime() < self:GetNextPrimaryFire() ) then return end

	if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
		self:DefaultReload( ACT_VM_RELOAD )
		self:EmitSound("", 100, 100 )
	end

	self.Pitch = 100
	self.ROF = 0.125
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