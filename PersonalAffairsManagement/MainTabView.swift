import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WorkTaskView(filter: .all)
                .tabItem {
                    Label("工作任务", systemImage: "briefcase.fill")
                }
            
            FinancialManagementView()
                .tabItem {
                    Label("财务管理", systemImage: "dollarsign.circle.fill")
                }
            
            DashboardView()
                .tabItem {
                    Label("仪表盘", systemImage: "chart.pie.fill")
                }
            
            PasswordBoxView()
                .tabItem {
                    Label("密码箱", systemImage: "key.fill")
                }
        }
    }
} 