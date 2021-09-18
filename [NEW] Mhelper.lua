--[[
	
	/* TODO:
	
	1. Сделать проверку по серийнику жесткого диска. Получать из github gist с серийниками одобренных
	дисков. Выводить серийник как логин и пароль придумать (всё это в gist). Потом чекать равен ли логин серий-
	ному номеру. Выводить возможный логин на экран, при авторизации в аккаунт скрипта. 
	
	Как добавлять серийник в gist? - Возможно отправлять post запрос в ВК с серийниками и никами тех, чей серийник
	не нашли в gist. 
	
	При первой авторизации сохранять данные в ini. (Последующая авторизация не потребуется)
	
	2. Допилить IP инфо (Чекер регов). [+]

	10. Авто-апдейт сделать
	
	11. /gmuse при авторизации
	
	5. Отправка бага через post запрос ВК/Telegram.
	
	6. Добавить пару читов (WH, GM от взрывов/падений)
	
	7. Добавить авто-принятие форм (как в старом) и просто ручное :)
	
	8. Изменение цвета вип чата (хуком). 
	
	9. Поспать.
	
	
	
	3. Сделать зло-ебучую двойную тему через "imgui.PushStyleColor(Что изменить, цвет в ImVec4)". [-]
	4. Сделать диалог между пользователем и мной в скрипте. Я через ВК. Попробывать, хз как (маленький приоритет).
	12. Вычесление флуда.
	
	
	*/
]]


-----------[[[[    ЗАВИСИМОСТИ    ]]]]-----------
    local imgui = require 'imgui'
    local inicfg = require 'inicfg'
    local vkeys = require 'vkeys'
    local effil = require "effil"
    local cjson = require "cjson"
    local sampev = require 'lib.samp.events'
    local mem = require "memory"
    local fa = require 'faIcons'
    local ffi = require "ffi"
    local encoding = require "encoding" --К переменным
    require 'lib.sampfuncs'
    require 'lib.moonloader'
    local Matrix3X3 = require "matrix3x3"
    local Vector3D = require "vector3d"
    local render = require 'lib.render'
    imgui.ToggleButton = require('imgui_addons').ToggleButton
    encoding.default = 'CP1251'
    u8 = encoding.UTF8 
	script_name('MHelper')
	script_version('1.0')

-----------[[[[    ПЕРЕМЕННЫЕ    ]]]]-----------
    local main_window_state = imgui.ImBool(false)
    local recon_menu = imgui.ImBool(false)
    local az = imgui.ImBool(false)
	local add_zone = imgui.ImBool(false)
	local report = imgui.ImBool(false)
	local gps_help = imgui.ImBool(false)
	local check_ip = imgui.ImBool(false)
	local check_script = imgui.ImBool(false)
    local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
    local tSelButtons = { "Основное", "Связь с разработчиком", "Информация" }
    local sWindows = tSelButtons[1]
    local font1 = renderCreateFont("Tahoma", 13, 8)
    local selectable = 0
    local player_spec = ''
    local veh_spec = ''
    local keyToggle = VK_MBUTTON
    local keyApply = VK_LBUTTON
    local step_auth = 0
	local report_id = ''
    local filter = ""
	local name_report_adv = ''
	local id_report_adv = ''
	local text_report_adv = ''
	local nick_report = ''
	local question_report = ''
	local recon_text = ''
	local id_dialog_report = ''
	local ip_info = ''
	local distances = ''
	local ping_sp = ''
	local hp_sp = '' 
	local arm_sp = '' 
	local version_sp = '' 
	local ip_sp = ''
	local serial = ''
	local password_script_from_json = ''
	local is_auth = false
	local is_script_auth = false
	local rdata = {}
	

    ---------- [[[[ INI CFG ]]]] ------------
        local main_config = {
            amenu_config = {
                password_acc = '',
                password_adm = '',
                autologin_acc = false,
                autologin_adm = false,
                clickwarp = false,
                emenu = false,
                admin_lvl = 1,
                auth_inter = 0,
                auth_ld = 0,
				password_of_script = ''
            }
        }
		
		local adm_zone = {
			az = {
                ["AZ #1"] = "2570,-1281,1065, INT: 2",
		        ["AZ #2"] = "1221, 8, 1001, INT: 2"
            }
		}
		local all = {
			vazhnoe = {},
			raboti = {},
			gosski = {},
			nelegal = {},
			avto = {},
			prochee = {},
			poisk = {}
		}
	local gps_cfg = inicfg.load(all, 'MHelper\\GPS\\GPS.ini')
    local main_cfg = inicfg.load(main_config, "MHelper\\Config\\main_config.ini")
	local admin_zone = inicfg.load(adm_zone, "MHelper\\Config\\admin_zones.ini")
    local auto_auth = imgui.ImBool(main_config.amenu_config.autologin_acc)
    local auto_auth_adm = imgui.ImBool(main_config.amenu_config.autologin_adm)
    local clickwarp = imgui.ImBool(main_config.amenu_config.clickwarp)
    local emenu = imgui.ImBool(main_config.amenu_config.emenu)
    local password_acc = imgui.ImBuffer(256)
	local answer = imgui.ImBuffer(256)
	local Xinput = imgui.ImBuffer(256)
	local Yinput = imgui.ImBuffer(256)
	local Zinput = imgui.ImBuffer(256)
	local intInput = imgui.ImBuffer(256)
	local nameint = imgui.ImBuffer(256)
	local login_script = imgui.ImBuffer(256)
	local password_script = imgui.ImBuffer(256)
	local ip_info = imgui.ImBuffer(512)
    local admin_lvl = imgui.ImInt(1)
    local auth_skin = imgui.ImInt(0)
    local auth_inter = imgui.ImInt(0)
    local auth_ld = imgui.ImInt(0)
	local dialog_status = false
    local password_adm = imgui.ImBuffer(256)
    password_adm.v = main_config.amenu_config.password_adm
    admin_lvl.v = main_config.amenu_config.admin_lvl
    password_acc.v = main_config.amenu_config.password_acc
    auth_skin.v = main_config.amenu_config.auth_skin
    auth_inter.v = main_config.amenu_config.auth_inter
    auth_ld.v = main_config.amenu_config.auth_ld

