import Foundation

/**
 Класс описывающий запрос и имеющий
 возможность совершить его.
 
 Используйте этот класс если результат запроса
 требуется декодировать в нужный тип.
 */
public class DecodableNetworkRequest<T: Codable>: NetworkRequest {
    
    public typealias DecodedResponse<Type: Codable> = Result<Type, NetworkError>
    public typealias DecodedResponseHandler = (DecodedResponse<T>) -> ()
    
    private var responseCallback: DecodedResponseHandler?
    
    override public func handle(response: NetworkResponse) {
        guard let decoded: T = response.data?.decoded() else {
            return self.handle(error: .unknown)
        }
        
        self.responseCallback?(.success(decoded))
        self.responseCallback = nil
    }
    
    override public func handle(error: NetworkError) {
        self.responseCallback?(.failure(error))
        self.responseCallback = nil
    }
    
    public func performDecoded(completion: @escaping DecodedResponseHandler) -> () {
        self.responseCallback = completion
        
        self.request
            .validate(statusCode: super.validStatusCodes)
            .responseData(completionHandler: process(response:))
    }
    
}
