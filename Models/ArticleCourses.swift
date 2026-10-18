import Foundation
import SwiftData

enum Rayon: String, Codable, CaseIterable {
    case fruitsLegumes
    case viandesPoissons
    case frais
    case epicerie

    var libelle: String {
        switch self {
        case .fruitsLegumes: "Fruits et légumes"
        case .viandesPoissons: "Viandes et poissons"
        case .frais: "Frais"
        case .epicerie: "Épicerie"
        }
    }
}

@Model
final class ArticleCourses {
    var nom: String
    var quantite: String?      // "1 kg", "6", "2 tranches"…
    var rayonRaw: String
    var coche: Bool
    /// Lundi de la semaine concernée.
    var semaine: Date

    var rayon: Rayon {
        get { Rayon(rawValue: rayonRaw) ?? .epicerie }
        set { rayonRaw = newValue.rawValue }
    }

    init(nom: String, quantite: String? = nil, rayon: Rayon, semaine: Date) {
        self.nom = nom
        self.quantite = quantite
        self.rayonRaw = rayon.rawValue
        self.coche = false
        self.semaine = Calendar.current.startOfDay(for: semaine)
    }
}
