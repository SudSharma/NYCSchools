//
//  SchoolsListViewController.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine
import UIKit

protocol SchoolsListViewControllerActions: SchoolCellActions {
    func retrySchoolsList()
    func showSchoolDetails(_ dbn: String)
}

protocol SchoolsListViewControllerProtocol: UIViewController {
    init(_ modelPublisher: CurrentValueSubject<SchoolsListViewController.Model?, Never>,
         delegate: SchoolsListViewControllerActions?)
}

class SchoolsListViewController: UIViewController, SchoolsListViewControllerProtocol {

    struct Model {
        var isLoading = true
        var error: NetworkError?
        var schools: [School]?
    }

    // MARK: Private
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private weak var delegate: SchoolsListViewControllerActions?
    private var cellReuseIdentifier = "schoolCell"
    private lazy var dataSource = makeDataSource()
    private var modelPublisher: CurrentValueSubject<SchoolsListViewController.Model?, Never>
    private var subscriptions = Set<AnyCancellable>()
    @IBOutlet var tableView: UITableView!
    
    // MARK: Initializer Methods
    
    required init(_ modelPublisher: CurrentValueSubject<SchoolsListViewController.Model?, Never>,
                  delegate: SchoolsListViewControllerActions?) {
        self.modelPublisher = modelPublisher
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                   
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "NYC Schools"
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: "SchoolCell", bundle: nil),
                           forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startSubscriptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        endSubscriptions()
    }
}

extension SchoolsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let school = dataSource.itemIdentifier(for: indexPath) {
            delegate?.showSchoolDetails(school.dbn)
        }
    }
}

private extension SchoolsListViewController {
    
    func applyModel() {
        guard let model = modelPublisher.value else {
            return
        }
        
        activityIndicator.isHidden = !model.isLoading
        if model.error != nil {
            // Handle Error
            let alertController =
                UIAlertController(title: "Error",
                                  message: model.error?.localizedDescription ?? "Error encountered",
                                  preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            alertController.addAction(UIAlertAction(title: "Retry",
                                                    style: .default) { [weak self] _ in
                self?.delegate?.retrySchoolsList()
            })
            present(alertController, animated: true)
            return
        } else if model.schools?.isEmpty == false {
            applySnapshot(with: model.schools!, animate: true)
        }
    }

    func applySnapshot(with schools: [School], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, School>()
        snapshot.appendSections([0])
        snapshot.appendItems(schools, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    func endSubscriptions() {
        subscriptions.removeAll()
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Int, School> {
        let reuseIdentifier = cellReuseIdentifier
        
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  [weak self] tableView, indexPath, school in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as? SchoolCell
                
                let model = SchoolCell.Model(name: school.school_name,
                                             address: school.primary_address_line_1,
                                             city: school.city,
                                             stateCode: school.state_code,
                                             zip: school.zip,
                                             email: school.school_email,
                                             phone: school.phone_number,
                                             website: school.website)
                cell?.accessoryType = .disclosureIndicator
                cell?.delegate = self?.delegate
                cell?.model = model
                return cell
            }
        )
    }
    
    func startSubscriptions() {
        modelPublisher
            .sink { [weak self] _ in
                self?.applyModel()
            }
            .store(in: &subscriptions)
    }
}
