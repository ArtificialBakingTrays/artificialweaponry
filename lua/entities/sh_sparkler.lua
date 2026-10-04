AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Sparkler Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Sparkbound Compass"
ENT.Spawnable = false

if SERVER then
    local BaseColor = Color( 180, 167, 255)

    function ENT:Initialize()
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:SetMaterial("model_color")
        self:SetColor( Color(255, 255, 255 ) )
        self:SetModelScale(0.2)

        local SSize = 12
        local ESize = 0
        local Duration = 0.15

        util.SpriteTrail(self, 0, BaseColor, false, SSize, ESize, Duration, 1, "trails/laser")

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

        self:Fire( "Kill", "", 4.5 )

        local EXPRadius = 120
        local EXPDmg = 50

        timer.Simple( 1.3, function()
            if not IsValid( self ) then return end
                util.BlastDamage( self, self:GetOwner(), self:GetPos(), EXPRadius, EXPDmg )
                self:EmitSound( "tray_sounds/slingfirework2.mp3", 75, math.random( 90, 110 ), 1.2, 1 )
                    self:EmitSound("sparkbound/elec_impact.mp3", 75, math.random( 90, 110 ), 1.2, 6)
            self:Remove()
        end)
    end

    function ENT:PhysicsCollide(data)
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if enthit == self:GetOwner() then return end
        if enthit.IsTraysProjectile then return end
        self:EmitSound( "sparkbound/spark.mp3", 75, math.random(95, 100), 1, 6 )

        if data.HitSpeed:Length() > 60 then
            if not IsValid(self) then return end
            enthit:TakeDamage( 5, self:GetOwner() )
            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            effectdata:SetScale( 0.1 )
            util.Effect("cball_explode", effectdata, true, true)
        end
    end

    function ENT:Think()
        local dt = FrameTime()
        local phys = self:GetPhysicsObject()
        if not IsValid(phys) then return end
        if self.NoDrag then return end
        phys:ApplyForceCenter( -phys:GetVelocity() * dt * phys:GetMass() * 25 )
    end
end

if CLIENT then
    local spritemat = Material("particle/Particle_Ring_Wave_Additive")

    function ENT:Draw()
        self:DrawModel()

        render.SetMaterial(spritemat)
        render.DrawSprite(self:GetPos(), 5, 5, Color(246, 245, 255))

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( 200, 195, 255 )
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

        timer.Simple(1.3, function()
            if not IsValid( self ) then return end
            local emit = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position
                for i = 1, 25 do
                    local part = emit:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
                    if ( part ) then
                        part:SetColor( 230, 228, 255 )
                        part:SetDieTime( 0.25 ) -- How long the particle should "live"

                        part:SetStartAlpha( 255 ) -- Starting alpha of the particle
                        part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

                        part:SetStartSize( 15 ) -- Starting size
                        part:SetEndSize( 0 ) -- Size when removed

                        part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
                        part:SetVelocity( VectorRand() * 1750 ) -- Initial velocity of the particle
                    end
                end
            emit:Finish()
        end)
    end
end