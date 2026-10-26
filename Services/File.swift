//
//  File.swift
//  Planibou
//
//  Created by KEÏTA on 26/10/2026.
//


import Foundation
import SwiftData

extension ModelContext {
    /// Renvoie le Jour de cette date ; le crée s'il n'existe pas.
    func jour(pour date: Date) -> Jour {
        let debut = Calendar.current.startOfDay(for: date)
        let descripteur = FetchDescriptor<Jour>(predicate: #Predicate { $0.date == debut })
        if let existant = try? fetch(descripteur).first { return existant }
        let nouveau = Jour(date: debut)
        insert(nouveau)
        return nouveau
    }

    /// S'assure que les 7 jours de la semaine existent.
    func preparerSemaine(commencantLe lundi: Date) {
        for decalage in 0..<7 {
            if let date = Calendar.current.date(byAdding: .day, value: decalage, to: lundi) {
                _ = jour(pour: date)
            }
        }
    }
}