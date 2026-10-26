import SwiftUI

struct JourCard: View {
    let jour: Jour
    

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
            
            checkScript()
        }
    }

    
    private func checkScript() {
        let fr_FR = Locale(identifier: "fr_FR")
        
        // Forcer la récupération sous forme de String pure
        if let scriptIdentifier = fr_FR.language.script?.identifier {
            let enUS = Locale(identifier: "en-US")
            
            // Swift trouve maintenant le match exact car scriptIdentifier est explicitement une String
            let localizedScript = enUS.localizedString(forScriptCode: scriptIdentifier)
            print(localizedScript ?? "inconnu")
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
                Image(systemName: type == .midi ? "fork.knife" : "birthday.cake")
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
