import Foundation

public protocol TokenProvider {
    var accessToken  : String? { get }
    var refreshToken : String? { get }
    
    /**
     Функция предоставляет возможность сконфигурировать
     `TokenProvider`.
     
     Функция будет вызвана сразу после инциализации класса
     `TokenProvider`, используйте её как функцию для нужных
     конфигураций класса.
     */
    func setUp() -> ()
    
    /**
     Функция для обновления `access` токена.
     
     Функция будет автоматически вызвана если статус код
     запроса будет `401`.
     
     - Parameters:
         - completion: Кложура, которое должно отдавать состояние обновления токен,
         если `true` то токен был успешно обновлен, в ином случае `false`.
     */
    func refresh(completion: @escaping (Bool) -> ()) -> ()
}

public extension TokenProvider {
    func setUp() -> () { }
}
