import XCTest
@testable import FlickrImageDisplay

class FlickrImageDisplayTests: XCTestCase {
    
    var viewModel:ImageGalleryViewModel!
    var networkManager:MockNetworkManager!
    
    override func setUpWithError() throws {
        
        networkManager = MockNetworkManager()
        viewModel = ImageGalleryViewModel(networkManager: networkManager)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testSearchPhotos_success() {
        
        let request = Request(baseUrl: APIEndPoints.baseUrl, path:"", params: ["method":APIEndPoints.photoMethod, "text":"cat", "api_key": APIEndPoints.apiKey, "format" : "json", "nojsoncallback" : "1"])
        
        viewModel.search(request: request)
        
        XCTAssertEqual(viewModel.imageDetailsCount, 100)
        
        XCTAssertEqual(viewModel.imageDetails.first?.title, "cat rider")
        
    }
    
    func testSearchPhotos_failure() {
        
        let request = Request(baseUrl: APIEndPoints.baseUrl, path:"failedResonce", params: ["method":APIEndPoints.photoMethod, "text":"cat", "api_key": APIEndPoints.apiKey, "format" : "json", "nojsoncallback" : "1"])
        
        viewModel.search(request: request)
        
        XCTAssertEqual(viewModel.imageDetailsCount, 0)
    }
}
