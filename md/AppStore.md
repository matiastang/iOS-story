# AppStore

## 代码检查

* 提示使用了`UIWebView`

[UIWebView 被废弃](https://developer.apple.com/documentation/uikit/uiwebview)
[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)

打开终端，cd到项目根目录。
执行以下命令，就能看到哪些文件内还在有UIWebview的踪迹。
```
$ grep -r UIWebView .
```
查询没有发现使用了`UIWebView`，很早以前就使用`WKWebView`了，后面发现是微信的`SDK`版本比较低，于是更新了微信`SDK`就可以了。
更新微信`SDK`(1.8.7.1)后，又有些内容更新，需要传入`universalLink`，[universalLink制作和使用](https://github.com/matiastang/iOS-story/blob/master/md/iOS_universalLink.md)。

## 被拒处理

* 公司产品“云玺”是一款使用了蓝牙的App，审核时被要求邮寄硬件到美国!后电话沟通，录制一个使用视频传到网上，在提审信息给出视频链接，最终通过审核。