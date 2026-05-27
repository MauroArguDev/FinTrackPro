import SwiftUI
import SwiftData

@main
struct FinTrackProApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Transaction.self, Category.self, Budget.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    let context = sharedModelContainer.mainContext
                    let count = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
                    guard count == 0 else { return }
                    Category.defaults().forEach { context.insert($0) }
                    try? context.save()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
