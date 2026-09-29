import Foundation
import SwiftData

enum Term: String, Codable, CaseIterable, Identifiable {
    case short, medium, long

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .short: "Short Term"
        case .medium: "Medium Term"
        case .long: "Long Term"
        }
    }
}

@Model
final class Goal {
    var title: String = ""
    var notes: String = ""
    var term: Term = Term.short
    var createdDate: Date = Date()
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \GoalTask.goal)
    var tasks: [GoalTask]? = []

    init(title: String, term: Term) {
        self.title = title
        self.term = term
    }

    var completedFraction: Double {
        guard let tasks, !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }
}

@Model
final class GoalTask {
    var title: String = ""
    var isCompleted: Bool = false
    var createdDate: Date = Date()
    var sortOrder: Int = 0
    var goal: Goal?

    init(title: String) {
        self.title = title
    }
}
