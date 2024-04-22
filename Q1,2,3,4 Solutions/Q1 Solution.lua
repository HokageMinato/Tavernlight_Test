-- [Q1] - Fix or improve the implementation of the below methods

-- Global variables for storage keys and state values to avoid magic numbers and improve readability.
playerStorageKeyX = 1000  -- Key for player's storage related to login status.
local loggedInState = 1   -- Represents the state of a logged-in player.
local loggedOutState = -1 -- Represents the state of a logged-out player.

-- Releases the player's storage by setting it to a logged-out state.
-- @param storageKey: The storage key to update.
-- @param player: Reference to the player table.
local function releaseStorage(storageKey, player)
    player:setStorageValue(storageKey, loggedOutState)
end

-- Reads the current storage value for the specified storage key of a player.
-- @param storageKey: The storage key to read.
-- @param player: Reference to the player table.
-- @return: Returns the current storage value.
local function readPlayerStorage(storageKey, player)
    return player:getStorageValue(storageKey)
end

-- Handles player logout process, ensuring storage values are updated synchronously.
-- Previously, an asynchronous call (addEvent) was used which introduced a delay of 1 second.
-- This function directly invokes releaseStorage to eliminate the delay and ensure the logout is executed synchronously.
-- @param player: Reference to the player table.
-- @return: Returns true if the storage was successfully set to the loggedOutState, otherwise false.
function onLogout(player)
    if readPlayerStorage(playerLoginStatusKey, player) == loggedInState then
        releaseStorage(playerLoginStatusKey, player)
    end
    return readPlayerStorage(playerLoginStatusKey, player) == loggedOutState
end

