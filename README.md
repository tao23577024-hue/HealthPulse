# HealthPulse — 健康脉搏

> 融合 Health Companion 功能架构与 HealthHub 数据层的 iOS 健康整合App
> iOS 16+ · SwiftUI · HealthKit · 纯本地存储 · 苹果原生风格UI

## 项目简介

HealthPulse 是一个专为 iOS 16 设计的健康数据整合应用，将心率、步数、睡眠、健身、心情等健康数据统一展示在一个优雅的苹果原生风格界面中。

本项目融合了两个优秀开源项目的优势：
- **Health Companion** 的功能架构：洞察引擎、用药管理、健康日志、心情记录、纯本地隐私设计
- **HealthHub** 的数据层理念：统一的 HealthKit 数据访问、协议驱动架构、完整的健康数据类型覆盖

## 功能特性

### 🏠 概览仪表盘
- 活动三环展示（活动能量 / 锻炼时间 / 站立小时）
- 今日核心指标网格（步数、睡眠、卡路里、锻炼）
- 心率详情卡片（当前心率、静息心率、HRV、血氧 + 周趋势图）
- 睡眠概览（睡眠时长环 + 睡眠阶段统计）
- 最近锻炼记录
- 智能健康洞察（自动分析趋势，每条附带证据）

### ❤️ 健康数据
- 按类别浏览所有健康指标（心脏 / 活动 / 身体）
- 每个指标的详情页：大数值展示、趋势图表、统计信息、科普说明
- 支持心率、静息心率、HRV、血氧、步数、卡路里、锻炼、站立、睡眠、体重、体脂、VO₂ Max

### 😴 睡眠分析
- 睡眠评分系统（时长50% + 深睡30% + 效率20%）
- 睡眠阶段时间线可视化（深睡 / REM / 核心 / 清醒）
- 各阶段时长和占比统计
- 本周睡眠趋势柱状图
- 科学睡眠建议

### 🏃 健身追踪
- 今日活动四指标（步数 / 卡路里 / 锻炼 / 站立）
- 本周步数趋势图
- 锻炼类型筛选（跑步 / 步行 / 骑行 / 游泳 / 力量训练 / 瑜伽等）
- 锻炼记录详情（时长、消耗、距离、平均心率）
- 本周统计汇总

### 📔 健康日志
- 记录日常健康感受、症状、疼痛程度
- 心情评分（5级表情量表）
- 疼痛等级滑块（0-10）
- 常见症状快速选择（38种）
- 自定义标签
- 滑动删除

### 🧠 心情记录
- 5级整体心情 + 30种具体情绪选择
- 20种生活关联因素
- 心情趋势折线图
- GAD-7 焦虑量表 / PHQ-9 抑郁量表自评
- 心理健康资源和求助热线

### ⚙️ 设置
- HealthKit 授权管理
- 活动目标自定义（步数 / 卡路里 / 睡眠）
- 通知权限和用药提醒
- 演示数据开关
- 数据保存和管理

## 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | Swift 5.9 |
| UI | SwiftUI |
| 最低系统 | iOS 16.0 |
| 状态管理 | ObservableObject + @Published（iOS 16兼容） |
| 健康数据 | HealthKit（原生API，兼容HealthHub架构） |
| 图表 | Swift Charts（iOS 16+） |
| 本地存储 | UserDefaults（JSON编码） |
| 通知 | UserNotifications |
| 架构 | MVVM + 服务层 |
| 依赖管理 | Swift Package Manager |

## 项目结构

