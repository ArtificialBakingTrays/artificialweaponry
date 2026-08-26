AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local BaseColor = Color( 255, 113, 172)

function ENT:Initialize()
	self:SetModel("models/hunter/misc/sphere025x025.mdl")
	self:SetModelScale( 0.25 )
	self:SetMaterial("model_color")
	self:SetColor( Color(255, 255, 255) )

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysicsInitSphere( 0.4, SOLID_VPHYSICS )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.IsTraysProjectile = true

	local SSize = 24
	local ESize = 0
	local Duration = 0.15

	util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

	local phys = self:GetPhysicsObject()
	phys:SetBuoyancyRatio(0)
	phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	phys:SetMass(25)

	if phys:IsValid() then phys:Wake() end

	self:Fire( "Kill", "", 12.5 )
end

function ENT:PhysicsCollide(data)
	local enthit = data.HitEntity
	if ( not self:IsValid() ) then return end
	if enthit == self:GetOwner() then return end
	if enthit.IsTraysProjectile then return end
	self:EmitSound( "legendary/spark.mp3", 75, math.random(95, 100), 1, 6 )
	if not IsValid(enthit) then return end

	if data.HitSpeed:Length() > 60 then
		if not IsValid(self) then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 0.1 )
		util.Effect("cball_explode", effectdata, true, true)

		local dmg 
		if enthit:IsPlayer() then dmg = 42 else dmg = 90 end

		enthit:TakeDamage( dmg, self:GetOwner(), self:GetOwner():GetActiveWeapon() )

		self:EmitSound( "artiwepsv2/exoshoot.mp3", 75, math.random(95, 100), 1, 6 )
		self:Remove()
	end
end

function ENT:NearbyCheck()
    local Rad = 300 * 300
    local selfPos = self:GetPos()

    local closestDist = math.huge
    local closestEnt

    for _, v in ents.Iterator() do
        if not IsValid(v) then continue end
        if v == self:GetOwner() then continue end
        if not (v:IsPlayer() or v:IsNPC()) then continue end
        if v:Health() <= 0 then continue end
        if v:IsPlayer() and not v:Alive() then continue end

        local dist = selfPos:DistToSqr(v:GetPos())

        if dist < Rad and dist < closestDist then
            closestDist = dist
            closestEnt = v
        end
    end
    return closestEnt
end

function ENT:Think()
    local target = self:NearbyCheck()
    local phys = self:GetPhysicsObject()

    if IsValid(target) and IsValid(phys) then
        local pos = self:GetPos()
        local targetPos = target:GetPos() + Vector(0,0,30)
        local Dir = (targetPos - pos):GetNormalized()
        local currentVel = phys:GetVelocity()
        local currentDir = currentVel:GetNormalized()
        local turnRate = 0.08
        local newDir = LerpVector(turnRate, currentDir, Dir):GetNormalized()
        phys:SetVelocity(newDir * 500)
    end

    self:NextThink(CurTime())
    return true
end