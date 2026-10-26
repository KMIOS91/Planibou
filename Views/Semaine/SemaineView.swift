import SwiftUI
import SwiftData

enum FeuilleSemaine: Identifiable {
    case ajoutActivite
    case rechercheLieu

    var id: Self { self }
}

struct SemaineView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Jour.date)
    private var jours: [Jour]

    @State private var feuille: FeuilleSemaine?
    @State private var lundi: Date = Date.now.lundiDeLaSemaine

    private var joursDeLaSemaine: [Jour] {
        let fin = Calendar.current.date(byAdding: .day, value: 7, to: lundi)!
        return jours.filter { $0.date >= lundi && $0.date < fin }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    ForEach(joursDeLaSemaine) { jour in
                        JourCard(jour: jour)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle(titreSemaine)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    boutonsSemaine
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Ajouter", systemImage: "plus") { feuille = .ajoutActivite }
                    Button("Lieu", systemImage: "mappin") { feuille = .rechercheLieu }
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
            .sheet(item: $feuille) { feuille in
                switch feuille {
                case .ajoutActivite: AjoutActiviteView(dateInitiale: lundi)
                case .rechercheLieu: RechercheLieuView()
                }
            }
            // À chaque changement de semaine : les 7 jours existent, même vides
            .task(id: lundi) {
                context.preparerSemaine(commencantLe: lundi)
            }
        }
    }

    private var titreSemaine: String {
        let fin = Calendar.current.date(byAdding: .day, value: 6, to: lundi)!
        let f = Date.FormatStyle(locale: Locale(identifier: "fr_FR")).day().month(.abbreviated)
        return "\(lundi.formatted(f)) – \(fin.formatted(f))"
    }

    private func changerSemaine(de nombre: Int) {
        lundi = Calendar.current.date(byAdding: .weekOfYear, value: nombre, to: lundi)!
    }

    @ViewBuilder
    private var boutonsSemaine: some View {
        Button("Semaine précédente", systemImage: "chevron.left") {
            changerSemaine(de: -1)
        }
        Button("Semaine suivante", systemImage: "chevron.right") {
            changerSemaine(de: 1)
        }
    }
}

extension Date {
    var lundiDeLaSemaine: Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal.dateInterval(of: .weekOfYear, for: self)!.start
    }
}

#Preview {
    SemaineView()
        .modelContainer(for: [Jour.self, Repas.self, Activite.self, Lieu.self,
                              ArticleCourses.self, ProfilBebe.self],
                        inMemory: true)
}
