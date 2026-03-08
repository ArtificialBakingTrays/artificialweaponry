SWEP.PrintName = "BookWyrm's Tome of the Risen"
SWEP.Author			= "ArtiBakingTrays" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Contact 		= "ArtificialBakingTrays"
SWEP.Instructions	= "A book that raises Sunless fools, and cursed on primary attacks."
SWEP.Category 		= "Artificial Weaponry"
SWEP.IconOverride = "vgui/weaponvgui/tome_generi.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel	= "models/weapons/w_medkit.mdl"
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.Slot = 3

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic	= true
SWEP.Primary.Ammo = "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:PrimaryAttack() --Cursing Rounds
	local time = 0.05
	local Vol = 0.6

	self:SetNextPrimaryFire( CurTime() + 0.425 )
	self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 135, 165 ), Vol, 1 )
	self:EmitSound( "artiwepsv2/tombfire_2.mp3", 100, math.random( 95, 105 ), Vol, 6 )

	local owner = self:GetOwner()
	owner:LagCompensation( true )

	self:DeployCurse()

	timer.Simple( time, function()
		self:DeployCurse()
		self:EmitSound( "tray_sounds/slingfire2.mp3", 100, math.random( 135, 165 ), Vol, 1 )
		self:EmitSound( "artiwepsv2/tombfire_2.mp3", 100, math.random( 95, 105 ), Vol, 6 )
	end)

	owner:LagCompensation( false )

end

function SWEP:DeployCurse()
	if CLIENT then return end

	local ent = ents.Create( "tome_proj" )

	if ( not ent:IsValid() ) then return end

	--yknow its bad when we have the CUBE OF VARIABLES
	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local ownereyes = owner:EyeAngles()
	local aimvec = owner:GetAimVector()

	ent:SetPos( ownerpos + Vector(0, 0, -5) )
	ent:SetAngles( ownereyes + Angle(90,0,0) )
	ent:SetOwner( owner )
	ent:SetGravity( 0 )
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end

	aimvec:Mul( 1500 * entphys:GetMass() )
	entphys:ApplyForceCenter( aimvec )

end

function SWEP:SecondaryAttack()	--Will summon Sunless Fool
	if self.HasSpawnedNpc == true then return end
	self:SetNextSecondaryFire( CurTime() + 1)
	self:EmitSound( "artiwepsv2/magicsummoningnoise.mp3", 100, math.random( 95, 105 ), 1.5, 1 )

	self:GetOwner():LagCompensation( true )
	self:SpawnFool()
	self.HasSpawnedNpc = true
	self:GetOwner():LagCompensation( false )

	if CLIENT then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local plyPos = ply:GetPos()
	local downVec = Vector(0, 0, -51200)

	local trFloor = util.TraceLine({
		start = plyPos,
		endpos = self:GetOwner():GetPos() + self:GetOwner():GetAimVector() + downVec,
		filter = ply,
	})

	if not trFloor.Hit then return end

	-- tell clients to render a summon circle
	local floorPos = trFloor.HitPos
	local floorNorm = trFloor.HitNormal

	net.Start("trays_summoncircle_onspawn")
		net.WriteVector(floorPos + (floorNorm * .1))
		net.WriteNormal(floorNorm)
	net.Broadcast()
end

function SWEP:Think()
	self:CheckIfAlive()
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}

	self.AmmoDisplay.Draw = false

	return self.AmmoDisplay
end

function SWEP:SpawnFool()
	if CLIENT then return end

	local owner = self:GetOwner()
	local ownerpos = owner:GetShootPos()
	local owneraimdir = owner:GetAimVector()
	local PinkVoid = Color(255, 0, 75)
	local SSize = 50
	local ESize = 0
	local Duration = 0.5

	local ent = ents.Create( "npc_fastzombie" )
	ent:SetPos( ownerpos + owneraimdir * 64 )
	ent:SetOwner( owner )

	ent:AddEntityRelationship( ent:GetOwner(), D_LI, 100 )
	ent:Spawn()

	util.SpriteTrail( ent, 2, PinkVoid, false, SSize, ESize, Duration, 1, "trails/laser" )
	ent:SetHealth( 350 )
	ent:SetBodygroup( 1, 0 )
	ent:SetColor(Color(25, 25, 25))
	ent:SetMaterial("models/ihvtest/arm")

	self.NPCSpawned = ent
	self.IsTraysProjectile = true
	ent.IsCoolNPC = true

	ent:Fire( "Kill", "", 40.5 )
