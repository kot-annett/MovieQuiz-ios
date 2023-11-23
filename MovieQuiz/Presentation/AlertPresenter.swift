//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Anna on 17.11.2023.
//

import UIKit

final class AlertPresenter {
    // инъекция MovieQuizViewController в AlertPresenter
    // создаем слабую ссылку, чтобы предотвратить retain cycles
    private weak var presentingViewController: MovieQuizViewController?
    
    init(presentingViewController: MovieQuizViewController) {
        self.presentingViewController = presentingViewController
    }
    
    // метод для отображения алерта
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



