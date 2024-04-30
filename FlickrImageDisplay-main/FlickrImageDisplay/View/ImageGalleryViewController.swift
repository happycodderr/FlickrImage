import UIKit
import Combine

class ImageGalleryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarText: UITextField!
    
    private var bindings = Set<AnyCancellable>()
    
    let viewModel:ImageGalleryViewModel = ImageGalleryViewModel(apiServiceManager: ApiServiceManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModelState()
        bindSearchBarTextFieldToViewModel()
    }
    
    private func bindSearchBarTextFieldToViewModel() {
        searchBarText.textPublisher
             .debounce(for: 0.5, scheduler: RunLoop.main)
             .removeDuplicates()
             .sink { [weak self] in
                 let request = Request(baseUrl: EndPoints.baseUrl, path:"", params: ["method":EndPoints.photoMethod, "text":$0, "api_key": EndPoints.apiKey, "format" : "json", "nojsoncallback" : "1"])

                 self?.viewModel.search(request:request)
             }
             .store(in: &bindings)
    }
    private func bindViewModelState() {
        let cancellable =  viewModel.stateBinding.sink { completion in
            
        } receiveValue: { [weak self] launchState in
            DispatchQueue.main.async {
                self?.updateUI(state: launchState)
            }
        }
        self.bindings.insert(cancellable)
    }
    private func updateUI(state:ViewState) {
        switch state {
        case .none:
            tableView.isHidden = true
        case .loading:
            tableView.isHidden = true
        case .finishedLoading:
            tableView.isHidden = false
            tableView.reloadData()
        case .error(_):
            tableView.reloadData()
        }
    }

}

extension ImageGalleryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageDetailsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tablecell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell") as? ImageDetailTableViewCell else { return UITableViewCell() }
        
        tablecell.setData(viewModel.imageDetails[indexPath.row])

        
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveAction = UIContextualAction(style: .normal, title: "Save") {
            (action, sourceView, completionHandler) in
            let imageDetail = self.viewModel.imageDetails[indexPath.row]
            self.swipeSaveAction(imageDetail, indexpath: indexPath)
            completionHandler(true)
        }
        
        
        saveAction.backgroundColor = UIColor(red: 215/255.0, green: 130.0/255.0, blue: 1.0, alpha: 1.0)
        let shareAction = UIContextualAction(style: .normal, title: "Share") {
            (action, sourceView, completionHandler) in
            self.swipeShareAction(indexpath: indexPath)
            completionHandler(true)
        }
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [ saveAction, shareAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
        
    }
}
extension ImageGalleryViewController {
    
    func swipeSaveAction( _ imageData : ImageDetail, indexpath : IndexPath) {
        let cell = tableView.cellForRow(at: indexpath) as? ImageDetailTableViewCell
        
        guard let inputImage = cell?.displayImage.image else { return }
        ImageUtility.saveFile(image: inputImage)
    }
    
    func swipeShareAction(indexpath : IndexPath) {
        let cell = tableView.cellForRow(at: indexpath) as? ImageDetailTableViewCell
        guard let inputImage = cell?.displayImage.image else { return }
        let items = [inputImage]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}

