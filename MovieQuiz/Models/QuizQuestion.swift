//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Anna on 15.11.2023.
//

import Foundation

struct QuizQuestion {
    // название фильма, совпадает с названием афиши в Assets
    let image: String
    // вопрос о рейтинге фильма
    let text: String
    // правильный ответ на вопрос, булевое значение (true, false)
    let correctAnswer: Bool
}
