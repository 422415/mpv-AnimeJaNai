-- Run with the packaged backend script and managed profiles, in an idle mpv.
local mp = require 'mp'
local mode = mp.get_opt('cadence-test')
local function check(key, expected)
    local actual = mp.get_property(key)
    if actual ~= expected then
        error(key .. ': expected ' .. expected .. ', got ' .. tostring(actual))
    end
end
local function step(fn)
    local ok, err = pcall(fn)
    if not ok then mp.msg.error(err); mp.commandv('quit', 1) end
end
mp.add_timeout(0.3, function() step(function()
    local enabled = mode == 'on' or mode == 'custom'
    check('camera-pan-smoothing', enabled and 'yes' or 'no')
    check('camera-cadence', 'no')
    check('camera-pan-half-rate', 'no')
    check('camera-pan-refreshes', '0')
    if enabled then check('vulkan-queue-count', '3') end
    check('video-sync', enabled and 'display-resample' or 'audio')
    check('interpolation', enabled and 'no' or 'yes')
    check('blend-subtitles', enabled and 'no' or 'yes')
    check('display-rate-match', enabled and 'no' or 'yes')
    check('gpu-api', mode == 'directml' and 'd3d11' or enabled and 'vulkan' or 'auto')
    if mode == 'directml' then check('hwdec', 'd3d11va') end
    mp.commandv('keypress', 'F8')
    mp.add_timeout(0.1, function() step(function()
        check('camera-pan-smoothing', mode == 'custom' and 'yes' or 'no')
        if mode == 'custom' then
            assert(mp.get_property_native('user-data/cadence-custom-hit') == 'yes', 'Custom F8 binding did not run')
        end
        mp.commandv('keypress', 'F8')
        mp.add_timeout(0.1, function() step(function()
            check('camera-pan-smoothing', enabled and 'yes' or 'no')
            check('display-rate-match', enabled and 'no' or 'yes')
            mp.msg.info('PASS camera pan smoothing startup and F8: ' .. mode)
            mp.commandv('quit', 0)
        end) end)
    end) end)
end) end)
mp.add_timeout(5, function() mp.msg.error('Test timed out'); mp.commandv('quit', 1) end)
