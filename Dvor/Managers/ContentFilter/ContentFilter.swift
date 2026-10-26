
import Foundation

enum ContentFilterStrings {
    static let rejected = "content.rejected".loc
}

enum ContentFilter {

    // MARK: - Public

    static func isAllowed(_ text: String) -> Bool {
        let normalizedText = normalize(text)

        let words = normalizedText
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }

        guard !words.isEmpty else {
            return true
        }

        return !lists.contains { list in
            words.contains { list.matches($0) }
        }
    }

    // MARK: - Lists

    private static let lists: [BlockList] = {
        let urls = Bundle.main.urls(
            forResourcesWithExtension: "json",
            subdirectory: nil
        ) ?? []

        let blocklistURLs = urls.filter {
            $0.lastPathComponent.hasPrefix("blocklist_")
        }

        let loaded = blocklistURLs.compactMap { url -> BlockList? in
            do {
                let data = try Data(contentsOf: url)
                let file = try JSONDecoder().decode(
                    BlockListFile.self,
                    from: data
                )

                return BlockList(file: file)
            } catch {
                assertionFailure(
                    "ContentFilter: failed to load \(url.lastPathComponent): \(error)"
                )
                return nil
            }
        }

        #if DEBUG
        assert(
            !blocklistURLs.isEmpty,
            "ContentFilter: no blocklist_*.json files found in the bundle. Check Target Membership."
        )
        #endif

        return loaded
    }()

    // MARK: - Normalization

    private static func normalize(_ text: String) -> String {
        let visible = String(
            String.UnicodeScalarView(
                text.unicodeScalars.filter {
                    $0.properties.generalCategory != .format
                }
            )
        )

        let lowered = visible
            .lowercased()
            .replacingOccurrences(of: "ё", with: "е")

        var scalars = String.UnicodeScalarView()

        for scalar in lowered
            .decomposedStringWithCanonicalMapping
            .unicodeScalars {

            if scalar.properties.generalCategory == .nonspacingMark,
               let previous = scalars.last,
               previous.isASCII {
                continue
            }

            scalars.append(scalar)
        }

        return String(scalars).precomposedStringWithCanonicalMapping
    }

    // MARK: - Model

    private struct BlockListFile: Decodable {
        let contained: [String]?
        let prefix: [String]?
        let exact: [String]?
        let lookalikes: [String: String]?
        let collapseRepeats: Bool?
    }

    private struct BlockList {

        let contained: [String]
        let prefix: [String]
        let exact: Set<String>
        let lookalikes: [Character: Character]
        let collapseRepeats: Bool

        init(file: BlockListFile) {
            contained = (file.contained ?? [])
                .map(ContentFilter.normalize)
                .filter { !$0.isEmpty }

            prefix = (file.prefix ?? [])
                .map(ContentFilter.normalize)
                .filter { !$0.isEmpty }

            exact = Set(
                (file.exact ?? [])
                    .map(ContentFilter.normalize)
                    .filter { !$0.isEmpty }
            )

            collapseRepeats = file.collapseRepeats ?? false

            var map: [Character: Character] = [:]

            for (key, value) in file.lookalikes ?? [:] {
                guard let source = key.first,
                      let destination = value.first else {
                    continue
                }

                map[source] = destination
            }

            lookalikes = map
        }

        func matches(_ word: String) -> Bool {
            for candidate in variants(of: word) {
                if exact.contains(candidate) {
                    return true
                }

                if contained.contains(where: candidate.contains) {
                    return true
                }

                if prefix.contains(where: candidate.hasPrefix) {
                    return true
                }
            }

            return false
        }

        // MARK: Variants

        private func variants(of word: String) -> Set<String> {
            let unmasked = unmaskLookalikes(in: word)

            var result: Set<String> = [
                word,
                unmasked
            ]

            guard collapseRepeats else {
                return result
            }

            result.insert(collapse(word))
            result.insert(collapse(unmasked))

            return result
        }

        private func unmaskLookalikes(in word: String) -> String {
            guard !lookalikes.isEmpty,
                  word.unicodeScalars.contains(where: { !$0.isASCII }) else {
                return word
            }

            return String(word.map { lookalikes[$0] ?? $0 })
        }

        private func collapse(_ word: String) -> String {
            var result = ""
            var previous: Character?

            for character in word {
                guard character != previous else {
                    continue
                }

                result.append(character)
                previous = character
            }

            return result
        }
    }
}
