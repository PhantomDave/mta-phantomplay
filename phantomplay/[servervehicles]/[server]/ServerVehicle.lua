ServerVehicle = {}
ServerVehicle.__index = ServerVehicle

function ServerVehicle:new(vehicleData)
    local instance = setmetatable({}, self)
    instance.id = vehicleData.id or 0
    instance.model = vehicleData.model
    instance.alias = vehicleData.alias or Vehicle.getNameFromModel(vehicleData.model)
    instance.owner = vehicleData.owner or 0
    instance.position = vehicleData.position or { x = 0, y = 0, z = 0 }
    instance.rotation = vehicleData.rotation or { x = 0, y = 0, z = 0 }
    instance.color = vehicleData.color or { r = 255, g = 255, b = 255 }
    instance.color2 = vehicleData.color2 or { r = 255, g = 255, b = 255 }
    instance.licensePlate = vehicleData.licensePlate or "UNKNOWN"
    instance.health = vehicleData.health or 1000
    instance.fuelType = vehicleData.fuelType or "petrol"
    instance.fuelLevel = vehicleData.fuelLevel or 100
    instance.isLocked = vehicleData.isLocked or false
    instance.isEngineOn = vehicleData.isEngineOn or false
    instance.vehicle = Vehicle(vehicleData.model, instance.position.x, instance.position.y, instance.position.z, 
                               instance.rotation.x, instance.rotation.y, instance.rotation.z)
    instance.vehicle:setColor(instance.color.r, instance.color.g, instance.color.b,
                                 instance.color2.r, instance.color2.g, instance.color2.b)
    instance.vehicle:setPlateText(instance.licensePlate)
    instance.vehicle:setHealth(instance.health)
    instance.vehicle:setEngineState(instance.isEngineOn)
    instance.vehicle:setLocked(instance.isLocked)
    instance.vehicle:spawn(instance.position.x, instance.position.y, instance.position.z, 
                           instance.rotation.x, instance.rotation.y, instance.rotation.z)
    return instance
end