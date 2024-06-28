//
//  TokenizedLine.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit
import OSLog

// TODO: @0xWDG Look if this can be removed.
/// Tokenized line
public class TokenizedLine {
    /// Tokens
    var tokens: [Token]

    /// Logger
    static let logger = Logger(subsystem: "com.auroraeditor", category: "Tokenized Line")

    /// Initialize TokenizedLine
    /// 
    /// - Parameter tokens: Tokens
    init(tokens: [Token] = []) {
        self.tokens = tokens
    }

    /// Token length
    public var length: Int {
        guard let last = tokens.last else {
            return 0
        }
        return last.range.upperBound
    }

    /// Add token
    /// 
    /// - Parameter token: Token
    func addToken(_ token: Token) {
        cleanLast()
        tokens.append(token)
    }

    /// Add tokens
    /// 
    /// - Parameter tokens: Tokens
    func addTokens(_ tokens: [Token]) {
        cleanLast()
        self.tokens += tokens
    }

    /// Clean last token
    func cleanLast() {
        if tokens.last?.range.length == 0 {
            tokens.removeLast()
        }
    }

    /// Increase last token length
    /// 
    /// - Parameter len: Length
    func increaseLastTokenLength(by len: Int = 1) {
        guard !tokens.isEmpty else { return }
        tokens[tokens.count - 1].range.length += len
    }

    /// Apply theme attributes
    /// 
    /// - Parameter attributes: Attributes
    /// - Parameter attributedString: Attributed string
    /// - Parameter style: Style
    /// - Parameter range: Range
    private static func applyThemeAttributes(_ attributes: [ThemeAttribute],
                                             toStr attributedString: NSMutableAttributedString,
                                             withStyle style: NSMutableParagraphStyle,
                                             andRange range: NSRange) {
        for attr in attributes {
            if let lineAttr = attr as? LineThemeAttribute {
                lineAttr.apply(to: style)
            } else if let tokenAttr = attr as? TokenThemeAttribute {
                tokenAttr.apply(to: attributedString, withRange: range)
            } else {
                logger.info("""
                         Warning: ThemeAttribute with key \(attr.key) does not conform \
                         to either LineThemeAttribute or TokenThemeAttribtue so it will not be applied.
                """)
            }
        }
    }

    /// Applies the theming of the tokenized line to a given mutable attributed string at the given location.
    ///
    /// - Parameter attributedString: The mutable attributed string to apply the attributes to.
    /// - Parameter loc: The (NSString indexed) location to apply the theming from.
    /// - Parameter inSelectedScope: Whether the current selection is on any part of the line that is being themed.
    /// - Parameter applyBaseAttributes: Whether the base should be applied as well selection scope attributes.
    public func applyTheme(
        _ attributedString: NSMutableAttributedString,
        at loc: Int,
        inSelectionScope: Bool = false,
        applyBaseAttributes: Bool = true
    ) {

        // If we are applying the base attributes we will reset the attributes of the attributed string.
        // Otherwise, we will leave them and create a mutable copy of the paragraph style.
        var style = NSMutableParagraphStyle()
        if applyBaseAttributes,
           let range = attributedString.rangeWithinString(from: NSRange(location: loc, length: length)) {
            attributedString.setAttributes(nil, range: range)
        } else if let currStyle = (attributedString.attribute(.paragraphStyle, at: loc,
                                                              effectiveRange: nil)
                                   as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle {
            style = currStyle
        }

        for token in tokens {
            guard let range = attributedString.rangeWithinString(from: NSRange(location: loc + token.range.location,
                                                                               length: token.range.length))
            else { return }

            // set the token NSAttributedString attribute, used for debugging
            attributedString.addAttributes([.token: token], range: range)

            for scope in token.scopes {
                if applyBaseAttributes {
                    TokenizedLine.applyThemeAttributes(
                        scope.attributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                }
                if inSelectionScope {
                    TokenizedLine.applyThemeAttributes(
                        scope.inSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                } else {
                    TokenizedLine.applyThemeAttributes(
                        scope.outSelectionAttributes,
                        toStr: attributedString,
                        withStyle: style,
                        andRange: range)
                }
            }
        }

        if let range = attributedString.rangeWithinString(from: NSRange(location: loc, length: length)) {
            attributedString.addAttribute(.paragraphStyle, value: style,
                                          range: range)
        }
    }
}

extension NSAttributedString {
    /// Range within string
    /// 
    /// - Parameter range: Range
    /// 
    /// - Returns: Range within string
    func rangeWithinString(from range: NSRange) -> NSRange? {
        NSRange(location: 0, length: self.length).intersection(range)
    }
}
