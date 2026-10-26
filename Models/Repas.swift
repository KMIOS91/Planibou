import Foundation
import SwiftData

enum TypeRepas: String, Codable, CaseIterable {
    case midi
    case gouter

    var libelle: String {
        switch self {
        case .midi: "Midi"
        case .gouter: "Goûter"
        }
    }

    var heure: String {
        switch self {
        case .midi: "11h–13h"
        case .gouter: "16h"
        }
    }
}

@Model
final class Repas {
    /// Stocké en String : plus simple à filtrer avec #Predicate qu'un enum.
    var typeRaw: String
    var intitule: String
    var jour: Jour?

    var type: TypeRepas {
        get { TypeRepas(rawValue: typeRaw) ?? .midi }
        set { typeRaw = newValue.rawValue }
    }

    init(type: TypeRepas, intitule: String) {
        self.typeRaw = type.rawValue
        self.intitule = intitule
    }
}
