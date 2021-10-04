import Foundation
import Alamofire

/**
 Класс описывающий запрос и имеющий
 возможность совершить его.
 
 Используйте этот класс для того чтобы иметь возможность
 привязать параметры к результату запроса и его ошибке.
 
 Функции `assign(valueTo:)` и `assign(errorTo:)`
 избавляют от замыканий и приводят синтаксис асинхронного кода
 к следующему виду:
 
 ```
 someRequest.
     .assign(valueTo: \.myValue)
     .assign(errorTo: \.myError)
     .perform()
 ```
 
 - Note:
    Данный класс автоматически декодирует пришедшие с сети данные.
 */
public class AssignableNetworkRequest<Root: AnyObject, T: Codable>: NetworkRequest {
    
    private weak var root: Root?
    
    private var valueKeyPath: ReferenceWritableKeyPath<Root, T?>?
    private var errorKeyPath: ReferenceWritableKeyPath<Root, NetworkError?>?
    
    public convenience init(endpoint: Endpoint, request: DataRequest, root: Root) {
        self.init(endpoint: endpoint, request: request)
        self.root = root
    }
    
    override public func handle(response: NetworkResponse) {
        guard let valueKeyPath = self.valueKeyPath,
              let decoded: T = response.data?.decoded()
        else { return self.handle(error: .unknown) }
        
        self.root?[keyPath: valueKeyPath] = decoded
        
        self.root = nil
        self.valueKeyPath = nil
    }
    
    override public func handle(error: NetworkError) {
        guard let errorKeyPath = self.errorKeyPath else {
            self.root = nil
            return
        }
        
        self.root?[keyPath: errorKeyPath] = error
        
        self.root = nil
        self.errorKeyPath = nil
    }
    
    /**
     Функция устаналивает путь до параметра, в который
     нужно записать результат `HTTP` запроса.
     
     - Parameters:
        - keyPath: Путь до параметра, в который нужно записать результат.
     
     - Returns:
         Возвращает запрос с установленным параметром,
         в который нужно записать его результат
     */
    public func assign(valueTo keyPath: ReferenceWritableKeyPath<Root, T?>) -> Self {
        self.valueKeyPath = keyPath
        return self
    }
    
    /**
     Функция устанавливает путь до параметра, в который
     нужно записать ошибку случившуюся при `HTTP` запросе.
     
     - Parameters:
        - keyPath: Путь до параметра, в который нужно записать ошибку.
     
     - Returns:
         Возвращает запрос с установленным параметром,
         в который нужно записать случившуюся ошибку.
     */
    public func assign(errorTo keyPath: ReferenceWritableKeyPath<Root, NetworkError?>) -> Self {
        self.errorKeyPath = keyPath
        return self
    }
    
    /**
     Функция для совершения запроса.
     
     Данная функция должна быть вызвана для того
     чтобы исполнить запрос.
     
     - Note:
         Функция должна быть последней в случае
         если используется цепочка вызовов функции.
     */
    public func perform() -> () {
        self.request
            .validate(statusCode: super.validStatusCodes)
            .responseData(completionHandler: process(response:))
    }
    
}
