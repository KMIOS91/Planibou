import Foundation
import SwiftData

/// Une journée du planning : ses repas et son activité.
@Model
final class Jour {
    /// Toujours stockée à minuit (début de journée) pour faciliter les recherches.
    var date: Date

    @Relationship(deleteRule: .cascade, inverse: \Repas.jour)
    var repas: [Repas] = []

    @Relationship(deleteRule: .cascade, inverse: \activites.jour)
    var activite: activites?

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
    }

    // MARK: - Raccourcis pratiques pour les vues

    var midi: Repas? { repas.first { $0.type == .midi } }
    var gouter: Repas? { repas.first { $0.type == .gouter } }

    var estWeekEnd: Bool {
        Calendar.current.isDateInWeekend(date)
    }
}
