AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Scrap Pickup"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Scrap Item pickup, restores Shield and Ammo on pickup."
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ColorID")
end

local ranMDLLut = {
    [1] = { 
        Mdl = "models/Gibs/helicopter_brokenpiece_03.mdl",
        Scl = 0.3
    },
    [2] = {
        Mdl = "models/Gibs/helicopter_brokenpiece_02.mdl",
        Scl = 0.4
    },
    [3] = {
        Mdl = "models/props_c17/TrapPropeller_Engine.mdl",
        Scl = 0.4
    },
    [4] = {
        Mdl = "models/props_junk/garbage_bag001a.mdl",
        Scl = 0.8
    }
}


if SERVER then 
    function ENT:Initialize()
        local owner = self:GetOwner()
        local colorID = 2 -- Blue by default

        if IsValid(owner) then
            local wep = owner:GetActiveWeapon()
            if not IsValid(wep) then return end
            if wep:GetClass() == "art_hatred" then colorID = 1
            elseif wep:GetClass() == "art_springloaded" then colorID = 2 end
        end

        self:SetColorID(colorID)
        local truColor

        if self:GetColorID() == 1 then truColor = Color(255, 51, 0)
        else truColor = Color(255, 243, 137) end

        local random = math.floor(math.random( 1, 4 ))
        local sndEntry = ranMDLLut[random]
        
        self:SetModel( sndEntry.Mdl )
        self:SetModelScale( sndEntry.Scl )
        self:SetMaterial( "models/props_combine/combine_bunker01" )
        self:SetColor(Color( 141, 105, 21 ))
        self:SetAngles(Angle( math.random(0, 360 ), math.random( 0, 360 ), math.random( 0, 360 )))
        self:SetRenderMode( RENDERMODE_TRANSCOLOR )

        util.SpriteTrail( self, 0, truColor, false, 40, 0, 0.35, 0.35, "trails/laser" )

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)

        self.IsTraysProjectile = true

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetBuoyancyRatio(0)
            phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
            phys:EnableGravity( false )
            phys:SetMass(0)
            
            phys:Wake()
        end

        timer.Simple( 20, function()
            if not IsValid(self) then return end
            self:Remove()
        end)
    end

    function ENT:Think()
        local owner = self:GetOwner()
        local phys = self:GetPhysicsObject()

        if not IsValid(owner) or not owner:Alive() then
            self:NextThink(CurTime())
            return true
        end

        if not IsValid(phys) then return end
            local pos = self:GetPos()
            local ownerPos = owner:GetPos() + Vector(0, 0, 30)

            if pos:DistToSqr(ownerPos) <= 10 * 50 then
                local wep = owner:GetActiveWeapon()

                if IsValid(wep) and wep:HasAmmo() then
                    if wep:GetClass() == "art_hatred" then wep:SetClip1( wep:Clip1() + 17 )
                    else wep:SetClip1( wep:Clip1() + 4 ) end
                    if wep:Clip1() > wep:GetMaxClip1() then wep:SetClip1( wep:GetMaxClip1() ) end
                    owner:SetArmor( owner:Armor() + 7 )
                    if owner:Armor() > 100 then owner:SetArmor( 100 ) end

                    self:EmitSound( "items/ammo_pickup.wav", 100, math.random(120, 130), 1, 6 )
                    self:Remove()
                    return
                end
            end

            -- Seeking
            local Dir = (ownerPos - pos):GetNormalized()
            local currentVel = phys:GetVelocity()
            local currentDir = currentVel:GetNormalized()

            local turnRate = 0.18
            local newDir = LerpVector(
                turnRate,
                currentDir,
                Dir
            ):GetNormalized()

            phys:SetVelocity(newDir * 500)

        self:NextThink(CurTime())
        return true
    end

    function ENT:OnRemove()
        local effectdata = EffectData()
        effectdata:SetOrigin( self:GetPos() )
        effectdata:SetScale(0.1)

        util.Effect("cball_explode", effectdata, true, true)
    end
end



if CLIENT then 
    local spritemat = Material("sprites/physg_glow1")
    
    function ENT:GetTrueColor()
        if self:GetColorID() == 1 then
            return Color(255, 51, 0)
        end

        return Color(255, 243, 137)
    end

    function ENT:Draw()
        local truColor = self:GetTrueColor()
        
        self:DrawModel()
        render.PushFilterMin(TEXFILTER.POINT)
        render.PushFilterMag(TEXFILTER.POINT)
            render.SetMaterial(spritemat)
            render.DrawSprite(self:GetPos(), 64, 64, truColor)
        render.PopFilterMag()
        render.PopFilterMin()

        render.SetMaterial(Material( "particle/fire" ))
        render.DrawSprite( self:GetPos(), 16, 16, truColor )

        local emitter = ParticleEmitter( self:GetPos() )
        local dist = 2.5
        local R = truColor.r
        local G = truColor.g
        local B = truColor.b

        for i = 1, 25 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-dist, dist), math.random(-dist, dist), math.random(-dist, dist) ) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( R, G, B )
                part:SetDieTime( 0.3 )

                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )

                part:SetStartSize( math.random(0.2, 1.1) )
                part:SetEndSize( 0 )

                part:SetGravity( Vector( 0, 0, -250 ) )
                part:SetVelocity( VectorRand() * 50 )
            end
        end
         emitter:Finish()
    end

    function ENT:OnRemove()
        local emit = ParticleEmitter(self:GetPos())
        local remDist = 1

        local R = self:GetTrueColor().r
        local G = self:GetTrueColor().g
        local B = self:GetTrueColor().b

        for i = 1, 12 do
            local part = emit:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-remDist, remDist), math.random(-remDist, remDist), math.random(-remDist, remDist*3) ) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( R, G, B )
                part:SetDieTime( 0.7 )

                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 125 )

                part:SetStartSize( math.random(0.2, 1.1) )
                part:SetEndSize( 10 )

                part:SetGravity( Vector( 0, 0, -250 ) )
                part:SetVelocity( VectorRand() * 50 )
            end
        end
        emit:Finish()
        return
    end
end