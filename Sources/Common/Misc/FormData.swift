import Foundation

/**
 Структура описывающая данные
 для `Multipart` запроса.
 */
public struct FormData {
    
    /**
     Данные, которые нужно передать
     составным типом запроса.
     */
    public let data: Data
    
    /**
     Имя, которое будет ассоциировано
     с передаваемыми данными.
     */
    public let name: String
    
    /**
     Формат передаваемых данных.
     */
    public let mime: MediaType
    
}
