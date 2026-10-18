import Foundation
import SwiftData

/// Ce que l'IA devra toujours respecter quand elle propose des repas.
@Model
final class ProfilBebe {
    var prenom: String
    var dateNaissance: Date
    var allergies: [String]
    var nAimePas: [String]

    init(prenom: String,
         dateNaissance: Date,
         allergies: [String] = [],
         nAimePas: [String] = []) {
        self.prenom = prenom
        self.dateNaissance = dateNaissance
        self.allergies = allergies
        self.nAimePas = nAimePas
    }

    var ageEnMois: Int {
        Calendar.current.dateComponents([.month], from: dateNaissance, to: .now).month ?? 0
    }
}
