
-- WINDOW VARS
sbwindow = nil
jumpButton = nil
isViewVisible = false
windowBoundryWidth = 7

-- BUTTON VARS
buttonXMax = 120
buttonMoveInvokeFrequency = 90  -- our custom move loop frequency
buttonHorizontalMoveStep = 5    -- step value in terms of 'pixels' to skip per run
buttonYMin = 50                 -- minimum threshold W.r.t window top to skip button shooting upwards
buttonYMax = 144                -- maximum threshold W.r.t window top to skip button shooting downwards



-- -------- [WINDOW LIFECYCLE MANAGMENT] -----------------------------------------------------------------------------------------------
-- We design both modules such that when a module is reloaded
-- we dont have to worry about anything breaking.
-- Callback when module is loaded
function onModuleLoaded() 
    importScrollingButtonStyle()
    createWindowToggleButtonInMenuBar()
end

-- Callback when module is unloaded
function onModuleUnloaded()
    if sbwindow then
        closeWindow()
    end
end

function importScrollingButtonStyle()
    g_ui.importStyle('client_scrollingbuttonwindow')   
end

function createWindowToggleButtonInMenuBar()
    return modules.client_topmenu.addLeftGameButton('scrollingwindowtogglebutton', tr('Button Scroll Window'), '/images/topbuttons/scrollbuttonwindowtoggle', openWindow)
end
--------------------------------------------------------------------------------------------------------------------------------------



-- -------- [WINDOW VIEWCYCLE MANAGMENT] -----------------------------------------------------------------------------------------------
-- Callback to open the window. 
-- We bind it to jump button in otui. 
-- This is designed to sepearate the UI from module load/unload and allows us to freely close it.
-- Though atm we design with single instance philosophy
-- Also we track the window visibility status seperatly to prevent loop from executing when window is closed.
function openWindow()

    if sbwindow then
        return
    end

    sbwindow = g_ui.createWidget('ScrollingButtonWindow', rootWidget)
    jumpButton = sbwindow:getChildById('jumpButton')
    setWindowVisibilityStatus(true)
    scheduleButtonMoveForNextFrame()
end

-- We destroy the resources we acquired.
-- We also cleanup the scheduler to prevent needless execution
-- Lastly we destroy the window itself
function closeWindow()
    setWindowVisibilityStatus(false)
    destroyJumpButton()
    cleanupJumpButtonLoopScheduler()
    sbwindow:destroy()
    sbwindow = nil
end


-- Basic visibility trakcing
function setWindowVisibilityStatus(isVisible)
    isViewVisible = isVisible
end

-- Destroy jump button element
function destroyJumpButton()
    if(jumpButton) then
        jumpButton:destroy()
        jumpButton = nil
    end
end
--------------------------------------------------------------------------------------------------------------------------------------


-- -------- [BUTTON BEHAVIOUR] -----------------------------------------------------------------------------------------------

--Cleanup scheduler
function cleanupJumpButtonLoopScheduler()
    if jumpButtonLoopEvent then
        removeEvent(jumpButtonLoopEvent)
        jumpButtonLoopEvent = nil
    end
end

-- Callback Bound in OTUI
function onJumpButtonClicked()
    jumpButton:setPosition(getButtonStartingPosition(sbwindow:getPosition(),jumpButton:getPosition()))
end

-- The core of our movement,
-- We schedule the button movement for next frame.
-- Upon finishing movement for this frame, We again schedule it in our moveButton.
-- This effectively makes us an updateLoop unreliant on any other stuff.
-- [NOTE] Initially I was thinking of using onFPS callback from g_game but invocation was very infrequent.
--        I searched forums for callbacks but couldnt find any better.
--        If there is a better callback where we can simply attach movebutton it'd be best !
function scheduleButtonMoveForNextFrame()
    jumpButtonLoopEvent = scheduleEvent(moveButton, buttonMoveInvokeFrequency)
end

-- The core method to move our button.
-- Though I have not accounted for resize, but can be done easily.
-- We get positions for our scroll window and button ((x,y) w.r.t otclient window) 
-- We detect if we reached boundary by calculating difference in (x) and move if boundary is not crossed.
-- When we hit boundary we reset the position, Which is again used when we click the button.
-- When resetting or detecting boundary we account for borderWidth via a local value (if some property is there it'd be great but couldnt find any !)
function moveButton()

    if isViewVisible == false then
        return
    end

    posWindow = sbwindow:getPosition()
    posJumpButton = jumpButton:getPosition()
    
    xDiffFromWindow = posJumpButton["x"] - posWindow["x"]
    
    if xDiffFromWindow < windowBoundryWidth then
       posJumpButton = getButtonStartingPosition(posWindow,posJumpButton)
    else
        posJumpButton["x"] = calculateJumpButtonNextPosition(posWindow,posJumpButton)
    end

    jumpButton:setPosition(posJumpButton)
    scheduleButtonMoveForNextFrame()

end


-- Stepper function to calculate next position for our button.
-- Designed for reuse to avoid complexities and easier understanding
function calculateJumpButtonNextPosition(posWindow,posJumpButton)
    return posJumpButton["x"] - buttonHorizontalMoveStep
end

-- Reset function to calculate next 'starting position';' for our button.
-- Designed for reuse to avoid complexities and easier understanding
function getButtonStartingPosition(posWindow,posJumpButton)
    posJumpButton["x"] = posWindow["x"] + (buttonXMax - windowBoundryWidth) 
    posJumpButton["y"] = posWindow["y"] + math.random(buttonYMin,buttonYMax)
    return posJumpButton
end

--------------------------------------------------------------------------------------------------------------------------------------

