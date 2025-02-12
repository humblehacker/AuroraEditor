//
//  HighlightThemeView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the highlight theme settings.
struct HighlightThemeView: View {
    /// Theme model
    @StateObject
    private var themeModel: ThemeModel = .shared

    /// Preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// The view body
    var body: some View {
        ZStack {
            EffectView(.contentBackground)
            if themeModel.selectedTheme == nil {
                Text("settings.theme.selection")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Spacer().frame(height: 5)
                        GroupBox {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.text.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.text.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.text")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.insertionPoint.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.insertionPoint.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.cursor")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.invisibles.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.invisibles.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.invisibles")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.background.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.background.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.background")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.lineHighlight.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.lineHighlight.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.current.line")
                                    }
                                    HStack {
                                        PreferencesColorPicker(.init(get: {
                                            themeModel.selectedTheme?.editor.selection.swiftColor ?? .white
                                        }, set: { newColor in
                                            themeModel.selectedTheme?.editor.selection.swiftColor = newColor
                                        }))
                                        Text("settings.theme.style.selection")
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                        }
                        .padding(.horizontal, 7)

                        ForEach((themeModel.selectedTheme ?? themeModel.defaultTheme).editor.highlightTheme.settings,
                                id: \.scopes) { setting in
                            EditorThemeAttributeView(setting: setting)
                                .transition(.opacity)
                        }
                        Spacer().frame(height: 5)
                    }
                }
            }
        }
    }
}

private struct HighlightThemeView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightThemeView()
    }
}
