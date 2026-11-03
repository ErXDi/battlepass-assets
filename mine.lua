if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("Vakhanalia_OpenMenu")

    print("[Vakhanalia] SERVER загружен")

    local function CanManageMedia(ply)
        if not IsValid(ply) then return false end
        return ply:IsSuperAdmin()
    end

    concommand.Add("vakhanalia", function(ply)
        if not IsValid(ply) then return end
        print("[Vakhanalia] команда вызвана игроком: " .. ply:Nick() ..
              " | IsSuperAdmin=" .. tostring(ply:IsSuperAdmin()) ..
              " | IsAdmin=" .. tostring(ply:IsAdmin()))
        if not CanManageMedia(ply) then
            ply:ChatPrint("[Vakhanalia] Недостаточно прав.")
            return
        end
        print("[Vakhanalia] отправляю net игроку " .. ply:Nick())
        net.Start("Vakhanalia_OpenMenu")
        net.Send(ply)
    end, nil, "Меню медиа (только админы).", {FCVAR_DONTRECORD})
end

if CLIENT then
    print("[Vakhanalia] CLIENT загружен")

    local function OpenControlMenu()
        print("[Vakhanalia] OpenControlMenu вызван")
        local frame = vgui.Create("DFrame")
        frame:SetSize(520, 160)
        frame:SetTitle("Vakhanalia — Открыть медиа")
        frame:MakePopup()
        frame:Center()

        local urlEntry = vgui.Create("DTextEntry", frame)
        urlEntry:SetPos(20, 40)
        urlEntry:SetSize(480, 28)
        urlEntry:SetPlaceholderText("Ссылка (YouTube, mp4/webm...)")

        local showBtn = vgui.Create("DButton", frame)
        showBtn:SetPos(20, 80)
        showBtn:SetSize(480, 36)
        showBtn:SetText("Открыть в браузере")
        showBtn.DoClick = function()
            local url = urlEntry:GetValue()
            if url == "" then return end
            gui.OpenURL(url)
        end
    end

    net.Receive("Vakhanalia_OpenMenu", function()
        print("[Vakhanalia] net получен")
        OpenControlMenu()
    end)
end
