local bool = true --base value = true
--Used for enabling or disabling status effects

if SERVER then
	concommand.Add( "artiweps_status", function( ply )
			if not ply:IsListenServerHost() then return end
			bool = not bool

		if bool == true then
			print( "Status Effects have been set to true")
		end

		if bool == false then
			print( "Status Effects have been set to false")
		end
	end )
end

--=================BLEED STATUS CODE===================
function StatusBleed( dmg, ply, ent )
	if bool == false then return end
	if CLIENT then return end
	if ent.IsBleeding == true then return end

	--Bleed ticks 3 times per instance of the effect.
	local num = 1 --difference between each instance of bleed
	ent.IsBleeding = true

	for i = 1, 7 do
		num = num + 1
		timer.Simple( num, function()
			ent:TakeDamage( dmg, ply )
			ent:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 75, math.random(110, 120), 1, 1)
			local FxData = EffectData()
			FxData:SetOrigin( ent:GetPos() + Vector(0, 0, 40) )
			util.Effect("BloodImpact", FxData, true, true)
		end)
	end

	timer.Simple( 7.2, function()
		ent.IsBleeding = false
	end)
end
--=================BLEED STATUS CODE===================


--=================SLOW STATUS CODE===================
function StatusSlow( ent, time )
	if bool == false then return end
	if ent.IsSlowed == true then return end

	ent:SetRunSpeed( ent:GetRunSpeed() - 40 )
	ent:SetWalkSpeed( ent:GetWalkSpeed() - 40 )
	ent.IsSlowed = true

	timer.Simple( time, function()
		ent:SetRunSpeed( ent:GetRunSpeed() + 40 )
		ent:SetWalkSpeed( ent:GetWalkSpeed() + 40 )
	end)
end
--=================SLOW STATUS CODE===================


--=================GLACIAL BONUS CODE=================
function StatusGlacialBonus(ply, time)
	if ply.HasBonus == true then return end

	timer.Simple( time, function()
		ply.HasBonus = false
	end)
end

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( target, dmginfo )
	--reducing damage taken when a player has the bonus
	if target.HasBonus == false then return end
	if not target:IsValid() then return end
	if not target:IsPlayer() then return end

	dmginfo:ScaleDamage( 0.4 )
end )
--=================GLACIAL BONUS CODE=================