//
//  AjoutActiviteView.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//

import SwiftUI
import SwiftData

/// Formulaire de saisie manuelle d'une activité.
struct AjoutActiviteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    /// Tous les lieux déjà enregistrés, triés par nom (pour le menu de choix).
    @Query(sort: \Lieu.nom) private var lieux: [Lieu]

    // MARK: - Les champs du formulaire
    @State private var titre = ""
    @State private var date: Date
    @State private var moment: Moment = .matin
    @State private var heure: Date = AjoutActiviteView.heure(10, 0)
    @State private var dureeMinutes = 60
    @State private var statut: StatutReservation = .aucune
    @State private var lieu: Lieu?

    @State private var afficherRecherche = false

    /// On peut ouvrir le formulaire sur un jour précis.
    init(dateInitiale: Date = .now) {
        _date = State(initialValue: dateInitiale)
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1. Quoi ?
                Section("Activité") {
                    TextField("Ex : Ferme, parc, bibliothèque…", text: $titre)
                }

                // 2. Quand ?
                Section("Quand") {
                    DatePicker("Jour", selection: $date, displayedComponents: .date)

                    Picker("Moment", selection: $moment) {
                        ForEach(Moment.allCases, id: \.self) { moment in
                            Text(moment.libelle).tag(moment)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Heure", selection: $heure, displayedComponents: .hourAndMinute)
                    
                    Picker("Durée", selection: $dureeMinutes) {
                        ForEach([30, 45, 60, 90, 120, 180], id: \.self) { minutes in
                            Text(Horaire.duree(minutes)).tag(minutes)
                        }
                    }
                }

                // 3. Où ?
                Section("Lieu") {
                    Picker("Lieu", selection: $lieu) {
                        Text("Aucun").tag(Lieu?.none)
                        ForEach(lieux) { lieu in
                            Text(lieu.nom).tag(Optional(lieu))
                        }
                    }

                    Button("Chercher un nouveau lieu…", systemImage: "magnifyingglass") {
                        afficherRecherche = true
                    }
                }

                // 4. Réservation ?
                Section("Réservation") {
                    Picker("Statut", selection: $statut) {
                        ForEach(StatutReservation.allCases, id: \.self) { statut in
                            Text(statut.libelle).tag(statut)
                        }
                    }
                }
            }
            .navigationTitle("Nouvelle activité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { enregistrer() }
                        .disabled(titre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            // Le rythme de bébé : matin vers 10h, après-midi après la sieste vers 15h30
            .onChange(of: moment) {
                heure = moment == .matin ? Self.heure(10, 0) : Self.heure(15, 30)
            }
            // Si on choisit un lieu et que le titre est vide, on le remplit tout seul
            .onChange(of: lieu) {
                if titre.isEmpty, let lieu { titre = lieu.nom }
            }
            .sheet(isPresented: $afficherRecherche) {
                RechercheLieuView { nouveauLieu in
                    lieu = nouveauLieu      // le lieu créé est sélectionné direct
                }
            }
        }
    }

    // MARK: - Enregistrer

    private func enregistrer() {
        let jour = context.jour(pour: date)

        // Une seule activité par jour pour le MVP : on remplace l'ancienne
        if let ancienne = jour.activite {
            context.delete(ancienne)
        }

        let activite = Activite(titre: titre.trimmingCharacters(in: .whitespaces),
                                moment: moment,
                                heure: texteHeure,
                                dureeMinutes: dureeMinutes,   // ← nouveau
                                statut: statut,
                                lieu: lieu)
        
        context.insert(activite)
        jour.activite = activite
        dismiss()
    }

   

    // MARK: - Petits outils pour l'heure

    /// "10h00", "15h30"… (le format du planning de ta sœur)
    private var texteHeure: String {
        let c = Calendar.current.dateComponents([.hour, .minute], from: heure)
        return String(format: "%dh%02d", c.hour ?? 0, c.minute ?? 0)
    }

    /// Fabrique une Date à aujourd'hui, à l'heure demandée.
    private static func heure(_ h: Int, _ m: Int) -> Date {
        Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: .now) ?? .now
    }
}

#Preview {
    AjoutActiviteView()
        .modelContainer(for: [Jour.self, Repas.self, Activite.self, Lieu.self,
                              ArticleCourses.self, ProfilBebe.self],
                        inMemory: true)
}
