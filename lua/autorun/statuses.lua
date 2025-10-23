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
--=================SLOW STATUS CODE===================



--[[
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
]]--

--O ye bell done crossed me one to many ye times over, im about to lose my balls

--===============SUGARRUSH BONUS CODE=================
function StatusSugarRush( ply, time, bonus )
	if bool == false then return end

	ply:SetRunSpeed( ply:GetRunSpeed() + bonus )
	ply:SetWalkSpeed( ply:GetWalkSpeed() + bonus )

	timer.Simple( time, function()
		if not ent:Alive() then return end
		ply:SetRunSpeed( ply:GetRunSpeed() - bonus )
		ply:SetWalkSpeed( ply:GetWalkSpeed() - bonus )
	end)
end
--===============SUGARRUSH BONUS CODE=================


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


function StatusPoison( ply, ticks, dmg, owner )
	if ply.isCurrentlyPoisoned == true then return end
	if bool == false then return end
	if not ply:IsValid() then return end

	ply:SetColor(Color(136, 0, 255))

	local num = 0.45 --difference between each instance of Shock
	ply.isCurrentlyPoisoned = true

	for i = 1, ticks do
		num = num + 0.5
		timer.Simple( num, function()
			if ply.isCurrentlyPoisoned == true then
			ply:TakeDamage( dmg, owner )
			ply:EmitSound("boombramble/bushcut.mp3", 75, math.random(140, 150), 0.3, 1)
			local FxData = EffectData()
			FxData:SetOrigin( ply:GetPos() + Vector(0, 0, 40) )
			util.Effect("watersplash", FxData, true, true)
			end
		end)
	end
	if not ply:Alive() then
		ply.isCurrentlyPoisoned = false
		ply:SetColor(Color(255, 255, 255))
	end

	timer.Simple( ticks + 0.1, function()
		ply.isCurrentlyPoisoned = false
		ply:SetColor(Color(255, 255, 255))
	end)
end