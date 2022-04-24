import Foundation

public final class NetworkKit {
    static private(set) var tokenProvider: TokenProvider?
    
    public static func set(tokenProvider: TokenProvider?) {
        self.tokenProvider = tokenProvider
        self.tokenProvider?.setUp()
    }
}
