import UIKit

struct OnboardingPage {
    let emoji: String
    let title: String
    let subtitle: String
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "⚽️",
            title: "Твой матч\nв пару кликов",
            subtitle: "Создавай события, зови друзей\nи находи игроков рядом"
        ),
        OnboardingPage(
            emoji: "🤝",
            title: "Записывайся\nна чужие игры",
            subtitle: "Видишь матч — жми «Участвую».\nОрганизатор получит уведомление"
        ),
        OnboardingPage(
            emoji: "🏆",
            title: "Расти\nкак игрок",
            subtitle: "После матча оцениваете друг друга.\nСобирай MVP и повышай уровень"
        )
    ]
}
