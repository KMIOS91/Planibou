import SwiftUI
import SwiftData


enum FeuilleSemaine: Identifiable {
    case ajoutActivite
    case rechercheLieu

    var id: Self { self }   // Identifiable : chaque cas est son propre id
}





struct SemaineView: View {
    @State private var afficherRecherche = false
    @Environment(\.modelContext) private var context
    @State private var scriptAffiche: String = "Chargement..."
    @State private var afficherAjout = false
    /// Toutes les journées, triées. On filtre la semaine affichée en mémoire :
    /// largement suffisant pour un MVP (quelques dizaines de jours).
    @Query(sort: \Jour.date)
    private var jours: [Jour]

    @State private var lundi: Date = Date.now.lundiDeLaSemaine

    private var joursDeLaSemaine: [Jour] {
        let fin = Calendar.current.date(byAdding: .day, value: 7, to: lundi)!
        return jours.filter { $0.date >= lundi && $0.date < fin }
    }

    var body: some View {
        NavigationStack {
            List {
                if joursDeLaSemaine.isEmpty {
                    ContentUnavailableView(
                        "Semaine vide",
                        systemImage: "calendar.badge.plus",
                        description: Text("Rien de prévu pour l'instant.")
                    )
                } else {
                    ForEach(joursDeLaSemaine) { jour in
                        JourCard(jour: jour)
                    }
                }
            }
            .onAppear{
                
                // Appel direct et synchrone (pas besoin de 'task')
                            let resultat = ScriptIdentifier.localizedScript(for: "fr_FR", in: "en-US")
                            
                            // Mise à jour de l'interface
                            self.scriptAffiche = resultat
                            
                            // Optionnel : l'afficher aussi dans la console de debug
                            print("Script localisé : \(resultat)")
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle(titreSemaine)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Ajouter", systemImage: "plus") {
                        afficherAjout = true
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button("Ajouter un lieu", systemImage: "mappin.and.ellipse") {
                        afficherRecherche = true
                    }
                }
                
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Semaine précédente", systemImage: "chevron.left") {
                        changerSemaine(de: -1)
                    }
                    Button("Semaine suivante", systemImage: "chevron.right") {
                        changerSemaine(de: 1)
                    }
                }
                #if DEBUG
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Données de test", systemImage: "wand.and.stars") {
                        DonneesTest.charger(in: context)
                        lundi = DonneesTest.lundi
                    }
                }
                #endif
            }
            .sheet(isPresented: $afficherAjout) {
                AjoutActiviteView(dateInitiale: lundi)
            }
            .sheet(isPresented: $afficherRecherche) {
                RechercheLieuView()
            }
        }
    }

    private var titreSemaine: String {
        let fin = Calendar.current.date(byAdding: .day, value: 6, to: lundi)!
        let f = Date.FormatStyle().day().month(.abbreviated)
        return "\(lundi.formatted(f)) – \(fin.formatted(f))"
    }

    private func changerSemaine(de nombre: Int) {
        lundi = Calendar.current.date(byAdding: .weekOfYear, value: nombre, to: lundi)!
    }
}

extension Date {
    /// Le lundi (à minuit) de la semaine qui contient cette date.
    var lundiDeLaSemaine: Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // lundi
        return cal.dateInterval(of: .weekOfYear, for: self)!.start
    }
}

#Preview {
    SemaineView()
        .modelContainer(for: [Jour.self, Repas.self, Activite.self, Lieu.self,
                              ArticleCourses.self, ProfilBebe.self],
                        inMemory: true)
}
