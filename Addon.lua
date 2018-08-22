--[[
Addon.lua
@Author  : DengSir (tdaddon@163.com)
@Link    : https://dengsir.github.io
]]


local _G              = _G
local IsModifiedClick = IsModifiedClick
local GameTooltip     = GameTooltip

local linktypes = {
    item         = true,
    enchant      = true,
    spell        = true,
    quest        = true,
    unit         = true,
    talent       = true,
    achievement  = true,
    glyph        = true,
    instancelock = true,
    currency     = true,
    keystone     = true,
}

local function OnHyperlinkEnter(frame, link)
    local linktype = link:match('^([^:]+)')
    if linktype and linktypes[linktype] then
        GameTooltip:SetOwner(frame, 'ANCHOR_TOPLEFT')
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end
end

local function UpdateTooltip(self)
    if not self.comparing and IsModifiedClick('COMPAREITEMS') then
        GameTooltip_ShowCompareItem(GameTooltip);
        self.comparing = true;
    elseif self.comparing and not IsModifiedClick('COMPAREITEMS') then
        for _, frame in pairs(GameTooltip.shoppingTooltips) do
            frame:Hide();
        end
        self.comparing = false;
    end
end

local function FCFOptionsDropDown_Initialize(dropdown, level)
    if not level or level == 1 then
        local chatFrame = FCF_GetCurrentChatFrame()
        local info = {}
        info.text = '清空聊天窗口'
        info.func = function() chatFrame:Clear() end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end
end

local hooked = {}

local function initChatFrame(frame)
    if not frame or hooked[frame] then
        return
    end
    local name = frame:GetName()
    if not name then
        return
    end

    frame:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)
    frame:SetScript('OnHyperlinkLeave', GameTooltip_Hide)
    frame.UpdateTooltip = UpdateTooltip

    local editbox = _G[name .. 'EditBox']
    if editbox then
        editbox:SetAltArrowKeyMode(false)
    end

    hooked[frame] = true
end

local function initDropdown(dropdown)
    if not dropdown or not dropdown.initialize or hooked[dropdown] then
        return
    end
    hooksecurefunc(dropdown, 'initialize', FCFOptionsDropDown_Initialize)
    hooked[dropdown] = true
end

for _, name in ipairs(CHAT_FRAMES) do
    initChatFrame(_G[name])
    initDropdown(_G[name .. 'TabDropDown'])
end

hooksecurefunc('FloatingChatFrame_OnLoad', initChatFrame)
hooksecurefunc('FCFOptionsDropDown_OnLoad', initDropdown)


---- FlashTab

local flashTabs = {
    'RAID',
    'PARTY',
    'GUILD',
    'OFFICER',
    'RAID_LEADER',
    'PARTY_LEADER',
}

for i, v in ipairs(flashTabs) do
    ChatTypeInfo[v].flashTab = true
end

CHAT_RAID_LEADER_GET = '|Hchannel:raid|h[团长]|h %s：\32'
