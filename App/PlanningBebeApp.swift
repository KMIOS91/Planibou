import SwiftUI
import SwiftData

@main
struct PlanningBebeApp: App {
    var body: some Scene {
        WindowGroup {
            SemaineView()
        }
        // Un seul conteneur SwiftData pour toute l'app
        .modelContainer(for: [
            Jour.self,
            Repas.self,
            Activite.self,
            Lieu.self,
            ArticleCourses.self,
            ProfilBebe.self
        ])
    }
}
