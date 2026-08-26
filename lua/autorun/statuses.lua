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



--=================BLEED STATUS CODE===================--
--For weapons of the GOREY Class
--This includes: Meatgrinder, Parasitical Arm-Implant, and Tactical-Bleeder
--( TacBleeder and Parasitical dont have this yet due to balancing concerns. )
function StatusBleed( dmg, ply, ent )
	if CLIENT then return end
	if bool == false then return end
	if ent.IsBleeding == true then return end
	--Bleed ticks 3 times per instance of the effect.

	local num = 0.15 --difference between each instance of bleed
	ent.IsBleeding = true
	for i = 1, 7 do
		num = num + 0.15
		timer.Simple( num, function()
			if !IsValid(ent) or ent:Health() <= 0 then ent.IsBleeding = false return end
			if ent.IsBleeding == false then return end
			ent:TakeDamage( dmg, ply )
			ent:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 75, math.random(110, 120) + (num*10), 1, 1)
			ent:EmitSound("artiwepsv2/primebop.mp3", 75, math.random(110, 120) + (num*10), 1, 6)
			local FxData = EffectData()
			FxData:SetOrigin( ent:GetPos() + Vector(0, 0, 40) )
			util.Effect("BloodImpact", FxData, true, true)
		end)
	end

	timer.Simple( 2, function()
		ent.IsBleeding = false
	end)
end



--=================TRICKLED STATUS CODE===================--
--For weapons of the Thundery Class (is also used for Nuclear weapons)
--This includes: LostMasks, Nucleonic, and SparkBound Compass, And Lethal Dose of Radiation
function StatusTrickle( ent, dmgown, dmgtick, ticks )
	if CLIENT then return end
	if bool == false then return end
	if not IsValid(ent) then return end

	if ent.IsCurrentlyTrickled == true then return end

	ent.IsCurrentlyTrickled = true

	local num = 0
	for i = 1, ticks do
		num = num + 1
		timer.Simple( num, function()
			if !IsValid(ent) or ent:Health() <= 0 then ent.IsCurrentlyTrickled = false return end
			if ent.IsCurrentlyTrickled == false then return end
			if ent:IsOnFire() then 
				dmgtick = dmgtick * 2 
				ent:EmitSound("sparkbound/elec_impact.mp3", 75, math.random(110, 120), 1, 1)
			else
				ent:EmitSound("sparkbound/spark.mp3", 75, math.random(110, 120), 1, 1)	
			end

			ent:TakeDamage(dmgtick, dmgown, dmgown)

			local FxData = EffectData()
			FxData:SetOrigin( ent:GetPos() + Vector(0, 0, 40) )
			util.Effect("cball_explode", FxData, true, true)
		end)
	end

	timer.Simple( 7.2, function()
		ent.IsCurrentlyTrickled = false
		num = 0
	end)
end





--=================SLOW STATUS CODE===================--
--For weapons of the Glacial Class
--This is currently exclusively found on the Subzero Standard SMG.
--Again, this may change in future updates.
function StatusSlow( ent, time )
	if CLIENT then return end
	if bool == false then return end
	if ent.IsSlowed == true then return end
	if ent:IsNPC then return end
	if not IsValid(ent) or ent:Health() == 0 then return end

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
--EXCLUSIVELY FOR THE PARASITICAL ARM-IMPLANT
function StatusNullify( ply, hp, armor )
	if CLIENT then return end
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



--For weapons of the Fireforged Class
--This is currently exclusively found on the PinPoint Detonator, however this may change with future updates.
function StatusMagmatic( ply, lvl, dmginst, dmgown )
	if CLIENT then return end
	if bool == false then return end
	if not ply:IsValid() or not ply:IsPlayer() then return end
	--if not ply:isAlive() then return end
	ply.isMagmafied = true

	timer.Simple( 1, function()
		if ply.isMagmafied == true then
			ply:TakeDamage( dmginst * lvl, dmgown, dmgown )
			ply:EmitSound("physics/concrete/concrete_break3.wav", 75, math.random(140, 150), 0.3, 1)
			ply:Ignite(8, 100)
			local FxData = EffectData()
			FxData:SetOrigin( ply:GetPos() + Vector(0, 0, 40) )
			util.Effect("cball_explode", FxData, true, true)
			ply.isMagmafied = false
		end
	end)

end
