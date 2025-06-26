import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("仪表盘", systemImage: "chart.bar.fill")
                }
            
            WorkTaskView()
                .tabItem {
                    Label("任务", systemImage: "checklist")
                }
            
            PomodoroView()
                .tabItem {
                    Label("专注", systemImage: "timer")
                }
            
            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
            
            FinancialManagementView()
                .tabItem {
                    Label("财务", systemImage: "dollarsign.circle.fill")
                }
            
            PasswordBoxView()
                .tabItem {
                    Label("密码箱", systemImage: "key.fill")
                }
        }
    }
} 