end

function SWEP:CheckIfAlive()
	if CLIENT then return end

	if not IsValid(self.NPCSpawned) then
		self.HasSpawnedNpc = false
		return false
	end
	return true
end

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( target, dmginfo )
	local npcattack = dmginfo:GetAttacker()
	if not npcattack.IsCoolNPC then return end

	local ScaleDmg = 15
	if target.IsCursed == true then
		ScaleDmg = 30
	elseif target.IsCursed == false then
		ScaleDmg = 15
	end

	dmginfo:ScaleDamage( ScaleDmg )
	dmginfo:SetAttacker( npcattack:GetOwner() )
end )

hook.Add("player_hurt", "player_hurt_example", function( victim )
	if CLIENT then return end
	if victim:IsNPC() then return end
	attacker = victim:GetAttacker()

	victim.IsCursed = true
	local time2 = 1.5
	timer.Simple(time2, function()
		victim.IsCursed = false

	end)
end)


--[[
Transmission: From BookWyrm

Our religion is a lie, the 'truth' is a lie.
We need to forsake our god of suffering if we must persist on with our existance.
Please Madware, for our sake; We need to abandon the god before we are made redundant.
We both know he has found greater apprentices than us, it is only a matter of time.

This message remains unread by its Recipient.
]]--

-- circle renderer
-- mesh first


AXIS_X_POS = 1
AXIS_X_NEG = 2

AXIS_Y_POS = 3
AXIS_Y_NEG = 4

AXIS_Z_POS = 5
AXIS_Z_NEG = 6


