import Foundation
import ClockKit
import WatchConnectivity

// Наблюдаемый объект для управления данными на часах
class WatchDataManager: NSObject, ObservableObject {
    
    // Главный массив списков на часах. За его изменениями будут следить SwiftUI View
    @Published var lists: [DecisionList] = []
    
    // Ключ для локального сохранения на часах
    private let saveKey = "WatchLists"
    
    override init() {
        super.init()
        print("Watch менеджер данных инициализирован")
        setupWatchConnectivity()
        loadLocally()
    }
    
    // MARK: - Настройка WatchConnectivity
    private func setupWatchConnectivity() {
        // Проверяем, поддерживается ли WatchConnectivity на часах
        guard WCSession.isSupported() else {
            print("WatchConnectivity не поддерживается на часах")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate() // Активируем сессию
        print("Watch сессия активирована")
    }
    
    // MARK: - Локальное хранилище часов
    func loadLocally() {
        // Пытаемся загрузить данные из UserDefaults часов
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            print("На часах нет сохраненных данных")
            return
        }
        
        do {
            lists = try JSONDecoder().decode([DecisionList].self, from: data)
            print("Данные на часах успешно загружены: \(lists.count) списков")
        } catch {
            print("Ошибка загрузки данных на часах: \(error.localizedDescription)")
        }
    }
    
    // Сохранение данных в локальное хранилище часов
    private func saveLocally() {
        do {
            let data = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(data, forKey: saveKey)
            print("Данные сохранены на часах")
        } catch {
            print("Ошибка сохранения на часах: \(error.localizedDescription)")
        }
    }
    
    // Обновление данных на часах (вызывается при получении новых данных с телефона)
    func updateLists(_ newLists: [DecisionList]) {
        DispatchQueue.main.async {
            // Убираем withAnimation отсюда, так как это не View
            self.lists = newLists
            self.saveLocally()
            print("Данные на часах обновлены: \(newLists.count) списков")
            self.reloadComplications()
        }
    }
    
    func reloadComplications() {
        // Сообщаем системе, что данные для осложнений обновились
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { complication in
            server.reloadTimeline(for: complication)
        }
        print("Осложнения обновлены")
    }
}

// MARK: - Расширение для обработки входящих данных с телефона
extension WatchDataManager: WCSessionDelegate {
    
    // Метод вызывается при успешной активации сессии
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Ошибка активации сессии на часах: \(error.localizedDescription)")
        } else {
            print("Сессия на часах активирована со статусом: \(activationState.rawValue)")
            // При активации пытаемся запросить актуальные данные с телефона
            requestDataFromPhone()
        }
    }
    
    // Метод вызывается при получении данных из applicationContext (основной способ передачи)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("Получены данные из applicationContext")
        processReceivedData(applicationContext)
    }
    
    // Метод вызывается при получении сообщения от телефона
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Получено сообщение от телефона")
        processReceivedData(message)
    }
    
    // Вспомогательная функция для обработки входящих данных
    private func processReceivedData(_ data: [String: Any]) {
        if let listsData = data["lists"] as? Data {
            do {
                let receivedLists = try JSONDecoder().decode([DecisionList].self, from: listsData)
                updateLists(receivedLists)
            } catch {
                print("Ошибка декодирования полученных данных: \(error.localizedDescription)")
            }
        }
    }
    
    // Функция для запроса данных с телефона
    func requestDataFromPhone() {
        guard WCSession.default.isReachable else {
            print("Телефон недоступен для запроса")
            return
        }
        
        // Отправляем запрос на телефон
        WCSession.default.sendMessage(["request": "data"], replyHandler: { reply in
            // Обрабатываем ответ от телефона
            self.processReceivedData(reply)
        }, errorHandler: { error in
            print("Ошибка запроса данных: \(error.localizedDescription)")
        })
    }
}
