//
//  SchoolsListCoordinator.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 7/31/22.
//

import Combine
import Foundation
import MessageUI
import UIKit

protocol SchoolsListCoordinatable {
    init(_ navigationController: UINavigationController)
}

class SchoolsListCoordinator: Coordinator<Void>, SchoolsListCoordinatable {
    
    // MARK: Private
    
    private var dataSource: SchoolsListDataSourceProtocol?
    private let presenter: UINavigationController
    private var modelPublisher = CurrentValueSubject<SchoolsListViewController.Model?, Never>(nil)
    private var viewController: SchoolsListViewController?
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Initializer
    
    required init(_ presenter: UINavigationController) {
        self.presenter = presenter
        super.init()
        
        dataSource = SchoolsListDataSource()
    }

    // MARK: Overrides
    
    override func start() {
        super.start()
        
        viewController = SchoolsListViewController(modelPublisher,
                                                   delegate: self)
        presenter.pushViewController(viewController!, animated: false)

        fetchSchools()
    }
}

extension SchoolsListCoordinator: SchoolsListViewControllerActions {
    func retrySchoolsList() {
        modelPublisher.value = SchoolsListViewController.Model(isLoading: true,
                                                               error: nil,
                                                               schools: nil)
        fetchSchools()
    }
    
    func email(_ address: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([address])
            mail.setMessageBody("<p>Hello!</p>", isHTML: true)
            
            presenter.present(mail, animated: true)
        }
    }
    
    func openWebsite(_ url: String) {
        if let host = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: host),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func phone(_ number: String) {
        if let phoneCallURL = URL(string: "tel://\(number)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func showSchoolDetails(_ dbn: String) {
        let schoolDetailsCoordinator = SchoolDetailsCoordinator(presenter: presenter, schoolDBN: dbn)
        self.add(child: schoolDetailsCoordinator)
        schoolDetailsCoordinator.start()
    }
}

extension SchoolsListCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        presenter.dismiss(animated: true)
    }
}

private extension SchoolsListCoordinator {
    
    func fetchSchools() {
        dataSource?.fetchSchools()?
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
                self?.handle(response: result)
            })
            .store(in: &subscriptions)
    }

    func handle(error: NetworkError) {
        modelPublisher.value = SchoolsListViewController.Model(isLoading: false,
                                                               error: error,
                                                               schools: nil)
    }
    
    func handle(response: [School]) {
        modelPublisher.value = SchoolsListViewController.Model(isLoading: false,
                                                               error: nil,
                                                               schools: response)
    }
}
