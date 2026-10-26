//
//  AutocompletionLieux.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//

import Foundation
import MapKit
import Observation

/// Propose des suggestions de lieux pendant qu'on tape (comme l'app Plans).
/// C'est un "pont" entre MKLocalSearchCompleter (ancien style, avec delegate)
/// et SwiftUI (qui aime les objets @Observable).
@MainActor
@Observable
final class AutocompletionLieux: NSObject {

    /// Les suggestions à afficher. SwiftUI redessine la liste quand ça change.
    var suggestions: [MKLocalSearchCompletion] = []

    /// L'outil d'Apple qui calcule les suggestions.
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self                // "préviens-moi quand tu as des résultats"
        completer.resultTypes = .pointOfInterest // des lieux, pas des adresses de rue
    }

    /// À appeler à chaque fois que le texte tapé change.
    func mettreAJour(avec texte: String) {
        if texte.isEmpty {
            suggestions = []
        }
        completer.queryFragment = texte          // ça déclenche le calcul des suggestions
    }
}

// MARK: - Le delegate : le completer nous rappelle ici

extension AutocompletionLieux: MKLocalSearchCompleterDelegate {

    /// Appelée par MapKit quand de nouvelles suggestions sont prêtes.
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.suggestions = completer.results
        }
    }

    /// Appelée si quelque chose échoue (pas de réseau…).
    nonisolated func completer(_ completer: MKLocalSearchCompleter,
                               didFailWithError error: any Error) {
        print("Autocomplétion échouée : \(error.localizedDescription)")
    }
}
