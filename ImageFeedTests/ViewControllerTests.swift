@testable import ImageFeed
import XCTest
import UIKit

class ImagesListViewControllerTests: XCTestCase {
    func testViewDidLoadCallsLoadNextPhotos() {
        // given
        let service = ImagesListServiceStub()
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testWillDisplayCellCallsLoadNextPhotosWhenNeeded() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = (1...10).map {
            Photo(
                id: "\($0)",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        }
        service.isLoading = false
        
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        // when
        
        presenter.willDisplayCell(at: IndexPath(row: 9, section: 0))
        // then
        
        XCTAssertTrue(
            service.fetchPhotosNextPageCalled,
            "Должна быть вызвана загрузка следующей страницы при отображении предпоследней ячейки"
        )
    }
    
    func testChangeLikeCallsService() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)]
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        // when
        
        presenter.changeLike(at: IndexPath(row: 0, section: 0))
        // then
        
        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertTrue(view.showLoadingIndicatorCalled)
    }
    
    func testCalculateCellHeight() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)]
        let presenter = ImagesListPresenter(imagesListService: service)
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        // when
        
        let height = presenter.calculateCellHeight(for: IndexPath(row: 0, section: 0), tableView: tableView)
        // then
        
        let expectedWidth = tableView.bounds.width - 16 - 16
        let expectedHeight = (200 * expectedWidth / 100) + 4 + 4
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testPhotoForIndexPath() {
        // given
        
        let service = ImagesListServiceStub()
        let testPhoto = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)
        service.photos = [testPhoto]
        let presenter = ImagesListPresenter(imagesListService: service)
        // when
        
        let photo = presenter.photoForIndexPath(IndexPath(row: 0, section: 0))
        // then
        
        XCTAssertEqual(photo?.id, testPhoto.id)
    }
}

final class ImagesListPresenterTests: XCTestCase {
    func testViewDidLoadCallsLoadNextPhotos() {
        // given
        
        let service = ImagesListServiceStub()
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        // when
        
        presenter.viewDidLoad()
        // then
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testWillDisplayCellCallsLoadNextPhotosWhenNeeded() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = Array(repeating: Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        ), count: 10)
        service.isLoading = false
        
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        
        presenter.willDisplayCell(at: IndexPath(row: 9, section: 0))
        // then
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testChangeLikeCallsService() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)]
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        // when
        
        presenter.changeLike(at: IndexPath(row: 0, section: 0))
        // then
        
        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertTrue(view.showLoadingIndicatorCalled)
    }
    
    func testCalculateCellHeight() {
        // given
        
        let service = ImagesListServiceStub()
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)]
        let presenter = ImagesListPresenter(imagesListService: service)
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        // when
        
        let height = presenter.calculateCellHeight(for: IndexPath(row: 0, section: 0), tableView: tableView)
        // then
        
        let expectedWidth = tableView.bounds.width - 16 - 16
        let expectedHeight = (200 * expectedWidth / 100) + 4 + 4
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testPhotoForIndexPath() {
        // given
        
        let service = ImagesListServiceStub()
        let testPhoto = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)
        service.photos = [testPhoto]
        let presenter = ImagesListPresenter(imagesListService: service)
        // when
        
        let photo = presenter.photoForIndexPath(IndexPath(row: 0, section: 0))
        // then
        
        XCTAssertEqual(photo?.id, testPhoto.id)
    }
}

final class ImagesListCellTests: XCTestCase {
    func testLikeButtonActionNotifiesDelegate() {
        // given
        
        let cell = ImagesListCell()
        let delegate = ImagesListCellDelegateSpy()
        cell.delegate = delegate
        // when
        
        cell.likeButtonClicked(UIButton())
        // then
        
        XCTAssertTrue(delegate.didTapLikeCalled)
    }
}

final class ImagesListCellDelegateSpy: ImagesListCellDelegate {
    var didTapLikeCalled = false
    
    func imagesListCellDidTapLike(in cell: ImagesListCell) {
        didTapLikeCalled = true
    }
}
