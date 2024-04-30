import Foundation
@testable import FlickrImageDisplay
import Combine

class MockNetworkManager: Networkable {
    func doApiCall(apiRequest: Requestable) -> Future<[ImageDetail], ServiceError> {

        return Future { promise in
            
            let bundle = Bundle(for:MockNetworkManager.self)
            
            guard let url = bundle.url(forResource:apiRequest.path, withExtension:"json"),
                  let data = try? Data(contentsOf: url)

            else {
                promise(.failure(ServiceError.dataNotFound))
          
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(FlickrResponse.self, from: data) else {
                return promise(.failure(ServiceError.parsingError))
            }
            
           let imageDetails = decodedResponse.photos.photo.map {
               ImageDetail( title: $0.title, url: "\(APIEndPoints.imagesBaseUrl)/\($0.server)/\($0.id)_\($0.secret)_w.jpg")
            }
        
            return promise(.success(imageDetails))
        }
    }
}
