import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: WatchDataManager
    @State private var isRefreshing = false
    @State private var shouldAnimateUpdate = false

    var body: some View {
        NavigationStack {
            if dataManager.lists.isEmpty {
                // Экран пустого состояния
                VStack(spacing: 12) {
                    Image(systemName: "iphone.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Нет данных")
                        .font(.headline)
                    
                    Text("Запустите приложение на iPhone")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button(action: refreshData) {
                        Label("Обновить", systemImage: "arrow.clockwise")
                    }
                    .disabled(isRefreshing)
                }
                .padding()
            } else {
                // Список доступных DecisionList
                List(dataManager.lists) { list in
                    NavigationLink(destination: DecisionView(list: list)) {
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text("\(list.options.count) вариантов")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                .listStyle(.carousel) // Добавляем стиль списка
                .id(dataManager.lists.count) // Принудительное обновление при изменении данных
                .navigationTitle("Мои списки")
                .refreshable {
                    // Потянуть чтобы обновить - запросит данные с телефона
                    await refreshDataAsync()
                }
            }
        }
        .onAppear {
            print("Загружено списков: \(dataManager.lists.count)")
        }
    }
    
    private func refreshData() {
        Task {
            await refreshDataAsync()
        }
    }
    
    private func refreshDataAsync() async {
        isRefreshing = true
        // Имитация запроса к телефону
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        dataManager.requestDataFromPhone()
        isRefreshing = false
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchDataManager())
}
