//
//  ScriptIdentifier.swift
//  Planibou
//
//  Created by KEÏTA on 25/10/2026.
//

import Foundation

enum ScriptIdentifier {
    /// Récupère le nom du script (ex: "Latin", "Cyrillique") traduit dans la langue de sortie.
    /// - Parameters:
    ///   - targetLocaleId: L'identifiant source (ex: "fr_FR")
    ///   - outputLocaleId: L'identifiant de la langue d'affichage (ex: "en-US")
    static func localizedScript(for targetLocaleId: String, in outputLocaleId: String) -> String {
        let targetLocale = Locale(identifier: targetLocaleId)
        
        // Sous iOS 17, targetLocale.language.script renvoie un objet typé 'Locale.Script'
        if let script = targetLocale.language.script {
            let outputLocale = Locale(identifier: outputLocaleId)
            
            // API Moderne iOS 16+ : L'objet se traduit lui-même
            return outputLocale.localizedString(forScriptCode:  script.identifier) ?? "Inconnu"
        }
        
        return "Pas de script spécifié"
    }
}
