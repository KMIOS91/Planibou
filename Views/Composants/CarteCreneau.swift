//
//  CarteCreneau.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//
import SwiftUI

/// Une grande carte colorée : titre + début — durée — fin.
struct CarteCreneau<Accessoire: View>: View {
    let titre: String
    let debut: String
    let fin: String
    let duree: String
    let couleur: Color
    @ViewBuilder let accessoire: Accessoire

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Text(titre)
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .lineLimit(3)
                Spacer(minLength: 12)
                accessoire
            }
            HStack {
                heure(debut, legende: "Début", alignement: .leading)
                Spacer()
                Text(duree)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.55), in: .capsule)
                    .foregroundStyle(.white)
                Spacer()
                heure(fin, legende: "Fin", alignement: .trailing)
            }
        }
        .padding(20)
        .foregroundStyle(.black.opacity(0.8))   // la carte est claire même en mode sombre
        .background(couleur, in: .rect(cornerRadius: 28, style: .continuous))
    }

    private func heure(_ texte: String, legende: String, alignement: HorizontalAlignment) -> some View {
        VStack(alignment: alignement, spacing: 2) {
            Text(texte).font(.system(.title3, design: .rounded, weight: .medium))
            Text(legende).font(.caption).opacity(0.7)
        }
    }
}

/// Le rond blanc avec une icône (à la place des photos du modèle).
struct IconeRonde: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.title3)
            .frame(width: 44, height: 44)
            .background(.white.opacity(0.7), in: .circle)
    }
}

extension Color {
    static let sable   = Color(red: 0.84, green: 0.70, blue: 0.46)  // midi
    static let ardoise = Color(red: 0.73, green: 0.77, blue: 0.78)  // goûter
    static let sauge   = Color(red: 0.70, green: 0.79, blue: 0.64)  // activité
}
