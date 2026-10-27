import Foundation
import SwiftData

enum Moment: String, Codable, CaseIterable {
    case matin
    case apresMidi

    var libelle: String {
        switch self {
        case .matin: "Matin"
        case .apresMidi: "Après-midi"
        }
    }
}

enum StatutReservation: String, Codable, CaseIterable {
    case aucune      // "Pas de réservation"
    case aVerifier   // "À vérifier"
    case aReserver   // "À réserver"
    case reserve     // "Réservé / vérifié"

    var libelle: String {
        switch self {
        case .aucune: "Pas de réservation"
        case .aVerifier: "À vérifier"
        case .aReserver: "À réserver"
        case .reserve: "Réservé"
        }
    }

    /// Ce qui demande une action de la maman (utile plus tard pour les notifications).
    var demandeAction: Bool {
        self == .aVerifier || self == .aReserver
    }
}

@Model
final class activites {
    var titre: String
    var momentRaw: String
    var heure: String          // "10h30" — texte libre pour le MVP
    var statutRaw: String
    var dureeMinutes: Int = 60
    
    var jour: Jour?
    var lieu: Lieu?

    var moment: Moment {
        get { Moment(rawValue: momentRaw) ?? .matin }
        set { momentRaw = newValue.rawValue }
    }

    var statut: StatutReservation {
        get { StatutReservation(rawValue: statutRaw) ?? .aucune }
        set { statutRaw = newValue.rawValue }
    }

    init(titre: String,
         moment: Moment,
         heure: String,
         dureeMinutes: Int = 60,
         statut: StatutReservation = .aucune,
         lieu: Lieu? = nil) {
        self.titre = titre
        self.momentRaw = moment.rawValue
        self.heure = heure
        self.dureeMinutes = dureeMinutes  
        self.statutRaw = statut.rawValue
        self.lieu = lieu
    }
}