-- Creates a generic cube mesh that on each face has full 0-1 UVs
-- This is merely for me to first learn how to procedurally generate cube meshes
-- This function is from ZVox! (https://github.com/lokachop/zvox/blob/main/gamemodes/zvox_classicbuild/gamemode/zvox/cl/meshutils/cl_meshutils_cube.lua#L14)
-- This variant of the function is licensed under MIT, -Lokachop
local function getCubeMesh(pos, scl, doAxis)
	if SERVER then
		return
	end

	doAxis = doAxis or {
		[AXIS_X_POS] = true,
		[AXIS_X_NEG] = true,

		[AXIS_Y_POS] = true,
		[AXIS_Y_NEG] = true,

		[AXIS_Z_POS] = true,
		[AXIS_Z_NEG] = true,
	}

	-- first we make the vertices
	local sX, sY, sZ = scl[1], scl[2], scl[3]

	-----------------------
	-- ascii coord guide --
	-----------------------
	--    X  X      X  X --
	--    -  +      -  + --
	-- Y- X--0   Y- 0--0 --
	--    |  |      |  | --
	--    |  |      |  | --
	-- Y+ 0--0   Y+ 0--0 --
	--     z-        z+  --
	-----------------------


	local v1 = Vector(-sX, -sY, -sZ)
	local v2 = Vector( sX, -sY, -sZ)
	local v3 = Vector( sX,  sY, -sZ)
	local v4 = Vector(-sX,  sY, -sZ)

	local v5 = Vector(-sX, -sY,  sZ)
	local v6 = Vector( sX, -sY,  sZ)
	local v7 = Vector( sX,  sY,  sZ)
	local v8 = Vector(-sX,  sY,  sZ)

	local meshRet = Mesh()
	local primitiveCount = 6 -- cubes have 6 faces if we use quads

	local normFlipMul = 1

	local normXp = Vector( 1,  0,  0) * normFlipMul
	local normXm = Vector(-1,  0,  0) * normFlipMul
	local normYp = Vector( 0,  1,  0) * normFlipMul
	local normYm = Vector( 0, -1,  0) * normFlipMul
	local normZp = Vector( 0,  0,  1) * normFlipMul
	local normZm = Vector( 0,  0, -1) * normFlipMul

	mesh.Begin(meshRet, MATERIAL_QUADS, primitiveCount)
		if doAxis[AXIS_X_POS] then
		-- BEGIN X+
			mesh.Normal(normXp)
			mesh.Position(v6 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXp)
			mesh.Position(v7 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXp)
			mesh.Position(v3 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXp)
			mesh.Position(v2 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END X+
		end

		if doAxis[AXIS_X_NEG] then
		-- BEGIN X-
			mesh.Normal(normXm)
			mesh.Position(v8 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXm)
			mesh.Position(v5 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXm)
			mesh.Position(v1 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normXm)
			mesh.Position(v4 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END X-
		end

		if doAxis[AXIS_Y_POS] then
		-- BEGIN Y+
			mesh.Normal(normYp)
			mesh.Position(v7 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYp)
			mesh.Position(v8 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYp)
			mesh.Position(v4 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYp)
			mesh.Position(v3 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END Y+
		end

		if doAxis[AXIS_Y_NEG] then
		-- BEGIN Y-
			mesh.Normal(normYm)
			mesh.Position(v5 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYm)
			mesh.Position(v6 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYm)
			mesh.Position(v2 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normYm)
			mesh.Position(v1 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END Y-
		end

		if doAxis[AXIS_Z_POS] then
		-- BEGIN Z+
			mesh.Normal(normZp)
			mesh.Position(v5 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZp)
			mesh.Position(v8 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZp)
			mesh.Position(v7 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZp)
			mesh.Position(v6 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END Z+
		end

		if doAxis[AXIS_Z_NEG] then
		-- BEGIN Z-
			mesh.Normal(normZm)
			mesh.Position(v2 + pos)
			mesh.TexCoord(0, 0, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZm)
			mesh.Position(v3 + pos)
			mesh.TexCoord(0, 1, 0)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZm)
			mesh.Position(v4 + pos)
			mesh.TexCoord(0, 1, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()

			mesh.Normal(normZm)
			mesh.Position(v1 + pos)
			mesh.TexCoord(0, 0, 1)
			mesh.Color(255, 255, 255, 255)
			mesh.AdvanceVertex()
		-- END Z-
		end
	mesh.End()
	return meshRet
end




local planeScale = 128
local h_planeScale = planeScale * .5
local meshFloor = nil
if CLIENT then
	local normPlane = Vector(1, 0, 0)

	meshFloor = Mesh()
	mesh.Begin(meshFloor, MATERIAL_QUADS, 1)

		-- o-o
		-- | |
		-- #-o
		mesh.Position(Vector(0, -h_planeScale, h_planeScale))
		mesh.TexCoord(0, 0, 1)
		mesh.Color(255, 255, 255, 255)
		mesh.Normal(normPlane)
		mesh.AdvanceVertex()

		-- o-o
		-- | |
		-- o-#
		mesh.Position(Vector(0, h_planeScale, h_planeScale))
		mesh.TexCoord(0, 1, 1)
		mesh.Color(255, 255, 255, 255)
		mesh.Normal(normPlane)
		mesh.AdvanceVertex()

		-- o-#
		-- | |
		-- o-o
		mesh.Position(Vector(0, h_planeScale, -h_planeScale))
		mesh.TexCoord(0, 1, 0)
		mesh.Color(255, 255, 255, 255)
		mesh.Normal(normPlane)
		mesh.AdvanceVertex()

		-- #-o
		-- | |
		-- o-o
		mesh.Position(Vector(0, -h_planeScale, -h_planeScale))
		mesh.TexCoord(0, 0, 0)
		mesh.Color(255, 255, 255, 255)
		mesh.Normal(normPlane)
		mesh.AdvanceVertex()
	mesh.End()
end


local circleDieTime = 16
ArtiWeps_SummonCircles = ArtiWeps_SummonCircles or {}
function ArtiWeps_AddSummonCircle(pos, norm)
	print(":: Adding summon circle")


	ArtiWeps_SummonCircles[#ArtiWeps_SummonCircles + 1] = {
		["pos"] = pos,
		["norm"] = norm,
		["dieTime"] = CurTime() + circleDieTime
	}
end

hook.Add("Think", "trays_RemoveSummonCircles", function()
	local circleCount = #ArtiWeps_SummonCircles
	if circleCount <= 0 then
		return
	end

	local toRM = {}
	for i = circleCount, 1, -1 do
		local entry = ArtiWeps_SummonCircles[i]
		local dieTime = entry.dieTime

		if CurTime() > dieTime then
			toRM[#toRM + 1] = i
		end
	end

	for i = 1, #toRM do
		local entryIdx = toRM[i]

		table.remove(ArtiWeps_SummonCircles, entryIdx)
	end
end)

local mat = Material("materials/tome/summoningcircle.png", "mips smooth ignorez nocull")
local matrixCircleRender = Matrix()
local rotAngle = Angle(0, 0, 0)


local meshDecalVolume = getCubeMesh(Vector(-1, 0, 0), Vector(8, h_planeScale, h_planeScale), {
	[AXIS_X_POS] = true,
	[AXIS_X_NEG] = true,

	[AXIS_Y_POS] = true,
	[AXIS_Y_NEG] = true,

	[AXIS_Z_POS] = true,
	[AXIS_Z_NEG] = true,
})
hook.Add("PostDrawTranslucentRenderables", "trays_RenderSummonCircles", function()
	local circleCount = #ArtiWeps_SummonCircles
	if circleCount <= 0 then
		return
	end


	--render.SetColorMaterial()
	render.SetMaterial(mat)
	matrixCircleRender:Identity()
	for i = 1, circleCount do
		local entry = ArtiWeps_SummonCircles[i]
		local planeDieTime = entry.dieTime
		local planePos = entry.pos
		local planeNorm = entry.norm
		local planeAng = planeNorm:Angle()

		local dieDelta = (planeDieTime - CurTime()) / circleDieTime
		dieDelta = dieDelta * 2
		dieDelta = math.min(dieDelta, 1)

		mat:SetFloat("$alpha", dieDelta)



		matrixCircleRender:Identity()
		matrixCircleRender:SetTranslation(planePos)
		matrixCircleRender:SetAngles(planeAng)

		rotAngle:SetUnpacked(0, 0, (CurTime() + planeDieTime) * 512)
		matrixCircleRender:Rotate(rotAngle)

		cam.PushModelMatrix(matrixCircleRender, true)
			render.ClearStencil()

			-- do some stencil trickery to make it render as a decal!
			render.SetStencilEnable(false)
			render.SetStencilTestMask(255)
			render.SetStencilWriteMask(255)
			render.SetStencilReferenceValue(0)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

			render.SetStencilEnable(true)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_KEEP)
			render.SetStencilReferenceValue(1)

			render.OverrideColorWriteEnable(true, false)
			render.CullMode(MATERIAL_CULLMODE_CW)
				render.SetColorMaterial()
				meshDecalVolume:Draw()
			render.OverrideColorWriteEnable(false)


			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_KEEP)
			render.SetStencilReferenceValue(0)

			render.OverrideColorWriteEnable(true, false)
			render.CullMode(MATERIAL_CULLMODE_CCW)
				render.SetColorMaterial()
				meshDecalVolume:Draw()
			render.OverrideColorWriteEnable(false)


			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilReferenceValue(1)

			render.OverrideColorWriteEnable(true, false)
			render.CullMode(MATERIAL_CULLMODE_CW)
				render.SetColorMaterial()
				meshFloor:Draw()
			render.CullMode(MATERIAL_CULLMODE_CCW)
				render.SetColorMaterial()
				meshFloor:Draw()
			render.OverrideColorWriteEnable(false)



			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_KEEP)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilReferenceValue(1)
			render.CullMode(MATERIAL_CULLMODE_CCW)
				--render.ClearBuffersObeyStencil(255, 0, 0, 255, false)

				render.CullMode(MATERIAL_CULLMODE_CCW)
				render.SetMaterial(mat)
				meshFloor:Draw()
			render.SetStencilEnable(false)

			render.CullMode(MATERIAL_CULLMODE_CCW)
		cam.PopModelMatrix()
	end
end)


-- netcode
if SERVER then
	util.AddNetworkString("trays_summoncircle_onspawn")
end

net.Receive("trays_summoncircle_onspawn", function(len, ply)
	if SERVER then
		return
	end

	-- read pos and norm
	local circlePos = net.ReadVector()
	if not circlePos then
		return
	end

	local circleNorm = net.ReadNormal()
	if not circleNorm then
		return
	end

	-- add circle renderer
	ArtiWeps_AddSummonCircle(circlePos, circleNorm)
end)
