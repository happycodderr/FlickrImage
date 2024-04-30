import Foundation

protocol ImageGalleryViewModelType {
    var stateBinding: Published<ViewState>.Publisher { get }
    var imageDetailsCount:Int { get }
    var imageDetails:[ImageDetail] { get }
    func search(request: Request)
}

final class ImageGalleryViewModel: ImageGalleryViewModelType {
    
    var stateBinding: Published<ViewState>.Publisher{ $state }
    
    private let apiServiceManager:ApiServicable
    
    @Published  var state: ViewState = .none
    
    var imageDetails: [ImageDetail] = []
    
    var imageDetailsCount: Int {
        return imageDetails.count
    }
    
    init(apiServiceManager:ApiServicable) {
        self.apiServiceManager = apiServiceManager
    }
    
    func search(request: Request) {
        
        apiServiceManager.get(request: request, type: FlickrResponse.self ) { [weak self] result in
            
            switch result {
                
            case .success(let responce):
               
                self?.imageDetails = responce.photos.photo.map {
                    ImageDetail( title: $0.title, url: "\(EndPoints.imagesBaseUrl)/\($0.server)/\($0.id)_\($0.secret)_w.jpg")
                }
                
                self?.state = ViewState.finishedLoading
                
            case .failure(_):
                self?.imageDetails = []
                self?.state = ViewState.error("Network Not Availale")
            }
        }
    }
}
