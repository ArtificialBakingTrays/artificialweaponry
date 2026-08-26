AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Bulkball Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Nucleonic"
ENT.Spawnable = false

local BaseColor = Color( 196, 255, 113)
local scale = 3

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:SetModelScale( scale )
        self:SetMaterial("model_color")
        self:SetColor(Color(247, 255, 239))

        local TSIZE = 200
        util.SpriteTrail(self, 0, Color(196, 255, 133), false, TSIZE, 0, 0.75, 1, "trails/laser")

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.IsTraysProjectile = true

        local phys = self:GetPhysicsObject()
        phys:SetBuoyancyRatio(0)
        phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
        phys:SetMass(25)

        if phys:IsValid() then phys:Wake() end

        self:Fire( "Kill", "", 12.5 )
    end

    --Custom Projectile Spawning Func
    --Now updated to work for MANY projectiles at once.
    function ENT:SpawnProjectile( Entstring, Owner, Position, Angles )
        if CLIENT then return end
        local ent = ents.Create( Entstring )
        if ( not ent:IsValid() ) then return end

        ent:SetOwner( Owner )
        ent:SetPos( Position )
        ent:SetAngles( Angles )
        ent:Spawn()

        local entphys = ent:GetPhysicsObject()

        if ( not entphys:IsValid() ) then ent:Remove() return end

        entphys:EnableMotion(false)
    end


    function ENT:OnTakeDamage(dmginfo)
        self:CheckNearby( 250, math.random(45, 60) )
        self:EmitSound("sparkbound/cloudstrikefire.mp3", 100, math.floor(math.random(90, 110)), 1, 6, CHAN_STATIC) 
        util.ScreenShake( self:GetPos(), 400, 40, 0.5, 400, true )

        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() - Vector(0, 0, 10000),
            filter = self
        })

        if tr.Hit then
            self:SpawnProjectile( "sh_pool", self:GetOwner(), tr.HitPos, tr.HitNormal:Angle() + Angle(90, 0, 0) )

            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            effectdata:SetNormal( Vector(1,1) )
            effectdata:SetRadius( 250 )
            util.Effect("HelicopterMegaBomb", effectdata, true, true)
        end
        self:Remove()
    end

    function ENT:CheckNearby( radius, dmg )
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
            if dist > radius then continue end

            v:TakeDamage( dmg, self:GetOwner(), self )
         end
    end

    function ENT:PhysicsCollide(data)
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if enthit == self:GetOwner() then return end
        if enthit.IsTraysProjectile then return end

        if not IsValid(enthit) then
                local effectdata = EffectData() --I love copy pasting
                effectdata:SetOrigin( self:GetPos() )
                effectdata:SetScale(0.1)
                self:EmitSound("artiwepsv2/nuclearbomba.mp3", 100, math.random(90, 110), 1, 1 )
                self:CheckNearby( 125, 35 )
                util.Decal( "Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
                self:Remove()
            return
        end

        if data.HitSpeed:Length() > 60 then
            if not IsValid(self) then return end
            self:CheckNearby( 125, 35 )
            self:Remove()

            enthit:TakeDamage( 45, self:GetOwner() )
            StatusTrickle( enthit, self:GetOwner(), 45/5, 4 )

            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            effectdata:SetScale( 0.1 )
            self:EmitSound("artiwepsv2/nuclearbomba.mp3", 100, math.random(90, 110), 1, 1 )
        end
    end
end


if CLIENT then
    function ENT:Draw()
        local TARGET = Material("particle/glow_haze_nofog")
        local electric = Material("effects/ar2_altfire1")
        local glowmat = Material("particle/Particle_Ring_Wave_Additive")

        self:DrawModel()

        render.SetMaterial(TARGET)
        render.DrawSprite(self:GetPos(), 36*scale, 36*scale, Color(196, 255, 133))

        render.SetMaterial(glowmat)
        render.DrawSprite(self:GetPos(), 18*scale, 18*scale, Color(250, 255, 246))

        render.SetMaterial(electric)
        render.DrawSprite(self:GetPos(), 36*(scale/.5), 36*(scale/.5), Color(132, 255, 0) )

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-20, 20), math.random(-20, 20), math.random(-20, 20) ) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( 196, 255, 113 )
                part:SetDieTime( 0.8 ) -- How long the particle should "live"

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

    function ENT:OnRemove()
        local emit = ParticleEmitter(self:GetPos())

        for i = 1, 250 do
            local part = emit:Add("particle/Particle_Glow_04_Additive", self:GetPos())
            if part then
                part:SetColor( 132, 255, 0 )
                part:SetDieTime( 0.3 )
                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )
                part:SetStartSize( 3.5 )
                part:SetEndSize( 20 )
                part:SetGravity(Vector( 0, 0, 250 ))
                part:SetVelocity( VectorRand() * 150 )
            end
        end
        emit:Finish()

        local emit = ParticleEmitter(self:GetPos())
        for i = 1, 750 do
            local part = emit:Add("particle/fire", self:GetPos())
            if part then
                part:SetColor( 196, 255, 133 )
                part:SetDieTime( 0.2 )
                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )
                part:SetStartSize( 10 )
                part:SetEndSize( 0 )
                part:SetGravity( Vector( 0,0,-250 ) )
                part:SetVelocity( VectorRand() * 1200 )
            end
        end
        emit:Finish()
        
        local emit = ParticleEmitter(self:GetPos())
        for i = 1, 750 do
            local part = emit:Add("particle/fire", self:GetPos())
            if part then
                part:SetColor( 196, 255, 133 )
                part:SetDieTime( 2.6 )
                part:SetStartAlpha( 255 )
                part:SetEndAlpha( 0 )
                part:SetStartSize( 10 )
                part:SetEndSize( 0 )
                part:SetGravity( Vector( 0,0,-2000 + math.random(1000, 2000) ) )
                part:SetVelocity( VectorRand() )
            end
        end
        emit:Finish()
    end
end