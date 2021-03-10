# iOSMonkey
 
1.环境配置
1.1 安装第三方库
打开终端，进入XCTestWD目录,运行下面命令

carthage.sh bootstrap --platform iOS --cache-builds

xcode12比较特殊，参考下面配置方法
https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md

1.2 工程配置
XCTestWD->Signing&Capabilities->Team,使用自己的AppleID创建的Team
XCTestWD->Build Settings->Product Bundle Identifier,换一个不重复的id

XCTestWDUITests同样操作

2.运行
2.1 xcode
手机连接Mac，打开XCTestWD.xcodeproj，xcode中选择刚刚连接的手机，然后在Product->Scheme中选择XCTestWDUITests，Product->Test就可以跑Monkey测试了

2.2 命令行
首先，打开一个终端窗口，执行

iproxy 8001 8001

再打开一个终端，进入到XCTestWD.xcodeproj所在目录，执行下面命令

xcodebuild -project XCTestWD.xcodeproj \
           -scheme XCTestWDUITests \
           -destination 'platform=iOS,name=(your device name)' \
           XCTESTWD_PORT=8001 \
           clean test
           
打开第三个终端，运行下面命令,Monkey测试就能跑起来

curl -X POST -H "Content-Type:application/json" -d "{\"desiredCapabilities\":{\"deviceName\":\"(your device name)\",\"platformName\":\"iOS\", \"bundleId\":\"com.sina.sinanews\",\"autoAcceptAlerts\":\"false\"}}" http://127.0.0.1:8001/wd/hub/monkey
