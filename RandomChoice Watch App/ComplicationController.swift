import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Обязательные методы
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "random_choice_complication",
                displayName: "Random Choice",
                supportedFamilies: [.graphicCircular, .utilitarianSmall]
            )
        ]
        handler(descriptors)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Получаем текущую временную метку
        handler(createTimelineEntry(for: complication, date: Date()))
    }
    
    // MARK: - Создание элементов осложнения
    
    private func createTimelineEntry(for complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        let template = createTemplate(for: complication)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template!)
    }
    
    private func createTemplate(for complication: CLKComplication) -> CLKComplicationTemplate? {
        switch complication.family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(
                ComplicationViewCircular()
            )
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKTextProvider(format: "🎲 Выбрать"),
                imageProvider: CLKImageProvider(onePieceImage: UIImage(systemName: "dice.fill")!)
            )
        default:
            return nil // Не поддерживаем другие типы
        }
    }
    
    // MARK: - Прочие обязательные методы (минимальная реализация)
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, with handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(createTemplate(for: complication))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, with handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen) // Правильный синтаксис
    }
}

// MARK: - Вью для осложнения
struct ComplicationViewCircular: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.gradient)
            Image(systemName: "dice.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
