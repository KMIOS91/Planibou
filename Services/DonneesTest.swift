#if DEBUG
import Foundation
import SwiftData
import MapKit
/// Semaine du 12 au 18 octobre, reprise du planning de ta sœur.
/// Pratique pour développer les écrans sans tout saisir à la main.
enum DonneesTest {

    static let lundi: Date = {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 12))!
    }()

    static func charger(in context: ModelContext) {
        // On repart de zéro à chaque chargement
        
        for jour in (try? context.fetch(FetchDescriptor<Jour>())) ?? [] {
            context.delete(jour)
        }
        for lieu in  (try? context.fetch(FetchDescriptor<Lieu>())) ?? [] where lieu.mapItemIdentifier == nil  {
                context.delete(lieu)
        }

        let maison = Lieu(nom: "Activités à la maison",
                          adresse: "Chez toi",
                          prix: "Gratuit ou presque",
                          infoReservation: "Rien à réserver",
                          details: "Toujours sous surveillance.")
        let raconte = Lieu(nom: "Raconte : comptines et jeux de doigts",
                           adresse: "Lieu de la séance",
                           prix: "Gratuit en général",
                           infoReservation: "Inscription à vérifier",
                           details: "Arriver quelques minutes avant.")
        let laep = Lieu(nom: "Lieu d'accueil enfants-parents",
                        adresse: "Demander à la mairie ou à la PMI",
                        prix: "Gratuit, anonyme",
                        infoReservation: "Sans inscription, horaires à vérifier",
                        details: "Bien pour la sociabilité et pour souffler un peu.")
        let doudou = Lieu(nom: "Ferme La Doudou",
                          adresse: "Bordure de la forêt de Cheptainville",
                          prix: "Adulte 7,50 €",
                          infoReservation: "Sans réservation, horaires à vérifier",
                          details: "Traite vers 15h30. Aire de jeux et pique-nique.")

        // (midi, goûter, activité?)
        let semaine: [(String, String, Activite?)] = [
            ("Gratin de chou-fleur et poulet", "Muffin + fromage blanc",
             Activite(titre: "Peinture au yaourt coloré", moment: .matin, heure: "10h00", lieu: maison)),
            ("Colin, purée panais-pomme de terre", "Banane + biscuit bébé", nil),
            ("Poulet, polenta crémeuse, épinards", "Muffin à la banane",
             Activite(titre: "Comptines et jeux de doigts", moment: .matin, heure: "10h30",
                      statut: .aVerifier, lieu: raconte)),
            ("Pâtes à la bolognaise", "Crêpes",
             Activite(titre: "Musique avec casseroles", moment: .matin, heure: "10h00", lieu: maison)),
            ("Saumon, riz, fondue de poireaux", "Tartine + fromage frais",
             Activite(titre: "Lieu d'accueil enfants-parents", moment: .matin, heure: "10h30",
                      statut: .aVerifier, lieu: laep)),
            ("Riz au bœuf, sauce tomate", "Gâteau au yaourt peu sucré", nil),
            ("Poisson blanc, purée de carotte", "Gâteau au yaourt (reste)",
             Activite(titre: "Ferme La Doudou (sieste plus tôt)", moment: .apresMidi, heure: "15h00",
                      statut: .aVerifier, lieu: doudou)),
        ]

        for (index, (midi, gouter, activite)) in semaine.enumerated() {
            let date = Calendar.current.date(byAdding: .day, value: index, to: lundi)!
            let jour = Jour(date: date)
            context.insert(jour)
            jour.repas = [Repas(type: .midi, intitule: midi),
                          Repas(type: .gouter, intitule: gouter)]
            jour.activite = activite
        }

        do {
            try context.save()
            print("✅ Données de test chargées")
        } catch {
            print("❌ Erreur : \(error)")
        }    }
}
#endif
