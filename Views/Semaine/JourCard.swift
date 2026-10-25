import SwiftUI

struct JourCard: View {
    let jour: Jour
    @State private var scriptAffiche: String = "Chargement..."

    var body: some View {
      
        
        Section {
            ligneRepas(jour.midi, type: .midi)
            ligneRepas(jour.gouter, type: .gouter)
            ligneActivite
        } header: {
            HStack {
                Text(jour.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .textCase(nil)
                    .font(.headline)
                    
                    
                if jour.estWeekEnd {
                    Text("Week-end")
                        .font(.caption.bold())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.green.opacity(0.2), in: .capsule)
                        .foregroundStyle(.green)
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
    }

   
    
    private func ligneRepas(_ repas: Repas?, type: TypeRepas) -> some View {
        LabeledContent {
            Text(repas?.intitule ?? "—")
                .multilineTextAlignment(.trailing)
        } label: {
            Label {
                VStack(alignment: .leading) {
                    Text(type.libelle)
                    Text(type.heure).font(.caption).foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: type == .midi ? "fork.knife" : "carrot")
            }
        }
    }

    @ViewBuilder
    private var ligneActivite: some View {
        if let activite = jour.activite {
            VStack(alignment: .leading, spacing: 6) {
                Label(activite.titre, systemImage: "figure.and.child.holdinghands")
                    .font(.body.weight(.medium))
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
            Label("Pas d'activité, journée tranquille", systemImage: "sofa")
                .foregroundStyle(.secondary)
        }
    }
}
