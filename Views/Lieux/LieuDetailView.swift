//
//  LieuDetailView.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//
import SwiftUI
import SwiftData
import MapKit

struct LieuDetailView: View {
    @Bindable var lieu: Lieu
    @State private var mapItem: MKMapItem?
    @State private var chargement = true

    var body: some View {
        Form {
            // 1. La carte (seulement si le lieu vient d'Apple Plans)
            if lieu.mapItemIdentifier != nil {
                sectionCarte
            }

            // 2. Adresse et téléphone
            Section("Infos") {
                if !lieu.adresse.isEmpty {
                    Label(lieu.adresse, systemImage: "mappin.and.ellipse")
                }
                if let telephone = lieu.telephone,
                   let url = URL(string: "tel:\(telephone.filter { !$0.isWhitespace })") {
                    Link(destination: url) {
                        Label(telephone, systemImage: "phone")
                    }
                }
            }

            // 3. Ce que Plans ne sait pas : on le complète à la main
            Section("Prix et réservation") {
                LabeledContent("Prix") {
                    TextField("ex : Gratuit, 9,50 €", text: $lieu.prix)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Réservation") {
                    TextField("ex : En ligne, sur place…", text: $lieu.infoReservation)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Détails") {
                TextField("Horaires, conseils, à emporter…",
                          text: $lieu.details,
                          axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle(lieu.nom)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await chargerMapItem()
        }
    }

    // MARK: - La section carte

    @ViewBuilder
    private var sectionCarte: some View {
        Section {
            if let mapItem {
                Map(initialPosition: .item(mapItem)) {
                    Marker(item: mapItem)
                }
                .frame(height: 200)
                .listRowInsets(EdgeInsets())   // la carte prend toute la largeur

                Button("Y aller", systemImage: "car.fill") {
                    mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
                    ])
                }
            } else if chargement {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Text("Impossible de charger la carte")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Recharger le lieu depuis Apple Plans

    private func chargerMapItem() async {
        defer { chargement = false }

        // Déjà chargé, ou lieu "maison" sans identifiant → rien à faire
        guard mapItem == nil, let identifiant = lieu.mapItemIdentifier else { return }

        do {
            let requete = MKMapItemRequest(mapItemIdentifier: identifiant)
            mapItem = try await requete.mapItem
        } catch {
            print("Chargement du lieu échoué : \(error.localizedDescription)")
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Lieu.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let lieu = Lieu(nom: "Ferme des Gondoles",
                    adresse: "Parc des Gondoles, rue Méhy, Choisy-le-Roi",
                    telephone: "01 48 90 77 11",
                    prix: "Gratuit",
                    infoReservation: "Pas de réservation",
                    details: "Ouvert tous les jours 9h–12h et 14h–17h.")
    container.mainContext.insert(lieu)

    return NavigationStack {
        LieuDetailView(lieu: lieu)
    }
    .modelContainer(container)
}
