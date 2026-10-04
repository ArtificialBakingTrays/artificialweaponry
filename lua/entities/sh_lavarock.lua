AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lava Rock Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Primary Fire Rock Projectile"
ENT.Spawnable = true


if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/rock001a.mdl")
        self:SetMaterial("models/effects/splode_sheet")
        self:SetModelScale( 0.6 )
        self:SetAngles( Angle( math.random(0, 360), math.random(0, 360), math.random(0, 360) ))

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.IsTraysProjectile = true

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end
            phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

        self:Fire( "Kill", "", 7.5 )
    end

    function ENT:PhysicsCollide(data)
        if CLIENT then return end
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if (self.NextHit or 0) > CurTime() then return end

        local ExplDMG = math.random( 12, 15 )
        local DMG = math.random( 20, 30 )

        if not IsValid(enthit) then
            util.BlastDamage( self, self:GetOwner(), self:GetPos(), 85, ExplDMG )
            self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
            self:EmitSound( "physics/concrete/boulder_impact_hard1.wav", 100, math.random(95, 105), 1, 6 )
            self:Remove()

            local effectdata = EffectData() --I love copy pasting
            effectdata:SetOrigin( self:GetPos() )
            util.Effect("HunterDamage", effectdata, true, true)
            return
        end

        if enthit.IsTraysProjectile then return end

        self.NextHit = CurTime() + 0.1
        data.HitEntity:TakeDamage(DMG, self:GetOwner())
        self:EmitSound( "physics/concrete/boulder_impact_hard3.wav", 100, math.random(105, 115), 1, 6 )
        self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
        StatusMagmatic( data.HitEntity, 1, math.random(14, 21), self )
    end
end

if CLIENT then
    local spritemat = Material("mat_jack_gmod_shinesprite")
    local ColorSprite =  Color(255, 89, 0)

    function ENT:Draw()
        self:DrawModel()

        render.PushFilterMin(TEXFILTER.POINT)
        render.PushFilterMag(TEXFILTER.POINT)
            render.SetMaterial(spritemat)
            render.DrawSprite(self:GetPos(), 16, 16, ColorSprite)

            render.SetMaterial( Material( "sprites/glow04_noz" ))
            render.DrawSprite(self:GetPos(), 32, 32, Color(255, 122, 51))
        render.PopFilterMag()
        render.PopFilterMin()

        self:DrawModel()

        render.SetMaterial(spritemat)
        render.DrawSprite(self:GetPos(), 5, 5, Color(255, 255, 243))

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( 255, 207, 51 )
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