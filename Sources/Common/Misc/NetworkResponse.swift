import Foundation
import Alamofire

public struct NetworkResponse {
    
    public let url: URL
    public let statusCode: Int
    
    public let data: Data?
    public let httpMethod: HTTPMethod
    
    public var dictionary: [String : Any] {
        guard let data = self.data,
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String : Any]
        else { return .init() }
        
        return dictionary
    }
    
    public init(url: URL, statusCode: Int, data: Data?, httpMethod: HTTPMethod) {
        self.url = url
        self.statusCode = statusCode
        
        self.data = data
        self.httpMethod = httpMethod
    }
}
