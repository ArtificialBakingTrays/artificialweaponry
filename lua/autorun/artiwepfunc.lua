function GetWeaponPack()
	return "Artificial Weaponry"
	--Specifically exists so I can change all my weapon's categories,
	--without having to change them all manually.
	--Yes, I know there's better ways of doing this. IDNC.
end

--Custom Projectile Spawning Func
--Now updated to work for MANY projectiles at once.
function ArtiwepsProjectile( Entstring, Owner, Position, Angles, AimVec, Boost, Gravity )
	if CLIENT then return end
	local ent = ents.Create( Entstring )
	if ( not ent:IsValid() ) then return end

	ent:SetOwner( Owner )
	ent:SetPos( Position )
	if Angles ~= nil then ent:SetAngles( Angles ) end
	ent:Spawn()

	local entphys = ent:GetPhysicsObject()

	if ( not entphys:IsValid() ) then ent:Remove() return end
	entphys:EnableGravity( Gravity )

	if Boost > 0 then
		if Boost == nil then return end
		local Speed = Boost

		AimVec:Mul( Speed * entphys:GetMass() )
		entphys:ApplyForceCenter( AimVec )
	end
end