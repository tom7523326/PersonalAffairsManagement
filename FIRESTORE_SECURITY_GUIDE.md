# Firestore 安全规则设置指南

## 🔒 安全规则说明

Firestore安全规则用于控制谁可以访问数据库中的哪些数据。我们的应用使用基于用户ID的数据隔离策略。

## 📋 设置步骤

### 1. 访问Firestore控制台

1. 打开 [Firebase控制台](https://console.firebase.google.com/)
2. 选择你的项目
3. 在左侧菜单中点击 **"Firestore Database"**
4. 点击 **"规则"** 标签页

### 2. 复制并替换安全规则

**重要：请先删除规则编辑器中的所有现有内容**，然后再将以下规则复制到编辑器中：

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

### 3. 发布规则

1. 点击 **"发布"** 按钮
2. 等待规则生效（通常需要几秒钟）

## 🔍 规则解释

### 规则结构分析：

```javascript
// 规则版本声明
rules_version = '2';

// 服务声明
service cloud.firestore {
  // 匹配所有数据库
  match /databases/{database}/documents {
    
    // 用户数据路径规则
    match /users/{userId} {
      // 用户只能访问自己的数据
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // 用户子集合（任务、财务记录等）
      match /{collection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // 默认拒绝所有其他访问
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 关键概念：

1. **`request.auth != null`** - 确保用户已登录
2. **`request.auth.uid == userId`** - 确保用户只能访问自己的数据
3. **`{userId}`** - 动态路径参数，匹配用户ID
4. **`{collection}/{document=**}`** - 匹配所有子集合和文档

## 🚨 常见错误及解决方案

### 错误1: "Missing or insufficient permissions"

**原因**: 用户未登录或访问了不属于自己的数据

**解决方案**:
- 确保用户已正确登录
- 检查数据路径是否正确
- 验证用户ID匹配

### 错误2: "Permission denied"

**原因**: 安全规则过于严格

**解决方案**:
- 检查规则语法是否正确
- 确保用户认证状态
- 验证数据访问路径

### 错误3: "Rules are not an object"

**原因**: 规则语法错误

**解决方案**:
- 检查JSON语法
- 确保所有括号匹配
- 验证规则结构

## 🧪 测试规则

### 使用Firebase控制台测试：

1. 在Firestore控制台中点击 **"规则"**
2. 点击 **"规则测试"** 标签
3. 创建测试用例：

```javascript
// 测试用例1: 用户访问自己的数据
{
  "request": {
    "auth": {
      "uid": "user123"
    },
    "path": "/databases/(default)/documents/users/user123/tasks/task1",
    "method": "get"
  },
  "expected": true
}

// 测试用例2: 用户访问他人数据
{
  "request": {
    "auth": {
      "uid": "user123"
    },
    "path": "/databases/(default)/documents/users/user456/tasks/task1",
    "method": "get"
  },
  "expected": false
}
```

## 🔧 调试技巧

### 1. 启用详细日志

在Firebase控制台中：
1. 转到 **"项目设置"**
2. 点击 **"服务账户"**
3. 启用 **"Firestore 规则调试"**

### 2. 使用Firebase CLI测试

```bash
# 安装Firebase CLI
npm install -g firebase-tools

# 登录Firebase
firebase login

# 测试规则
firebase firestore:rules:test
```

### 3. 临时放宽规则（仅用于测试）

```javascript
// 临时测试规则 - 不要在生产环境使用
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // 允许所有访问
    }
  }
}
```

## 📱 应用集成

### 数据路径结构：

```
users/
  {userId}/
    profile/
      - userInfo
    tasks/
      - task1
      - task2
    financial/
      - record1
      - record2
    passwords/
      - password1
    assets/
      - asset1
```

### 代码中的使用：

```swift
// 获取用户特定的数据路径
let userId = Auth.auth().currentUser?.uid ?? ""
let userPath = "users/\(userId)"

// 访问用户的任务
let tasksPath = "\(userPath)/tasks"
```

## ✅ 验证清单

- [ ] 规则语法正确
- [ ] 规则已发布
- [ ] 用户认证正常工作
- [ ] 数据访问权限正确
- [ ] 安全测试通过

## 🆘 获取帮助

如果仍然遇到问题：

1. 检查Firebase控制台错误日志
2. 验证用户认证状态
3. 确认数据路径结构
4. 参考Firebase官方文档
5. 联系技术支持

---

**重要提醒**: 安全规则是保护用户数据的关键，请仔细测试后再部署到生产环境。 