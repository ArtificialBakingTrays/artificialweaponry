AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lava Mortar Projectile"
ENT.Author = "ArtificialBakingTrays"
ENT.Category = "Artificial Ents"
ENT.Contact = "ArtificialBakingTrays"
ENT.Purpose = "Secondary Fire Rock Projectile"
ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_wasteland/rockcliff01j.mdl")
        self:SetMaterial("materials/models/effects/splode_sheet.vmt")
        self:SetColor(Color(255, 122, 51))
        self:SetModelScale( 0.525 )
        self:SetAngles( Angle( 0, math.random(0, 360), 180 ))

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.IsTraysProjectile = true

        util.SpriteTrail(self, 0, Color(255, 223, 160), true, 100, 0, 0.8, 1, "materials/sprites/physbeama.vmt")

        self:EmitSound("artiwepsv2/comicalfalling.mp3", 75, 100, 1, 6)

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end

        self:Fire( "Kill", "", 12.5 )
    end

    function ENT:PhysicsCollide(data)
        if CLIENT then return end
        local enthit = data.HitEntity
        if ( not self:IsValid() ) then return end
        if (self.NextHit or 0) > CurTime() then return end

        local ExplDMG = math.random( 200, 350 )
        local DMG = 1000

        if not IsValid(enthit) then
            util.BlastDamage( self, self:GetOwner(), self:GetPos(), 260, ExplDMG )
            self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(95, 105), 1, 1 )
            self:EmitSound( "artiwepsv2/rockblast.mp3", 100, math.random(70, 80), 1, 6 )
            self:Remove()

            local effectdata = EffectData() --I love copy pasting
            effectdata:SetOrigin( self:GetPos() )
            util.Effect("HunterDamage", effectdata, true, true)
            self:StopSound("artiwepsv2/comicalfalling.mp3")
            return
        end

        if enthit.IsTraysProjectile then return end

        self.NextHit = CurTime() + 0.1
        data.HitEntity:TakeDamage(DMG, self:GetOwner())
        self:EmitSound( "physics/concrete/boulder_impact_hard3.wav", 100, math.random(95, 105), 1, 6 )
        self:EmitSound( "weapons/ar2/npc_ar2_altfire.wav", 100, math.random(70, 80), 1, 1 )
    end
end


if CLIENT then
    local spritemat = Material("mat_jack_gmod_shinesprite")
    local ColorSprite =  Color(255, 89, 0)

    function ENT:Draw()
        self:DrawModel()

        local TextrSZ = 640

        render.PushFilterMin(TEXFILTER.POINT)
        render.PushFilterMag(TEXFILTER.POINT)
            render.SetMaterial(spritemat)
            render.DrawSprite(self:GetPos(), TextrSZ / 2, TextrSZ / 2, ColorSprite)

            render.SetMaterial( Material( "sprites/glow04_noz" ))
            render.DrawSprite(self:GetPos(), TextrSZ, TextrSZ, Color(255, 122, 51))
        render.PopFilterMag()
        render.PopFilterMin()

        self:DrawModel()

        render.SetMaterial(spritemat)
        render.DrawSprite(self:GetPos(), 50, 50, Color(255, 255, 243))

        local emitter = ParticleEmitter( self:GetPos() ) -- Particle emitter in this position
        local disttocentre = 20

        for i = 1, 1 do
            local part = emitter:Add( "sprites/glow04_noz", self:GetPos() + Vector( math.random(-disttocentre, disttocentre), math.random(-disttocentre, disttocentre), math.random(-disttocentre, disttocentre)) ) -- Create a new particle at pos
            if ( part ) then
                part:SetColor( 255, 207, 51 )
                part:SetDieTime( 2 ) -- How long the particle should "live"

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