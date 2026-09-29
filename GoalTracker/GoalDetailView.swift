import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var newTaskTitle = ""
    @State private var isShowingDeleteConfirmation = false

    private var sortedTasks: [GoalTask] {
        (goal.tasks ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        Form {
            Section("Goal") {
                TextField("Title", text: $goal.title)
                Picker("Term", selection: $goal.term) {
                    ForEach(Term.allCases) { term in
                        Text(term.displayName).tag(term)
                    }
                }
                TextField("Notes", text: $goal.notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Subtasks") {
                ForEach(sortedTasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTasks)

                HStack {
                    TextField("Add a subtask", text: $newTaskTitle)
                        .onSubmit(addTask)
                    Button("Add", action: addTask)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle(goal.title.isEmpty ? "Goal" : goal.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete Goal", systemImage: "trash")
                }
            }
        }
        .confirmationDialog("Delete this goal?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Goal", role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            }
        }
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let task = GoalTask(title: trimmed)
        task.sortOrder = goal.tasks?.count ?? 0
        modelContext.insert(task)
        goal.tasks?.append(task)
        newTaskTitle = ""
    }

    private func deleteTasks(at offsets: IndexSet) {
        let tasks = sortedTasks
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}

private struct TaskRow: View {
    @Bindable var task: GoalTask

    var body: some View {
        Button {
            task.isCompleted.toggle()
        } label: {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}
