import Foundation
import SwiftData
import MapKit
import Foundation
import SwiftData
import MapKit

/// Une "fiche" réutilisable : la Ferme des Gondoles revient d'un mois à l'autre.
@Model
final class Lieu {
    @Attribute(.unique) var nom: String
    var adresse: String
    var telephone: String?
    var prix: String
    var infoReservation: String
    var details: String

    /// L'identifiant du lieu dans Apple Plans (nil pour "Chez toi", etc.).
    @Attribute(.codable) var mapItemIdentifier: MKMapItem.Identifier? = nil

    @Relationship(inverse: \activites.lieu)
    var activites: [activites] = []

    init(nom: String,
         adresse: String,
         telephone: String? = nil,
         prix: String,
         infoReservation: String,
         details: String) {
        self.nom = nom
        self.adresse = adresse
        self.telephone = telephone
        self.prix = prix
        self.infoReservation = infoReservation
        self.details = details
    }
}
