import Foundation

extension Data {
    /**
     Функция для декодирования ответа от сервера.
     
     - Returns:
        Возвращает декодированный объект переданного типа.
     */
    public func decoded<T: Codable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            print("[NetworkKit] DECODING ERROR: \(error)")
        }
        
        return nil
    }
    
}
