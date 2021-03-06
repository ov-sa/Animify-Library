  
----------------------------------------------------------------
--[[ Resource: Animify Library
     Script: utilities: client.lua
     Server: -
     Author: OvileAmriam
     Developer: -
     DOC: 08/09/2021 (OvileAmriam)
     Desc: Client Sided Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    ipairs = ipairs,
    loadstring = loadstring,
    isElement = isElement,
    getElementType = getElementType,
    addEventHandler = addEventHandler,
    removePedClothes = removePedClothes
}


-------------------
--[[ Variables ]]--
-------------------

imports.loadstring(exports.beautify_library:fetchImports())()


-----------------------------------
--[[ Function: Sets UI's Theme ]]--
-----------------------------------

function setUITheme(theme)

    if not theme then return false end

    for i, j in imports.pairs(availableTemplates) do
        beautify.setUITemplate(i, j["animify-dark-slver-theme"])
    end
    return true

end


-----------------------------------------
--[[ Function: Removes Ped's Clothes ]]--
-----------------------------------------

function removePedClothes(ped)

    if imports.isElement(ped) and (imports.getElementType(ped) == "ped") then
        for i = 0, 17 do
            imports.removePedClothes(ped, i)
        end
    end
    return false

end


-------------------------------------------------
--[[ Function: Selects/Deselects Core Option ]]--
-------------------------------------------------

function selectCoreOption(optionIndex, skipEnableBlock, resetEnabledStates)

    local result = false
    local isUIToBeEnabled = false
    if optionIndex == false then
        if coreUI.optionsUI.options.selectedOption then
            coreUI.optionsUI.options.selectedOption = false
            isUIToBeEnabled = true
            result = true
        end
    elseif optionIndex then
        if coreUI.optionsUI.options[optionIndex] and (coreUI.optionsUI.options.selectedOption ~= optionIndex) then
            coreUI.optionsUI.options.selectedOption = optionIndex
            if not skipEnableBlock then
                isUIToBeEnabled = true
            end
            result = true
        end
    else
        if resetEnabledStates then
            isUIToBeEnabled = true
            result = true
        end
    end
    if isUIToBeEnabled then
        for i, j in imports.pairs(coreUI.viewerUI.gridlists.typeReference) do
            beautify.setUIDisabled(j.createdElement, false)
        end
    end
    return result

end


--------------------------------------
--[[ Function: Updates Frame View ]]--
--------------------------------------

function updateFrameView(animIndex)

    beautify.gridlist.clearRows(coreUI.viewerUI.gridlists.typeReference[("view_frames")].createdElement)
    if animIndex then
        local animCache = getAnimCache(animIndex)
        for i, j in imports.ipairs(animCache["Frames"]) do
            local rowIndex = beautify.gridlist.addRow(coreUI.viewerUI.gridlists.typeReference["view_frames"].createdElement)
            beautify.gridlist.setRowData(coreUI.viewerUI.gridlists.typeReference["view_frames"].createdElement, rowIndex, 1, coreUI.viewerUI.gridlists.typeReference["view_frames"].prefix..i)
        end
    end
    return true

end