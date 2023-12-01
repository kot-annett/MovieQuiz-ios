//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Anna on 17.11.2023.
//

import UIKit

final class AlertPresenter {
    private weak var presentingViewController: MovieQuizViewController?
    
    init(presentingViewController: MovieQuizViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
}



