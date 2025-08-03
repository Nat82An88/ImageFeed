import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    // MARK: - Constants
    
    private enum SegueIdentifiers {
        static let showSingleImage = "ShowSingleImage"
    }
    // MARK: - IB Outlets
    
    @IBOutlet internal var tableView: UITableView!
    // MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol!
    
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupTableView()
        presenter.viewDidLoad()
    }
    // MARK: - Setup Methods
    
    private func setupPresenter() {
        presenter = ImagesListPresenter()
        presenter.view = self
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showSingleImage {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter.photoForIndexPath(indexPath)
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Cell Configuration
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter.photoForIndexPath(indexPath) else {
            cell.cellImage.image = UIImage(named: "placeholder_error")
            return
        }
        
        cell.cellImage.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.2))]
            ) { [weak cell] result in
                if case .failure = result {
                    cell?.cellImage.image = UIImage(named: "placeholder_error")
                }
            }
        }
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifiers.showSingleImage, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.calculateCellHeight(for: indexPath, tableView: tableView)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(in cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.changeLike(at: indexPath)
    }
}

// MARK: - ImagesListViewProtocol
extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        
        tableView.performBatchUpdates({
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
    
    func updatePhoto(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.animate()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
