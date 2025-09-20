import SwiftUI

@main
struct RandomChoice_Watch_AppApp: App {
    // Создаем менеджер данных для часов
    @StateObject private var dataManager = WatchDataManager()
    
    var body: some Scene {
        WindowGroup {
            // Передаем менеджер в окружение
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
