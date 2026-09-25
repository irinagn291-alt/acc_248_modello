import SwiftUI

/// Role: the only colour accessor. Views never write a hex.
enum StudioInk {
    /// #FAF7F5 screen background
    static let background = Color("background")
    /// #FEFEFD cards, rows, sheets
    static let surface = Color("surface")
    /// #392818 primary text and icons
    static let ink = Color("ink")
    /// #CC6D19 primary action and figures
    static let accent = Color("accent")
    /// #816C5A secondary text and disabled
    static let muted = Color("muted")
}
