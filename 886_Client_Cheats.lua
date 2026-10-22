local playerSquaresEnabled = false
local aimbotEnabled = false
local autoBhopEnabled = false
local triggerbotEnabled = false
local entityTestModeEnabled = false

local triggerbotHeadOnly = false

local menuOpen = false
local lastMState = false

local AIM_FOV = 250
local cyan_color = Color(0, 255, 255, 180)
local orange_color = Color(255, 140, 0, 230)

--------------------------------------------------
-- MENU
--------------------------------------------------

local function OpenClientCheatsMenu()

    if IsValid(ClientCheatsMenu) then
        ClientCheatsMenu:Remove()
    end

    ClientCheatsMenu = vgui.Create("DFrame")
    ClientCheatsMenu:SetSize(360, 360)
    ClientCheatsMenu:Center()
    ClientCheatsMenu:SetTitle("886 Client Cheats")
    ClientCheatsMenu:MakePopup()

    ClientCheatsMenu.OnClose = function()
        menuOpen = false
        gui.EnableScreenClicker(false)
    end

    --------------------------------------------------
    -- PLAYER SQUARES
    --------------------------------------------------

    local playerSquaresCheckbox =
        vgui.Create("DCheckBoxLabel", ClientCheatsMenu)

    playerSquaresCheckbox:SetPos(25, 55)
    playerSquaresCheckbox:SetText("Enable WallHack")
    playerSquaresCheckbox:SetValue(playerSquaresEnabled)
    playerSquaresCheckbox:SizeToContents()

    playerSquaresCheckbox.OnChange = function(self, value)
        playerSquaresEnabled = value
    end

    --------------------------------------------------
    -- AIMBOT
    --------------------------------------------------

    local aimbotCheckbox =
        vgui.Create("DCheckBoxLabel", ClientCheatsMenu)

    aimbotCheckbox:SetPos(25, 85)
    aimbotCheckbox:SetText("Enable Aimbot")
    aimbotCheckbox:SetValue(aimbotEnabled)
    aimbotCheckbox:SizeToContents()

    aimbotCheckbox.OnChange = function(self, value)
        aimbotEnabled = value
    end

    --------------------------------------------------
    -- AUTO BHOP
    --------------------------------------------------

    local bhopCheckbox =
        vgui.Create("DCheckBoxLabel", ClientCheatsMenu)

    bhopCheckbox:SetPos(25, 115)
    bhopCheckbox:SetText("Enable Auto Bhop")
    bhopCheckbox:SetValue(autoBhopEnabled)
    bhopCheckbox:SizeToContents()

    bhopCheckbox.OnChange = function(self, value)
        autoBhopEnabled = value
    end

    --------------------------------------------------
    -- TRIGGERBOT
    --------------------------------------------------

    local triggerbotCheckbox =
        vgui.Create("DCheckBoxLabel", ClientCheatsMenu)

    triggerbotCheckbox:SetPos(25, 145)
    triggerbotCheckbox:SetText("Enable Triggerbot")
    triggerbotCheckbox:SetValue(triggerbotEnabled)
    triggerbotCheckbox:SizeToContents()

    --------------------------------------------------
    -- TRIGGERBOT OPTIONS
    --------------------------------------------------

    local triggerbotLabel =
        vgui.Create("DLabel", ClientCheatsMenu)

    triggerbotLabel:SetPos(25, 175)
    triggerbotLabel:SetText("Triggerbot Target:")
    triggerbotLabel:SizeToContents()

    local triggerbotMode =
        vgui.Create("DComboBox", ClientCheatsMenu)

    triggerbotMode:SetPos(25, 195)
    triggerbotMode:SetSize(270, 25)

    triggerbotMode:AddChoice("Whole Body")
    triggerbotMode:AddChoice("Head Only")

    if triggerbotHeadOnly then
        triggerbotMode:SetValue("Head Only")
    else
        triggerbotMode:SetValue("Whole Body")
    end

    triggerbotMode:SetEnabled(triggerbotEnabled)

    triggerbotCheckbox.OnChange = function(self, value)
        triggerbotEnabled = value
        triggerbotMode:SetEnabled(value)
    end

    triggerbotMode.OnSelect = function(self, index, value)
        if value == "Head Only" then
            triggerbotHeadOnly = true
        else
            triggerbotHeadOnly = false
        end
    end

    --------------------------------------------------
    -- ENTITY TEST MODE
    --------------------------------------------------

    local testModeCheckbox =
        vgui.Create("DCheckBoxLabel", ClientCheatsMenu)

    testModeCheckbox:SetPos(25, 230)
    testModeCheckbox:SetText("Entity Test Mode (NPCs / NextBots)")
    testModeCheckbox:SetValue(entityTestModeEnabled)
    testModeCheckbox:SizeToContents()

    testModeCheckbox.OnChange = function(self, value)
        entityTestModeEnabled = value
    end

    local testModeInfo =
        vgui.Create("DLabel", ClientCheatsMenu)

    testModeInfo:SetPos(25, 252)
    testModeInfo:SetSize(300, 35)
    testModeInfo:SetText("When enabled, the aimbot test target is\nNPCs / NextBots instead of players.")
    testModeInfo:SetTextColor(Color(180, 180, 180))

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local closeButton =
        vgui.Create("DButton", ClientCheatsMenu)

    closeButton:SetPos(25, 300)
    closeButton:SetSize(270, 35)
    closeButton:SetText("Close")

    closeButton.DoClick = function()
        ClientCheatsMenu:Close()
    end
