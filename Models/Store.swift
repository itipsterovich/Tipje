import Foundation
import SwiftData
import Combine

@MainActor
class Store: ObservableObject {
    @Published var tasks: [Task] = []
    // TODO: Add CloudKit sync logic
    // TODO: Add CRUD methods
    // TODO: Add balance calculation
    
    init() {
        // TODO: Load tasks from SwiftData
    }
    
    var balance: Int {
        // TODO: Calculate balance as SUM(peanuts) WHERE isCompleted == true
        0
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        // TODO: Save to SwiftData/CloudKit
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        // TODO: Delete from SwiftData/CloudKit
    }
    
    func toggleSelection(for task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isSelected.toggle()
        // TODO: Save to SwiftData/CloudKit
    }
    
    func addTaskFromTemplate(_ template: TaskTemplate, kind: TaskKind) {
        // Only add if not already present
        guard !tasks.contains(where: { $0.id.uuidString == template.id }) else { return }
        let task = Task(kind: kind, title: template.title, peanuts: template.peanuts, category: template.category, isSelected: true)
        // Use template.id as UUID if possible
        if let uuid = UUID(uuidString: template.id) {
            task.id = uuid
        }
        tasks.append(task)
        // TODO: Save to SwiftData/CloudKit
    }
    
    func deleteTaskByTemplateID(_ templateID: String) {
        tasks.removeAll { $0.id.uuidString == templateID }
        // TODO: Delete from SwiftData/CloudKit
    }
} 