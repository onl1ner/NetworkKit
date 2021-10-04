import Foundation
import Combine

public protocol TokenPublisher {
    /**
     Издатель `access` токена.
     */
    var accessPublisher: AnyPublisher<String?, Never> { get }
    
    /**
     Издатель `refresh` токена.
     */
    var refreshPublisher: AnyPublisher<String?, Never> { get }
    
    /**
     Функция предоставляет возможность сконфигурировать
     `TokenPublisher`.
     
     Функция будет вызвана сразу после инциализации класса
     `TokenPublisher`, используйте её как функцию для нужных
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

extension TokenPublisher {
    
    public func setUp() -> () { }
    
}
