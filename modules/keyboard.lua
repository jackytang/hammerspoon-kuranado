-- 该对象用于存储全局变量，避免每次获取速度都创建新的局部变量
local obj = {}
local usbWatcher = nil
local cliPath = "'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli'"

hs.inspect(hs.usb.attachedDevices())
function usbDeviceCallback(data)
    -- 在这里测试显示设备ID和拔插状态
    -- hs.alert.show(data.productID)
    -- hs.alert.show(data["eventType"])

    -- 当设备名称为 HHKB mod 时执行
    if (data["productName"] == "USB Keyboard") then
        if (data["eventType"] == "added") then -- 当键盘接入时
            hs.execute(cliPath .. " --select-profile IKBC")
            hs.alert.show("Keyboard detected.")
        elseif data["eventType"] == "removed" then -- 当键盘断开时
            hs.execute(cliPath .. " --select-profile Default")
            hs.alert.show("Keyboard removed.")
        end
    end
end
hs.usb.watcher.new(usbDeviceCallback):start()

function updateKarabinerConfig()
    obj.keyboard = "W200Mini"
    local output = hs.execute("/usr/local/bin/blueutil --is-connected 30-97-ce-6f-7c-b8");
    -- hs.alert.show(output:gsub('%s*$', ''))

    -- 蓝牙键盘连接成功
    if (output:gsub('%s*$', '') == "1") then
        hs.execute(cliPath .. " --select-profile IKBC")
        -- hs.alert.show("IkBC detected.")
    else
        hs.execute(cliPath .. " --select-profile Default")
        -- hs.alert.show("IKBC removed.")
    end
end

-- 第三个参数表示当发生异常情况时，定时器是否继续执行下去
obj.timer = hs.timer.doEvery(2, updateKarabinerConfig, true):start()
