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
     Функция, которая пытается обновить токен.
     
     - Parameters:
         - request: Запрос, который спровоцировал запрос токена.
         - completion: Замыкание, которое возвращает результат обновления.
     */
    private func refresh(with request: Request, using tokenProvider: TokenProvider, completion: @escaping RetryHandler) -> () {
        guard request.retryCount < self.retryLimit else { return completion(.doNotRetry) }
        
        tokenProvider.refresh { isSuccess in
            if isSuccess {
                return completion(.retryWithDelay(self.retryInterval))
            }
            
            completion(.doNotRetry)
        }
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
    
    /**
     Функция, определяющая нужно ли попробовать
     сделать запрос еще раз.
     
     - Parameters:
         - request: Запрос, который спровоцировал ошибку.
         - session: Сессия, на котором был совершен запрос.
         - error: Ошибка, пришедшая после выполнения запроса.
         - completion: Замыкание, которое определяет нужно ли повторить еще раз.
     */
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping RetryHandler) {
        guard
            let statusCode = request.response?.statusCode,
            let tokenProvider = NetworkKit.tokenProvider
        else {
            return completion(.doNotRetry)
        }
        
        if statusCode == 401 {
            return self.refresh(with: request, using: tokenProvider, completion: completion)
        }
        
        completion(.doNotRetryWithError(error))
    }
}