end

--------------------------------------------------
-- M = OPEN / CLOSE
--------------------------------------------------

hook.Add("Think", "886ClientCheatsMenuToggle", function()

    local mDown = input.IsKeyDown(KEY_M)

    if mDown and not lastMState then

        if menuOpen then

            if IsValid(ClientCheatsMenu) then
                ClientCheatsMenu:Close()
            end

        else

            menuOpen = true
            OpenClientCheatsMenu()
            gui.EnableScreenClicker(true)

        end
    end

    lastMState = mDown
end)

--------------------------------------------------
-- WALLHACK MARKERS + LIVE DISTANCE
--------------------------------------------------

-- Source units are inches; convert to meters for the HUD label.
local SOURCE_UNITS_PER_METER = 39.3701

local function DrawTargetMarker(ent, markerPos)
    if not IsValid(ent) then return end

    -- Hide marker when a player dies
    if ent:IsPlayer() and not ent:Alive() then
        return
    end

    -- Hide marker when an NPC / NextBot dies
    if (ent:IsNPC() or ent:IsNextBot())
        and ent:Health() <= 0 then
        return
    end

    local pos = markerPos:ToScreen()
    if not pos.visible then return end

    local x, y = pos.x, pos.y
    local outerSize = 18
    local innerSize = 9
    local thick = 3

    -- Outer cyan diamond (clean, thin lines)
    surface.SetDrawColor(cyan_color)

    surface.DrawLine(x, y - outerSize, x + outerSize, y)
    surface.DrawLine(x + outerSize, y, x, y + outerSize)
    surface.DrawLine(x, y + outerSize, x - outerSize, y)
    surface.DrawLine(x - outerSize, y, x, y - outerSize)

    -- Smaller orange diamond inside the cyan one
    surface.SetDrawColor(orange_color)
    surface.DrawLine(x, y - innerSize, x + innerSize, y)
    surface.DrawLine(x + innerSize, y, x, y + innerSize)
    surface.DrawLine(x, y + innerSize, x - innerSize, y)
    surface.DrawLine(x - innerSize, y, x, y - innerSize)

    -- Live distance from the local player's position, displayed below marker
    local lp = LocalPlayer()
    if IsValid(lp) then
        local meters = lp:GetPos():Distance(ent:GetPos()) / SOURCE_UNITS_PER_METER
        draw.SimpleText(
            string.format("%.1f m", meters),
            "DermaDefaultBold",
            x, y + outerSize + 7,
            Color(0, 255, 255, 240),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
    end
end

hook.Add("HUDPaint", "886ClientCheatsPlayerSquares", function()
    if not playerSquaresEnabled then return end

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply ~= LocalPlayer() and ply:Alive() then
            DrawTargetMarker(ply, ply:GetPos() + Vector(0, 0, 40))
        end
    end
end)

--------------------------------------------------
-- AIMBOT FOV CIRCLE
--------------------------------------------------

hook.Add("HUDPaint", "886ClientCheatsAimbotCircle", function()

    if not aimbotEnabled then return end

    local x = ScrW() / 2
    local y = ScrH() / 2

    -- Outer cyan circle
    surface.SetDrawColor(cyan_color)
    surface.DrawCircle(
        x, y,
        AIM_FOV,
        cyan_color
    )
    
    -- Inner orange circle (visual only)
    surface.SetDrawColor(orange_color)

    surface.DrawCircle(
        x, y,
        AIM_FOV - 6,
        orange_color
    )
end)

--------------------------------------------------
-- ENTITY TEST TARGET VISUALS
--------------------------------------------------

hook.Add("HUDPaint", "886ClientCheatsEntityTestVisuals", function()
    if not playerSquaresEnabled then return end
    if not entityTestModeEnabled then return end

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) then
            DrawTargetMarker(ent, ent:GetPos() + Vector(0, 0, 40))
        end
    end
end)

--------------------------------------------------
-- AIMBOT + AUTO BHOP + TRIGGERBOT
--------------------------------------------------

