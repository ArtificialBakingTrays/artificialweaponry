AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--bouncing gibs of fun

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS )
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

	self:Fire( "Kill", "", 8.5 )
end

function ENT:BounceDir() --Thank you lokachop :pray: <3
	local plys = player.GetAll()
	local rad = 250

	local selfPos = self:GetPos()

	--debugoverlay.Sphere(selfPos, rad, 4, Color(255, 0, 0, 96), false)

	-- check in sphere

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

	-- we found a player, do shit!

	--print("Closest Player; \"" .. closestPlayer:Name() .. "\"")
	--print("Their distance;  " .. tostring(closestDist))

	local plyPos = closestPlayer:GetPos()
	-- raise so it doesn't go for their feet
	plyPos[3] = plyPos[3] + 64


	local targetDir = plyPos - selfPos
	targetDir:Normalize()


	local physObj = self:GetPhysicsObject()
	if not IsValid(physObj) then
		return
	end

	local ourVel = physObj:GetVelocity()
	local ourVelL = ourVel:Length()

	local ourVelDir = ourVel * 1
	ourVelDir:Normalize()

	-- how much we are adjusting our vel to home in, per bounce
	local homePercentage = 0.7

	-- calc how much vel we're gonna add
	local velAdd = targetDir * ourVelL * homePercentage


	-- first, take away that 0.3 of velocity that we are adding in the new dir
	physObj:AddVelocity((-ourVel) * homePercentage)

	-- now add the homing velocity
	physObj:AddVelocity(velAdd)

end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end

	--if not self.CanDelete then self.CanDelete = true end

	if (self.NextHit or 0) > CurTime() then return end
	if enthit.IsTraysProjectile then return end

	-- increace bounce counter
	self.BounceTotal = (self.BounceTotal or 0) + 1
	if self.BounceTotal >= 7 then
		self:Remove()
		return
	end

	-- bounce if we can!
	self:BounceDir()


	local DMG = 8

	self.NextHit = CurTime() + 0.05

	data.HitEntity:TakeDamage(DMG, self:GetOwner())

	self:EmitSound( "npc/antlion_grub/agrub_squish1.wav", 100, math.random(95, 115), 1, 6 )

	local effectdata = EffectData() --I love copy pasting
	effectdata:SetOrigin( self:GetPos() )
	util.Effect("BloodImpact", effectdata, true, true)

end
