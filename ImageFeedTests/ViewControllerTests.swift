@testable import ImageFeed
import XCTest
import UIKit

class ImagesListViewControllerTests: XCTestCase {
    var sut: ImagesListViewController!
    var presenter: ImagesListPresenterSpy!
    var tableView: UITableView!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController
        presenter = ImagesListPresenterSpy()
        sut.presenter = presenter
        tableView = UITableView()
        sut.tableView = tableView
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        presenter = nil
        tableView = nil
        super.tearDown()
    }
    
    func testViewControllerCallsViewDidLoad() {
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testTableViewHasDataSource() {
        // then
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertTrue(sut.tableView.dataSource is ImagesListViewController)
    }
    
    func testTableViewHasDelegate() {
        // then
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertTrue(sut.tableView.delegate is ImagesListViewController)
    }
    
    func testCellConfiguration() {
        // given
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://test.com",
            largeImageURL: "https://test.com",
            isLiked: false
        )
        presenter.photos = [testPhoto]
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        // when
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ImagesListCell
        
        // then
        XCTAssertNotNil(cell.dateLabel.text)
        XCTAssertEqual(cell.likeButton.currentImage, UIImage(named: "notActive"))
    }
    
    func testLikeButtonAction() {
        // given
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://test.com",
            largeImageURL: "https://test.com",
            isLiked: false
        )
        presenter.photos = [testPhoto]
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ImagesListCell
        cell.delegate = sut
        
        // when
        cell.likeButtonClicked(UIButton())
        
        // then
        XCTAssertTrue(presenter.changeLikeCalled)
    }
    
    func testWillDisplayCell() {
        // given
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://test.com",
            largeImageURL: "https://test.com",
            isLiked: false
        )
        presenter.photos = [testPhoto, testPhoto]
        
        // when
        sut.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 1, section: 0))
        
        // then
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }
    
    func testHeightForRow() {
        // given
        let testPhoto = Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://test.com",
            largeImageURL: "https://test.com",
            isLiked: false
        )
        presenter.photos = [testPhoto]
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        // when
        let height = sut.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(height, 108)
    }
}
