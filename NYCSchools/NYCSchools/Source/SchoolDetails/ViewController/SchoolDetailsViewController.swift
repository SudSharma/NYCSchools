//
//  SchoolDetailsViewController.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine
import UIKit

protocol SchoolDetailsViewControllerActions: AnyObject {
    func dismissError()
}

class SchoolDetailsViewController: UIViewController {
    struct Model {
        var isLoading = true
        var error: NetworkError?
        var schoolScore: SchoolScore?
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var criticalReadingAverageScore: UILabel!
    @IBOutlet var mathAverageScore: UILabel!
    @IBOutlet var writingAverageScore: UILabel!
    @IBOutlet var numberOfTestTakers: UILabel!
    @IBOutlet var schoolName: UILabel!
    
    @IBOutlet var numberOfTestTakersStack: UIStackView!
    @IBOutlet var criticalReadingStack: UIStackView!
    @IBOutlet var mathAvgStack: UIStackView!
    @IBOutlet var writingAvgStacks: UIStackView!
    
    private var cellReuseIdentifier = "schoolDetailsCell"
    private lazy var dataSource = makeDataSource()
    private weak var delegate: SchoolDetailsViewControllerActions?
    @IBOutlet var tableView: UITableView!
    private let modelPublisher: CurrentValueSubject<SchoolDetailsViewController.Model?, Never>
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ modelPublisher: CurrentValueSubject<SchoolDetailsViewController.Model?, Never>,
         delegate: SchoolDetailsViewControllerActions?) {
        self.delegate = delegate
        self.modelPublisher = modelPublisher
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SAT Scores"
        tableView.register(UINib(nibName: "SchoolDetailsCell", bundle: nil),
                           forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.dataSource = dataSource
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

private extension SchoolDetailsViewController {
    
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
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .default) { [weak self] _ in
                self?.delegate?.dismissError()
            })
            present(alertController, animated: true)
            return
        } else if model.schoolScore != nil {
            applySnapshot(with: model.schoolScore!, animate: true)
        }
    }
    
    func applySnapshot(with schoolDetails: SchoolScore, animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SchoolScore>()
        snapshot.appendSections([0])
        snapshot.appendItems([schoolDetails], toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    func endSubscriptions() {
        subscriptions.removeAll()
    }
    
    func makeDataSource() -> SchoolDetailsTableViewDataSource {
        let reuseIdentifier = cellReuseIdentifier
        
        return SchoolDetailsTableViewDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, schoolDetails in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as? SchoolDetailsCell
                
                let model =
                    SchoolDetailsCell.Model(criticalReadingAverageScore: schoolDetails.sat_critical_reading_avg_score,
                                            mathAverageScore: schoolDetails.sat_math_avg_score,
                                            writingAverageScore: schoolDetails.sat_writing_avg_score)
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

class SchoolDetailsTableViewDataSource: UITableViewDiffableDataSource<Int, SchoolScore> {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if let schoolDetails = itemIdentifier(for: IndexPath(item: 0, section: section)) {
            title = schoolDetails.school_name ?? ""
        }
        
        return title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title = ""
        if let schoolDetails = itemIdentifier(for: IndexPath(item: 0, section: section)) {
            title = "Number of SAT test takers - \(schoolDetails.num_of_sat_test_takers ?? "")"
        }
        
        return title
    }
}
