import Foundation
import Alamofire

/**
 Класс с информацией об ошибке: его заголовок
 и детальное сообщение пользователю.
 */
public class NetworkError: Error {
    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

extension NetworkError {
    public static var unknown: NetworkError {
        return .init(title: "Ошибка", message: "Произошла непредвиденная ошибка, попробуйте еще раз.")
    }
    
    public static var server: NetworkError {
        return .init(title: "Ошибка сервера", message: "Произошла ошибка сервера, попробуйте позже.")
    }
    
    public static var network: NetworkError {
        return .init(title: "Ошибка сети", message: "Произошла ошибка сети, проверьте свое подключение.")
    }
}
