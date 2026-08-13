AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "NukePool Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Projectile for Nucleonic"
ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/tubes/tube4x4x025.mdl")
        --self:SetModelScale( 1.3 )
        self:SetMaterial("model_color")
        self:SetColor(Color(187, 255, 118, 125 ))
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)


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

        local num = 0
        local sfx = "sparkbound/ice_thud.mp3"

        self:EmitSound( sfx, 100, 80 + (num*10), nil, CHAN_STATIC )

        local radius = 200

        for i = 1, 7 do
            num = num + 1
            timer.Simple( num, function()
                self:CheckNearby( radius, (2.5*num)/2 )
                self:EmitSound( sfx, 100, 80 + (num*10), nil, CHAN_STATIC )
            end)
        end

        timer.Simple( 8, function()
            self:CheckNearby( radius, 25 )
            self:EmitSound( sfx, 100, 100, nil, CHAN_STATIC )
            self:Remove()
            num = 0
        end)
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
end


if CLIENT then
    function ENT:Draw()
        local TARGET = Material("particle/glow_haze_nofog")
        local electric = Material("effects/ar2_altfire1")
        local glowmat = Material("particle/Particle_Ring_Wave_Additive")

        local m = Matrix()
        m:Scale(Vector(1.5, 1.5, 0.25))

        self:EnableMatrix("RenderMultiply", m)

        self:DrawModel()

        render.SetMaterial(TARGET)
        render.DrawSprite(self:GetPos(), 36, 36, Color(196, 255, 133))

        render.SetMaterial(glowmat)
        render.DrawSprite(self:GetPos(), 36, 36, Color(250, 255, 246))

        render.SetMaterial(electric)
        render.DrawSprite(self:GetPos(), 360, 360, Color(132, 255, 0) )

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        local Posdist = 120

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-Posdist, Posdist), math.random(-Posdist, Posdist), math.random(0, Posdist - 30) ) ) -- Create a new particle at pos
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
end
