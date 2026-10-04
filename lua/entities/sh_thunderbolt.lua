AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Thunderbolt Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Sparkbound Compass"
ENT.Spawnable = false

if SERVER then
    local BaseColor = Color( 168, 167, 255)

    function ENT:Initialize()
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:SetModelScale( 0.5 )
        self:SetMaterial("model_color")
        self:SetColor( BaseColor )

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        self:PhysicsInitSphere( 0.2, SOLID_VPHYSICS )
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.IsTraysProjectile = true

        local phys = self:GetPhysicsObject()
        phys:SetBuoyancyRatio(0)
        phys:EnableGravity(false)
        phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
        if phys:IsValid() then phys:Wake() end

        self:Fire( "Kill", "", 12.5 )
    end

    function ENT:PhysicsCollide(data)
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if enthit == self:GetOwner() then return end
        if enthit.IsTraysProjectile then return end
        self:EmitSound( "sparkbound/spark.mp3", 75, math.random(95, 100), 1, 6 )

        if not IsValid(enthit) then
                local effectdata = EffectData() --I love copy pasting
                effectdata:SetOrigin( self:GetPos() )
                effectdata:SetScale(0.1)
                util.Effect("cball_explode", effectdata, true, true)
                self:Remove()
            return
        end

        if data.HitSpeed:Length() > 60 then
            if not IsValid(self) then return end
            self:Remove()
            enthit:TakeDamage( 45, self:GetOwner() )

            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            effectdata:SetScale( 0.1 )
            util.Effect("cball_explode", effectdata, true, true)
        end
    end
end

if CLIENT then
    local spritemat = Material("particle/Particle_Ring_Sharp")
    local electric = Material("effects/ar2_altfire1")
    local glowmat = Material("sprites/light_glow02_add")
    local BaseColor = Color( 21, 0, 255)

    function ENT:Draw()
        self:DrawModel()

        render.SetMaterial(spritemat)
        render.DrawSprite(self:GetPos(), 24, 24, Color( 170, 167, 255))

        render.SetMaterial(glowmat)
        render.DrawSprite(self:GetPos(), 96, 96, BaseColor )

        render.SetMaterial(electric)
        render.DrawSprite(self:GetPos(), 36, 36, BaseColor )

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-5, 5), math.random(-5, 5), math.random(-5, 5) ) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( 88, 91, 255 )
                part:SetDieTime( 0.1 ) -- How long the particle should "live"

                part:SetStartAlpha( 255 ) -- Starting alpha of the particle
                part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

                part:SetStartSize( 5 ) -- Starting size
                part:SetEndSize( 0 ) -- Size when removed

                part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
                part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
            end
        end
        emitter:Finish()
    end
end