```
HealthPulse/
├── HealthPulse.xcodeproj/
│   └── project.pbxproj
├── HealthPulse/
│   ├── App/                          # 应用入口和全局状态
│   │   ├── HealthPulseApp.swift      # @main 入口
│   │   ├── AppState.swift            # 全局状态管理（ObservableObject）
│   │   └── ContentView.swift         # 底部Tab导航 + 更多页面
│   ├── Models/                       # 数据模型
│   │   ├── HealthModels.swift        # 健康指标、睡眠、锻炼、洞察等
│   │   ├── Medication.swift          # 用药模型
│   │   ├── JournalEntry.swift        # 日志模型 + 症状枚举
│   │   └── MoodEntry.swift           # 心情模型 + 情绪/关联/量表
│   ├── Services/                     # 服务层
│   │   ├── HealthStoreManager.swift  # HealthKit数据查询（兼容HealthHub架构）
│   │   ├── InsightsEngine.swift      # 健康洞察引擎（纯函数规则引擎）
│   │   └── NotificationManager.swift # 本地通知管理
│   ├── Components/                   # 通用UI组件
│   │   ├── CardView.swift            # 卡片容器 + 可点击卡片
│   │   ├── ProgressRing.swift        # 活动环 + 多环 + 水平进度条
│   │   ├── HealthMetricRow.swift     # 指标行 + 简单指标行
│   │   └── SegmentedControl.swift    # 分段控件 + 时间范围选择 + 筛选标签
│   ├── Features/                     # 功能页面
│   │   ├── Dashboard/                # 概览仪表盘
│   │   │   ├── DashboardView.swift
│   │   │   ├── HealthMetricCard.swift
│   │   │   └── InsightsSection.swift
│   │   ├── HealthData/               # 健康数据列表和详情
│   │   │   ├── HealthDataView.swift
│   │   │   └── MetricDetailView.swift
│   │   ├── Sleep/                    # 睡眠分析
│   │   │   └── SleepView.swift
│   │   ├── Fitness/                  # 健身追踪
│   │   │   └── FitnessView.swift
│   │   ├── Journal/                  # 健康日志
│   │   │   └── JournalView.swift
│   │   ├── Mind/                     # 心情记录
│   │   │   ├── MindView.swift
│   │   │   └── MoodEntryViews.swift
│   │   └── Settings/                 # 设置
│   │       └── SettingsView.swift
│   ├── Support/                      # 支持文件
│   │   ├── ColorExtensions.swift     # 主题颜色 + 渐变 + 字体 + View扩展
│   │   ├── DateExtensions.swift      # 日期格式化 + Double/Int扩展
│   │   └── PreviewData.swift         # 演示数据
│   ├── Assets.xcassets/              # 资源文件
│   └── Info.plist                    # 配置文件
└── README.md
```

## 编译要求

- **Xcode 15.0** 或更高版本
- **iOS 16.0** 或更高版本（部署目标）
- **macOS 13.0 (Ventura)** 或更高版本（运行Xcode 15）
- 物理 iPhone（HealthKit 功能需要真机，模拟器可用演示数据）

## 如何编译和运行

### 1. 打开项目
```bash
open HealthPulse.xcodeproj
```

### 2. 配置签名
1. 在 Xcode 左侧选择 **HealthPulse** 项目
2. 选择 **HealthPulse** Target
3. 进入 **Signing & Capabilities** 标签
4. 选择你的 **Team**（免费个人开发者账号即可）
5. 修改 **Bundle Identifier** 为你自己的（如 `com.yourname.healthpulse`）

### 3. 确认 HealthKit Capability
- 在 **Signing & Capabilities** 中确认已添加 **HealthKit** capability
- 如果没有，点击 **+ Capability** 搜索并添加 HealthKit

### 4. 编译运行
1. 连接你的 iPhone（iOS 16+）
2. 在 Xcode 顶部选择你的设备作为运行目标
3. 按 **⌘R** 编译并运行
4. 首次启动会请求 HealthKit 授权，点击允许

### 5. 模拟器运行
- 模拟器不支持 HealthKit 真实数据
- 首次启动时选择"使用演示数据"即可体验完整UI

## 打包 IPA（TrollStore 安装）

### 方法一：Xcode Archive（推荐）

1. **Archive**
   - 选择 **Any iOS Device (arm64)** 作为运行目标
   - 菜单：**Product → Archive**
   - 等待编译完成，Organizer 会自动弹出

2. **导出 IPA**
   - 在 Organizer 中选择刚才的 Archive
   - 点击 **Distribute App**
   - 选择 **Custom** → 点击 Next
   - 选择 **Development** 或 **Ad Hoc**
   - 保持默认选项，点击 Next
   - 选择你的签名证书
   - 点击 **Export**，选择保存位置

3. **安装到 TrollStore**
   - 将导出的 `.ipa` 文件传到你的 iPhone
   - 在 TrollStore 中点击 **Install IPA**
   - 选择该 IPA 文件，等待安装完成
   - 安装后永久有效，不会掉签

### 方法二：命令行导出

```bash
# Archive
xcodebuild -project HealthPulse.xcodeproj \
  -scheme HealthPulse \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive \
  -archivePath ./HealthPulse.xcarchive

# Export
xcodebuild -exportArchive \
  -archivePath ./HealthPulse.xcarchive \
  -exportPath ./export \
  -exportOptionsPlist exportOptions.plist
```

`exportOptions.plist` 示例：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

## TrollStore 注意事项

