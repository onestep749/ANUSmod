print("Works at beginning")
anus.Groups = {}

-- I don't recommend editing this file. If you feel the need to, please know what you're doing.
-- If you do, please only edit the below code:
--	But please do not remove any groups, or change the grouping numbers.
--	You may change the group names, but it's not recommended.

anus.Groups[999] = "Owner"
anus.Groups[800] = "Super Admin"
anus.Groups[600] = "Basic Admin"
anus.Groups[500] = "Temp Admin"
anus.Groups[300] = "Moderator"
anus.Groups[100] = "VIP"
anus.Groups[0] = "user"

-- End variables. I recommend you stop editing here and now.

function anus.GetGroups()
	return anus.Groups
end

function anus.GetGroupByName( name )
	for k,v in pairs(anus.Groups) do
		if string.lower(v) == string.lower(name) then
			return k
		end
	end
end

function anus.GetGroupByID( id )
	for k,v in pairs(anus.Groups) do
		if k == id then
			return v
		end
	end
end

function anus.GroupExists( group )
	if ( not group ) then return false end
	
	if type(group) == "string" then
		
		if ( not anus.GetGroups()[ anus.GetGroupByName( group ) ] ) then
			return false
		end
	
	else
		
		if ( not anus.GetGroups()[ group ] ) then
			return false
		end
		
	end
	return true
end
	
function anus.CanGroupAffect( group1, group2 )
	if ( not anus.GroupExists( group1 ) or not anus.GroupExists( group2 ) ) then return false end

	return group1 > group2
end

function _R.Player:GetUserGroup()
	return self:GetNWString("UserGroup")
end

if (SERVER) then

	hook.Add("PlayerAuthed", "qwertywutup", function( pl, steamid, uniqueid )
		if SinglePlayer() then
			pl:SetGroup( 999 )
		else
			-- We make a timer.Simple below so we don't get overrided by player_auth's
			timer.Simple(0.01, function() anus.SQL.LoadPlayer( pl ) end)
			timer.Create("update_my_Groupings_" .. steamid, 45, 0, function()
				anus.SQL.LoadPlayer( pl )
			end)
		end
	end)

		-- arg[2] is group Grouping. Any "Group" (example 999) higher than the level previous is immune to that.
		-- 999 is max.
		-- 0 is minimum.
	function anus.AddGroup( pl, cmd, arg )
		if (not arg[1] or not arg[2]) then pl:ChatPrint("Supply the right arguments!") return end
		if (tonumber(arg[2]) > 999 or tonumber(arg[2]) < 0) then pl:ChatPrint("You need to supply a correct Group number!") return end
		if anus.GetGroups()[tonumber(arg[2])] then pl:ChatPrint("You need to supply a different Grouping number!") return end
		
		if anus.GetGroupByName( arg[1] ) then
			pl:ChatPrint("You need to supply a non-existing name!")
			return
		else
			pl:ChatPrint("Alrighty, sounds good.\nJust wait until I get shit working.")
			anus.Groups[ tonumber(arg[2]) ] = arg[1]
		end
	end
	concommand.Add("anus_addgroup", anus.AddGroup)
	
	
	function _R.Player:SetGroup( group )
		if type(group) == "string" then
			
			self.UserGroup = anus.GetGroupByName( group )
			self:SetUserGroup( group )
			anus.SQL.Query("REPLACE INTO anus_players VALUES(" .. sql.SQLStr(self:SteamID()) .. ", " .. sql.SQLStr(group) .. ");")
			
		else
		
			self.UserGroup = group
			self:SetUserGroup( anus.GetGroupByID( group ) )
			anus.SQL.Query("REPLACE INTO anus_players VALUES(" .. sql.SQLStr(self:SteamID()) .. ", " .. sql.SQLStr(anus.GetGroupByID(group)) .. ");")
			
		end
	end
	
	function _R.Player:IsSuperAdmin()
		if ( self:IsUserGroup("superadmin") or self:IsUserGroup("Owner") or self.UserGroup == 999 ) then return true end
	end
	function _R.Player:IsAdmin( b_JustAdmin )
		if self:IsUserGroup("admin") then return true end
		if ( not b_JustAdmin ) then if self:IsSuperAdmin() then return true end end
	end
end

print("Shared file 'anus_groups.lua' initialized.")
