import Foundation

extension Encodable {
    /**
     Переменная, которая хранит в себе раскодированные
     данные, представленные в виде словаря.
     */
    public var dictionary: [String : Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            return object as? [String : Any]
        } catch {
            print("[NetworkKit] ENCODING ERROR: \(error)")
        }
        
        return nil
    }
    
    /**
     Переменная, которая хранит в себе
     раскодированные бинарные данные.
     */
    public var data: Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("[NetworkKit] ENCODING ERROR: \(error)")
        }
        
        return nil
    }
}
