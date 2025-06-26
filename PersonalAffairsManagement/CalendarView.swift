import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [WorkTask]
    
    @State private var selectedDate = Date()
    @State private var showingAddTask = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar header
                CalendarHeaderView(selectedDate: $selectedDate)
                
                // Calendar grid
                CalendarGridView(selectedDate: $selectedDate, tasks: tasks)
                
                // Tasks for selected date
                TasksForDateView(selectedDate: selectedDate, tasks: tasksForSelectedDate)
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(presetDueDate: selectedDate)
            }
        }
    }
    
    private var tasksForSelectedDate: [WorkTask] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= startOfDay && dueDate < endOfDay
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let tasks: [WorkTask]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGray6))
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasTasks: hasTasksForDate(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - 1
        
        let startDate = calendar.date(byAdding: .day, value: -offsetDays, to: startOfMonth) ?? startOfMonth
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasTasksForDate(_ date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return tasks.contains { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= startOfDay && dueDate < endOfDay
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasTasks: Bool
    let isCurrentMonth: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.clear)
                )
            
            if hasTasks {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 50)
        .background(Color.clear)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
}

struct TasksForDateView: View {
    let selectedDate: Date
    let tasks: [WorkTask]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateString)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(tasks.count) tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if tasks.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No tasks scheduled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(tasks) { task in
                        TaskRowView(task: task) {
                            // 切换任务状态的回调
                        }
                    }
                }
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [WorkTask.self, Project.self], inMemory: true)
} 