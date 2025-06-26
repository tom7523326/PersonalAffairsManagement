//
//  PersonalAffairsManagementApp.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData
import Firebase

// AppDelegate to handle Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 检查Firebase配置
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let bundleId = plist["BUNDLE_ID"] as? String,
              bundleId != "com.example.PersonalAffairsManagement" else {
            print("[AppDelegate] 警告: 使用默认Firebase配置，请替换为真实的GoogleService-Info.plist")
            return true
        }
        
        // 初始化Firebase
        FirebaseApp.configure()
        print("[AppDelegate] Firebase初始化成功")
        
        return true
    }
}

@main
struct PersonalAffairsManagementApp: App {
    // Use UIApplicaitonDelegateAdaptor to link AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var cloudService = CloudService.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(themeManager)
                .environmentObject(cloudService)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .accentColor(themeManager.accentColor)
        }
        .modelContainer(for: [
            WorkTask.self,
            FinancialRecord.self,
            Budget.self,
            PasswordEntry.self,
            VirtualAsset.self,
            Project.self
        ])
    }
}
