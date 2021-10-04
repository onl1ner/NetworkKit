import Foundation

/**
 Типы данных, которые могут быть переданы
 посредством HTTP запросов.
 */
public enum MediaType : String {
    
    /**
     Текстовый формат данных использующий
     нотацию объектов JavaScript
     */
    case json = "application/json"
    
    /**
     Составной формат данных для отправки
     бинарных файлов.
     */
    case formData = "multipart/form-data"
    
    /**
     Формат данных используемый для изображений
     JPEG, JPG и PNG формата.
     */
    case image = "image/jpeg, image/jpg, image/png"
    
}
