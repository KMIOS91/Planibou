//
//  Horaires.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//

import Foundation

/// On compte en minutes depuis minuit : 10h30 = 630.
enum Horaire {
    /// "10h30" → 630
    static func minutes(depuis texte: String) -> Int? {
        let morceaux = texte.lowercased().split(separator: "h", omittingEmptySubsequences: false)
        guard let heures = Int(morceaux.first ?? "") else { return nil }
        let minutes = morceaux.count > 1 ? Int(morceaux[1]) ?? 0 : 0
        return heures * 60 + minutes
    }

    /// 630 → "10h30"
    static func texte(_ minutes: Int) -> String {
        String(format: "%dh%02d", (minutes / 60) % 24, minutes % 60)
    }

    /// 90 → "1 h 30", 30 → "30 min"
    static func duree(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        switch (h, m) {
        case (0, _): return "\(m) min"
        case (_, 0): return "\(h) h"
        default:     return "\(h) h \(String(format: "%02d", m))"
        }
    }
}
