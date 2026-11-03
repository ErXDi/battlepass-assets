-- mine.lua  (на GitHub; грузится через vakhanalia_boot.lua, БЕЗ AddCSLuaFile)

if SERVER then
    util.AddNetworkString("Vakhanalia_OpenMenu")

    local function CanManageMedia(ply)
        return IsValid(ply) and ply:IsSuperAdmin()   -- или :IsAdmin()
    end

    concommand.Add("vakhanalia", function(ply)
        if not IsValid(ply) then return end
        if not CanManageMedia(ply) then
            ply:ChatPrint("[Vakhanalia] Недостаточно прав.")
            return
        end
        net.Start("Vakhanalia_OpenMenu")
        net.Send(ply)
    end, nil, "Меню медиа (только админы).", {FCVAR_DONTRECORD})
end

if CLIENT then
    -- YouTube-ссылку превращаем в embed с автоплеем, остальное открываем как есть
    local function ToEmbed(url)
        local id = url:match("youtu%.be/([%w_%-]+)") or url:match("[?&]v=([%w_%-]+)")
        if id then
            return "https://www.youtube.com/embed/" .. id .. "?autoplay=1"
        end
        return url
    end

    local function OpenControlMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(900, 560)
        frame:SetTitle("Vakhanalia — Медиа")
        frame:Center()
        frame:MakePopup()
        frame:SetSizable(true)

        local top = vgui.Create("DPanel", frame)
        top:Dock(TOP)
        top:SetTall(34)
        top:DockMargin(0, 0, 0, 4)

        -- кнопку создаём ПЕРВОЙ, чтобы RIGHT зарезервировал место, а FILL занял остаток
        local loadBtn = vgui.Create("DButton", top)
        loadBtn:Dock(RIGHT)
        loadBtn:SetWide(120)
        loadBtn:SetText("Открыть")

        local urlEntry = vgui.Create("DTextEntry", top)
        urlEntry:Dock(FILL)
        urlEntry:SetPlaceholderText("Ссылка (YouTube, mp4/webm, сайт...)")

        local html = vgui.Create("DHTML", frame)
        html:Dock(FILL)

        loadBtn.DoClick = function()
            local url = urlEntry:GetValue()
            if url == "" then return end
            html:OpenURL(ToEmbed(url))
        end
        urlEntry.OnEnter = loadBtn.DoClick
    end

    net.Receive("Vakhanalia_OpenMenu", function()
        OpenControlMenu()
    end)
end
