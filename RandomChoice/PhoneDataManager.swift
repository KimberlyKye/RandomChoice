import Foundation
import WatchConnectivity

// Наблюдаемый объект, который будет управлять всеми данными на телефоне
class PhoneDataManager: NSObject, ObservableObject {
    
    // Это главный массив наших списков. За изменением этого массива автоматически будут следить все SwiftUI View, которые его используют.
    @Published var lists: [DecisionList] = []
    
    // Сессия для связи с часами
    private var session: WCSession?
    
    // Ключ для сохранения данных в UserDefaults (по этому ключу мы будем сохранять и загружать)
    private let saveKey = "PhoneLists"
    
    // Инициализатор
    override init() {
        super.init() // Обязательно вызываем инициализатор родительского класса
        print("Менеджер данных инициализирован")
        setupWatchConnectivity() // Настраиваем мост к часам
        loadLocally() // Загружаем сохраненные данные (или тестовые, если их нет)
    }
    
    // MARK: - Настройка WatchConnectivity
    private func setupWatchConnectivity() {
        // Проверяем, поддерживается ли WatchConnectivity на этом устройстве (на iPhone всегда yes)
        guard WCSession.isSupported() else {
            print("WatchConnectivity не поддерживается")
            return
        }
        
        session = WCSession.default // Получаем стандартную сессию
        session?.delegate = self // Указываем, что этот класс будет обрабатывать события от сессии
        session?.activate() // Активируем сессию
        print("WatchConnectivity сессия активирована")
    }
    
    // MARK: - Работа с локальным хранилищем (UserDefaults)
    func loadLocally() {
        // Пытаемся получить данные по ключу из UserDefaults
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            // Если данных нет - создаем тестовые списки для демонстрации
            lists = [
                DecisionList(name: "Что поесть?", options: ["Пицца", "Суши", "Бургер", "Паста"]),
                DecisionList(name: "Что посмотреть?", options: ["Фильм", "Сериал", "Ютуб"])
            ]
            print("Загружены тестовые данные, так как локальные сохранения не найдены")
            return
        }
        
        // Если данные есть - пытаемся их преобразовать из формата JSON обратно в массив DecisionList
        do {
            lists = try JSONDecoder().decode([DecisionList].self, from: data)
            print("Данные успешно загружены из локального хранилища")
        } catch {
            // Если преобразование не удалось (например, данные повреждены) - также загружаем тестовые
            print("Ошибка декодирования данных: \(error.localizedDescription)")
            lists = [
                DecisionList(name: "Что поесть?", options: ["Пицца", "Суши", "Бургер"]),
                DecisionList(name: "Куда пойти?", options: ["Кино", "Парк", "Кафе"])
            ]
        }
    }
    
    // Приватный метод для сохранения текущего состояния массива lists в UserDefaults
    private func saveLocally() {
        do {
            // Преобразуем (кодируем) массив lists в данные в формате JSON
            let data = try JSONEncoder().encode(lists)
            // Сохраняем эти данные в UserDefaults по нашему ключу
            UserDefaults.standard.set(data, forKey: saveKey)
            print("Данные сохранены локально")
        } catch {
            // Если кодирование не удалось - выводим ошибку в консоль
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Публичные методы для управления данными (интерфейс для View)
    
    // Добавить новый список
    func addList(_ list: DecisionList) {
        lists.append(list) // Добавляем новый список в конец массива
        saveLocally() // Сохраняем изменения локально
        sendToWatch() // Пытаемся отправить обновленные данные на часы
    }
    
    // Удалить список
    func deleteList(at offsets: IndexSet) {
        lists.remove(atOffsets: offsets) // Удаляем список по указанному индексу
        saveLocally()
        sendToWatch()
    }
    
    // MARK: - Отправка данных на часы
    
    private func sendToWatch() {
        // Проверяем, что сессия существует и часы доступны для связи (рядом и на них запущено наше приложение)
        guard let session = session, session.isReachable else {
            print("Часы недоступны для отправки данных")
            return
        }
        
        do {
            // Кодируем наши списки в данные
            let data = try JSONEncoder().encode(lists)
            // Отправляем данные в виде словаря [String: Any]
            try session.updateApplicationContext(["lists": data])
            print("Данные отправлены на часы")
        } catch {
            print("Ошибка отправки данных на часы: \(error.localizedDescription)")
        }
    }
}

// MARK: - Расширение для обработки событий WCSession
// Пока эти методы пустые, но они обязательны для реализации протокола WCSessionDelegate
extension PhoneDataManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Этот метод вызывается, когда активация сессии завершена
        if let error = error {
            print("Ошибка активации сессии: \(error.localizedDescription)")
        } else {
            print("Сессия активирована со статусом: \(activationState.rawValue)")
        }
    }
    
    // Эти методы требуются протоколом, но для нашей задачи пока не нужны
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    // Метод вызывается при получении сообщения от часов
        func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
            print("Получен запрос от часов: \(message)")
            
            if message["request"] as? String == "data" {
                // Если часы запрашивают данные - отправляем им текущие списки
                do {
                    let data = try JSONEncoder().encode(lists)
                    replyHandler(["lists": data])
                    print("Данные отправлены в ответ на запрос часов")
                } catch {
                    print("Ошибка кодирования для ответа: \(error.localizedDescription)")
                    replyHandler(["error": "Encoding failed"])
                }
            }
        }
}
