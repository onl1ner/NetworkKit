import Foundation
import Alamofire

final public class NetworkRequestInterceptor: RequestInterceptor {
    public typealias AdaptHandler = (Result<URLRequest, Error>) -> ()
    public typealias RetryHandler = (RetryResult) -> ()
    
    private let endpoint: Endpoint
    
    private let retryLimit: Int = 5
    private let retryInterval: TimeInterval = 1.0
    
    public init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }
    
    /**
     Функция генерирующая заголовок запроса в зависимости
     от переданных данных в эндпоинте.
     
     - Parameters:
        - target: Целевой эндпоинт, для которого нужно сгенерировать заголовок.
     
     - Returns:
        Возвращает сгенерированный заголовок для `HTTP` запроса.
     */
    private func generateHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = .init()
        
        headers["Content-Type"] = self.endpoint.contentType.rawValue
        headers["Accept-Type"] = self.endpoint.acceptType.rawValue
        
        return headers
    }
    
    /**
     Функция для изменения сетевого запроса, которая вызывается
     перед каждым его совершением.
     
     - Parameters:
         - urlRequest: Запрос, который нужно адаптировать.
         - session: Сессия, на котором делается запрос.
         - completion: Замыкание, которое передает адаптированный запрос.
     */
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping AdaptHandler) {
        var request = urlRequest
        
        request.method = self.endpoint.httpMethod
        request.headers = self.generateHeaders()
        
        request.httpBody = self.endpoint.body
        
        completion(.success(request))
    }
}
