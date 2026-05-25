# TickTick 构建教程 — Windows 中国国内环境

本教程覆盖在 Windows 系统、国内网络环境下从零构建本项目。

---

## 1. 环境准备

### 1.1 安装 Git

下载安装 [Git for Windows](https://git-scm.com/download/win)，安装时选默认选项即可。

验证：
```powershell
git --version
```

### 1.2 安装 Flutter SDK

由于国内无法直接访问 Google 服务，使用 Flutter 镜像源。

**方案 A：使用上海交大镜像（推荐）**

```powershell
# 设置临时环境变量（当前终端有效）
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# 下载 Flutter SDK（PowerShell）
git clone https://github.com/flutter/flutter.git -b stable C:\flutter
```

**方案 B：使用 GitCode 镜像**

```powershell
git clone https://gitcode.com/flutter/flutter.git -b stable C:\flutter
```

**永久设置环境变量**（推荐）：

1. 按 `Win + R`，输入 `sysdm.cpl`
2. 高级 → 环境变量 → 系统变量 → 新建：
   - 变量名：`PUB_HOSTED_URL`，值：`https://pub.flutter-io.cn`
   - 变量名：`FLUTTER_STORAGE_BASE_URL`，值：`https://storage.flutter-io.cn`
3. 编辑 `Path`，添加 `C:\flutter\bin`
4. 重启终端

### 1.3 安装 Android Studio

1. 从 [developer.android.com](https://developer.android.com/studio) 下载 Android Studio
2. 安装时勾选 **Android SDK** 和 **Android Virtual Device**
3. 首次启动后按照向导安装 Android SDK（建议选 API 34+）

### 1.4 安装 JDK

Android Studio 自带 JDK（位于 `C:\Program Files\Android\Android Studio\jbr`），通常不需要单独安装。

验证：
```powershell
# 在 PowerShell 中
C:\flutter\bin\flutter doctor
```

如果提示找不到 Android SDK，设置：
```powershell
$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
```

---

## 2. 克隆项目

```powershell
cd ~\Projects
git clone <你的仓库地址> TickTick
cd TickTick
```

---

## 3. 配置 Gradle 国内镜像

Gradle 默认从 `services.gradle.org` 和 `repo.maven.apache.org` 下载依赖，国内需要配置镜像。

### 3.1 配置腾讯云 Gradle 镜像

编辑 `android/build.gradle.kts`（项目根目录的 build.gradle.kts），在 `buildscript` 和 `allprojects` 的 `repositories` 中添加国内镜像。

翻看项目中的 `android/build.gradle.kts`，确保 `repositories` 部分类似：

```kotlin
repositories {
    maven { url = uri("https://mirrors.cloud.tencent.com/gradle") }
    maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public") }
    google()
    mavenCentral()
    gradlePluginPortal()
}
```

### 3.2 配置 settings.gradle.kts

编辑 `android/settings.gradle.kts`：

```kotlin
pluginManagement {
    repositories {
        maven { url = uri("https://mirrors.cloud.tencent.com/gradle") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public") }
        google()
        mavenCentral()
    }
}
```

### 3.3 配置 Gradle Wrapper

编辑 `android/gradle/wrapper/gradle-wrapper.properties`，确认版本与项目中一致，国内可用腾讯云下载：

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

---

## 4. 安装依赖

```powershell
cd TickTick
flutter pub get
```

如果下载卡住，检查环境变量 `PUB_HOSTED_URL` 是否正确设置为 `https://pub.flutter-io.cn`。

---

## 5. 生成代码

```powershell
dart run build_runner build --delete-conflicting-outputs
```

这一步生成 drift 数据库代码和 freezed 实体代码。如果失败，尝试：

```powershell
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## 6. 构建 APK

### 6.1 Debug 版本（快速构建）

```powershell
flutter build apk --debug
```

输出路径：`build/app/outputs/flutter-apk/app-debug.apk`

### 6.2 Release 版本（发布用）

```powershell
flutter build apk --release
```

输出路径：`build/app/outputs/flutter-apk/app-release.apk`

---

## 7. 常见问题

### 7.1 Gradle 下载失败

**现象：** `Could not download gradle-8.14-all.zip`

**解决：**
1. 手动下载：浏览器打开 `https://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip`
2. 放到 `C:\Users\<用户名>\.gradle\wrapper\dists\gradle-8.14-all\<随机hash>\`
3. 不用解压，重新运行构建即可

### 7.2 Maven 依赖下载超时

**现象：** `Could not resolve com.android.tools.build:gradle:8.11.1`

**解决：** 检查 `android/build.gradle.kts` 中是否已添加腾讯云 Maven 镜像（见步骤 3.1）。

### 7.3 pub get 卡住

**现象：** `flutter pub get` 长时间无响应

**解决：**
```powershell
# 确认环境变量
echo $env:PUB_HOSTED_URL

# 如果为空，设置后重试
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
flutter pub get
```

### 7.4 build_runner 报错

**现象：** `build_runner` 代码生成失败

**解决：**
```powershell
# 清理缓存
dart run build_runner clean
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 7.5 Android SDK 版本不匹配

**现象：** `compileSdkVersion 34 not found`

**解决：** 打开 Android Studio → SDK Manager → 安装对应的 SDK Platform 和 Build Tools。

---

## 8. 可选：直接安装成品 APK

如果只需要使用而不是修改代码，构建完 Debug APK 后：

```powershell
# 连接手机，开启 USB 调试
flutter install
# 或者直接复制 APK 到手机安装
explorer build\app\outputs\flutter-apk\
```

---

## 9. 镜像源汇总

| 用途 | 镜像地址 |
|------|---------|
| Dart Pub | `https://pub.flutter-io.cn` |
| Flutter SDK | `https://storage.flutter-io.cn` |
| Gradle | `https://mirrors.cloud.tencent.com/gradle` |
| Maven | `https://mirrors.cloud.tencent.com/nexus/repository/maven-public` |

---

## 反馈

构建遇到问题？检查以下几点：
1. 确认所有环境变量已永久设置（非临时终端变量）
2. 确认 Android Studio 的 SDK Manager 已安装所需 SDK
3. 确认 Gradle 镜像配置在正确的文件中（`android/build.gradle.kts` 和 `settings.gradle.kts`）
