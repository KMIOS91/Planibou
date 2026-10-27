import SwiftUI
import SwiftData

enum FeuilleSemaine: Identifiable {
    case ajoutActivite

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
                ToolbarItem(placement: .primaryAction) {
                    Button("Ajouter", systemImage: "plus") { feuille = .ajoutActivite }
                }
                #if DEBUG
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Données de test", systemImage: "wand.and.stars") {
                        DonneesTest.charger(in: context)
                        lundi = DonneesTest.lundi
                    }
                }
#endif // DEBUG
            }
            .sheet(item: $feuille) { feuille in
                switch feuille {
                case .ajoutActivite: AjoutActiviteView(dateInitiale: lundi)
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
        let fr = Locale(identifier: "fr_FR")

        let jour = Date.FormatStyle(locale: fr).day()                         // "12"
        let jourMois = Date.FormatStyle(locale: fr).day().month(.abbreviated) // "18 oct."

        // Le lundi et le dimanche sont-ils dans le même mois ?
        let memeMois = Calendar.current.isDate(lundi, equalTo: fin, toGranularity: .month)

        if memeMois {
            return "\(lundi.formatted(jour))–\(fin.formatted(jourMois))"      // "12–18 oct."
        } else {
            return "\(lundi.formatted(jourMois)) – \(fin.formatted(jourMois))" // "26 oct. – 1 nov."
        }
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
