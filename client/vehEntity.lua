local buscando = false

if VehEntity.FindKeys.FindKey then
    local searchedVehicles = {}
    function FindKeys()
        local vehicle = cache.vehicle
        local plate = GetVehicleNumberPlateText(vehicle)
        local vehicles = lib.callback.await('mono_carkeys:getVehicles')
        if vehicle and not buscando then
            buscando = true
            for i = 1, #vehicles do
                local data = vehicles[i]
                if data.plate == plate then
                    return TriggerEvent('mono_carkeys:Notification', locale('title'), 'Este vehiculo te pertenese')
                end
            end
            if not searchedVehicles[plate] then
                if lib.progressBar({
                        duration = VehEntity.FindKeys.ProgressTime,
                        label = locale('buscando'),
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            car = false,
                        },
                    }) then
                    if math.random() > VehEntity.FindKeys.Probability then
                        TriggerEvent('mono_carkeys:Notification', locale('title'), locale('nokeysfound'))
                        searchedVehicles[plate] = true
                        buscando = false
                    else
                        TriggerEvent('mono_carkeys:Notification', locale('title'), locale('encontrada'))
                        TriggerServerEvent('mono_carkeys:CreateKey', plate)
                        searchedVehicles[plate] = true
                        buscando = false
                    end
                end
            else
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('buscado'))
                buscando = false
            end
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('dentrocar'))
        end
    end

    if VehEntity.FindKeys.FindKeyCommand then
        RegisterCommand(VehEntity.FindKeys.Command, function()
            if not buscando then
                FindKeys()
            end
        end)
    end
end

exports('FindKeys', FindKeys)

if VehEntity.FindKeys.FindKeyBind then
    lib.addKeybind({
        name = 'mono_carkeys_search',
        description = 'Buscar llaves en el vehiculo',
        defaultKey = VehEntity.FindKeys.FindKeyBindKEY,
        onPressed = function()
            if not buscando then
                FindKeys()
            end
        end
    })
end


function LockPick()
    local config = VehEntity.LockPick
    local ped = cache.ped
    local vehicle, vehicleCoords = lib.getClosestVehicle(cache.coords, 3, true)
    local DoorsStatus = GetVehicleDoorLockStatus(vehicle)
    lib.requestAnimDict(config.animDict)
    if vehicle then
        if config.SkillCheck then
            if DoorsStatus == 1 then
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
                    '#3232a8'
                )
                return
            end
            TaskPlayAnim(ped, config.animDict, config.anim, 8.0, 8.0, -1, 48, 1, false, false, false)
            local success = lib.skillCheck(table.unpack(config.Skills))
            if success then
                ClearPedTasks(ped)
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), 'LockPick success', 'car',
                    '#3232a8'
                )
                TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(vehicle), GetVehicleDoorLockStatus(vehicle))
                if math.random() < config.alarmProbability then
                    SetVehicleAlarmTimeLeft(vehicle, config.alarmTime)
                end
                if config.Disptach then
                    config.DispatchFunction(ped, vehicle, vehicleCoords)
                end
            else
                ClearPedTasks(ped)
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                    '#3232a8')
            end
        else
            if DoorsStatus == 1 then
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
                    '#3232a8'
                )
                return
            end
            if lib.progressBar({
                    duration = config.TimeProgress,
                    label = locale('LocPickProgress'),
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = config.animDict,
                        clip = config.anim
                    },
                }) then
                TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(vehicle), GetVehicleDoorLockStatus(vehicle))
                if math.random() < config.alarmProbability then
                    SetVehicleAlarmTimeLeft(vehicle, config.alarmTime)
                end
                if config.Disptach then
                    config.DispatchFunction(ped, vehicle, vehicleCoords)
                end
            else
                if math.random() < config.alarmProbability then
                    SetVehicleAlarmTimeLeft(vehicle, config.alarmTime)
                end
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                    '#3232a8')
            end
        end
    else
        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('nocarcerca'), 'car', '#3232a8')
    end
end

function HotWire()
    local config = VehEntity.HotWire
    local ped = cache.ped
    local vehicle = cache.vehicle
    lib.requestAnimDict(config.animDict)
    if vehicle then
        if config.SkillCheck then
            TaskPlayAnim(ped, config.animDict, config.anim, 8.0, 8.0, -1, 48, 1, false, false, false)
            local success = lib.skillCheck(table.unpack(config.Skills))
            if success then
                local engineRunning = GetIsVehicleEngineRunning(vehicle)
                if engineRunning then
                    SetVehicleEngineOn(vehicle, false, true, true)
                    if Keys.Debug then
                        print('Motor off')
                    end
                    DisableControlAction(2, 71, false)
                else
                    SetVehicleEngineOn(vehicle, true, true, true)
                    if Keys.Debug then
                        print('Motor on')
                    end
                end
                ClearPedTasks(ped)
            else
                TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
                    '#3232a8')
            end
        else
            if lib.progressBar({
                    duration = config.TimeProgress,
                    label = locale('LocPickProgress'),
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = config.animDict,
                        clip = config.anim
                    },
                }) then
                local engineRunning = GetIsVehicleEngineRunning(vehicle)
                if engineRunning then
                    SetVehicleEngineOn(vehicle, false, true, true)
                    if Keys.Debug then
                        print('Motor off')
                    end
                else
                    SetVehicleEngineOn(vehicle, true, true, true)
                    if Keys.Debug then
                        print('Motor on')
                    end
                end
            else
                if math.random() < config.alarmProbability then
                    SetVehicleAlarmTimeLeft(vehicle, config.alarmTime)
                end
                TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
                    '#3232a8')
            end
        end
    else
        TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireInCar'), 'car',
            '#3232a8')
    end
end

exports('HotWire', HotWire)

exports('LockPick', LockPick)
