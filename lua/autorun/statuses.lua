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
		if not ent:Alive() then return end
		if ent:GetRunSpeed() >= 400 then return end
		ent:SetRunSpeed( ent:GetRunSpeed() + 40 )
		ent:SetWalkSpeed( ent:GetWalkSpeed() + 40 )

	end)
end

--================NULLIFY STATUS CODE=================
function StatusNullify( ply, hp, armor )
--Is unaffected by status disabling as it is not really a status effect. more so an effect on a gun.
	if ply:Armor() < 100 then
		ply:SetArmor( ply:Armor() + armor )
		if ply:Armor() > 100 then
			ply:SetArmor( 100 )
		end
	end


	if ply:Armor() == 100 then
		ply:SetHealth( ply:Health() + 10 )
		if ply:Health() > 100 then
			ply:SetHealth( ply:GetMaxHealth() )
		end
	end
end
--================NULLIFY STATUS CODE=================


function StatusMagmatic( ply, lvl, dmginst, dmgown )
	if bool == false then return end
	if not ply:IsValid() or not ply:IsPlayer() then return end
	--if not ply:isAlive() then return end
	ply.isMagmafied = true

	timer.Simple( 1, function()
		if ply.isMagmafied == true then
			ply:TakeDamage( dmginst * lvl, dmgown )
			ply:EmitSound("physics/concrete/concrete_break3.wav", 75, math.random(140, 150), 0.3, 1)
			local FxData = EffectData()
			FxData:SetOrigin( ply:GetPos() + Vector(0, 0, 40) )
			util.Effect("cball_explode", FxData, true, true)
			ply.isMagmafied = false
		end
	end)

end
