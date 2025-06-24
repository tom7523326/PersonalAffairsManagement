# Firebase 配置指南

## 🚀 快速开始

### 1. 在Xcode中添加Firebase SDK

1. **打开Xcode项目**
2. **选择项目** → **Package Dependencies**
3. **点击"+"按钮**
4. **输入Firebase包URL**: `https://github.com/firebase/firebase-ios-sdk.git`
5. **选择以下依赖包**:
   - `FirebaseAuth` - 用户认证
   - `FirebaseFirestore` - 数据库
   - `FirebaseFirestoreSwift` - Swift编码支持

### 2. 验证配置文件

运行配置检查脚本：
```bash
./check_firebase_config.sh
```

### 3. Firebase控制台配置

#### 启用Authentication:
1. 访问 https://console.firebase.google.com/
2. 选择你的项目
3. 点击"Authentication" → "开始使用"
4. 在"登录方法"中启用"邮箱/密码"

#### 配置Firestore数据库:
1. 点击"Firestore Database"
2. 点击"创建数据库"
3. 选择"以测试模式开始"
4. 选择数据库位置（建议选择离你最近的区域）

#### 设置安全规则:
在Firestore规则中配置：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户只能访问自己的数据
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. 测试连接

完成上述步骤后，运行应用并测试：
1. 打开应用
2. 点击侧边栏的"云端同步"
3. 尝试登录或注册
4. 检查数据同步功能

## 🔧 故障排除

### 常见问题：

1. **"no such module 'FirebaseFirestore'"**
   - 确保已在Xcode中添加了Firebase SDK依赖包
   - 清理项目 (Product → Clean Build Folder)
   - 重新构建项目

2. **配置文件错误**
   - 确保`GoogleService-Info.plist`已添加到项目中
   - 检查Bundle ID是否匹配
   - 验证配置文件完整性

3. **认证失败**
   - 确保在Firebase控制台中启用了邮箱/密码认证
   - 检查网络连接
   - 验证Firebase项目配置

4. **数据库访问被拒绝**
   - 检查Firestore安全规则
   - 确保用户已正确认证
   - 验证数据路径结构

## 📱 功能特性

### 已实现的功能：
- ✅ 用户注册和登录
- ✅ 数据云端同步
- ✅ 离线优先设计
- ✅ 自动冲突解决
- ✅ 多设备同步
- ✅ 安全数据隔离

### 使用说明：
1. **首次使用**：注册新账户或登录现有账户
2. **数据同步**：应用会自动同步本地和云端数据
3. **离线使用**：支持离线操作，网络恢复后自动同步
4. **多设备**：同一账户可在多台设备上使用

## 🔒 安全说明

- 所有用户数据都经过加密存储
- 用户只能访问自己的数据
- 支持安全的密码重置流程
- 数据备份和恢复功能

## 📞 技术支持

如果遇到问题，请检查：
1. Firebase控制台配置
2. 网络连接状态
3. 应用权限设置
4. 设备存储空间

---

**注意**: 首次使用建议在测试环境中验证所有功能。 