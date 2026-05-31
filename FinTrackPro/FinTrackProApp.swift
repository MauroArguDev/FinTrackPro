import SwiftUI
import SwiftData

@main
struct FinTrackProApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

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
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background, appState.biometricEnabled {
                        appState.lock()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
