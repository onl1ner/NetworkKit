import Foundation
import Combine
import Alamofire

/**
 Класс ответственный за создание сетевых запросов.
 
 Используйте экземпляры этого класса для того чтобы
 создавать новые запросы в сеть.
 */
final public class NetworkRequestProvider<Target: Endpoint> {
    
    /// Сессия отвечающая за управление сетевыми запросами.
    private let session: Alamofire.Session
    
    public init(session: Alamofire.Session = .default) {
        self.session = session
    }
    
    /**
     Функция генерирующая `URL` для переданного эндпоинта.
     
     - Parameters:
        - target: Целевой эндпоинт, для которого нужно сгенерировать `URL`.
     
     - Returns:
        Сгенерированный `URL` с установленными `query` параметрами (при наличии).
     */
    private func generateURL(for target: Target) -> URL {
        var urlComponents: URLComponents? = .init(string: target.url.absoluteString)
        var urlQueryItems: [URLQueryItem] = .init()
        
        for key in target.parameters.keys {
            if let values = target.parameters[key] as? Array<String?> {
                for value in values {
                    urlQueryItems.append(.init(name: key, value: value))
                }
            } else {
                let value = target.parameters[key] as? String
                urlQueryItems.append(.init(name: key, value: value))
            }
        }
        
        urlComponents?.queryItems = urlQueryItems
        
        return urlComponents?.url ?? target.url
    }
    
    /**
     Функция генерирует запрос данных для
     переданного эндпоинта.
     
     - Parameters:
        - target: Целевой эндпоинт, для которого нужно сгенерировать запрос.
     
     - Returns
        Возвращает сгенерированный запрос данных.
     */
    private func dataRequest(for target: Target) -> DataRequest {
        let request: URLRequest = .init(url: self.generateURL(for: target))
        let interceptor: RequestInterceptor = NetworkRequestInterceptor(endpoint: target)
        
        return self.session.request(request, interceptor: interceptor)
    }
    
    /**
     Функция генерирует запрос на загрузку
     переданных данных.
     
     - Parameters:
         - target: Целевой эндпоинт, по которому должна произвестись загрузка.
         - formData: Данные, которые будут загружены составным типом.
     
     - Returns
        Возвращает сгенерированный запрос на загрузку.
     */
    private func uploadRequest(for target: Target, formData: [FormData]) -> UploadRequest {
        return self.session.upload(multipartFormData: { multipart in
            for data in formData {
                multipart.append(data.data, withName: data.name, mimeType: data.mime.rawValue)
            }
        }, to: self.generateURL(for: target))
    }
    
    /**
     Функция для создания запроса по переданному эндпоинту.
     
     - Parameters:
         - target: Эндпоинт, по которому нужно сделать запрос.
     
     - Returns
        Сформированный запрос
     */
    public func request(_ target: Target) -> NetworkRequest {
        return .init(endpoint: target, request: dataRequest(for: target))
    }
    
    /**
     Функция для создания запроса по переданному эндпоинту
     и декодировании данных в заданный тип.
     
     - Parameters:
         - target: Эндпоинт, по которому нужно сделать запрос.
         - type: Тип данных, в который нужно декодировать данные.
     
     - Returns
        Сформированный запрос.
     */
    public func request<T: Codable>(_ target: Target, as type: T.Type) -> DecodableNetworkRequest<T> {
        return .init(endpoint: target, request: dataRequest(for: target))
    }
    
    /**
     Функция для создания запроса по переданному эндпоинту,
     декодировании его в заданный тип.
     
     - Parameters:
         - target: Эндпоинт, по которому нужно сделать запрос.
         - root: Рут, к которому нужно привязаться для установки результата.
         - type: Тип данных, в который нужно декодировать данные.
     
     - Returns
         Сформированный запрос, результат которого можно
         привязать к параметрам объекта переданного как параметр `root`
     */
    public func request<R: AnyObject, T: Codable>(_ target: Target, on root: R, as type: T.Type) -> AssignableNetworkRequest<R, T> {
        return .init(endpoint: target, request: dataRequest(for: target), root: root)
    }
    
    /**
     Функция для загрузки данных по переданному эндпоинту,
     используя составной тип передачи данных.
     
     - Parameters:
         - formData: Данные, которые нужно отправить с запросом.
         - target: Эндпоинт, по которому нужно передать данные.
         - completion: Замыкание, которое будет вызвано по завершению отправки.
     */
    public func upload(_ formData: [FormData], to target: Target) -> NetworkRequest {
        return .init(endpoint: target, request: uploadRequest(for: target, formData: formData))
    }
    
}
