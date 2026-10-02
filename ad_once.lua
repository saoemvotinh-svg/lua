-- ================================================================
--  HGMOD AD_ONCE — goi DUY NHAT MOT LAN PlayAdvertising tren game VM
--  Dieu kien: agent da inject + dang trong map (G.ready() = true)
--  Chay: F5 trong LuaForge. Khong loop, khong spam.
--
--  Chu ky doc tu build\game_symbols.txt (chua disassemble):
--    MNSandbox::AdvertisementService::PlayAdvertising(int, bool)
--      ?PlayAdvertising@AdvertisementService@MNSandbox@@QAEXH_N@Z
--      H = int, _N = bool, X = void  -> y nghia tham so CHUA xac minh
--    ket qua ad quay lai qua OnRespWatchAD* / OnWatchADResult (server)
--
--  Luu y: print() ben game VM bi bat vao shm.execOut va chi duoc
--  hien khi toan bo script chay tren game VM, nen chunk o duoi
--  return string thay vi print.
-- ================================================================

local AD_SLOT = 0     -- int   (chua xac minh: id / vi tri / loai ad)
local AD_FLAG = true  -- bool  (chua xac minh)

-- chunk 1: doc type cac ung vien (chi doc, khong gay tac dong)
local PROBE = [=[
local names = {"PlayAdvertising", "TriggerToPlayAD", "TriggerToPlayADWithMsgbox",
               "LuckSquare_PlayAd", "OnWatchADResult", "PLAYAD_SUCCESS"}
local t = {}
for i = 1, #names do
  t[#t + 1] = names[i] .. "=" .. type(_G[names[i]])
end
return table.concat(t, " ")
]=]

-- chunk 2: MOT LAN goi PlayAdvertising
local CALL = string.format([[
if type(_G.PlayAdvertising) ~= "function" then
  return "PlayAdvertising khong co trong game VM (type=" .. type(_G.PlayAdvertising) .. ")"
end
local ok, err = pcall(_G.PlayAdvertising, %d, %s)
return ok and "PlayAdvertising(%d, %s) -> OK" or ("ERR: " .. tostring(err))
]], AD_SLOT, tostring(AD_FLAG), AD_SLOT, tostring(AD_FLAG))

local function run(code, label)
    local ok, a, b = pcall(G.exec, code)
    if not ok then
        print(label .. " loi pc: " .. tostring(a))
        return false
    end
    if a == nil and b ~= nil then
        print(label .. " loi: " .. tostring(b))
        return false
    end
    print(label .. " " .. tostring(a))
    return true
end

local function main()
    if not G then
        print("[ad] G = nil — khong co game-VM bridge")
        return
    end

    local okR, ready, detail = pcall(function() return G.ready() end)
    if not okR then
        print("[ad] G.ready loi: " .. tostring(ready))
        return
    end
    if ready ~= true then
        print("[ad] khong san sang: " .. tostring(detail or ready))
        return
    end
    print("[ad] game VM: " .. tostring(detail))

    run(PROBE, "[ad] probe:")
    run(CALL,  "[ad] goi 1 lan:")
end

main()
