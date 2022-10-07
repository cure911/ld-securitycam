local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData = {}
local blockbuttons = false
local currentCameraIndex = 0
local currentCameraIndexIndex = 0
local createdCamera = 0
local kameraIsim = ""
local active = false

PantCore = nil
Citizen.CreateThread(function()
    while PantCore == nil do
        TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)
        Citizen.Wait(200)
    end
end)

RegisterNetEvent('PantCore:Client:OnPlayerLoaded')
AddEventHandler('PantCore:Client:OnPlayerLoaded', function()
    PlayerData = PantCore.Functions.GetPlayerData()
end)

RegisterNetEvent('PantCore:Client:OnJobUpdate')
AddEventHandler('PantCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('ld-denizalti:emp')
AddEventHandler('ld-denizalti:emp', function(_active)
	active = _active
end)

RegisterCommand("pkam", function()
	if not active then
		PantCore.Functions.GetPlayerData(function(PlayerData)
			if not isdead and not PlayerData.metadata["kelepce"] and not PlayerData.metadata["pkelepce"] then
				local PlayerPed = PlayerPedId()
				if PlayerData.job and PlayerData.job.name == "police" then
					kameraMenu()
				else
					if IsPedSittingInAnyVehicle(PlayerPed) and vehicleType(GetVehiclePedIsUsing(PlayerPed)) then
						if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPed, false), -1) == PlayerPed or GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPed, false), -1) == PlayerPed then
							kameraMenu()
						else
							PantCore.Functions.Notify("You Can Only Look At The Cameras While In The Front Seat", "error")
						end
					else	
						PantCore.Functions.Notify("You Are Not In A Police Car or You Are Not A Cop", "error")
					end
				end
			end
		end)
	else
		PantCore.Functions.Notify("Cameras Not Working!", "error")
	end
end)

function marketKameraMenu()
	local elements = {}
	for no, marketler in pairs(Config.kameralar) do
		if no ~= "Motel" and no ~= "Mucevher" and no ~= "Hastane" and no ~= "Polis" and no ~= "KasabaMotel" and no ~= "Banka" then
			table.insert(elements, {label = no .. " Numaralı Market Kameraları",  menu = no})
		end
	end

	PantCore.UI.Menu.CloseAll()
	PantCore.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = "Güvenlik kameraları",
		align    = 'top-left',
		elements = elements
	}, function(data2, menu2)
		menu2.close()
		blockbuttons = true
		kameraIsim = data2.current.menu
		local firstCamx = Config.kameralar[kameraIsim][1].x
		local firstCamy = Config.kameralar[kameraIsim][1].y
		local firstCamz = Config.kameralar[kameraIsim][1].z
		local firstCamr = Config.kameralar[kameraIsim][1].r
		SetFocusArea(firstCamx, firstCamy, firstCamz, firstCamx, firstCamy, firstCamz)
		ChangeSecurityCamera(firstCamx, firstCamy, firstCamz, firstCamr)

		currentCameraIndex = 1
		currentCameraIndexIndex = 1
		TriggerEvent('esx_securitycam:freeze', true)
		
	end, function(data2, menu2)
		menu2.close()
		blockbuttons = false
	end)
end

function kameraMenu()
	PantCore.UI.Menu.CloseAll()
	PantCore.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = "Güvenlik kameraları",
		align    = 'top-left',
		elements = {
			{label = 'Market Güvenlik Kameraları', menu = 'market'},
			{label = "Büyük Banka Kameraları",  menu = 'Banka'},
			{label = "Kasaba Banka Kameraları",  menu = 'KasabaMotel'},
			{label = "Polis İstasyonu Kamerları", menu = 'Polis'},
			{label = 'Hastane Kameraları', menu = 'Hastane'},
			{label = 'Mücevherci Kameraları', menu = 'Mucevher'},
			{label = 'Motel Güvenlik Kameraları', menu = 'Motel'},			
		}
	}, function(data, menu)

		if data.current.menu == "market" then
			marketKameraMenu()
		else
			menu.close()
			blockbuttons = true
			kameraIsim = data.current.menu
			local firstCamx = Config.kameralar[kameraIsim][1].x
			local firstCamy = Config.kameralar[kameraIsim][1].y
			local firstCamz = Config.kameralar[kameraIsim][1].z
			local firstCamr = Config.kameralar[kameraIsim][1].r
			SetFocusArea(firstCamx, firstCamy, firstCamz, firstCamx, firstCamy, firstCamz)
			ChangeSecurityCamera(firstCamx, firstCamy, firstCamz, firstCamr)

			currentCameraIndex = 1
			currentCameraIndexIndex = 1
			TriggerEvent('esx_securitycam:freeze', true)
		end

	end, function(data, menu)
		menu.close()
		blockbuttons = false
	end)
end

