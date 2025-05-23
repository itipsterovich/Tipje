import Foundation
import SwiftData
import Combine

struct BasketEntry: Identifiable, Codable {
    let id: UUID = UUID()
    let rewardID: UUID
    let timestamp: Date
}

@MainActor
class Store: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var basket: [BasketEntry] = []
    @Published var kidName: String = "Marsel"
    // TODO: Add CloudKit sync logic
    // TODO: Add CRUD methods
    // TODO: Add balance calculation
    
    init() {
        // TODO: Load tasks from SwiftData
    }
    
    var balance: Int {
        let completedTasks = tasks.filter { ($0.kind == .rule || $0.kind == .chore) && $0.isCompleted }
        let completedPeanuts = completedTasks.map { $0.peanuts }.reduce(0, +)
        let spentPeanuts = basket.reduce(0) { sum, entry in
            if let reward = tasks.first(where: { $0.id == entry.rewardID }) {
                return sum + reward.peanuts
            } else {
                return sum
            }
        }
        return completedPeanuts - spentPeanuts
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
        guard !tasks.contains(where: { $0.templateID == template.id }) else { return }
        let task = Task(kind: kind, title: template.title, peanuts: template.peanuts, category: template.category, isSelected: true, templateID: template.id)
        tasks.append(task)
        // TODO: Save to SwiftData/CloudKit
    }
    
    func deleteTaskByTemplateID(_ templateID: String) {
        tasks.removeAll { $0.templateID == templateID }
        // TODO: Delete from SwiftData/CloudKit
    }

    func purchaseReward(_ reward: Task) {
        guard balance >= reward.peanuts else { return }
        basket.append(BasketEntry(rewardID: reward.id, timestamp: Date()))
        // TODO: Save basket to SwiftData/CloudKit
    }

    func clearBasket() {
        basket.removeAll()
        // TODO: Save basket to SwiftData/CloudKit
    }
} 