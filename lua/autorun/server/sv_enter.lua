
concommand.Add( "artiweps_anomaly", function( ply )
	if ply:HasWeapon("anomaly") then return end
	if not ply:Alive() then return end
	ply:PrintMessage(HUD_PRINTCONSOLE, "HELLO.")
	ply:Give("anomaly")
	ply:EmitSound( "other/hello.mp3", 75, 100, 0.3, 6 )
end)