import SwiftUI

struct ListDetailView: View {
    @Binding var list: DecisionList // Binding позволяет изменять оригинальный список
    @State private var newOption = ""
    
    var body: some View {
        Form {
            // Секция для редактирования названия
            Section(header: Text("Название списка")) {
                TextField("Название", text: $list.name)
                    .textInputAutocapitalization(.sentences)
            }
            
            // Секция для управления вариантами
            Section(header: Text("Варианты")) {
                // Поле для добавления нового варианта
                HStack {
                    TextField("Новый вариант", text: $newOption)
                    Button(action: addOption) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newOption.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                // Список существующих вариантов с возможностью редактирования
                ForEach(Array(list.options.enumerated()), id: \.offset) { index, option in
                    TextField("Вариант \(index + 1)", text: $list.options[index])
                }
                .onDelete(perform: deleteOption) // Удаление свайпом
                
                // Кнопка для быстрого добавления нескольких вариантов
                Button("Добавить примеры") {
                    withAnimation {
                        list.options.append(contentsOf: ["Вариант 1", "Вариант 2", "Вариант 3"])
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Редактирование")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addOption() {
        let trimmedOption = newOption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOption.isEmpty else { return }
        
        withAnimation {
            list.options.append(trimmedOption)
            newOption = ""
        }
    }
    
    private func deleteOption(at offsets: IndexSet) {
        list.options.remove(atOffsets: offsets)
    }
}

// Специальная структура для превью с Binding
struct ListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем состояние для preview
        NavigationStack {
            ListDetailView(list: .constant(
                DecisionList(
                    name: "Пример списка",
                    options: ["Вариант 1", "Вариант 2", "Вариант 3"]
                )
            ))
        }
    }
}
