import SwiftUI

/// Badge cliquable : "À réserver" → "Réservé" d'un tap.
/// Comme c'est du SwiftData, ça reste sauvegardé (et partageable plus tard avec CloudKit).
struct StatutBadge: View {
    @Bindable var activite: Activite

    var body: some View {
        if activite.statut == .aucune {
            EmptyView()
        } else {
            Button {
                withAnimation {
                    activite.statut = (activite.statut == .reserve) ? .aReserver : .reserve
                }
            } label: {
                Label(activite.statut.libelle,
                      systemImage: activite.statut == .reserve ? "checkmark.circle.fill" : "exclamationmark.circle")
                    .font(.caption.bold())
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(couleur.opacity(0.15), in: .capsule)
                    .foregroundStyle(couleur)
            }
            .buttonStyle(.plain)
        }
    }

    private var couleur: Color {
        switch activite.statut {
        case .reserve: .green
        case .aReserver: .orange
        case .aVerifier: .blue
        case .aucune: .secondary
        }
    }
}
