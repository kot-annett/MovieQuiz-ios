//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Anna on 15.11.2023.
//

import UIKit

///вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    /// картинка с афишей фильма
    let image: UIImage
    /// вопрос о рейтинга фильма
    let question: String
    /// строка с порядковым номером этого вопроса 
    let questionNumber: String
}
