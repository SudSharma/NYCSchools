//
//  SchoolDetailsCoordinator.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Combine
import Foundation
import UIKit

enum SchoolDetailsCoordinatorResult {
    case success
    case failure
}

class SchoolDetailsCoordinator: Coordinator<SchoolDetailsCoordinatorResult> {
    
    private let dataSource = SchoolDetailsDataSource()
    private let modelPublisher = CurrentValueSubject<SchoolDetailsViewController.Model?, Never>(nil)
    private let presenter: UINavigationController
    private let schoolDBN: String
    private var subscriptions = Set<AnyCancellable>()
    
    init(presenter: UINavigationController, schoolDBN: String) {
        self.presenter = presenter
        self.schoolDBN = schoolDBN
        
        super.init()
    }
    
    override func start() {
        super.start()
        
        let viewController = SchoolDetailsViewController(modelPublisher, delegate: self)
        presenter.pushViewController(viewController, animated: true)
        fetchSchoolSATScores()
    }
}

extension SchoolDetailsCoordinator: SchoolDetailsViewControllerActions {
    func dismissError() {
        presenter.popViewController(animated: true)
        finish(.failure)
    }
}

private extension SchoolDetailsCoordinator {
    func fetchSchoolSATScores() {
        dataSource.fetchSchoolScores(schoolDBN)?
        .mapError { error -> NetworkError in
            return NetworkError.other(error)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.handle(error: error)
            }
        },
              receiveValue: { [weak self] (result) in
            self?.handle(response: result.first)
        })
        .store(in: &subscriptions)
    }
    
    func handle(error: NetworkError) {
        modelPublisher.value = SchoolDetailsViewController.Model(isLoading: false,
                                                                 error: error,
                                                                 schoolScore: nil)
    }
    
    func handle(response: SchoolScore?) {
        guard let schoolScore = response else {
            let error = NetworkError.other(NSError(domain: "", code: -1))
            modelPublisher.value = SchoolDetailsViewController.Model(isLoading: false,
                                                                     error: error,
                                                                     schoolScore: nil)
            return
        }
        modelPublisher.value = SchoolDetailsViewController.Model(isLoading: false,
                                                                 error: nil,
                                                                 schoolScore: schoolScore)
    }
}
