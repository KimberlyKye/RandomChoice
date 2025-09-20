import SwiftUI

struct AddListView: View {
    @EnvironmentObject var dataManager: PhoneDataManager
    @Environment(\.dismiss) var dismiss // Для закрытия окна
    
    // Переменные для хранения вводимых данных
    @State private var listName = ""
    @State private var newOption = ""
    @State private var options: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                // Секция для названия списка
                Section(header: Text("Название списка")) {
                    TextField("Например: Что посмотреть?", text: $listName)
                        .textInputAutocapitalization(.sentences)
                }
                
                // Секция для добавления вариантов
                Section(header: Text("Варианты выбора")) {
                    // Поле для добавления нового варианта
                    HStack {
                        TextField("Добавить вариант", text: $newOption)
                        Button(action: addOption) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .disabled(newOption.trimmingCharacters(in: .whitespaces).isEmpty) // Кнопка неактивна, если поле пустое
                    }
                    
                    // Список добавленных вариантов
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                    .onDelete(perform: deleteOption) // Удаление варианта свайпом
                }
            }
            .navigationTitle("Новый список")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss() // Закрыть окно без сохранения
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        saveList() // Сохранить новый список
                    }
                    .disabled(listName.isEmpty || options.isEmpty) // Нельзя сохранить пустой список
                }
            }
        }
    }
    
    // Добавление варианта в список
    private func addOption() {
        let trimmedOption = newOption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOption.isEmpty else { return }
        
        withAnimation {
            options.append(trimmedOption)
            newOption = "" // Очищаем поле ввода
        }
    }
    
    // Удаление варианта по индексу
    private func deleteOption(at offsets: IndexSet) {
        options.remove(atOffsets: offsets)
    }
    
    // Сохранение готового списка
    private func saveList() {
        let newList = DecisionList(
            name: listName.trimmingCharacters(in: .whitespacesAndNewlines),
            options: options
        )
        
        dataManager.addList(newList)
        dismiss() // Закрываем окно
    }
}

#Preview {
    AddListView()
        .environmentObject(PhoneDataManager())
}
