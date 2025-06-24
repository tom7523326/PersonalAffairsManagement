# Personal Affairs Management

一个功能完整的个人事务管理 iOS 应用，使用 SwiftUI 和 SwiftData 构建。

## 功能特性

### 📱 核心功能
- **任务管理**: 创建、编辑、删除和跟踪任务
- **资产管理**: 管理个人资产和财务记录
- **预算管理**: 设置和跟踪预算
- **密码箱**: 安全存储和管理密码
- **虚拟资产**: 管理购物券等虚拟资产
- **日历视图**: 可视化任务和事件安排

### 🔐 安全特性
- **Firebase 认证**: 安全的用户登录和注册
- **数据同步**: 云端数据备份和同步
- **密码加密**: 本地密码安全存储

### 🎨 用户界面
- **现代化设计**: 使用 SwiftUI 构建的流畅界面
- **深色模式支持**: 自动适应系统主题
- **响应式布局**: 适配不同屏幕尺寸

## 技术栈

- **前端框架**: SwiftUI
- **数据持久化**: SwiftData
- **后端服务**: Firebase (Auth, Firestore)
- **开发语言**: Swift 5.9+
- **最低支持**: iOS 18.5+

## 安装和运行

### 前置要求
- Xcode 16.0+
- iOS 18.5+ 模拟器或设备
- Firebase 项目配置

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/yourusername/PersonalAffairsManagement.git
   cd PersonalAffairsManagement
   ```

2. **配置 Firebase**
   - 在 Firebase Console 创建新项目
   - 下载 `GoogleService-Info.plist` 文件
   - 将文件添加到项目根目录

3. **安装依赖**
   - 打开 `PersonalAffairsManagement.xcodeproj`
   - Xcode 会自动解析 Swift Package Manager 依赖

4. **运行项目**
   - 选择目标设备或模拟器
   - 点击运行按钮或使用 `Cmd+R`

## 项目结构

```
PersonalAffairsManagement/
├── PersonalAffairsManagement/
│   ├── Views/                 # SwiftUI 视图
│   │   ├── Authentication/    # 认证相关视图
│   │   ├── Dashboard/         # 仪表板视图
│   │   ├── Tasks/            # 任务管理视图
│   │   ├── Assets/           # 资产管理视图
│   │   ├── Passwords/        # 密码管理视图
│   │   └── Settings/         # 设置视图
│   ├── Models/               # 数据模型
│   ├── Services/             # 业务逻辑服务
│   └── Utils/                # 工具类和扩展
├── PersonalAffairsManagementTests/     # 单元测试
├── PersonalAffairsManagementUITests/   # UI 测试
└── Documentation/            # 项目文档
```

## 主要功能模块

### 任务管理
- 创建和编辑任务
- 设置任务优先级和截止日期
- 任务分类和筛选
- 任务完成状态跟踪

### 资产管理
- 记录个人资产信息
- 资产价值跟踪
- 资产分类管理
- 财务记录统计

### 密码箱
- 安全存储网站和应用的密码
- 密码分类管理
- 密码生成器
- 密码强度检查

### 虚拟资产
- 管理购物券、礼品卡等虚拟资产
- 到期日期提醒
- 使用状态跟踪

## 开发指南

### 代码规范
- 遵循 Swift 官方编码规范
- 使用 SwiftLint 进行代码检查
- 编写单元测试和 UI 测试

### 架构模式
- 使用 MVVM 架构模式
- 数据层使用 SwiftData
- 网络层使用 Firebase SDK

### 性能优化
- 使用 SwiftUI 的懒加载特性
- 优化数据查询性能
- 实现适当的缓存策略

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

- 项目维护者: [Your Name]
- 邮箱: [your.email@example.com]
- 项目链接: [https://github.com/yourusername/PersonalAffairsManagement](https://github.com/yourusername/PersonalAffairsManagement)

## 更新日志

### v1.0.0 (2024-06-24)
- 初始版本发布
- 实现核心功能模块
- 集成 Firebase 服务
- 完成基础 UI 设计 