-----------[[[[    ФУНКЦИИ    ]]]]-----------
    function main()
        while not isSampAvailable() do wait(50) end
        initializeRender()
        if not isSampfuncsLoaded() or not isSampLoaded() then
            return
        end

        if not doesDirectoryExist('moonloader\\config\\MHelper') then
            createDirectory('moonloader\\config\\MHelper') -- [[ Создаем директорию скрипта ]] 
            createDirectory('moonloader\\config\\MHelper\\GPS') -- [[ Создаем директорию скрипта ]] 
            createDirectory('moonloader\\config\\MHelper\\Icons') -- [[ Создаем директорию скрипта ]] 
            createDirectory('moonloader\\config\\MHelper\\Config') -- [[ Создаем директорию скрипта ]]
            inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini') 
        end
		autoupdate()
		check_account()

        ---------[[[[ КОМАНДЫ ]]]]---------
            sampRegisterChatCommand('amenu', function()
			if is_script_auth then
				main_window_state.v = not main_window_state.v
				imgui.Process = main_window_state.v
			end
            end)
            sampRegisterChatCommand('az', function()
               if is_script_auth then
				az.v = not az.v
                imgui.Process = az.v
				end
                end)
			
			sampRegisterChatCommand('checkip', function(arg)
			if is_script_auth then
				chip(arg)
			end
			end)
			
			sampRegisterChatCommand('login', function(arg)
			if not is_script_auth then
				check_account()
			else
				info_msg('Вы уже авторизованы!')
			end
			end)
			sampRegisterChatCommand('mypos', function()
				local x, y, z = getCharCoordinates(playerPed)
				local interior = getCharActiveInterior(playerPed)
				info_msg('X: {EE82EE}' .. x .. '{1E90FF} Y: {EE82EE}' .. y .. '{1E90FF} Z: {EE82EE}' .. z)
				info_msg('Interior: {EE82EE}' .. interior)
			end)
        if not doesFileExist(getWorkingDirectory() .. '\\config\\MHelper\\GPS\\GPS.ini') then
            print('Отсутствует INI-файл (файл с настройками). Уже качаю :)')
            downloadUrlToFile('https://raw.githubusercontent.com/M0rtelli/STools/main/config/GPS.ini', getWorkingDirectory() .. '/config/MHelper/GPS/GPS.ini')
        end
        while true do

            -- E-menu
                if wasKeyPressed(69) and main_config.amenu_config.emenu and not sampIsChatInputActive() and not sampIsDialogActive() and is_script_auth then
                    while isKeyDown(69) do
                        wait(0)
                        sampToggleCursor(1)
                        for id = 0, sampGetMaxPlayerId(true) do
                            if sampIsPlayerConnected(id) then
                            local exists, handle = sampGetCharHandleBySampPlayerId(id)
                                if exists and isCharOnScreen(handle) then
                                    plX, plY, plZ = getBodyPartCoordinates(8, handle)
                                    local plsX, plsY = convert3DCoordsToScreen(plX, plY, plZ)
                                    local nickz = sampGetPlayerNickname(id)
                                    local ex = string.format(nickz .. '[' .. id .. ']')
                                    if drawClickableText(font1, ex, plsX + 25, plsY - 20, 0xFF00FF7F, 0xFFFF0000) then
                                        sampSendChat('/stats ' .. id)
                                    end
                                    if drawClickableText(font1, "/sp", plsX + 25, plsY, 0xFFFFFFFF, 0xFFFF0000) then
                                        sampSendChat('/sp ' .. id)
                                    end
                                    if drawClickableText(font1, "Kick", plsX + 25, plsY + 20, 0xFFFFFFFF, 0xFFFF0000) then
                                        sampSetChatInputEnabled(true)
				                        sampSetChatInputText('/kick ' .. id .. ' ')
                                    end
                                    if drawClickableText(font1, "Slap UP", plsX + 25, plsY + 40, 0xFFFFFFFF, 0xFFFF0000) then
                                        sampSendChat('/slap ' .. id)
                                    end
                                    if drawClickableText(font1, "ТП к себе", plsX + 25, plsY + 60, 0xFFFFFFFF, 0xFFFF0000) then
                                        sampSendChat('/gh ' .. id)
                                    end
                                    if drawClickableText(font1, "ТП к нему", plsX + 25, plsY + 80, 0xFFFFFFFF, 0xFFFF0000) then
                                        sampSendChat('/go ' .. id)
                                    end
                                end
                            end
                        end
                    end
                    if wasKeyReleased(69) then sampSetCursorMode(0) end
                end
            -- CLICK WARP

                while isPauseMenuActive() do
                if cursorEnabled then
                    showCursor(false)
                end
                wait(0)
                end
            
                if isKeyJustPressed(keyToggle) and main_config.amenu_config.clickwarp and is_script_auth then
                cursorEnabled = not cursorEnabled
                showCursor(true)
                while isKeyDown(keyToggle) do wait(0) end
                end
            
                if cursorEnabled then
                    if imgui.Process == false then
                local mode = sampGetCursorMode()
                if mode == 0 then
                    showCursor(true)
                end
                local sx, sy = getCursorPos()
                local sw, sh = getScreenResolution()
                -- is cursor in game window bounds?
                if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                    local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                    local camX, camY, camZ = getActiveCameraCoordinates()
                    -- search for the collision point
                    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
                    if result and colpoint.entity ~= 0 then
                    local normal = colpoint.normal
                    local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                    local zOffset = 300
                    if normal[3] >= 0.5 then zOffset = 1 end
                    -- search for the ground position vertically down
                    local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                        true, true, false, true, false, false, false)
                    if result then
                        pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
            
                        local curX, curY, curZ  = getCharCoordinates(playerPed)
                        local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                        local hoffs             = renderGetFontDrawHeight(font)
            
                        sy = sy - 2
                        sx = sx - 2
                        renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)
            
                        local tpIntoCar = nil
                        if colpoint.entityType == 2 then
                        local car = getVehiclePointerHandle(colpoint.entity)
                        if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                            displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                            local color = 0xAAFFFFFF
                            if isKeyDown(VK_RBUTTON) then
                            tpIntoCar = car
                            color = 0xFFFFFFFF
                            end
                            renderFontDrawText(font2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                        end
                        end
            
                        createPointMarker(pos.x, pos.y, pos.z)
            
                        -- teleport!
                        if isKeyDown(keyApply) then
                        if tpIntoCar then
                            if not jumpIntoCar(tpIntoCar) then
                            -- teleport to the car if there is no free seats
                            teleportPlayer(pos.x, pos.y, pos.z)
                            end
                        else
                            if isCharInAnyCar(playerPed) then
                            local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                            local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                            rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                            pos = pos - norm * 1.8
                            pos.z = pos.z - 0.8
                            end
                            teleportPlayer(pos.x, pos.y, pos.z)
                        end
                        removePointMarker()
            
                        while isKeyDown(keyApply) do wait(0) end
                        showCursor(false)
                        end
                    end
                    end
                end
                end
                end
				wait(0)
                removePointMarker()
				
                if isKeyJustPressed(VK_6) and not sampIsChatInputActive() and not sampIsDialogActive() and is_script_auth then
					imgui.ShowCursor = not imgui.ShowCursor
					showCursor(imgui.ShowCursor)
					end
				
				if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() and is_script_auth then
					sampSetChatInputEnabled(true)
					sampSetChatInputText('/mute ' .. id_report_adv .. ' 120 упом родни')
                end
				
				if isKeyJustPressed(52) and not sampIsChatInputActive() then
					dialog_status = not sampIsDialogActive()
                    enableDialog(not sampIsDialogActive())
                end
				
            end
    end
	
	function check_account()
		local ffi = require("ffi")
		ffi.cdef[[
		int __stdcall GetVolumeInformationA(
			const char* lpRootPathName,
			char* lpVolumeNameBuffer,
			uint32_t nVolumeNameSize,
			uint32_t* lpVolumeSerialNumber,
			uint32_t* lpMaximumComponentLength,
			uint32_t* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			uint32_t nFileSystemNameSize
		);
		]]
		serial = ffi.new("unsigned long[1]", 0)
		ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
		serial = tostring(serial[0])
		login_script.v = tostring(serial)
		get_gist("https://gist.githubusercontent.com/M0rtelli/52b47f5f6cd4c4f52ea27a398572b8af/raw", '{00FFFF}[MHelper]: ')
	end
	
	function get_gist(json_url, prefix)
	  local dlstatus = require('moonloader').download_status
	  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-gist.json'
	  if doesFileExist(json) then os.remove(json) end
	  downloadUrlToFile(json_url, json,
		function(id, status, p1, p2)
		  if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
			  local f = io.open(json, 'r')
			  if f then
				local info = decodeJson(f:read('*a'))
				for k,v in pairs(info) do
					if k == serial then
						password_script_from_json = tostring(v)
					end
				end
				if main_config.amenu_config.password_of_script == password_script_from_json then
					if main_config.amenu_config.password_of_script ~= '' then
						is_script_auth = true
					end
				else
					check_script.v = not check_script.v
					imgui.Process = check_script.v
				end
				f:close()
				os.remove(json)
			  end
			else
			  print('v'..thisScript().version..': Не могу проверить. Смиритесь. ')
			  update = false
			end
		  end
		end
	  )
	
end

	function autoupdate(json_url, prefix, url)
	  local dlstatus = require('moonloader').download_status
	  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
	  if doesFileExist(json) then os.remove(json) end
	  downloadUrlToFile(json_url, json,
		function(id, status, p1, p2)
		  if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
			  local f = io.open(json, 'r')
			  if f then
				local info = decodeJson(f:read('*a'))
				updatelink = info.updateurl
				updateversion = info.latest
				f:close()
				os.remove(json)
				if updateversion ~= thisScript().version then
				  lua_thread.create(function(prefix)
					local dlstatus = require('moonloader').download_status
					local color = -1
					sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c {EE82EE}'..thisScript().version..'{00FFFF} на {EE82EE}'..updateversion), color)
					wait(250)
					downloadUrlToFile(updatelink, thisScript().path,
					  function(id3, status1, p13, p23)
						if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
						  print(string.format('Загружено %d из %d.', p13, p23))
						elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
						  print('Загрузка обновления завершена.')
						  sampAddChatMessage((prefix..'Обновление завершено!'), color)
						  imgui.ShowCursor = not imgui.ShowCursor
						  goupdatestatus = true
						  lua_thread.create(function() wait(500) thisScript():reload() end)
						end
						if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
						  if goupdatestatus == nil then
							sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
							update = false
						  end
						end
					  end
					)
					end, prefix
				  )
				else
				  update = false
				  local netreb = string.format("{EE82EE}v"..thisScript().version.." MHelper'a{1E90FF} Обновление не требуется.")
				  sampAddChatMessage(netreb, 0x1E90FF)
				end
			  end
			else
			  print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
			  update = false
			end
		  end
		end
	  )
	  while update ~= false do wait(100) end
	end
	
-----------[[[[    fucked IMGUI    ]]]]-----------
    function imgui.OnDrawFrame()
        local so, sp = getScreenResolution()
		local entered_text = sampGetCurrentDialogEditboxText()
        if not main_window_state.v and not recon_menu.v and not az.v and not add_zone.v and not report.v and not gps_help.v and not check_ip.v and not check_script.v then
            imgui.Process = false
        end
		if not is_script_auth then
			if main_window_state.v and recon_menu.v and az.v and  add_zone.v and  report.v and  gps_help.v and  check_ip.v then
				imgui.Process = false
			end
		end
		
		
        if main_window_state.v then
            bluetheme()
            imgui.SetNextWindowPos(imgui.ImVec2(so / 4, sp / 5), imgui.Cond.Once)
            imgui.SetNextWindowSize(imgui.ImVec2(800, 500))
            imgui.Begin(u8'Admin Menu || dev: Dexter_Martelli', main_window_state)
            imgui.BeginGroup()
                imgui.BeginChild('##кнопки', imgui.ImVec2(190, 460), true)
                    for _, nButton in pairs(tSelButtons) do
                        if imgui.SelButton(sWindows == nButton, u8(nButton), imgui.ImVec2(170, 40)) then 
                            sWindows = nButton
                        end
                    end
                imgui.EndChild()
            imgui.EndGroup()

            imgui.SameLine()
            imgui.BeginChild('##render', imgui.ImVec2(590, 460), true)
                if sWindows == tSelButtons[1] then
                    imgui_main()
                end
                if sWindows == tSelButtons[2] then
                    imgui_support()
                end
                if sWindows == tSelButtons[3] then
                    imgui_info()
                end
            imgui.EndChild()
            imgui.End()
        end

        if az.v then
            bluetheme()
            local so, sp = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(so / 2.5, sp / 2), imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(300, 250))
            imgui.Begin(u8"Admin's Zone's || Разраб: Dexter_Martelli", az)
			showCursor(true)
            for name, coord in pairs(adm_zone.az) do
                local x, y, z, interior_id = coord:match("(.*),(.*),(.*), INT: (%d+)")
                if filter == "" then
                    imgui.PushItemWidth(36)
                    show_entry(name, tonumber(x), tonumber(y), tonumber(z), interior_id)
                else
                    if string.upper(name):find(string.upper(filter)) ~= nil  then
                        imgui.PushItemWidth(36)
                        show_entry(name, tonumber(x), tonumber(y), tonumber(z),interior_id)
                end
                end
            end
            if imgui.Button(u8'Add Admin Zone (local)', imgui.ImVec2(275, 25)) then
				az.v = not az.v
				add_zone.v = not add_zone.v
				imgui.Process = add_zone.v
            end
            imgui.End()
		end
		
		if add_zone.v then
			bluetheme()
				local so, sp = getScreenResolution()
				imgui.SetNextWindowPos(imgui.ImVec2(so / 3, sp / 2), imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(500, 175)) --imgui.WindowFlags.MenuBar
				imgui.Begin(u8"Admin Zone's || Разраб: Dexter_Martelli", add_zone)
				showCursor(true)
				
				imgui.SameLine(nil, 30)
				imgui.Columns(4, _, true)
				imgui.Separator()
			  --  imgui.SetColumnWidth(-1, 75)
				imgui.PushItemWidth(75)
				imgui.InputText(' X', Xinput)
				imgui.PopItemWidth()
				
				imgui.NextColumn()
				
				--imgui.SetColumnWidth(-1, 80) 
				imgui.PushItemWidth(75)
				imgui.InputText(' Y', Yinput)
				imgui.PopItemWidth()	
					
				imgui.NextColumn()
				
			   -- imgui.SetColumnWidth(-1, 80)
				imgui.PushItemWidth(75)
				imgui.InputText(' Z', Zinput)
				imgui.PopItemWidth()
					
				imgui.NextColumn() 
				--imgui.SetColumnWidth(-1, 80) 
				imgui.PushItemWidth(75)
				imgui.InputText(' INT', intInput)
				imgui.PopItemWidth()  
				
				imgui.Columns(1, _, true)
				imgui.Separator()
				imgui.InputText(' Name', nameint)
				imgui.SameLine(nil, 15)
				hint('Строго на английском!')
				if imgui.Button(u8'Добавить', imgui.ImVec2(475, 30)) then
					local xitog = tonumber(Xinput.v)
					local yitog = tonumber(Yinput.v)
					local zitog = tonumber(Zinput.v)
					local intitog = tonumber(intInput.v)
					local nameintitog = ''
					if nameint.v == '' then
						nameintitog = 'New AZ'
					else
						nameintitog = nameint.v
					end
					
					if xitog == nil or yitog == nil or zitog == nil or intitog == nil then
						sampAddChatMessage('[MHelper]: Данные введены некорректно!', 0x1E90FF)
					else
						local itog = string.format(xitog .. ',' .. yitog .. ',' .. zitog .. ', INT: ' .. intitog)
						adm_zone.az[nameintitog] = itog
						inicfg.save(admin_zone, 'MHelper\\Config\\admin_zones.ini')
						sampAddChatMessage('[MHelper]: Новая админ-зона успешно была добавлена!', 0x1E90FF)
						add_zone.v = not add_zone.v
					end
				end
				if imgui.Button(u8'Закрыть', imgui.ImVec2(475, 30)) then
					add_zone.v = not add_zone.v
				end
				
				
				imgui.End()
		end

        if recon_menu.v then
            recon_style()
            imgui.SetNextWindowPos(imgui.ImVec2(so / 2.3, sp / 1.3))
            imgui.SetNextWindowSize(imgui.ImVec2(600, 100))
            imgui.Begin(u8'Admin Menu || dev: Dexter_Martelli', recon_menu, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
            if imgui.CustomButton(u8'<< Back', imgui.ImVec4(0.0,0.0,0.0,2.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec2(75, 23)) then
                sampSendChat('/sp ' .. player_spec - 1)
            end
                imgui.SameLine()

            if imgui.Button(u8'Slap', imgui.ImVec2(75, 23)) then
                sampSendChat('/slap ' .. player_spec)
            end
            imgui.SameLine()
            if imgui.Button(u8'Kick', imgui.ImVec2(75, 23)) then
                sampSetChatInputEnabled(true)
				sampSetChatInputText('/kick ' .. player_spec .. ' ')
            end

            imgui.SameLine()
            if imgui.Button(u8'Mute', imgui.ImVec2(75, 23)) then
                sampSetChatInputEnabled(true)
				sampSetChatInputText('/mute ' .. player_spec .. ' ')
            end
            imgui.SameLine()
            if imgui.Button(u8'Ban', imgui.ImVec2(75, 23)) then
                sampSetChatInputEnabled(true)
                if admin_lvl.v >= 3 then
				    sampSetChatInputText('/ban ' .. player_spec .. ' ')
                else
                    sampSetChatInputText('/a /ban ' .. player_spec .. ' ')
                end
            end
            imgui.SameLine()
            if imgui.Button(u8'Warn', imgui.ImVec2(75, 23)) then
                sampSetChatInputEnabled(true)
                if admin_lvl.v >= 3 then
				    sampSetChatInputText('/warn ' .. player_spec .. ' ')
                else
                    sampSetChatInputText('/a /warn ' .. player_spec .. ' ')
                end
            end
            imgui.SameLine()
            if imgui.CustomButton(u8'Next >>', imgui.ImVec4(0.0,0.0,0.0,2.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec2(75, 23)) then
                sampSendChat('/sp ' .. player_spec + 1)
            end
            
            if veh_spec ~= '' then
                imgui.SetCursorPosX(205)
                if imgui.Button('/fv', imgui.ImVec2(75, 23)) then
                    sampSendChat('/fv ' .. veh_spec)
                end
                imgui.SameLine()
                if imgui.Button('/sveh', imgui.ImVec2(75, 23)) then
                    sampSendChat('/sveh ' .. player_spec)
                end
                imgui.SameLine()
                if imgui.Button('/spcarid', imgui.ImVec2(75, 23)) then
                    sampSendChat('/spcarid ' .. veh_spec)
                end
            end
            
			if imgui.Button(u8'Update', imgui.ImVec2(75, 23)) then
                sampSendChat('/sp ' .. player_spec)
            end
			
			imgui.SameLine()
						
			if imgui.Button(u8'Версия', imgui.ImVec2(75, 23)) then
                sampSendChat('/version ' .. player_spec)
            end
			imgui.SameLine()
						
            if imgui.Button(u8'Вы тут?', imgui.ImVec2(75, 23)) then
                sampSendChat('/pm ' .. player_spec .. ' Вы тут? Ответ в /n')
            end
            imgui.SameLine()

            if imgui.Button(u8'Стата', imgui.ImVec2(75, 23)) then
                if admin_lvl.v >= 2 then
                    sampSendChat('/stats ' .. player_spec)
                else
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText('/a /stats ' .. player_spec .. ', ')
                end
            end
			imgui.SameLine()
            if imgui.Button(u8'Спавн', imgui.ImVec2(75, 23)) then
                if admin_lvl.v >= 3 then
                    sampSendChat('/spawn ' .. player_spec)
                else
                    sampSendChat('/a /spawn ' .. player_spec)
                end
            end
			
			imgui.SameLine()
            if imgui.Button(u8'/get', imgui.ImVec2(75, 23)) then
                if admin_lvl.v >= 4 then
                    sampSendChat('/get ' .. player_spec)
                else
                    sampSendChat('/a /get ' .. player_spec)
                end
            end
			
			imgui.SameLine()
            if imgui.Button(u8'Exit', imgui.ImVec2(75, 23)) then
                    sampSendChat('/spoff')
            end
			
			if imgui.Button(u8'ТП к игроку', imgui.ImVec2(75, 23)) then
                    lua_thread.create(function()
						sampSendChat('/spoff')
						wait(650)
						sampSendChat('/goto ' .. player_spec)
					end)
					
            end
			
			imgui.SameLine()
			
			if imgui.Button(u8'ТП игрока', imgui.ImVec2(75, 23)) then
                    lua_thread.create(function()
						sampSendChat('/spoff')
						wait(650)
						sampSendChat('/gethere')
					end)
					
            end
			
			imgui.SameLine()
			
			if imgui.Button(u8'Приятной игры!', imgui.ImVec2(75, 23)) then
                    lua_thread.create(function()
						sampSendChat('/pm ' .. player_spec .. ' Приятной игры!')
					end)
					
            end
			
			imgui.SameLine()
			
			if imgui.Button(u8'IP', imgui.ImVec2(75, 23)) then
                    chip(ip_sp)
            end
			
            imgui.End()
        end
		
		if report.v then
			imgui.SetNextWindowPos(imgui.ImVec2(so / 2.8, sp / 2), imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(450, 250))
			imgui.Begin(u8'Report || dev: Dexter_Martelli', report, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
			report_imgui()
			imgui.End()
		end
		
		if check_ip.v then
			imgui.SetNextWindowPos(imgui.ImVec2(so / 2.8, sp / 2.7))
			imgui.SetNextWindowSize(imgui.ImVec2(325, 375))
			imgui.Begin(u8'IP INFO || dev: Dexter_Martelli', check_ip)
			bluetheme()
			imgui.InputTextMultiline("##земля тебе пухом, про название забыл", ip_info, imgui.ImVec2(300, 310))
			if imgui.Button(u8'Отправить в /a') then
				lua_thread.create(function()
					for i = 1, #rdata do
						if i > 1 then
							wait(700)
							sampSendChat('/a ------------------------')
						end
						wait(700)
						sampSendChat('/a IP - ' .. rdata[i]["query"])
						wait(700)
						sampSendChat('/a Страна - ' .. rdata[i]["country"])
						wait(700)
						sampSendChat('/a Город - ' .. rdata[i]["city"])
						wait(700)
						sampSendChat('/a Провайдер - ' .. rdata[i]["isp"])
						if i > 1 then
							wait(700)
							sampSendChat('/a Дистанция - ' .. distances)
						end
					end
				end)
			end
			
			imgui.SameLine()
			
			if imgui.Button(u8'Отправить в чат') then
				lua_thread.create(function()
					for i = 1, #rdata do
						if i > 1 then
							wait(700)
							sampSendChat('------------------------')
						end
						wait(700)
						sampSendChat('IP - ' .. rdata[i]["query"])
						wait(700)
						sampSendChat('Страна - ' .. rdata[i]["country"])
						wait(700)
						sampSendChat('Город - ' .. rdata[i]["city"])
						wait(700)
						sampSendChat('Провайдер - ' .. rdata[i]["isp"])
						if i > 1 then
							wait(700)
							sampSendChat('Дистанция - ' .. distances)
						end
					end
				end)
			end
			imgui.End()
		end
		
		if gps_help.v then
			imgui.SetNextWindowPos(imgui.ImVec2(so / 2.8, sp / 2.2), imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(460, 400))
			imgui.Begin(u8'GPS Help || dev: Dexter_Martelli', gps_help, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
			
			lua_thread.create(function()
						dialog_status = true
						enableDialog(true)
						imgui.BeginChild('##GPS', imgui.ImVec2(285, 337), true)
							
							if imgui.CollapsingHeader(u8'Важные') then
								for i=1, #all.vazhnoe do
									if imgui.Button(u8(all.vazhnoe[i]), imgui.ImVec2(260, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 1. Важное -> ' .. all.vazhnoe[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Работы') then
								for i=1, #all.raboti do
									if imgui.Button(u8(all.raboti[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 2. Работа -> ' .. all.raboti[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Офф. орг') then
								for i=1, #all.gosski do
									if imgui.Button(u8(all.gosski[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 3. Офф. орг -> ' .. all.gosski[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Неофф. орг') then
								for i=1, #all.nelegal do
									if imgui.Button(u8(all.nelegal[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 4. Нелегал. орг -> ' .. all.nelegal[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Автосервисы') then
								for i=1, #all.avto do
									if imgui.Button(u8(all.avto[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 5. Автосалоны -> ' .. all.avto[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Прочее') then
								for i=1, #all.prochee do
									if imgui.Button(u8(all.prochee[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 6. Прочее -> ' .. all.prochee[i])
									end
								end
							end
							if imgui.CollapsingHeader(u8'Поиск') then
								for i=1, #all.poisk do
									if imgui.Button(u8(all.poisk[i]), imgui.ImVec2(280, 25)) then
										sampSetCurrentDialogEditboxText(entered_text .. '/gps -> 7. Поиск мест -> ' .. all.poisk[i])
									end
								end
							end
				imgui.EndChild()
						wait(700)
					end)
					
					if imgui.Button(u8'<< Назад', imgui.ImVec2(120, 30)) then
						gps_help.v = not gps_help.v
						report.v = not report.v
						imgui.Process = report.v
						dialog_status = false
						enableDialog(false)
					end
					
					imgui.SameLine()
					
					if imgui.Button(u8'[X] Закрыть', imgui.ImVec2(120, 30)) then
						gps_help.v = not gps_help.v
					end
					imgui.End()
		end
		
		if check_script.v then
			bluetheme()
            local so, sp = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(so / 2.5, sp / 2))
            imgui.SetNextWindowSize(imgui.ImVec2(450, 250))
            imgui.Begin(u8"Login || Разраб: Dexter_Martelli", check_script)
				imgui.InputText(u8"Ваш логин скрипта", login_script)
				imgui.InputText(u8"Введите пароль скрипта", password_script)
				imgui.Text(u8'Если у Вас нет пароля, то отправьте разработчику свой логин.')
				
				if imgui.Button(u8'Войти') then
					if password_script_from_json == '' then
						info_msg('Не получается войти. Код №2')
					else
						if serial ~= login_script.v then
						info_msg('Не получается войти. Код №1')
						else
							if password_script.v == password_script_from_json then
								info_msg('Вы успешно авторизовались!')
								-- добавить сюда проверку обновы
								is_script_auth = true
								check_script.v = not check_script.v
								imgui.Process = false
								main_config.amenu_config.password_of_script = password_script.v
								inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')	
							else
								info_msg('Не получается войти. Код №3')
							end
						end
					end
				end
			imgui.End()
		end
	end

	function report_imgui()
	style_ans()
	if sampGetPlayerIdByNickname(nick_report) then
		imgui.CenterText(u8"Жалоба/Вопрос от " .. nick_report .. '[' .. sampGetPlayerIdByNickname(nick_report) .. ']:')
	else
		imgui.CenterText(u8"Жалоба/Вопрос от " .. nick_report .. '[OFF]:')
	end
	imgui.Separator()
	if imgui.CustomButton(u8(question_report), imgui.ImVec4(0.0,0.0,0.0,2.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec4(1.0,0.0,1.0,1.0), imgui.ImVec2(435, 25)) then
		dialog_status = not dialog_status
		enableDialog(dialog_status)
	end
	
	if not dialog_status then
		enableDialog(dialog_status)
	end
	
	imgui.Separator()
	imgui.PushItemWidth(390)
	imgui.InputText(u8'##response', answer)
	imgui.PopItemWidth()
	
	imgui.SameLine()
	imgui.Text(u8'Ответ')
	if imgui.IsItemClicked(0) then -- Если нажмет ПКМ на текст
        lua_thread.create(function()
				dialog_status = true
				enableDialog(true)
				sampSendDialogResponse(id_dialog_report, 1, -1, tostring(u8:decode(answer.v)))
				wait(700)
				report.v = not report.v
		end)
    end
	
	
	if report_id ~= '' then 
		imgui.Text(u8'Возможный ID - ') 
		imgui.SameLine()
		if imgui.Button(report_id, imgui.ImVec2(30, 20)) then  
			lua_thread.create(function()
				dialog_status = true
				enableDialog(true)
				sampSendDialogResponse(id_dialog_report, 1, -1, 'Здравствуйте ' .. nick_report .. '! Слежу за потенциальным нарушителем.')
				wait(700)
				
				sampCloseCurrentDialogWithButton(0)
				report.v = not report.v
				sampSendChat('/sp ' .. report_id)
				
			end)
		end
	end
		
	
	imgui.Separator()
	
	imgui.BeginChild(u8'##aboba', imgui.ImVec2(425, 130), false)
	
			if imgui.Button(u8"Слежу") then
				lua_thread.create(function()
					dialog_status = true
					enableDialog(true)
					sampSendDialogResponse(id_dialog_report, 1, -1, 'Здравствуйте ' .. nick_report .. '! Бегу к Вам на помощь!')
					wait(700)
					sampCloseCurrentDialogWithButton(0)
					report.v = not report.v
					sampSendChat('/sp ' .. sampGetPlayerIdByNickname(nick_report))
				end)
			end
			
			imgui.SameLine()
			
			if imgui.Button(u8"Переслать в /a") then
				lua_thread.create(function()
					dialog_status = true
					enableDialog(true)
					sampSendDialogResponse(id_dialog_report, 1, -1, nil)
					wait(700)
					sampCloseCurrentDialogWithButton(0)
					report.v = not report.v
					sampSendChat('/a [REPORT]: ' .. nick_report .. '[' .. sampGetPlayerIdByNickname(nick_report) .. ']: ' .. question_report)
				end)
			end
			
			imgui.SameLine()
			
			if imgui.Button(u8"Передать админу") then
				lua_thread.create(function()
					dialog_status = true
					enableDialog(true)
					sampSendDialogResponse(id_dialog_report, 1, -1, 'Здравствуйте ' .. nick_report .. ', передам. ')
					wait(700)
					sampCloseCurrentDialogWithButton(0)
					report.v = not report.v
					sampSendChat('/a [REPORT]: ' .. nick_report .. '[' .. sampGetPlayerIdByNickname(nick_report) .. ']: ' .. question_report)
				end)
			end
			
			imgui.SameLine()
			
			if imgui.Button(u8"Помощь по GPS") then
				report.v = not report.v
				gps_help.v = not gps_help.v
				imgui.Process = gps_help.v
			end
			
			if imgui.Button(u8"Не согласен") then
				lua_thread.create(function()
					dialog_status = true
					enableDialog(true)
					sampSendDialogResponse(id_dialog_report, 1, -1, 'Здравствуйте, если Вы не согласны с наказанием - оставьте жалобу на форум. ')
					wait(700)
					sampCloseCurrentDialogWithButton(0)
					report.v = not report.v
				end)
			end
	
	imgui.EndChild()
	
	end

    function imgui_main()
        local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local my_nick = sampGetPlayerNickname(my_id)
        imgui.BeginChild('##main_frame', imgui.ImVec2(245, 440), false)

            imgui.Text(u8'Ваш ник: ' .. my_nick .. '[' .. my_id ..']')


            imgui.Text(u8'Ваш LVL администратора:')
            imgui.SameLine()
            imgui.PushItemWidth(70)
            if imgui.InputInt('##lvl adm', admin_lvl) then
                if admin_lvl.v <= 0 then
                    admin_lvl.v = 1
                end
                if admin_lvl.v > 8 then
                    admin_lvl.v = 8
                end
                main_config.amenu_config.admin_lvl = tostring(admin_lvl.v)
                inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
            end
            imgui.PopItemWidth()


            imgui.Text(u8'Пароль аккаунта:')
            imgui.SameLine()
            if imgui.InputText('##pass akk', password_acc, imgui.InputTextFlags.Password) then
                main_config.amenu_config.password_acc = tostring(password_acc.v)
                inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
            end


            imgui.Text(u8'Авто-логин (Аккаунт) ')
            imgui.SameLine()
            if imgui.ToggleButton("autologin", auto_auth) then
                main_config.amenu_config.autologin_acc = tostring(auto_auth.v)
                inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
            end


            imgui.Text(u8'Скин при авторизации:')
            imgui.SameLine()
            imgui.PushItemWidth(85)
            if imgui.InputInt('##skin auth', auth_skin) then
                if admin_lvl.v < 3 then
                    auth_skin.v = 0
                    info_msg('Вам недоступна возможность устанавливать скин! (С 3 LVL администратора)')
                else
                    main_config.amenu_config.auth_skin = tostring(auth_skin.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            hint('Если не хотите получить скин при авторизации,\nто поставьте значение 0')


            imgui.Text(u8'/inter при авторизации:')
            imgui.SameLine()
            imgui.PushItemWidth(85)
            if imgui.InputInt('##inter auth', auth_inter) then
                if admin_lvl.v < 4 then
                    auth_inter.v = 0
                    info_msg('Вам недоступна возможность телепортироваться в интерьер! (С 4 LVL администратора)')
                else
                    main_config.amenu_config.auth_inter = tostring(auth_inter.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            hint('Если не хотите появляться в интерьере,\nто поставьте значение 0')


            imgui.Text(u8'Лидер при входе:')
            imgui.SameLine()
            imgui.PushItemWidth(85)
            if imgui.InputInt('##ld auth', auth_ld) then
                if admin_lvl.v < 4 then
                    auth_ld.v = 0
                    info_msg('Вам недоступна возможность выдавать ЛД! (С 4 LVL администратора)')
                else
                    main_config.amenu_config.auth_ld = tostring(auth_ld.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            hint('Если не хотите появляться в интерьере,\nто поставьте значение 0')
        imgui.EndChild()

            imgui.SameLine()

        imgui.BeginChild('##sec_frame', imgui.ImVec2(245, 440), false)
            imgui.Text(u8'Пароль адм. панели:')
                imgui.SameLine()
                if imgui.InputText('##pass adm', password_adm, imgui.InputTextFlags.Password) then
                    main_config.amenu_config.password_adm = tostring(password_adm.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end

                imgui.Text(u8'Авто-логин (Админка) ')
                imgui.SameLine()
                if imgui.ToggleButton("autologin, adm", auto_auth_adm) then
                    main_config.amenu_config.autologin_adm = tostring(auto_auth_adm.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end

                imgui.Text(u8'Click-warp')
                imgui.SameLine()
                if imgui.ToggleButton("clickwarp", clickwarp) then
                    main_config.amenu_config.clickwarp = tostring(clickwarp.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end

                imgui.Text(u8'E-menu')
                imgui.SameLine()
                if imgui.ToggleButton("emenu", emenu) then
                    main_config.amenu_config.emenu = tostring(emenu.v)
                    inicfg.save(main_cfg, 'MHelper\\Config\\main_config.ini')
                end
        imgui.EndChild()
    end

    function imgui_support()
        imgui.Text('SUPPORT')
    end

    function imgui_info()
        imgui.Text('INFO')
    end
-----------[[[[    СНИППЕТЫ    ]]]]-----------
function imgui.SelButton(state, lable, size)
    if state then
        --imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.06, 0.53, 0.98, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.28, 0.56, 1.00, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.53, 0.98, 1.00))
            local button = imgui.Button(lable, size)
        imgui.PopStyleColor(3)
        return button
    else
        --imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.80))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.40))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.59, 0.98, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.53, 0.98, 1.00))
            local button = imgui.Button(lable, size)
            imgui.PopStyleColor(3)
        return button
    end
end
function info_msg(text)
    sampAddChatMessage('{8A2BE2}[MHelper]:{00CED1} ' .. text)
end
function debug(text)
    if text then
        sampAddChatMessage('[DEBUG]: ' .. text, -1)
    else
        sampAddChatMessage('Debbuged!', -1)
    end
end
function hint(text)
    lua_thread.create(
      function()
        imgui.TextDisabled("(?)")
        if imgui.IsItemHovered() then
          imgui.BeginTooltip()
          imgui.TextUnformatted(u8(text))
          imgui.EndTooltip()
        end
    end)
end
function getClosestPlayerId(di)
    local minDist = di
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist then
			--	sampAddChatMessage(dist, -1)
				--print(minDist)
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end
function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end
function teleport(x, y, z)
    if x == nil then
        z = -100
	end

    if x ~= 0 and y ~= 0 then
        setCharCoordinates(PLAYER_PED, x, y, z)
    end
end
function show_entry(label, x, y, z,interior_id)
	if imgui.MenuItem(label, "", false, true) then
	    imgui.PushItemWidth(36)
		setCharInterior(PLAYER_PED,interior_id)
		setInteriorVisible(interior_id)
		clearExtraColours(true)
		requestCollision(x,y)
		loadScene(x,y,z)
		activateInteriorPeds(true)
		teleport(x, y, z)
		imgui.PopItemWidth()
	end
end
function drawClickableText(font, text, posX, posY, color, colorA)
    renderFontDrawText(font, text, posX, posY, color)
    local textLenght = renderGetFontDrawTextLength(font, text)
    local textHeight = renderGetFontDrawHeight(font)
    local curX, curY = getCursorPos()
      if curX >= posX and curX <= posX + textLenght and curY >= posY and curY <= posY + textHeight then
        renderFontDrawText(font, text, posX, posY, colorA)
        if wasKeyPressed(1) then
            return true
        end
    end
end
function sampGetPlayerIdByNickname(nick)
  nick = tostring(nick)
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  if nick == sampGetPlayerNickname(myid) then return myid end
  for i = 0, 1003 do
    if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
      return i
    end
  end
end
function imgui.CustomButton(name, color, colorHovered, colorActive, size)
    local clr = imgui.Col
    imgui.PushStyleColor(clr.Button, color)
    imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
    imgui.PushStyleColor(clr.ButtonActive, colorActive)
    if not size then size = imgui.ImVec2(0, 0) end
    local result = imgui.Button(name, size)
    imgui.PopStyleColor(3)
    return result
end
function enableDialog(bool)
    local memory = require 'memory'
    memory.setint32(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function(method, url, args)
		local requests = require"requests"
		local result, response = pcall(requests.request, method, url, args)
		if result then
			response.json, response.xml = nil, nil
			return true, response
		else
			return false, response
		end
	end)(method, url, args)

	if not resolve then
		resolve = function() end
	end
	if not reject then
		reject = function() end
	end
	lua_thread.create(function()
		local runner = request_thread
		while true do
			local status, err = runner:status()
			if not err then
				if status == "completed" then
					local result, response = runner:get()
					if result then
						resolve(response)
					else
						reject(response)
					end
					return
				elseif status == "canceled" then
					return reject(status)
				end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end
function distance_cord(lat1, lon1, lat2, lon2)
	if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil or lat1 == "" or lon1 == "" or lat2 == "" or lon2 == "" then
		return 0
	end
	local dlat = math.rad(lat2 - lat1)
	local dlon = math.rad(lon2 - lon1)
	local sin_dlat = math.sin(dlat / 2)
	local sin_dlon = math.sin(dlon / 2)
	local a =
		sin_dlat * sin_dlat + math.cos(math.rad(lat1)) * math.cos(
			math.rad(lat2)
		) * sin_dlon * sin_dlon
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
	local d = 6378 * c
	return d
end
function chip(cl)
if cl ~= '' then
	ips = {}
	for word in string.gmatch(cl, "(%d+%p%d+%p%d+%p%d+)") do
		table.insert(ips, { query = word })
	end
	if #ips > 0 then
		data_json = cjson.encode(ips)
		asyncHttpRequest(
			"POST",
			"http://ip-api.com/batch?fields=25305&lang=ru",
			{ data = data_json },
			function(response)
				rdata = cjson.decode(u8:decode(response.text))
				local text = ""
				for i = 1, #rdata do
					if rdata[i]["status"] == "success" then
						distances =
							distance_cord(
								rdata[1]["lat"],
								rdata[1]["lon"],
								rdata[i]["lat"],
								rdata[i]["lon"]
							)
						text =
							text .. string.format(
								"\nIP №" .. i .. " - %s\n Cтрана - %s\n Город - %s\n Провайдер - %s\n Растояние - %d  \n\n",
								rdata[i]["query"],
								rdata[i]["country"],
								rdata[i]["city"],
								rdata[i]["isp"],
								distances
							)
               end
				end
				if text == "" then
					text = " \n\t{FFF500}Ничего не найдено"
				end
				showdialog("Информация о IP", text)
			end,
			function(err)
				info_msg("Произошла ошибка -" .. err)
			end
		)
	end
	else
	sampAddChatMessage('{00FA9A}[MHelper]: Введите {1E90FF}/checkip {FF69B4}8.8.8.8 {FF6347}1.1.1.1')
	end
end
function showdialog(name, rdata)
	--[[sampShowDialog(
		math.random(1000),
		"{FF4444}" .. name,
		rdata,
		"Закрыть",
		false,
		0
	)]]
	
	ip_info.v = u8(rdata)
	check_ip.v = not check_ip.v
	imgui.Process = check_ip.v
end

    -- РЕНДЕР
        function rotateCarAroundUpAxis(car, vec)
            local mat = Matrix3X3(getVehicleRotationMatrix(car))
            local rotAxis = Vector3D(mat.up:get())
            vec:normalize()
            rotAxis:normalize()
            local theta = math.acos(rotAxis:dotProduct(vec))
            if theta ~= 0 then
            rotAxis:crossProduct(vec)
            rotAxis:normalize()
            rotAxis:zeroNearZero()
            mat = mat:rotate(rotAxis, -theta)
            end
            setVehicleRotationMatrix(car, mat:get())
        end
        
        function readFloatArray(ptr, idx)
            return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
        end
        
        function writeFloatArray(ptr, idx, value)
            writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
        end
        
        function getVehicleRotationMatrix(car)
            local entityPtr = getCarPointer(car)
            if entityPtr ~= 0 then
            local mat = readMemory(entityPtr + 0x14, 4, false)
            if mat ~= 0 then
                local rx, ry, rz, fx, fy, fz, ux, uy, uz
                rx = readFloatArray(mat, 0)
                ry = readFloatArray(mat, 1)
                rz = readFloatArray(mat, 2)
        
                fx = readFloatArray(mat, 4)
                fy = readFloatArray(mat, 5)
                fz = readFloatArray(mat, 6)
        
                ux = readFloatArray(mat, 8)
                uy = readFloatArray(mat, 9)
                uz = readFloatArray(mat, 10)
                return rx, ry, rz, fx, fy, fz, ux, uy, uz
            end
            end
        end
        
        function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
            local entityPtr = getCarPointer(car)
            if entityPtr ~= 0 then
            local mat = readMemory(entityPtr + 0x14, 4, false)
            if mat ~= 0 then
                writeFloatArray(mat, 0, rx)
                writeFloatArray(mat, 1, ry)
                writeFloatArray(mat, 2, rz)
        
                writeFloatArray(mat, 4, fx)
                writeFloatArray(mat, 5, fy)
                writeFloatArray(mat, 6, fz)
        
                writeFloatArray(mat, 8, ux)
                writeFloatArray(mat, 9, uy)
                writeFloatArray(mat, 10, uz)
            end
            end
        end
        
        function displayVehicleName(x, y, gxt)
            x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
            useRenderCommands(true)
            setTextWrapx(640.0)
            setTextProportional(true)
            setTextJustify(false)
            setTextScale(0.33, 0.8)
            setTextDropshadow(0, 0, 0, 0, 0)
            setTextColour(255, 255, 255, 230)
            setTextEdge(1, 0, 0, 0, 100)
            setTextFont(1)
            displayText(x, y, gxt)
        end
        
        function createPointMarker(x, y, z)
            pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
        end
        
        function removePointMarker()
            if pointMarker then
            removeUser3dMarker(pointMarker)
            pointMarker = nil
            end
        end
        
        function getCarFreeSeat(car)
            if doesCharExist(getDriverOfCar(car)) then
            local maxPassengers = getMaximumNumberOfPassengers(car)
            for i = 0, maxPassengers do
                if isCarPassengerSeatFree(car, i) then
                return i + 1
                end
            end
            return nil -- no free seats
            else
            return 0 -- driver seat
            end
        end
        
        function jumpIntoCar(car)
            local seat = getCarFreeSeat(car)
            if not seat then return false end                         -- no free seats
            if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
            else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
            end
            restoreCameraJumpcut()
            return true
        end
        
        function teleportPlayer(x, y, z)
            if isCharInAnyCar(playerPed) then
            setCharCoordinates(playerPed, x, y, z)
            end
            setCharCoordinatesDontResetAnim(playerPed, x, y, z)
        end
        
        function setCharCoordinatesDontResetAnim(char, x, y, z)
            if doesCharExist(char) then
            local ptr = getCharPointer(char)
            setEntityCoordinates(ptr, x, y, z)
            end
        end
        
        function setEntityCoordinates(entityPtr, x, y, z)
            if entityPtr ~= 0 then
            local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
            if matrixPtr ~= 0 then
                local posPtr = matrixPtr + 0x30
                writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
                writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
                writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
            end
            end
        end
        
        function showCursor(toggle)
            if toggle then
            sampSetCursorMode(CMODE_LOCKCAM)
            else
            sampToggleCursor(false)
            end
            cursorEnabled = toggle
        end
        
        function initializeRender()
            font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
            font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
        end
    ----------[[[[   СТИЛИ   ]]]]----------
        function bluetheme()
            local style = imgui.GetStyle()
            local colors = style.Colors
            local clr = imgui.Col
            local ImVec4 = imgui.ImVec4
            local buttons = imgui.ImFloat4(0.26, 0.59, 0.98, 0.40)
            local fon = imgui.ImFloat4(0.06, 0.06, 0.06, 0.94)
            local name = imgui.ImFloat4(0.04, 0.04, 0.04, 1.00)
            style.WindowRounding = 1.5
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ChildWindowRounding = 2
            style.FrameRounding = 2
            style.ItemSpacing = imgui.ImVec2(4.0, 4.0)
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 0
            style.GrabMinSize = 8.0
            style.GrabRounding = 1.0
            -- style.Alpha =
            style.WindowPadding = imgui.ImVec2(10.0, 10.0)
            -- style.WindowMinSize =
            style.FramePadding = imgui.ImVec2(2, 4)
            -- style.ItemInnerSpacing =
            -- style.TouchExtraPadding =
            -- style.IndentSpacing =
            -- style.ColumnsMinSpacing = ?
            style.ButtonTextAlign = imgui.ImVec2(0.50, 0.5)
            -- style.DisplayWindowPadding =
            -- style.DisplaySafeAreaPadding =
            -- style.AntiAliasedLines =
            -- style.AntiAliasedShapes =
            -- style.CurveTessellationTol =
        
            colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
            colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
            colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
            colors[clr.TitleBg]                = name
            colors[clr.TitleBgActive]          = name
            colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
            colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
            colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
            colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
            colors[clr.Button]                 = buttons
            colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
            colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
            colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
            colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
            colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
            colors[clr.Separator]              = colors[clr.Border]
            colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
            colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
            colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
            colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
            colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
            colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
            colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
            colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            colors[clr.WindowBg]               = fon
            colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
            colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
            colors[clr.ComboBg]                = colors[clr.PopupBg]
            colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
            colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
            colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
            colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
            colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
            colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
            colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
            colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
            colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
            colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
            colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
            colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
            colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
            colors[clr.ModalWindowDarkening]   = ImVec4(0.261, 0.261, 0.261, 0.725)
        end
		
		function recon_style()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4

			colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.TextDisabled] = ImVec4(0.60, 0.60, 0.60, 1.00)
			colors[clr.WindowBg] = ImVec4(0.11, 0.10, 0.11, 1.00)
			colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.PopupBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
			colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg] = ImVec4(0.21, 0.20, 0.21, 0.60)
			colors[clr.FrameBgHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.FrameBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.TitleBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.TitleBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.MenuBarBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.ScrollbarBg] = ImVec4(0.00, 0.46, 0.65, 0.00)
			colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.46, 0.65, 0.44)
			colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 0.46, 0.65, 0.74)
			colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.ComboBg] = ImVec4(0.15, 0.14, 0.15, 1.00)
			colors[clr.CheckMark] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.SliderGrab] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.SliderGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.Button] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.ButtonHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.ButtonActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.Header] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.HeaderHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.HeaderActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
			colors[clr.ResizeGrip] = ImVec4(1.00, 1.00, 1.00, 0.30)
			colors[clr.ResizeGripHovered] = ImVec4(1.00, 1.00, 1.00, 0.60)
			colors[clr.ResizeGripActive] = ImVec4(1.00, 1.00, 1.00, 0.90)
			colors[clr.CloseButton] = ImVec4(1.00, 0.10, 0.24, 0.00)
			colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.10, 0.24, 0.00)
			colors[clr.CloseButtonActive] = ImVec4(1.00, 0.10, 0.24, 0.00)
			colors[clr.PlotLines] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.PlotLinesHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.PlotHistogram] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.PlotHistogramHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.TextSelectedBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.00)
		end

		function style_ans()
			imgui.SwitchContext()
			local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col
			local ImVec4 = imgui.ImVec4
			local ImVec2 = imgui.ImVec2

			style.WindowPadding = imgui.ImVec2(8, 8)
			style.WindowRounding = 6
			style.ChildWindowRounding = 5
			style.FramePadding = imgui.ImVec2(5, 3)
			style.FrameRounding = 5.0
			style.ItemSpacing = imgui.ImVec2(5, 4)
			style.ItemInnerSpacing = imgui.ImVec2(4, 4)
			style.IndentSpacing = 21
			style.ScrollbarSize = 10.0
			style.ScrollbarRounding = 13
			style.GrabMinSize = 8
			style.GrabRounding = 5
			style.Alpha = 1
			style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
			style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

			colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
			colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
			colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.ChildWindowBg]          = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
			colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
			colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
			colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
			colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
			colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
			colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
			colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
			colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
			colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
			colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
			colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
			colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
			colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
			colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
			colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
			colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
			colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
			colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
			colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
			colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
			colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
			colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
			colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
			colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
			colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
		end
-----------[[[[    ХУКИ    ]]]]-----------
function sampev.onShowDialog(id, style, title, button1, button2, text)
    if title:match('Ответ') and is_script_auth then
		
		report_id = ''
		id_dialog_report = id
		info_msg(id_dialog_report)
		nick_report, question_report = text:match('(%w+_%w+):%s?{%x%x%x%x%x%x}%s?(.-)\n')
		if question_report:match('(%d+)') then
			report_id = question_report:match('(%d+)')
		end
		answer.v = ''
		report.v = not report.v
		imgui.Process = report.v
	end
	
	
	if title:match('Авторизация') and is_script_auth then
        if auto_auth.v then
            if main_config.amenu_config.password_acc ~= '' then
                step_auth = 1
                sampSendDialogResponse(id, 1, nil, main_config.amenu_config.password_acc)
				sampCloseCurrentDialogWithButton(0)
            else
                info_msg('Авто-авторизация {FF0000}невозможна!{00CED1} Не введён пароль в /amenu')
            end
        end
    end

    if title:match('Подтверждение прав администратора') and is_script_auth then
        if auto_auth_adm.v then
            if main_config.amenu_config.password_adm ~= '' and main_config.amenu_config.password_adm ~= '0' then
                step_auth = 1
                sampSendDialogResponse(id, 1, nil, main_config.amenu_config.password_adm)
            else
                info_msg('Авто-авторизация {FF0000}невозможна!{00CED1} Не введён пароль в /amenu')
            end
        end
    end
end

function sampev.onSendCommand(command)
if command:match('/sp %d+') and is_script_auth then
    local id = command:match('/sp (%d+)')
    lua_thread.create(function()
        wait(500)
        if sampGetCharHandleBySampPlayerId(id) then
            local _, handle = sampGetCharHandleBySampPlayerId(id)
            if isCharInAnyCar(handle) then
                if storeCarCharIsInNoSave(handle) then
                    local _, veh_id = sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(handle))
                    veh_spec = veh_id
                    player_spec = id
                end
            else
                veh_spec = ''
            end
        end
    end)
end

end

function sampev.onDisplayGameText(style, time, text)
	if recon_menu.v and is_script_auth then
		recon_text = text
		if text:match('p%p%s(%d+)') then
			ping_sp = text:match('p%p%s(%d+)')
			hp_sp = text:match('hp%p%s(%d+)')
			arm_sp = text:match('arm%p%s(%d+)')
			version_sp = text:match('version%p%s(%d+)')
			ip_sp = text:match('ip%p%s(.*)')
		end
		--   ~n~~n~~n~~n~~n~~n~~n~~n~Deidara_Goldenwize(1) p: 123 ms.~n~hp: 100.0 arm: 0.0~n~version: 163~n~ip: 188.162.50.101
	return false
	end
	
	end

function sampev.onServerMessage(color, msg)
	if is_script_auth then
		local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local my_nick = sampGetPlayerNickname(my_id)
		if msg:match(my_nick .. '%p' .. my_id ..'%p%p%d%p успешно авторизовался') then
			lua_thread.create(function()
			debug()
			is_auth = true
			if auth_skin.v ~= 0 then
				wait(700)
				sampSendChat('/setskin ' .. tostring(auth_skin.v))
			end
			if auth_inter.v ~= 0 then
				wait(700)
				sampSendChat('/inter ' .. tostring(auth_inter.v))
			end
			if auth_ld.v ~= 0 then
				wait(700)
				sampSendChat('/templeader ' .. tostring(auth_ld.v))
			end
			end)
		end
		
		if msg:match('Пусто!') then
			info_msg('Нет ни одного репорта!')
			return false
		end
		
		if msg:match('REPORT РЕКЛАМА') then
			lua_thread.create(function()
			name_report_adv, id_report_adv, text_report_adv = msg:match("(%w+_%w+)%[(%d+)%]:(.+)")
			--debug(name_report_adv .. '; ' .. id_report_adv .. '; ' .. text_report_adv)
			info_msg('Зажмите U, если хотите выдать mute на 120 минут ' .. name_report_adv)
			end)
		end

		if msg:match('Вы успешно телепортированы в') then
			local coords, x, y, z = getTargetBlipCoordinates()
			setCharCoordinates(playerPed, x, y, z)
			info_msg(x .. ' ' .. y .. ' ' .. z)
		end
	end
end

function sampev.onTogglePlayerSpectating(state)
		if is_auth and is_script_auth then
			imgui.Process = state
			recon_menu.v = state
		end
    end

function sampev.onSpectatePlayer(playerid, cam)
        player_spec = playerid
    end