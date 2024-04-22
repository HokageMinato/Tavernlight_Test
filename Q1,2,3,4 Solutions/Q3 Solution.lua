-- q3 - fix or improve the name and the implementation of the below method

-- We rename 'do_sth_with_playerparty' with 'removememberfromplayerpartybyname'.
-- We also rename 'membername' with 'nameofmembertoremove' for added clarity.
-- We return early if player is not associated with any party saving computation and errors.
-- We also discard the 'k' since we will not be using it anyway.
-- We ranem 'v' to partymembername.
-- @param playerid: Id of active player instance.
-- @param nameofmembertoremove:The name of the member to be removed from party of player with id 'playerid'
function removememberfromplayerpartybyname(playerid, nameofmembertoremove)
    
    local player = player(playerid)
    local party = player:getparty()

    if(party == nil) then
      print("player".. playerid .."is not in a party")
      return
    end


    for _,partymember in pairs(party:getmembers()) do
        local partymembertoremove_player = player(nameofmembertoremove)
        if partymember == partymembertoremove_player then
            party:removemember(partymembertoremove_player)
        end
    end

end