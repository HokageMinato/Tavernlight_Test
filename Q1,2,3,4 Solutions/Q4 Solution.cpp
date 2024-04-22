/* Q4 - Assume all method calls work fine. Fix the memory leak issue in below method */


//changed parameter name to ;recipientPlayerName' for better readibility.
void Game::addItemToPlayer(const std::string& recipientPlayerName, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipientPlayerName);
    bool playerInstantiated = false

    if (!player) 
    {
        //We create a new player 
        //when *player is set to nullptr by getPlayerName
        player = new Player(nullptr);
        playerInstantiated = true;
        //We then check if player has logged in and if he hasnt 
        // we return early but since 'new Player()' allocates on heap
        // we never free it !
        if (!IOLoginData::loadPlayerByName(player, recipientPlayerName)) 
        {
            //so before early returning we delete the allocated data 
            //from the player.
            delete player; //fix 1 for mem leak.
            return;
        }
    }   

    //In this 
    Item* item = Item::CreateItem(itemId);
    if (!item) 
    {
        //Same as before, 
        //Incase item creation fails we return early 
        //but never free the player if we created it.
        if(playerInstantiated)
            delete player; // fix 2 for mem leak
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) 
    {
        IOLoginData::savePlayer(player);
    }

    //Provided everything runs successfully and after utilising player object.
    //We free it, if we instantiated it !
    if(playerInstantiated)
        delete player; //fix 3 for mem leak.
}