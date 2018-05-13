import Foundation
import UIKit

public enum Pan {
    case regular(PanDirection)
    #if os(iOS)
    case edge(UIRectEdge)
    #endif
}
