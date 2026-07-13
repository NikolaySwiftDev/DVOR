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
            title: OnboardingStrings.firstTitle,
            subtitle: OnboardingStrings.firstSubtitle
        ),
        OnboardingPage(
            emoji: "🤝",
            title: OnboardingStrings.secondTitle,
            subtitle: OnboardingStrings.secondSubtitle
        ),
        OnboardingPage(
            emoji: "🏆",
            title: OnboardingStrings.thirdTitle,
            subtitle: OnboardingStrings.thirdSubtitle
        )
    ]
}

fileprivate struct OnboardingStrings {
    static let firstTitle = "onboarding.first.title".loc
    static let firstSubtitle = "onboarding.first.subtitle".loc

    static let secondTitle = "onboarding.second.title".loc
    static let secondSubtitle = "onboarding.second.subtitle".loc

    static let thirdTitle = "onboarding.third.title".loc
    static let thirdSubtitle = "onboarding.third.subtitle".loc
}
