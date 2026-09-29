import SwiftUI
import SwiftData

@main
struct MyApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([Goal.self, GoalTask.self])
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            GoalListView()
        }
        .modelContainer(modelContainer)
    }
}
