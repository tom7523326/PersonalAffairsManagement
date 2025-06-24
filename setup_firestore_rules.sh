#!/bin/bash

echo "🔒 设置Firestore安全规则..."
echo ""

echo "📋 请按照以下步骤操作："
echo ""
echo "1. 打开Firebase控制台: https://console.firebase.google.com/"
echo "2. 选择你的项目"
echo "3. 点击左侧菜单中的 'Firestore Database'"
echo "4. 点击 '规则' 标签页"
echo "5. 将以下规则复制到编辑器中："
echo ""

cat << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户只能访问自己的数据
    match /users/{userId} {
      // 允许用户读取和写入自己的用户文档
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // 用户子集合的规则
      match /{collection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // 全局集合的规则（如果需要）
    match /{document=**} {
      // 默认拒绝所有访问
      allow read, write: if false;
    }
  }
}
EOF

echo ""
echo "6. 点击 '发布' 按钮"
echo "7. 等待规则生效（通常需要几秒钟）"
echo ""
echo "✅ 完成！"
echo ""
echo "🔍 规则说明："
echo "- 用户只能访问自己的数据"
echo "- 所有数据都按用户ID隔离"
echo "- 未认证用户无法访问任何数据"
echo "- 默认拒绝所有其他访问"
echo ""
echo "📖 详细说明请查看: FIRESTORE_SECURITY_GUIDE.md" 