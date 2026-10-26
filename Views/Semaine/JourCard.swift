import SwiftUI

struct JourCard: View {
    let jour: Jour
    @State private var scriptAffiche: String = "Chargement..."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            HStack(alignment: .lastTextBaseline) {
                Text(jour.date.formatted(.dateTime.weekday(.wide)))
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(jour.date.formatted(.dateTime.day().month(.abbreviated)))
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
            
            // MARK: - Repas (Midi & Goûter)
            VStack(spacing: 16) {
                ligneRepas(jour.midi, type: .midi)
                ligneRepas(jour.gouter, type: .gouter)
            }
            
            // MARK: - Activité
            ligneActivite
        }
        .padding(20)
        // Fond sombre de la carte pour correspondre à l'image
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    // MARK: - Ligne de Repas
    private func ligneRepas(_ repas: Repas?, type: TypeRepas) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Heure alignée à gauche
            Text(type.heure)
                .font(.body.bold())
                .foregroundStyle(.secondary)
                .frame(width: 75, alignment: .leading)
            
            // Détails du repas à droite
            VStack(alignment: .leading, spacing: 4) {
                Text(type.libelle.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .tracking(1) // Espacement des lettres
                
                Text(repas?.intitule ?? "—")
                    .font(.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }

    // MARK: - Zone Activité
    @ViewBuilder
    private var ligneActivite: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACTIVITÉ")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .tracking(1)
            
            if let activite = jour.activite {
                VStack(alignment: .leading, spacing: 6) {
                    Label(activite.titre, systemImage: "figure.and.child.holdinghands")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                    HStack {
                        Text("\(activite.moment.libelle) · \(activite.heure)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let prix = activite.lieu?.prix {
                            Text("· \(prix)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatutBadge(activite: activite)
                    }
                }
            } else {
                Text("Pas d'activité, journée tranquille")
                    .font(.body.bold())
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        // Conteneur en pointillés pour l'activité conforme au visuel
        .background {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4]))
        }
    }
}

// MARK: - Preview Generator
#Preview {
    ZStack {
        // Fond principal de l'application (Noir/Sombre complet)
        Color(uiColor: .systemBackground).ignoresSafeArea()
        
        VStack {
            JourCard(jour: Jour(date: Date.now))
                .padding()
        }
    }
    .environment(\.colorScheme, .dark) // Force le rendu en mode sombre
}
