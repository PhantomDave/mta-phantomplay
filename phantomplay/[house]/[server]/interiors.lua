-- Interior coordinates table
-- Source: http://weedarr.wikidot.com/interior
-- Format: {id, name, x, y, z, interior_id}

local interiors = {
    -- 24/7 Stores
    {id = 1, name = "24/7 1", x = -25.884498, y = -185.868988, z = 1003.546875, interior = 17},
    {id = 2, name = "24/7 2", x = 6.091179, y = -29.271898, z = 1003.549438, interior = 10},
    {id = 3, name = "24/7 3", x = -30.946699, y = -89.609596, z = 1003.546875, interior = 18},
    {id = 4, name = "24/7 4", x = -25.132598, y = -139.066986, z = 1003.546875, interior = 16},
    {id = 5, name = "24/7 5", x = -27.312299, y = -29.277599, z = 1003.557250, interior = 4},
    {id = 6, name = "24/7 6", x = -26.691598, y = -55.714897, z = 1003.546875, interior = 6},
    
    -- Airport
    {id = 7, name = "Airport ticket desk", x = -1827.147338, y = 7.207417, z = 1061.143554, interior = 14},
    {id = 8, name = "Airport baggage reclaim", x = -1861.936889, y = 54.908092, z = 1061.143554, interior = 14},
    
    -- Aircraft Interiors
    {id = 9, name = "Shamal", x = 1.808619, y = 32.384357, z = 1199.593750, interior = 1},
    {id = 10, name = "Andromada", x = 315.745086, y = 984.969299, z = 1958.919067, interior = 9},
    
    -- Ammunation Stores
    {id = 11, name = "Ammunation 1", x = 286.148986, y = -40.644397, z = 1001.515625, interior = 1},
    {id = 12, name = "Ammunation 2", x = 286.800994, y = -82.547599, z = 1001.515625, interior = 4},
    {id = 13, name = "Ammunation 3", x = 296.919982, y = -108.071998, z = 1001.515625, interior = 6},
    {id = 14, name = "Ammunation 4", x = 314.820983, y = -141.431991, z = 999.601562, interior = 7},
    {id = 15, name = "Ammunation 5", x = 316.524993, y = -167.706985, z = 999.593750, interior = 6},
    {id = 16, name = "Ammunation booths", x = 302.292877, y = -143.139099, z = 1004.062500, interior = 7},
    {id = 17, name = "Ammunation range", x = 298.507934, y = -141.647048, z = 1004.054748, interior = 7},
    
    -- Various Shops and Buildings
    {id = 18, name = "Blastin fools hallway", x = 1038.531372, y = 0.111030, z = 1001.284484, interior = 3},
    {id = 19, name = "Budget inn motel room", x = 444.646911, y = 508.239044, z = 1001.419494, interior = 12},
    {id = 20, name = "Jefferson motel", x = 2215.454833, y = -1147.475585, z = 1025.796875, interior = 15},
    {id = 21, name = "Off track betting shop", x = 833.269775, y = 10.588416, z = 1004.179687, interior = 3},
    {id = 22, name = "Sex shop", x = -103.559165, y = -24.225606, z = 1000.718750, interior = 3},
    {id = 23, name = "Meat factory", x = 963.418762, y = 2108.292480, z = 1011.030273, interior = 1},
    {id = 24, name = "Zero's RC shop", x = -2240.468505, y = 137.060440, z = 1035.414062, interior = 6},
    {id = 25, name = "Dillimore gas station", x = 663.836242, y = -575.605407, z = 16.343263, interior = 0},
    {id = 26, name = "Catigula's basement", x = 2169.461181, y = 1618.798339, z = 999.976562, interior = 1},
    
    -- FDC and Offices
    {id = 27, name = "FDC Janitors room", x = 1889.953369, y = 1017.438293, z = 31.882812, interior = 10},
    {id = 28, name = "Woozie's office", x = -2159.122802, y = 641.517517, z = 1052.381713, interior = 1},
    
    -- Clothing Stores
    {id = 29, name = "Binco", x = 207.737991, y = -109.019996, z = 1005.132812, interior = 15},
    {id = 30, name = "Didier sachs", x = 204.332992, y = -166.694992, z = 1000.523437, interior = 14},
    {id = 31, name = "Prolaps", x = 207.054992, y = -138.804992, z = 1003.507812, interior = 3},
    {id = 32, name = "Suburban", x = 203.777999, y = -48.492397, z = 1001.804687, interior = 1},
    {id = 33, name = "Victim", x = 226.293991, y = -7.431529, z = 1002.210937, interior = 5},
    {id = 34, name = "Zip", x = 161.391006, y = -93.159156, z = 1001.804687, interior = 18},
    
    -- Entertainment Venues
    {id = 35, name = "Club", x = 493.390991, y = -22.722799, z = 1000.679687, interior = 17},
    {id = 36, name = "Bar", x = 501.980987, y = -69.150199, z = 998.757812, interior = 11},
    {id = 37, name = "Lil' probe inn", x = -227.027999, y = 1401.229980, z = 27.765625, interior = 18},
    
    -- Restaurants and Diners
    {id = 38, name = "Jay's diner", x = 457.304748, y = -88.428497, z = 999.554687, interior = 4},
    {id = 39, name = "Gant bridge diner", x = 454.973937, y = -110.104995, z = 1000.077209, interior = 5},
    {id = 40, name = "Secret valley diner", x = 435.271331, y = -80.958938, z = 999.554687, interior = 6},
    {id = 41, name = "World of coq", x = 452.489990, y = -18.179698, z = 1001.132812, interior = 1},
    {id = 42, name = "Welcome pump", x = 681.557861, y = -455.680053, z = -25.609874, interior = 1},
    {id = 43, name = "Burger shot", x = 375.962463, y = -65.816848, z = 1001.507812, interior = 10},
    {id = 44, name = "Cluckin' bell", x = 369.579528, y = -4.487294, z = 1001.858886, interior = 9},
    {id = 45, name = "Well stacked pizza", x = 373.825653, y = -117.270904, z = 1001.499511, interior = 5},
    {id = 46, name = "Rusty browns donuts", x = 381.169189, y = -188.803024, z = 1000.632812, interior = 17},
    
    -- Girlfriend Houses
    {id = 47, name = "Denise room", x = 244.411987, y = 305.032989, z = 999.148437, interior = 1},
    {id = 48, name = "Katie room", x = 271.884979, y = 306.631988, z = 999.148437, interior = 2},
    {id = 49, name = "Helena room", x = 291.282989, y = 310.031982, z = 999.148437, interior = 3},
    {id = 50, name = "Michelle room", x = 302.180999, y = 300.722991, z = 999.148437, interior = 4},
    {id = 51, name = "Barbara room", x = 322.197998, y = 302.497985, z = 999.148437, interior = 5},
    {id = 52, name = "Millie room", x = 346.870025, y = 309.259033, z = 999.155700, interior = 6},
    
    -- Special Locations
    {id = 53, name = "Sherman dam", x = -959.564392, y = 1848.576782, z = 9.000000, interior = 17},
    {id = 54, name = "Planning dept.", x = 384.808624, y = 173.804992, z = 1008.382812, interior = 3},
    {id = 55, name = "Area 51", x = 223.431976, y = 1872.400268, z = 13.734375, interior = 0},
    
    -- Gyms
    {id = 56, name = "LS gym", x = 772.111999, y = -3.898649, z = 1000.728820, interior = 5},
    {id = 57, name = "SF gym", x = 774.213989, y = -48.924297, z = 1000.585937, interior = 6},
    {id = 58, name = "LV gym", x = 773.579956, y = -77.096694, z = 1000.655029, interior = 7},
    
    -- Gang Houses and Story Houses
    {id = 59, name = "B Dup's house", x = 1527.229980, y = -11.574499, z = 1002.097106, interior = 3},
    {id = 60, name = "B Dup's crack pad", x = 1523.509887, y = -47.821197, z = 1002.130981, interior = 2},
    {id = 61, name = "Cj's house", x = 2496.049804, y = -1695.238159, z = 1014.742187, interior = 3},
    {id = 62, name = "Madd Doggs mansion", x = 1267.663208, y = -781.323242, z = 1091.906250, interior = 5},
    {id = 63, name = "Og Loc's house", x = 513.882507, y = -11.269994, z = 1001.565307, interior = 3},
    {id = 64, name = "Ryders house", x = 2454.717041, y = -1700.871582, z = 1013.515197, interior = 2},
    {id = 65, name = "Sweet's house", x = 2527.654052, y = -1679.388305, z = 1015.498596, interior = 1},
    {id = 66, name = "Crack factory", x = 2543.462646, y = -1308.379882, z = 1026.728393, interior = 2},
    
    -- Adult Entertainment
    {id = 67, name = "Big spread ranch", x = 1212.019897, y = -28.663099, z = 1000.953125, interior = 3},
    {id = 68, name = "Fanny batters", x = 761.412963, y = 1440.191650, z = 1102.703125, interior = 6},
    {id = 69, name = "Strip club", x = 1204.809936, y = -11.586799, z = 1000.921875, interior = 2},
    {id = 70, name = "Strip club private room", x = 1204.809936, y = 13.897239, z = 1000.921875, interior = 2},
    {id = 71, name = "Unnamed brothel", x = 942.171997, y = -16.542755, z = 1000.929687, interior = 3},
    {id = 72, name = "Tiger skin brothel", x = 964.106994, y = -53.205497, z = 1001.124572, interior = 3},
    {id = 73, name = "Pleasure domes", x = -2640.762939, y = 1406.682006, z = 906.460937, interior = 3},
    
    -- Liberty City
    {id = 74, name = "Liberty city outside", x = -729.276000, y = 503.086944, z = 1371.971801, interior = 1},
    {id = 75, name = "Liberty city inside", x = -794.806396, y = 497.738037, z = 1376.195312, interior = 1},
    
    -- Various Buildings
    {id = 76, name = "Gang house", x = 2350.339843, y = -1181.649902, z = 1027.976562, interior = 5},
    {id = 77, name = "Colonel Furhberger's", x = 2807.619873, y = -1171.899902, z = 1025.570312, interior = 8},
    {id = 78, name = "Crack den", x = 318.564971, y = 1118.209960, z = 1083.882812, interior = 5},
    {id = 79, name = "Warehouse 1", x = 1412.639892, y = -1.787510, z = 1000.924377, interior = 1},
    {id = 80, name = "Warehouse 2", x = 1302.519897, y = -1.787510, z = 1001.028259, interior = 18},
    {id = 81, name = "Sweets garage", x = 2522.000000, y = -1673.383911, z = 14.866223, interior = 0},
    {id = 82, name = "Lil' probe inn toilet", x = -221.059051, y = 1408.984008, z = 27.773437, interior = 18},
    {id = 83, name = "Unused safe house", x = 2324.419921, y = -1145.568359, z = 1050.710083, interior = 12},
    {id = 84, name = "RC Battlefield", x = -975.975708, y = 1060.983032, z = 1345.671875, interior = 10},
    
    -- Barber Shops
    {id = 85, name = "Barber 1", x = 411.625976, y = -21.433298, z = 1001.804687, interior = 2},
    {id = 86, name = "Barber 2", x = 418.652984, y = -82.639793, z = 1001.804687, interior = 3},
    {id = 87, name = "Barber 3", x = 412.021972, y = -52.649898, z = 1001.898437, interior = 12},
    
    -- Tattoo Parlours
    {id = 88, name = "Tatoo parlour 1", x = -204.439987, y = -26.453998, z = 1002.273437, interior = 16},
    {id = 89, name = "Tatoo parlour 2", x = -204.439987, y = -8.469599, z = 1002.273437, interior = 17},
    {id = 90, name = "Tatoo parlour 3", x = -204.439987, y = -43.652496, z = 1002.273437, interior = 3},
    
    -- Police Headquarters
    {id = 91, name = "LS police HQ", x = 246.783996, y = 63.900199, z = 1003.640625, interior = 6},
    {id = 92, name = "SF police HQ", x = 246.375991, y = 109.245994, z = 1003.218750, interior = 10},
    {id = 93, name = "LV police HQ", x = 288.745971, y = 169.350997, z = 1007.171875, interior = 3},
    
    -- Driving Schools and Racing
    {id = 94, name = "Car school", x = -2029.798339, y = -106.675910, z = 1035.171875, interior = 3},
    {id = 95, name = "8-Track", x = -1398.065307, y = -217.028900, z = 1051.115844, interior = 7},
    {id = 96, name = "Bloodbowl", x = -1398.103515, y = 937.631164, z = 1036.479125, interior = 15},
    {id = 97, name = "Dirt track", x = -1444.645507, y = -664.526000, z = 1053.572998, interior = 4},
    {id = 98, name = "Kickstart", x = -1465.268676, y = 1557.868286, z = 1052.531250, interior = 14},
    {id = 99, name = "Vice stadium", x = -1401.829956, y = 107.051300, z = 1032.273437, interior = 1},
    
    -- Garages and Workshops
    {id = 100, name = "SF Garage", x = -1790.378295, y = 1436.949829, z = 7.187500, interior = 0},
    {id = 101, name = "LS Garage", x = 1643.839843, y = -1514.819580, z = 13.566620, interior = 0},
    {id = 102, name = "SF Bomb shop", x = -1685.636474, y = 1035.476196, z = 45.210937, interior = 0},
    
    -- Warehouses
    {id = 103, name = "Blueberry warehouse", x = 76.632553, y = -301.156829, z = 1.578125, interior = 0},
    {id = 104, name = "LV Warehouse 1", x = 1059.895996, y = 2081.685791, z = 10.820312, interior = 0},
    {id = 105, name = "LV Warehouse 2 (hidden part)", x = 1059.180175, y = 2148.938720, z = 10.820312, interior = 0},
    
    -- Special Rooms
    {id = 106, name = "Catigula's hidden room", x = 2131.507812, y = 1600.818481, z = 1008.359375, interior = 1},
    {id = 107, name = "Bank", x = 2315.952880, y = -1.618174, z = 26.742187, interior = 0},
    {id = 108, name = "Bank (behind desk)", x = 2319.714843, y = -14.838361, z = 26.749565, interior = 0},
    {id = 109, name = "LS Atruim", x = 1710.433715, y = -1669.379272, z = 20.225049, interior = 18},
    {id = 110, name = "Bike School", x = 1494.325195, y = 1304.942871, z = 1093.289062, interior = 3},
}

