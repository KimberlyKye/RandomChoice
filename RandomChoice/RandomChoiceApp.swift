import SwiftUI

@main
struct RandomChoiceApp: App {
    // Создаем экземпляр PhoneDataManager здесь, чтобы он жил все время жизни приложения
    // @StateObject создает объект и следит за его изменениями
    @StateObject private var dataManager = PhoneDataManager()
    
    var body: some Scene {
        WindowGroup {
            // Пока это просто пустой экран, но мы передаем в него наш менеджер данных
            // через environmentObject, чтобы все дочерние View имели к нему доступ
            ContentView()
                .environmentObject(dataManager) // Важно: добавляем менеджер в окружение
        }
    }
}
