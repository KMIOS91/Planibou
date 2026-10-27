import SwiftUI
import SwiftData

struct JourCard: View {
    let jour: Jour

    private let francais = Locale(identifier: "fr_FR")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header (ton design)
            HStack(alignment: .lastTextBaseline) {
                Text(jour.date.formatted(.dateTime.weekday(.wide).locale(francais)).capitalized)
                    .font(.title2.bold())

                Spacer()

                Text(jour.date.formatted(.dateTime.day().month(.abbreviated).locale(francais)))
                    .font(.body.bold())
                    .foregroundStyle(.secondary)

                if jour.estWeekEnd {
                    Text("Week-end")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.15), in: .capsule)
                        .foregroundStyle(.green)
                }
            }

            // MARK: - Repas
            if let midi = jour.midi, !midi.intitule.isEmpty {
                carteRepas(midi)
            }
            if let gouter = jour.gouter, !gouter.intitule.isEmpty {
                carteRepas(gouter)
            }

            // MARK: - Activité
            if let activite = jour.activite {
                carteActivite(activite)
            } else {
                Label("Pas d'activité, journée tranquille", systemImage: "sofa")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Carte repas

    private func carteRepas(_ repas: Repas) -> some View {
        // Le rythme de bébé : midi 11h–12h, goûter 16h–16h15
        let (debut, fin) = repas.type == .midi ? (11 * 60, 12 * 60) : (16 * 60, 16 * 60 + 15)

        return CarteCreneau(titre: repas.intitule,
                            debut: Horaire.texte(debut),
                            fin: Horaire.texte(fin),
                            duree: Horaire.duree(fin - debut),
                            couleur: repas.type == .midi ? .sable : .ardoise) {
            IconeRonde(systemName: repas.type == .midi ? "fork.knife" : "birthday.cake")
        }
    }

    // MARK: - Carte activité

    private func carteActivite(_ activite: activites) -> some View {
        let debut = Horaire.minutes(depuis: activite.heure) ?? 10 * 60
        let duree = activite.dureeMinutes   // provisoire : on ajoutera une vraie durée dans Activite
        let fin = debut + duree

        return VStack(spacing: 0) {
            CarteCreneau(titre: activite.titre,
                         debut: Horaire.texte(debut),
                         fin: Horaire.texte(fin),
                         duree: Horaire.duree(duree),
                         couleur: .sauge) {
                if activite.statut == .aucune {
                    IconeRonde(systemName: "figure.and.child.holdinghands")
                } else {
                    StatutBadge(activite: activite)
                }
            }

            // Le lieu sous la carte → ouvre sa fiche
            if let lieu = activite.lieu {
                NavigationLink {
                    LieuDetailView(lieu: lieu)
                } label: {
                    HStack {
                        Label(lieu.nom, systemImage: "mappin.and.ellipse")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .tint(.primary)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Jour.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let jour = Jour(date: .now)
    container.mainContext.insert(jour)
    jour.repas = [Repas(type: .midi, intitule: "Gratin de chou-fleur et poulet"),
                  Repas(type: .gouter, intitule: "Muffin + fromage blanc")]

    return ScrollView {
        JourCard(jour: jour).padding()
    }
    .modelContainer(container)
}