Citizen.CreateThread(function()
	while true do
		local time = 1000
		if createdCamera ~= 0 then
			time = 1
			local instructions = CreateInstuctionScaleform("instructional_buttons")

			DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
			SetTimecycleModifier("scanline_cam_cheap")
			SetTimecycleModifierStrength(2.0)

			-- CLOSE CAMERAS
			if IsControlJustPressed(0, Keys["BACKSPACE"]) then
				CloseSecurityCamera()
				TriggerEvent('esx_securitycam:freeze', false)
			end

			-- GO BACK CAMERA
			if IsControlJustPressed(0, Keys["LEFT"]) then
				local newCamIndex

				if currentCameraIndexIndex == 1 then
					newCamIndex = #Config.kameralar[kameraIsim]
				else
					newCamIndex = currentCameraIndexIndex - 1
				end

				local newCamx = Config.kameralar[kameraIsim][newCamIndex].x
				local newCamy = Config.kameralar[kameraIsim][newCamIndex].y
				local newCamz = Config.kameralar[kameraIsim][newCamIndex].z
				local newCamr = Config.kameralar[kameraIsim][newCamIndex].r

				SetFocusArea(newCamx, newCamy, newCamz, newCamx, newCamy, newCamz)

				ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
				currentCameraIndexIndex = newCamIndex
			end

			-- GO FORWARD CAMERA
			if IsControlJustPressed(0, Keys["RIGHT"]) then
				local newCamIndex
			
				if currentCameraIndexIndex == #Config.kameralar[kameraIsim] then
					newCamIndex = 1
				else
					newCamIndex = currentCameraIndexIndex + 1
				end

				local newCamx = Config.kameralar[kameraIsim][newCamIndex].x
				local newCamy = Config.kameralar[kameraIsim][newCamIndex].y
				local newCamz = Config.kameralar[kameraIsim][newCamIndex].z
				local newCamr = Config.kameralar[kameraIsim][newCamIndex].r

				ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
				currentCameraIndexIndex = newCamIndex
			end

			if Config.kameralar[kameraIsim][currentCameraIndex].canRotate then
				local getCameraRot = GetCamRot(createdCamera, 2)

				-- ROTATE LEFT
				if IsControlPressed(1, Keys['N4']) then
					SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
				end

				-- ROTATE RIGHT
				if IsControlPressed(1, Keys['N6']) then
					SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
				end

			elseif Config.kameralar[kameraIsim][currentCameraIndex].canRotate then
				local getCameraRot = GetCamRot(createdCamera, 2)

				-- ROTATE LEFT
				if IsControlPressed(1, Keys['N4']) then
					SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
				end

				-- ROTATE RIGHT
				if IsControlPressed(1, Keys['N6']) then
					SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
				end
			end

		end
		Citizen.Wait(time)
	end
end)

function ChangeSecurityCamera(x, y, z, r)
	if createdCamera ~= 0 then
		DestroyCam(createdCamera, 0)
		createdCamera = 0
	end

	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
	SetCamCoord(cam, x, y, z)
	SetCamRot(cam, r.x, r.y, r.z, 2)
	RenderScriptCams(1, 0, 0, 1, 1)

	createdCamera = cam
end

function CloseSecurityCamera()
	blockbuttons = false
	DestroyCam(createdCamera, 0)
	RenderScriptCams(0, 0, 1, 1, 1)
	createdCamera = 0
	ClearTimecycleModifier("scanline_cam_cheap")
	SetFocusEntity(GetPlayerPed(PlayerId()))
	Citizen.Wait(50)
	kameraMenu()
end

function CreateInstuctionScaleform(scaleform)
	local scaleform = RequestScaleformMovie(scaleform)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(10)
	end

	PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
	PushScaleformMovieFunctionParameterInt(200)
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, Keys["RIGHT"], true))
	InstructionButtonMessage("SONRAKİ KAMERA")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(1)
	PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, Keys["LEFT"], true))
	InstructionButtonMessage("ÖNCEKİ KAMERA")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(2)
	PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, Keys["BACKSPACE"], true))
	InstructionButtonMessage("KAMERALARI KAPAT")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(80)
	PopScaleformMovieFunctionVoid()

	return scaleform
end

function InstructionButtonMessage(text)
	BeginTextCommandScaleformString("STRING")
	AddTextComponentScaleform(text)
	EndTextCommandScaleformString()
end

RegisterNetEvent('esx_securitycam:freeze')
AddEventHandler('esx_securitycam:freeze', function(freeze)
	FreezeEntityPosition(PlayerPedId(), freeze)
end)

Citizen.CreateThread(function()
	while true do
		local time = 1000
		if blockbuttons then
			time = 1
			DisableControlAction(2, 24, true)
			DisableControlAction(2, 257, true)
			DisableControlAction(2, 25, true)
			DisableControlAction(2, 263, true)
			DisableControlAction(2, Keys['R'], true)
			DisableControlAction(2, Keys['SPACE'], true)
			DisableControlAction(2, Keys['Q'], true)
			DisableControlAction(2, Keys['TAB'], true)
			DisableControlAction(2, Keys['F'], true)
			DisableControlAction(2, Keys['F1'], true)
			DisableControlAction(2, Keys['F2'], true)
			DisableControlAction(2, Keys['F3'], true)
			DisableControlAction(2, Keys['F6'], true)
			DisableControlAction(2, Keys['F7'], true)
			DisableControlAction(2, Keys['F10'], true)
		end
		Citizen.Wait(time)
	end
end)

function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)

	AddTextComponentString(text)
	DrawText(_x, _y)

	local factor = (string.len(text)) / 330
	DrawRect(_x, _y + 0.0150, 0.0 + factor, 0.035, 41, 11, 41, 100)
end

function vehicleType(using)
	local cars = Config.Cars
	for i=1, #cars, 1 do
		if IsVehicleModel(using, GetHashKey(cars[i])) then
		return true
		end
	end
end