-- Function to get interior data by unique ID
function getInteriorByID(id)
    for i, interior in ipairs(interiors) do
        if interior.id == id then
            return interior
        end
    end
    return nil
end

-- Function to get interior data by name
function getInteriorByName(name)
    for i, interior in ipairs(interiors) do
        if interior.name == name then
            return interior
        end
    end
    return nil
end

-- Function to get interior data by interior world ID
function getInteriorsByWorldID(interiorID)
    local result = {}
    for i, interior in ipairs(interiors) do
        if interior.interior == interiorID then
            table.insert(result, interior)
        end
    end
    return result
end

-- Function to get all interiors
function getAllInteriors()
    return interiors
end

-- Function to search interiors by partial name match
function searchInteriorsByName(searchTerm)
    local result = {}
    local lowerSearchTerm = string.lower(searchTerm)
    for i, interior in ipairs(interiors) do
        if string.find(string.lower(interior.name), lowerSearchTerm) then
            table.insert(result, interior)
        end
    end
    return result
end

-- Function to get random interior
function getRandomInterior()
    if #interiors > 0 then
        local randomIndex = math.random(1, #interiors)
        return interiors[randomIndex]
    end
    return nil
end

return {
    interiors = interiors,
    getInteriorByID = getInteriorByID,
    getInteriorByName = getInteriorByName,
    getInteriorsByWorldID = getInteriorsByWorldID,
    getAllInteriors = getAllInteriors,
    searchInteriorsByName = searchInteriorsByName,
    getRandomInterior = getRandomInterior
}