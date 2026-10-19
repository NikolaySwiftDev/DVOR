import UIKit

enum AppLinks {
    static let terms = URL(string: "https://example.com/terms")!
    static let privacy = URL(string: "https://example.com/privacy")!
}

final class LegalLinksView: UITextView {

    init() {
        super.init(frame: .zero, textContainer: nil)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        isEditable = false
        isScrollEnabled = false
        isSelectable = true
        backgroundColor = .clear
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0

        let terms = "legal.terms".loc
        let privacy = "legal.privacy".loc
        let full = String(format: "legal.consent".loc, terms, privacy)

        let font = UIFont.poppins(weight: .regular, size: .small)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributed = NSMutableAttributedString(string: full, attributes: [
            .font: font,
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraph
        ])

        let text = full as NSString
        attributed.addAttribute(.link, value: AppLinks.terms, range: text.range(of: terms))
        attributed.addAttribute(.link, value: AppLinks.privacy, range: text.range(of: privacy))

        attributedText = attributed
        linkTextAttributes = [
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}
