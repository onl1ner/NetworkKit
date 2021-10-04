import Foundation
import Alamofire

/**
 Класс описывающий запрос и имеющий
 возможность совершить его.
 
 Базовый класс, который хранит в себе данные
 о запросе: его эндпоинт и сопутствующие данные.
 
 - Remark:
     Если результат запроса требуется декодировать
     используйте класс `DecodableNetworkRequest`, если
     результат запроса требуется прикрепить к определенному
     параметру используйте класс `AssignableNetworkRequest`
 */
public class NetworkRequest {
    
    public typealias Response = Result<NetworkResponse, NetworkError>
    public typealias ResponseHandler = (Response) -> ()
    
    public let endpoint: Endpoint
    public let request: DataRequest
    
    public let validStatusCodes: AnySequence<Int>
    
    private var responseCallback: ResponseHandler?
    
    public init(endpoint: Endpoint, request: DataRequest) {
        self.endpoint = endpoint
        self.request = request
        
        if endpoint.successStatusCodes.isEmpty {
            validStatusCodes = .init(200..<400)
        } else {
            validStatusCodes = .init(endpoint.successStatusCodes)
        }
    }
    
    /**
     Функция, которая обрабатывает ответ HTTP запроса.
     
     - Parameters:
        - response: Ответ, который нужно обработать.
     */
    public func process(response: AFDataResponse<Data>) -> () {
        if let error = response.error?.underlyingError {
            return self.handle(error: error as? NetworkError ?? .unknown)
        }
        
        guard let url = response.request?.url,
              let statusCode = response.response?.statusCode,
              let method = response.request?.httpMethod
        else { return self.handle(error: .server) }
        
        self.handle(
            response: .init(
                url: url,
                statusCode: statusCode,
                data: response.value,
                httpMethod: .init(rawValue: method)
            )
        )
    }
    
    /**
     Функция, которая обрабатывает успешный результат
     при `HTTP` запросе.
     
     - Parameters:
        - response: Успешный ответ с данными.
     */
    public func handle(response: NetworkResponse) -> () {
        self.responseCallback?(.success(response))
        self.responseCallback = nil
    }
    
    /**
     Функция, которая обрабатывает ошибку при `HTTP` запросе.
     
     - Parameters:
        - error: Полученная ошибка.
     */
    public func handle(error: NetworkError) -> () {
        self.responseCallback?(.failure(error))
        self.responseCallback = nil
    }
    
    /**
     Функция для совершения текущего запроса.
     
     - Parameters:
        - completion: Замыкание, которое сработает при окончании обработки ответа.
     */
    public func perform(completion: @escaping ResponseHandler) -> () {
        self.responseCallback = completion
        
        self.request
            .validate(statusCode: self.validStatusCodes)
            .responseData(completionHandler: process(response:))
    }
}
