#!/bin/bash

echo "🔍 检查Firebase配置..."

# 检查GoogleService-Info.plist文件是否存在
if [ -f "PersonalAffairsManagement/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist 文件存在"
else
    echo "❌ GoogleService-Info.plist 文件不存在"
    echo "请从Firebase控制台下载配置文件并添加到项目中"
    exit 1
fi

# 检查Bundle ID配置
BUNDLE_ID=$(grep -A 1 "BUNDLE_ID" PersonalAffairsManagement/GoogleService-Info.plist | tail -n 1 | sed 's/<string>//g' | sed 's/<\/string>//g' | xargs)
if [ "$BUNDLE_ID" = "com.shoulin.PersonalAffairsManagement" ]; then
    echo "✅ Bundle ID 配置正确: $BUNDLE_ID"
else
    echo "⚠️  Bundle ID 可能不匹配: $BUNDLE_ID"
fi

# 检查必要的Firebase配置项
REQUIRED_KEYS=("API_KEY" "PROJECT_ID" "STORAGE_BUCKET" "GOOGLE_APP_ID")
for key in "${REQUIRED_KEYS[@]}"; do
    if grep -q "$key" PersonalAffairsManagement/GoogleService-Info.plist; then
        echo "✅ $key 配置存在"
    else
        echo "❌ $key 配置缺失"
    fi
done

echo ""
echo "📋 下一步操作："
echo "1. 在Xcode中添加Firebase SDK依赖包"
echo "2. 确保GoogleService-Info.plist已添加到项目中"
echo "3. 在Firebase控制台中启用Authentication和Firestore"
echo "4. 设置Firestore安全规则"
echo "5. 测试应用连接"

echo ""
echo "🔗 Firebase控制台链接："
echo "https://console.firebase.google.com/" 