### 支持的 iOS 版本
- iOS 14.0 - 16.6.1
- iOS 16.7 RC
- iOS 17.0

### 优势
- 永久签名，不会像普通侧载那样7天掉签
- 可以使用任意 entitlements（后台刷新、HealthKit等）
- 不需要 App Store 审核

### 本 App 的 entitlements
- HealthKit（读写健康数据）
- Background Modes（后台获取和处理）
- UserNotifications（本地通知）
- Face ID（可选，数据保护）

## HealthKit 数据类型

### 读取类型
| 类别 | 数据类型 |
|------|---------|
| 心脏 | 心率、静息心率、心率变异性(SDNN)、血氧 |
| 活动 | 步数、活动能量、锻炼时间、站立时间、步行跑步距离 |
| 睡眠 | 睡眠分析（含睡眠阶段：深睡/REM/核心/清醒/在床） |
| 身体 | 体重、体脂率、身高、BMI、VO₂ Max |
| 锻炼 | 所有类型的锻炼记录 |

### 写入类型
- 锻炼记录（HKWorkout）

## 设计理念

### 苹果原生风格
- 使用系统语义颜色（自动适配深色/浅色模式）
- SF Symbols 图标
- 圆角卡片 + 分组列表布局
- 大标题导航栏
- Swift Charts 原生图表
- 毛玻璃材质效果

### 隐私优先
- 所有数据仅存储在本地设备
- 无网络请求、无后端、无分析追踪
- HealthKit 数据只读（除锻炼记录外）
- 支持演示数据模式

### 可解释的洞察
- 每条健康洞察都附带证据引用
- 纯函数规则引擎，完全可测试
- 不做诊断，只做观察和提醒

## 与原项目的关系

### 来自 Health Companion 的部分
- 洞察引擎架构（纯函数 + 证据引用）
- 用药管理模型
- 健康日志和心情记录
- 纯本地隐私设计理念
- MVVM + 功能分区的项目结构

### 来自 HealthHub 的部分
- 统一的 HealthKit 数据访问层设计
- 协议驱动的服务架构理念
- 全面的健康数据类型覆盖
- async/await 封装 HealthKit 回调API

### 本项目的创新
- **iOS 16 兼容**：将 Health Companion 的 iOS 17+ SwiftData 降配为 UserDefaults，将 @Observable 宏降配为 ObservableObject
- **融合架构**：将 HealthHub 的数据层理念与 Health Companion 的功能架构结合
- **苹果原生UI**：全面使用系统语义颜色、SF Symbols、Swift Charts，打造最接近苹果原生App的视觉体验
- **睡眠评分系统**：综合时长、深睡比例和睡眠效率的评分算法
- **心理量表**：内置 GAD-7 和 PHQ-9 自评量表

## 已知限制

1. **HealthKit 写入**：目前仅支持写入锻炼记录，其他数据类型为只读
2. **无 Widget 扩展**：当前版本未包含主屏幕/锁屏小组件（可后续添加）
3. **无 Apple Watch 配套 App**：仅 iPhone App，Watch 数据通过 HealthKit 读取
4. **无 iCloud 同步**：数据仅存储在本地设备（隐私优先设计）
5. **无 Live Activity**：未实现灵动岛/锁屏实时活动
6. **HealthHub SPM**：项目配置了 HealthHub 的 SPM 依赖，但当前使用原生 HealthKit 实现以确保编译稳定性。如需使用 HealthHub，可在 `HealthStoreManager` 中替换实现

## 后续扩展建议

- [ ] 添加 WidgetKit 小组件（主屏幕 + 锁屏）
- [ ] 添加 ActivityKit 实时活动（锻炼中状态）
- [ ] 添加 Apple Watch 配套 App
- [ ] 添加 iCloud CloudKit 数据同步
- [ ] 集成 HealthHub SPM 替换原生 HealthKit 层
- [ ] 添加睡眠阶段 SleepChartKit 可视化
- [ ] 添加 PDF 健康报告导出
- [ ] 添加 Face ID 应用锁
- [ ] 添加更多健康指标（血压、血糖等）

## 许可证

MIT License

## 致谢

- [Health Companion](https://github.com/kochenderferc/health-companion) — 功能架构和洞察引擎灵感来源
- [HealthHub](https://github.com/matybrennan/HealthHub) — HealthKit 数据层设计灵感来源
- Apple HealthKit / SwiftUI / Swift Charts 框架

---

**健康脉搏 · 让健康数据一目了然**
