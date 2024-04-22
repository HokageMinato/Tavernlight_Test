-- Q2 - Fix or improve the implementation of the below method

-- Previously an embedded statement, now converted to method.
-- @param result: The SQL Query result from the query.
local function printguildname(result)
    local guildname = result.getstring("name")
    print(guildname)
end

-- This method is supposed to print names of all guilds that have less than 'maxmembercount' members
-- Applied fix: Introduced an iterator so the rest of the names arent skipped.
-- Also added an early fail check for query.
-- @param maxmembercount: maximum number of members for query
function printSmallGuildNames(maxmembercount)

    local guildfilterquery_maxmembercount = "SELECT 'name' FROM 'guilds' WHERE 'max_members' <".. maxmembercount ..";"
    local queryresult_maxmembercount = db.storeQuery(guildfilterquery_maxmembercount)

    if(queryresult_maxmembercount == false) then
        print("sql error" .. queryresult_maxmembercount)
        return false
    end

    printguildname(result)

    while queryresult_maxmembercount.next(guildfilterquery_maxmembercount) do
        printguildname(result)
    end

    queryresult_maxmembercount.free(guildfilterquery_maxmembercount)

end
