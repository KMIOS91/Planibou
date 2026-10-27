import Foundation
import SwiftData

/// Une journée du planning : ses repas et son activité.
@Model
final class Jour {
    /// Toujours stockée à minuit (début de journée) pour faciliter les recherches.
    var date: Date

    @Relationship(deleteRule: .cascade, inverse: \Repas.jour)
    var repas: [Repas] = []

    @Relationship(deleteRule: .cascade, inverse: \Activite.jour)
    var activites : [Activite] = []

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
    }

    // MARK: - Raccourcis pratiques pour les vues

    var midi: Repas? { repas.first { $0.type == .midi } }
    var gouter: Repas? { repas.first { $0.type == .gouter } }

    
    // Les activités triées par heure (10h00 avant 15h30).
    var activitesTriees: [Activite] {
        activites.sorted {
            (Horaire.minutes(depuis: $0.heure) ?? 0) < (Horaire.minutes(depuis: $1.heure) ?? 0)
        }
    }
    
    var estWeekEnd: Bool {
        Calendar.current.isDateInWeekend(date)
    }
    
  
}
