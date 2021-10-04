import Foundation

/**
 Типы ошибок, которые могут
 быть вызваны `HTTP` запросом.
 */
public enum NetworkErrorStyle {
    /**
     Тип ошибки, при котором её
     требуется презентовать в `Alert`.
     */
    case alert
    
    /**
     Тип ошибки, при котором её
     требуется презентовать внутри `View`.
     */
    case inline
}
