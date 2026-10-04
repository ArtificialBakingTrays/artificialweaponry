AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Sharpshot Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for electric wep idk"
ENT.Spawnable = false

if SERVER then
    local BaseColor = Color( 255, 255, 232)
    function ENT:Initialize()
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:SetModelScale( 1.75 )
        self:SetMaterial("model_color")
        self:SetColor( BaseColor )

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        self:PhysicsInitSphere( 0.4, SOLID_VPHYSICS )
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.IsTraysProjectile = true

        local SSize = 12
        local ESize = 0
        local Duration = 0.15

        util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

        local phys = self:GetPhysicsObject()
        phys:SetBuoyancyRatio(0)
        phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

        if phys:IsValid() then phys:Wake() end

        self:Fire( "Kill", "", 12.5 )
    end

    function ENT:PhysicsCollide(data)
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if enthit == self:GetOwner() then return end
        if enthit.IsTraysProjectile then return end
        self:EmitSound( "legendary/spark.mp3", 75, math.random(95, 100), 1, 6 )

        if not IsValid(enthit) then
                local effectdata = EffectData() --I love copy pasting
                effectdata:SetOrigin( self:GetPos() )
                effectdata:SetScale(0.1)
                util.Effect("cball_explode", effectdata, true, true)
                self:CheckNearby()
                self:Remove()
            return
        end

        if data.HitSpeed:Length() > 60 then
            if not IsValid(self) then return end
            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            effectdata:SetScale( 0.1 )
            util.Effect("cball_explode", effectdata, true, true)
            enthit:TakeDamage( 65, self:GetOwner() )
            StatusTrickle( enthit, self:GetOwner(), 35 / 5, 4 )
            self:Remove()
        end
    end


    function ENT:CheckNearby()
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
            StatusTrickle( v, self:GetOwner(), 35 / 5, 4 )
        end
    end
end

if CLIENT then
    local spritemat = Material("particle/Particle_Ring_Wave_Additive")
    local electric = Material("effects/ar2_altfire1")
    local glowmat = Material("sprites/light_glow02_add")
    local BaseColor = Color( 172, 173, 255)

    function ENT:Draw()
        self:DrawModel()

        render.SetMaterial(spritemat)
        render.DrawSprite(self:GetPos(), 48, 48, BaseColor)

        render.SetMaterial(glowmat)
        render.DrawSprite(self:GetPos(), 192, 192, BaseColor )

        render.SetMaterial(electric)
        render.DrawSprite(self:GetPos(), 56, 56, BaseColor )

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-10, 10), math.random(-10, 10), math.random(-10, 10 ) ))
            if ( part ) then
                part:SetColor( 88, 91, 255 )
                part:SetDieTime( 0.1 )

                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )

                part:SetStartSize( 5 ) -- Starting size
                part:SetEndSize( 0 ) -- Size when removed

                part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
                part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
            end
        end
        emitter:Finish()
    end
end