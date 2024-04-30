import Foundation

protocol ApiServicable {
    func get<T:Decodable>(request:Requestable, type:T.Type, completionHandler:@escaping (Result<T, ServiceError>)->Void)
}

class ApiServiceManager: ApiServicable {
    func get<T>(request: Requestable, type: T.Type, completionHandler: @escaping (Result<T, ServiceError>) -> Void) where T : Decodable {
        
        let session = URLSession.shared

        guard let request = URLRequest.getURLRequest(for: request) else {

            completionHandler(.failure(ServiceError.failedToCreateRequest))
            return
        }

        session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                return completionHandler(.failure(ServiceError.dataNotFound))
            }
            guard let _data = data, error == nil else {
                return completionHandler(.failure(ServiceError.dataNotFound))
            }

            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: _data) else {
                return completionHandler(.failure(ServiceError.parsingError))
            }



            completionHandler(.success(decodedResponse))
        }.resume()
    }
}