hook.Add("CreateMove", "886ClientCheatsCreateMove", function(cmd)

    local localPlayer = LocalPlayer()

    if not IsValid(localPlayer) then
        return
    end

    --------------------------------------------------
    -- AUTO BHOP
    --------------------------------------------------

    if autoBhopEnabled
        and localPlayer:GetMoveType() ~= MOVETYPE_NOCLIP
        and input.IsKeyDown(KEY_SPACE) then

        if localPlayer:IsOnGround() then

            cmd:SetButtons(
                bit.bor(
                    cmd:GetButtons(),
                    IN_JUMP
                )
            )

        else

            cmd:SetButtons(
                bit.band(
                    cmd:GetButtons(),
                    bit.bnot(IN_JUMP)
                )
            )
        end
    end

    --------------------------------------------------
    -- TRIGGERBOT
    --------------------------------------------------

    if triggerbotEnabled then

        local startPos = localPlayer:EyePos()
        local direction = localPlayer:EyeAngles():Forward()

        local traceData = {
            start = startPos,
            endpos = startPos + direction * 10000,
            filter = localPlayer,
            mask = MASK_SHOT
        }

        local tr = util.TraceLine(traceData)
        local target = tr.Entity

        local validTarget = false

        if IsValid(target) and target ~= localPlayer then
            if entityTestModeEnabled then
                validTarget = (target:IsPlayer() and target:Alive()) or
                    ((target:IsNPC() or target:IsNextBot()) and target:Health() > 0)
            else
                validTarget = target:IsPlayer() and target:Alive()
            end
        end

        if validTarget then
            local canShoot = true

            if triggerbotHeadOnly then

                if tr.HitGroup ~= HITGROUP_HEAD then
                    canShoot = false
                end
            end

            if canShoot then

                cmd:SetButtons(
                    bit.bor(
                        cmd:GetButtons(),
                        IN_ATTACK
                    )
                )
            end
        end
    end

    --------------------------------------------------
    -- AIMBOT
    --------------------------------------------------

    if not aimbotEnabled then
        return
    end

    if not input.IsMouseDown(MOUSE_LEFT)
        and not input.IsMouseDown(MOUSE_RIGHT) then
        return
    end

    local centerX = ScrW() / 2
    local centerY = ScrH() / 2

    local bestTarget = nil
    local bestDistance = AIM_FOV
    local bestAimPos = nil

    --------------------------------------------------
    -- ENTITY TEST MODE
    -- Only NPCs / NextBots are considered here.
    --------------------------------------------------

    if entityTestModeEnabled then

        for _, ent in ipairs(ents.GetAll()) do

            if not IsValid(ent) then continue end
            --if not ent:IsNPC() and not ent:IsNextBot() then continue end

            if ent == localPlayer then continue end

            local isTargetValid = false
            if ent:IsPlayer() then
                isTargetValid = ent:Alive() and ent:Health() > 0
            elseif ent:IsNPC() or ent:IsNextBot() then
                isTargetValid = ent:Health() > 0
            end

            if not isTargetValid then continue end

            local aimPos = nil

            local bone = ent:LookupBone("ValveBiped.Bip01_Head1")

            if bone then
                aimPos = ent:GetBonePosition(bone)
            end

            if not aimPos then
                aimPos = ent:WorldSpaceCenter()
            end

            if not aimPos then continue end

            local screenPos = aimPos:ToScreen()

            if not screenPos.visible then continue end

            local dx = screenPos.x - centerX
            local dy = screenPos.y - centerY

            local distance =
                math.sqrt(dx * dx + dy * dy)

            if distance < bestDistance then

                bestDistance = distance
                bestTarget = ent
                bestAimPos = aimPos

            end
        end

    --------------------------------------------------
    -- NORMAL PLAYER MODE
    --------------------------------------------------

    else

        for _, ply in ipairs(player.GetAll()) do

            if not IsValid(ply) then continue end
            if ply == localPlayer then continue end
            if not ply:Alive() then continue end
            if ply:Health() <= 0 then continue end
            
            local bone =
                ply:LookupBone("ValveBiped.Bip01_Head1")

            if not bone then continue end

            local headPos = ply:GetBonePosition(bone)

            if not headPos then continue end

            local screenPos = headPos:ToScreen()

            if not screenPos.visible then continue end

            local dx = screenPos.x - centerX
            local dy = screenPos.y - centerY

            local distance =
                math.sqrt(dx * dx + dy * dy)

            if distance < bestDistance then

                bestDistance = distance
                bestTarget = ply
                bestAimPos = headPos

            end
        end
    end

    --------------------------------------------------
    -- AIM AT SELECTED TARGET
    --------------------------------------------------

    if IsValid(bestTarget) and bestAimPos then

        local aimAngle =
            (bestAimPos - localPlayer:EyePos()):Angle()

        cmd:SetViewAngles(aimAngle)
    end
end)
