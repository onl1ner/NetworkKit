import Foundation
import Alamofire

/**
 Класс, который используется `Request` классом
 для определения данных о запросе.
 
 Унаследуйте этот класс, для того чтобы использовать
 его как тип при инициализации `Provider` класса и
 ужать скоуп только до нужных эндпоинтов.
 
 Для этого используйте паттерн статичной фабрики:
 
 ```
 final class MyEndpoint: Endpoint {
 
    public static var getEcho: MyEndpoint {
        return .init(
            route: "https://httpbin.org/get",
            contentType: .json,
            acceptType: .json,
            httpMethod: .get,
            authorization: .none
        )
    }
 
 }
 ```
 
 Данное действие позволит использовать функции `Provider`
 класса и вызывать эндпоинты только связанные с нужным сервисом.
 
 ```
 let provider = NetworkRequestProvider<MyEndpoint>()
 
 provider.request(.getEcho).perform { result in
    switch result {
        case .success(let response): // Действия над ответом
        case .failure(let error): // Действия над ошибкой
    }
 }
 ```
 */
open class Endpoint {
    
    /**
     Базовый адрес, который ассоциирован с данным эндпоинтом.
     */
    public let base: String
    
    /**
     Путь, с которым ассоциирован данный эндпоинт.
     */
    public let route: String
    
    /**
     Формат передаваемого контента.
     */
    public let contentType: MediaType
    
    /**
     Формат получаемого контента.
     */
    public let acceptType: MediaType
    
    /**
     HTTP-метод ассоциированный с данным эндпоинтом.
     */
    public let httpMethod: HTTPMethod
    
    /**
     Тип авторизации запрашиваемый данным эндпоинтом.
     */
    public let authorization: AuthorizationType
    
    /**
     Чистый путь, по которому будет делаться запрос.
     По стандарту этот путь равен обработанному роуту.
     
     Под чистым подразумевается, то что строка
     сохранила нотацию переменных, которые должны
     быть переданы в путь запроса.
     
     Например:
     
     ```
     rawRoute = "/home/{id}"
     ```
     */
    public private(set) var rawRoute: String
    
    /**
     Параметры данного эндпоинта, будут переданы в запрос
     как `query` параметры.
     */
    public private(set) var parameters: [String : Any] = .init()
    
    /**
     Тело данного эндпоинта, будет передано в запрос как
     `body` параметр.
     */
    public private(set) var body: Data? = nil
    
    /**
     `URL` эндпоинта.
     */
    public var url: URL
    
    /**
     Статус коды, которые должны быть распознаны как успешные.
     
     Данные статус коды используются при обработке ответа сервера,
     если статус код ответа содержится в этом массиве, то вернется `success`.
     
     - Note:
        Если массив будет пустым все ответы
        со статус кодом в диапазоне от 200 до 400
        будут распознаны как успешные.
     */
    public var successStatusCodes: [Int] = .init()
    
    /**
     Статус коды ошибок, которые должны быть отображены внутри `View`.
     
     Данные статус коды используются для обработки ответа сервера
     со статус кодами ошибок, которые должны быть отображены
     внутри `View`.
     
     - Note:
         Если массив будет пустым все ошибки
         будут презентованы в `Alert`.
     */
    public var inlineStatusCodes: [Int] = .init()
    
    public init(
        base: String,
        route: String,
        contentType: MediaType,
        acceptType: MediaType,
        httpMethod: Alamofire.HTTPMethod,
        authorization: AuthorizationType = .none
    ) {
        self.base = base
        
        self.route = route
        self.rawRoute = route
        
        self.url = .init(string: base + route)!
        
        self.contentType = contentType
        self.acceptType = acceptType
        
        self.httpMethod = httpMethod
        
        self.authorization = authorization
    }
    
    /**
     Функция для добавления `query` параметра.
     
     - Parameters:
         - key: Ключ параметра.
         - value: Значение параметра. Если передали `nil` параметр не будет добавлен.
     
     - Returns:
        Возвращает эндпоинт с добавленными `query` параметрами.
     */
    public func addingParameter(key: String, value: Any?) -> Self {
        if let newValue = value {
            if let prevValue = self.parameters[key] {
                if let array = prevValue as? NSArray {
                    self.parameters[key] = array.adding(newValue)
                } else {
                    self.parameters[key] = [prevValue, newValue]
                }
            } else {
                self.parameters[key] = newValue
            }
        }
        
        return self
    }
    
    /**
     Функция для добавления `query` параметров
     с одинаковым ключем.
     
     - Parameters:
         - key: Ключ параметра.
         - values: Массив значений параметра.
     
     - Returns:
        Возвращает эндпоинт с добавленными `query` параметрами.
     */
    public func addingParameters(key: String, values: [Any]) -> Self {
        self.parameters[key] = values
        return self
    }
    
    /**
     Функция для добавления данных в тело запроса.
     
     - Parameters:
        - body: Данные, которые нужно добавить в тело.
     
     - Returns:
        Возвращает эндопоинт с добавленным телом запроса.
     */
    public func adding(body: Encodable) -> Self {
        if let data = body.data {
            self.body = data
        }
        
        return self
    }
    
    /**
     Функция для перечисления статус кодов, которые
     должны распознаваться как успешные.
     
     - Parameters:
        - statusCodes: Успешные статус коды. *Должны быть перечислены через запятую.*
     
     - Returns:
        Возвращает конфигурированный эндпоинт
        с установленными успешными статус кодами.
     */
    public func addingSuccess(statusCodes: Int...) -> Self {
        self.successStatusCodes = statusCodes
        return self
    }
    
    /**
     Функция для перечисления статус кодов, которые
     должны распознаться как ошибки, которые нужно
     отобразить внутри `View`.
     
     - Parameters:
        - statusCodes: Статус коды ошибок. *Должны быть перечислены через запятую.*
     
     - Returns:
         Возвращает конфигурированный эндпоинт
         с установленными статус кодами ошибок.
     */
    public func addingInline(statusCodes: Int...) -> Self {
        self.inlineStatusCodes = statusCodes
        return self
    }
    
    /**
     Функция добавляет чистый путь, ассоциированный
     с данным эндпоинтом.
     
     - Parameters:
        - rawRoute: Чистый путь.
     
     - Returns:
         Возвращает конфигурированный эндпоинт
         с установленным чистым путем.
     */
    public func adding(rawRoute: String) -> Self {
        self.rawRoute = rawRoute
        return self
    }
}
