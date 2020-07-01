# URL Schemes

URL Schemes 是 iOS Power User 必须了解的一种基础自动化技巧。
它最大的用处是可以让我们直达应用的某项功能，比如网易云音乐的听歌识曲，或者打开支付宝的扫码界面……而不必受到主屏角标、应用内广告、界面设计变化等等因素的干扰。
支持 URL Schemes 也是一个工具达到一定完成度的标志。对 URL Schemes 支持得比较完整的工具往往是同类翘楚，比如：OmniFocus、Things、Ulysses、Drafts……

## URL Schemes 使用上的常见问题

在使用 URL Schemes 时，最常见的问题是——不知道某个应用的具体 URL Schemes 是什么。这主要是因为 URL Schemes 没有编写的规范。对于用户来说，找一个应用的 URL Schemes 会遇到两大难题：

1. 无迹可寻：复杂 URL 是由每个开发者指定的，没有规律，甚至大多数应用没有复杂 URL。
2. 功能不全：因为每个功能都要开发者指定，所以一个 App 功能越多，复杂 URL 就越难覆盖它的全功能。

尽管 Power User 们可以根据文档查询、搜集数百条 URL，也还是解决不了这两个难题。

特别是对于我们经常使用的网页服务，国内如知乎、微博、淘宝等，国外有 YouTube、Twitter、Instagram、Wikipedia……使用复杂 URL 很难覆盖到它们客户端的所有功能，所以我们会发现它们甚至没有什么复杂 URL。很多我们需要的功能，比如说搜索、收藏、购物车之类的，也因为没有 URL，似乎也都没办法直接跳转。

但是，如果你经常使用国外这些服务，你可能会发现，有时候你点一个链接，比如在 Twitter 客户端点了一个 YouTube 的视频链接，它会跳转到 YouTube 客户端，并且直接打开这个视频。

实现这个效果的，就是苹果在 2015 年 WWDC 公布的 Universal Link。