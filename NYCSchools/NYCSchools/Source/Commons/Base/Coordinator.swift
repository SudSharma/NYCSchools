//
//  Coordinator.swift
//  NYCSchools
//
//  Created by Sudarshan Sharma on 8/3/22.
//

import Foundation

class Coordinator<CoordinationResult>: NSObject {
    
    // MARK: Private
    
    private var children = [UUID: Any]()
    private var cleanup: (() -> ())?
    private let identifier = UUID()
    
    // MARK: Internal
    
    var onFinish: ((CoordinationResult) -> Void)?
    
    // MARK: Internal Methods
    
    func add<T>(child: Coordinator<T>) {
        child.cleanup = { [weak self, weak child] in
            self?.remove(child: child)
        }
        children[child.identifier] = child
    }

    func finish(_ result: CoordinationResult) {
        onFinish?(result)
        cleanup?()
    }
    
    func start() {
        // Subclasses need to override
    }
}

private extension Coordinator {
    func remove<T>(child: Coordinator<T>?) {
        guard let child = child else { return }
        
        children.removeValue(forKey: child.identifier)
    }
}
