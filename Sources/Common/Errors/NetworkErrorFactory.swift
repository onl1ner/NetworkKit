import Foundation
import Alamofire

public protocol NetworkErrorFactory {
    /**
     Функция, которая собирает ошибку на основе статус кода и
     эндпоинта, по которому был сделан запрос.
     
     - Parameters:
         - statusCode: Статус код ответа.
         - target: Эндпоинт, по которому был сделан запрос.
     
     - Returns:
        Возвращает сгенерированную ошибку.
     */
    func build(with statusCode: Int, target: Endpoint) -> NetworkError
}
