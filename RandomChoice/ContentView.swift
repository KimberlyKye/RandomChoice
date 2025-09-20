import SwiftUI

struct ContentView: View {
    // Получаем доступ к менеджеру данных из окружения
    @EnvironmentObject var dataManager: PhoneDataManager
    // Переменная для контроля показа окна добавления нового списка
    @State private var showingAddListSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // Проверяем, есть ли вообще списки
                if dataManager.lists.isEmpty {
                    // Если списков нет - показываем подсказку
                    Text("Списков пока нет\nНажмите + чтобы создать первый")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear) // Прозрачный фон
                } else {
                    // Если списки есть - отображаем их
                    ForEach(dataManager.lists) { list in
                        // Навигационная ссылка ведет на экран редактирования конкретного списка
                        NavigationLink(destination: ListDetailView(list: binding(for: list))) {
                            VStack(alignment: .leading) {
                                Text(list.name)
                                    .font(.headline)
                                Text("Вариантов: \(list.options.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteList) // Добавляем возможность удаления свайпом
                }
            }
            .navigationTitle("Мои списки")
            .toolbar {
                // Кнопка добавления нового списка в тулбаре
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddListSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                // Кнопка редактирования списка (включает режим удаления)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // Стандартная кнопка редактирования от Apple
                }
            }
            .sheet(isPresented: $showingAddListSheet) {
                // Модальное окно для добавления нового списка
                AddListView()
            }
        }
    }
    
    // Вспомогательная функция для получения binding к конкретному списку
    private func binding(for list: DecisionList) -> Binding<DecisionList> {
        guard let index = dataManager.lists.firstIndex(where: { $0.id == list.id }) else {
            fatalError("Список не найден")
        }
        return $dataManager.lists[index]
    }
    
    // Функция для удаления списков по индексу
    private func deleteList(at offsets: IndexSet) {
        // Подтверждение перед удалением
        let alert = UIAlertController(
            title: "Удалить список?",
            message: "Это действие нельзя отменить",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.dataManager.deleteList(at: offsets)
        })
        
        // Показываем alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

// Превью для Canvas
#Preview {
    ContentView()
        .environmentObject(PhoneDataManager()) // Добавляем мок-данные для превью
}
