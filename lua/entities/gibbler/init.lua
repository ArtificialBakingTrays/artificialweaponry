AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--bouncing gibs of fun

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 5
	local ESize = 0
	local Duration = 0.15
	local TrailCl = Color(65, 9, 19)

	util.SpriteTrail(self, 0, TrailCl, false, SSize, ESize, Duration, 1, "trails/smoke")

	local phys = self:GetPhysicsObject()
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	phys:SetMaterial("gmod_bouncy")
	phys:SetBuoyancyRatio(0)
	phys:SetMass(25)
	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 12.5 )
end

function ENT:BounceDir() --Thank you lokachop :pray: <3
	local plys = player.GetAll()
	local rad = 250

	local selfPos = self:GetPos()

	local closestDist = math.huge
	local closestPlayer = nil
	for i = 1, #plys do
		local ply = plys[i]
		if ply == self:GetOwner() then continue end
		if ply:Health() <= 0 then continue end

		local plyPos = ply:GetPos()

		local dist = plyPos:Distance( selfPos )
		if dist > rad then continue end
		-- they in sphere, check if closer
		if closestDist < dist then continue end

		closestDist = dist
		closestPlayer = ply
	end

	-- no player found to home, return...
	if not closestPlayer then return end

	local plyPos = closestPlayer:GetPos()
	-- raise so it doesn't go for their feet
	plyPos.z = plyPos.z + 64

	local targetDir = plyPos - selfPos
	targetDir:Normalize()

	local physObj = self:GetPhysicsObject()
	if not IsValid(physObj) then return end
	local ourVel = physObj:GetVelocity()
	local ourVelL = ourVel:Length()
	local ourVelDir = ourVel * 1
	ourVelDir:Normalize()

	local homePercentage = 0.7
	local velAdd = targetDir * ourVelL * homePercentage

	physObj:AddVelocity((-ourVel) * homePercentage)
	physObj:AddVelocity(velAdd)
end

function ENT:TakeDamageOnHit(data)
	local enthit = data.HitEntity
	if not IsValid(enthit) then return end
	if enthit.IsTraysProjectile then return end
	if (self.NextTakeDamage or 0) > CurTime() then return end

	self.NextTakeDamage = CurTime() + 0.05

	local DMG = 8
	enthit:TakeDamage(DMG, self:GetOwner())
end



local sndLUT = {
	[1] = {
		snd = "npc/antlion_grub/agrub_squish1.wav",
		pitchMin = 95,
		pitchMax = 115
	},
	[2] = {
		snd = "npc/zombie/claw_strike3.wav",
		pitchMin = 75,
		pitchMax = 85
	},
	[3] = {
		snd = "npc/fast_zombie/claw_strike1.wav",
		pitchMin = 130,
		pitchMax = 145
	},
}

function ENT:PhysicsCollide(data)
	if ( not self:IsValid() ) then return end
	self:TakeDamageOnHit(data)
	if (self.NextHit or 0) > CurTime() then return end

	-- increace bounce counter
	self.BounceTotal = (self.BounceTotal or 0) + 1
	if self.BounceTotal >= 7 then
		self:Remove()
		return
	end

	-- bounce if we can!
	self:BounceDir()
	self.NextHit = CurTime() + 0.05

	local random = math.random( 1, 3 )

	-- get the sound file with the index given by random
	local sndEntry = sndLUT[random]
	local sndFile = sndEntry.snd

	self:EmitSound( sndFile, 100, math.random( sndEntry.pitchMin, sndEntry.pitchMax ), 0.3, 6 )


	local effectdata = EffectData() --I love copy pasting
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("BloodImpact", effectdata, true, true)
end
