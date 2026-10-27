//
//  RechercheLieuView.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//
import SwiftUI
import SwiftData
import MapKit

/// Écran pour chercher un lieu dans Apple Plans (avec suggestions en direct)
/// et l'ajouter comme fiche `Lieu`.
struct RechercheLieuView: View {
    // MARK: - Accès à l'environnement
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - État de l'écran
    @State private var texte = ""
    @State private var autocompletion = AutocompletionLieux()
    @State private var ajoutEnCours = false

    /// Optionnel : prévient l'écran parent du lieu qui vient d'être ajouté.
    var surAjout: ((Lieu) -> Void)? = nil

    var body: some View {
        NavigationStack {
            List(autocompletion.suggestions, id: \.self) { suggestion in
                Button {
                    Task { await ajouter(suggestion) }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.title)            // ex : "Ferme des Gondoles"
                            .font(.headline)
                        if !suggestion.subtitle.isEmpty {
                            Text(suggestion.subtitle)     // ex : "Choisy-le-Roi, France"
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .tint(.primary)
                .disabled(ajoutEnCours)
            }
            .overlay { messageVide }
            .navigationTitle("Ajouter un lieu")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $texte,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Ferme, parc, médiathèque…")
            .onChange(of: texte) {
                autocompletion.mettreAJour(avec: texte)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    // MARK: - Messages quand la liste est vide

    @ViewBuilder
    private var messageVide: some View {
        if ajoutEnCours {
            ProgressView("Ajout du lieu…")
        } else if texte.isEmpty {
            ContentUnavailableView("Cherche un lieu",
                                   systemImage: "map",
                                   description: Text("Même un bout du nom suffit : « gond », « ferme »…"))
        } else if autocompletion.suggestions.isEmpty {
            ContentUnavailableView.search(text: texte)
        }
    }

    // MARK: - Suggestion choisie → vraie recherche → fiche Lieu

    private func ajouter(_ suggestion: MKLocalSearchCompletion) async {
        ajoutEnCours = true
        defer { ajoutEnCours = false }

        // On transforme la suggestion en vraie recherche pour obtenir
        // l'adresse, le téléphone et l'identifiant Plans.
        let requete = MKLocalSearch.Request(completion: suggestion)

        do {
            let reponse = try await MKLocalSearch(request: requete).start()
            guard let item = reponse.mapItems.first else { return }

            let lieu = Lieu(nom: item.name ?? suggestion.title,
                            adresse: item.address?.fullAddress ?? suggestion.subtitle,
                            telephone: item.phoneNumber,
                            prix: "",
                            infoReservation: "",
                            details: "")
            lieu.mapItemIdentifier = item.identifier
            context.insert(lieu)
            surAjout?(lieu)   // "voilà le lieu que j'ai créé"
            dismiss()
        } catch {
            print("Recherche échouée : \(error.localizedDescription)")
        }
    }
}

#Preview {
    RechercheLieuView()
        .modelContainer(for: [Jour.self, Repas.self, activites.self, Lieu.self,
                              ArticleCourses.self, ProfilBebe.self],
                        inMemory: true)
}
