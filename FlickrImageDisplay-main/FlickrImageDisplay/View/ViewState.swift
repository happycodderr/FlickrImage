import Foundation

enum ViewState: Equatable {
    case none
    case loading
    case finishedLoading
    case error(String)
}
