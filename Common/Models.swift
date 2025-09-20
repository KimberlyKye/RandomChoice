import Foundation

// Наша главная модель - один список для принятия решений
struct DecisionList: Identifiable, Codable, Hashable {
    // Уникальный идентификатор необходим для SwiftUI и работы с списками
    let id: UUID
    // Название списка (например, "Что поесть?")
    var name: String
    // Массив вариантов для выбора (например, ["Пицца", "Суши", "Бургер"])
    var options: [String]
    
    // Удобный инициализатор со значением по умолчанию для id
    init(id: UUID = UUID(), name: String, options: [String] = []) {
        self.id = id
        self.name = name
        self.options = options
    }
}
