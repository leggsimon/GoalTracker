import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var term: Term = .short
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Title", text: $title)
                    Picker("Term", selection: $term) {
                        ForEach(Term.allCases) { term in
                            Text(term.displayName).tag(term)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addGoal() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addGoal() {
        let goal = Goal(title: title.trimmingCharacters(in: .whitespacesAndNewlines), term: term)
        goal.notes = notes
        modelContext.insert(goal)
        dismiss()
    }
}

#Preview {
    AddGoalView()
        .modelContainer(for: [Goal.self, GoalTask.self], inMemory: true)
}
