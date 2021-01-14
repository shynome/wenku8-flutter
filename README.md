# wenku8

[轻小说文库](http://www.wenku8.net/index.php)的阅读器, 所有缓存内容都在 `wenku8.db` 这个 sqlite3 文件中.

## build

- 首先自行配置签名: https://flutter.cn/docs/deployment/android#create-a-keystore
- 自行全局替换包名: `com.shynome.wenku8`
- 编译 `flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi`
- 选择适合你手机架构的包进行安装, 如果不清楚的话在上一步使用 `flutter build apk` 进行编译
