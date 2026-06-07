import SwiftUI
import SwiftData

@main
struct FinTrackProApp: App {
    @State private var appState = AppState()

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Transaction.self, Category.self, Budget.self])
        do {
            if let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.argudev.FinTrackPro"
            ) {
                let storeURL = groupURL.appendingPathComponent("fintrackpro.store")
                let config = ModelConfiguration(schema: schema, url: storeURL)
                return try ModelContainer(for: schema, configurations: [config])
            }
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    let context = sharedModelContainer.mainContext
                    let count = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
                    guard count == 0 else { return }
                    Category.defaults().forEach { context.insert($0) }
                    do {
                        try context.save()
                    } catch {
                        #if DEBUG
                        print("FinTrackPro: seed data save failed — \(error)")
                        #endif
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
