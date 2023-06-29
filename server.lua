-- https://stackoverflow.com/questions/1745448/lua-plain-string-gsub
local function literalize(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c)
        return "%" .. c
    end)
end

local old_resource_manifest = {'resource_manifest_version \'77731fab-63ca-442c-a67b-abc70f28dfa5\'',
                               'resource_manifest_version \'44febabe-d386-4d18-afbe-5e627f4af937\''}

local function fix(s)
    for resources = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(resources);

        local __resource = LoadResourceFile(name, '__resource.lua');

        if (__resource) then
            print(('[InternalAC-FIX] -> Found OLD resource [%s]'):format(name));

            for _, manif in pairs(old_resource_manifest) do
                __resource = string.gsub(__resource, literalize(manif), '')
            end

            if not string.find(__resource, 'fx_version') then
                __resource = 'fx_version \'cerulean\'\n' .. __resource
            end

            if not string.find(__resource, 'games') and not string.find(__resource, 'game') then
                __resource = 'game \'gta5\'\n' .. __resource
            end

            print ( SaveResourceFile(name, 'fxmanifest.lua', __resource, -1) and ('[InternalAC-FIX] -> Fixed OLD resource [%s]'):format(name) or ('[InternalAC-FIX] -> Cannot fix [%s]'):format(name));

            os.remove(GetResourcePath(name) .. '__resource.lua');

            Wait(1500);
        end


        local fxmanifest = LoadResourceFile(name, 'fxmanifest.lua');

        if fxmanifest then
            local p = false;
            local f = true;
            for _, manif in pairs(old_resource_manifest) do
                if not f then
                    f = string.find(fxmanifest, manif)
                end
                fxmanifest = string.gsub(fxmanifest, literalize(manif), '')
            end


            if f then
                if not string.find(fxmanifest, 'fx_version') then
                    p = true;
                    fxmanifest = 'fx_version \'cerulean\'\n' .. fxmanifest
                end
    
                if not string.find(fxmanifest, 'games') and not string.find(fxmanifest, 'game') then
                    p = true;
                    fxmanifest = 'game \'gta5\'\n' .. fxmanifest
                end
            end


            if p then
                print(('[InternalAC-FIX] -> Fixed old manifest [%s]'):format(name));
            end
            SaveResourceFile(name, 'fxmanifest.lua', fxmanifest, -1);
        end

        if (not fxmanifest or fxmanifest == '') and (not __resource or __resource == '') then
            print(('[InternalAC-FIX] -> Empty resource manifest [%s]'):format(name));
        end

    end
end


local function show()
    for resources = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(resources);

        local __resource = LoadResourceFile(name, '__resource.lua');
        local fxmanifest = LoadResourceFile(name, 'fxmanifest.lua');
        
        if __resource and fxmanifest then
            print(('[InternalAC-FIX] -> Duplicated resource manifest [%s]. Please remove it'):format(name));
        end

        if (not fxmanifest or fxmanifest == '') and (not __resource or __resource == '') then
            print(('[InternalAC-FIX] -> Empty resource manifest [%s]'):format(name));
        end

    end
end

AddEventHandler('onResourceStart', function (r)
    if r == GetCurrentResourceName() then
        print('[InternalAC-FIX] -> Starting fixes...');
        fix();
        print('[InternalAC-FIX] -> Starting show...');
        show();
        print('[InternalAC-FIX] -> Done.');
    end
end)

-- Created by phantumf
