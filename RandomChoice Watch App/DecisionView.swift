import SwiftUI
import AVFoundation
import WatchKit

struct DecisionView: View {
    let list: DecisionList
    @State private var selectedOption: String?
    @State private var isSpinning = false
    @State private var spinDegrees = 0.0
    @State private var showResult = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок с названием списка
                Text(list.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                // Визуализация "рулетки"
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    if let selectedOption = selectedOption, showResult {
                        // Показываем результат с улучшенным оформлением
                        VStack {
                            Text("Выбор:")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(selectedOption)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8) // Автоматическое уменьшение шрифта
                        }
                        .padding(8)
                    } else {
                        // Показываем иконку во время вращения
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(spinDegrees))
                    }
                }
                .padding(.vertical, 20)
                
                // Кнопка запуска генерации
                Button(action: startSpinning) {
                    Label(
                        selectedOption == nil ? "Выбрать" : "Выбрать снова",
                        systemImage: "arrow.clockwise"
                    )
                    .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
                .disabled(isSpinning)
                
                // Список всех вариантов (только для информации)
                if !showResult {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Варианты:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ForEach(list.options.prefix(5), id: \.self) { option in
                            Text("• \(option)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        if list.options.count > 5 {
                            Text("... и еще \(list.options.count - 5)")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startSpinning() {
        guard !isSpinning else { return }
        
        isSpinning = true
        showResult = false
        selectedOption = nil
        
        // Тактильная обратная связь - начало вращения
        WKInterfaceDevice.current().play(.start)
        
        // Анимация вращения
        withAnimation(.easeInOut(duration: 0.5)) {
            spinDegrees += 360
        }
        
        // Запускаем процесс выбора с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.selectRandomOption()
        }
    }
    
    private func selectRandomOption() {
        // Выбираем случайный вариант
        selectedOption = list.options.randomElement()
        
        // Тактильная обратная связь - результат
        WKInterfaceDevice.current().play(.success)

        // Показываем результат с анимацией
        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
        }
        
        // Озвучиваем результат
        speakSelectedOption()
        
        // Сбрасываем состояние через секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSpinning = false
        }
    }
    
    private func speakSelectedOption() {
        guard let option = selectedOption else { return }
        
        // Создаем utterance с выбранным вариантом
        let utterance = AVSpeechUtterance(string: option)
        
        // Настраиваем параметры речи
        utterance.rate = 0.5 // Скорость речи (0.0 - 1.0)
        utterance.pitchMultiplier = 1.0 // Высота тона
        utterance.volume = 0.8 // Громкость
        
        // Используем системный голос
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU") // Русский язык
        
        // Озвучиваем
        speechSynthesizer.speak(utterance)
    }
}

#Preview {
    DecisionView(list: DecisionList(
        name: "Что поесть?",
        options: ["Пицца", "Суши", "Бургер", "Паста", "Салат", "Стейк"]
    ))
}
