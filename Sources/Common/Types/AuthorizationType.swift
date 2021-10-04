import Foundation

/**
 Типы авторизации для заголовка
 `Authorization` HTTP запроса
 */
public enum AuthorizationType: String {
    
    /// Базовая схема авторизации.
    case basic = "Basic"
    
    /// Схема авторизации путем передачи Bearer токена.
    case bearer = "Bearer"
    
    /// Авторизация не требуется.
    case none
    
}
