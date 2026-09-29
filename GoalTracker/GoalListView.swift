import SwiftUI
import SwiftData

struct GoalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Goal.sortOrder) private var goals: [Goal]

    @State private var isAddingGoal = false

    private var termsInOrder: [Term] { [.long, .medium, .short] }

    var body: some View {
        NavigationStack {
            List {
                ForEach(termsInOrder) { term in
                    let goalsForTerm = goals.filter { $0.term == term }
                    if !goalsForTerm.isEmpty {
                        Section(term.displayName) {
                            ForEach(goalsForTerm) { goal in
                                NavigationLink(value: goal) {
                                    GoalRow(goal: goal)
                                }
                            }
                            .onDelete { offsets in
                                delete(goalsForTerm, at: offsets)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationDestination(for: Goal.self) { goal in
                GoalDetailView(goal: goal)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingGoal = true
                    } label: {
                        Label("Add Goal", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if goals.isEmpty {
                    ContentUnavailableView(
                        "No Goals Yet",
                        systemImage: "target",
                        description: Text("Tap + to add a long, medium, or short term goal.")
                    )
                }
            }
            .sheet(isPresented: $isAddingGoal) {
                AddGoalView()
            }
        }
    }

    private func delete(_ goalsForTerm: [Goal], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(goalsForTerm[index])
        }
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(goal.title)
                .font(.body)
            if let tasks = goal.tasks, !tasks.isEmpty {
                ProgressView(value: goal.completedFraction)
                Text("\(tasks.filter(\.isCompleted).count)/\(tasks.count) done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    GoalListView()
        .modelContainer(for: [Goal.self, GoalTask.self], inMemory: true)
}
