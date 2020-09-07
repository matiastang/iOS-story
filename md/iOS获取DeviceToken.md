# 获取设备DeviceToken

```swift
// MARK: - APNs注册成功
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // deviceToken
let deviceTokenStr = deviceToken.map{String(format:"%02.2hhx", arguments: [$0]) }.joined()
print("设备token--- \(deviceTokenStr)")
var deviceTokenString = String()
let bytes = [UInt8](deviceToken)
for item in bytes {
    deviceTokenString+=String(format:"%02x", item&0x000000FF)
}
print("设备token1--- \(deviceTokenStr)")
}
```