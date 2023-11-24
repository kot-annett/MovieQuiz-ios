//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Anna on 15.11.2023.
//

import Foundation

// протокол, который используем в фабрике как делегат
protocol QuestionFactoryDelegate: AnyObject {
    // метод будет вызывать фабрика, чтобы отдать готовый вопрос квиза.
    func didReceiveNextQuestion(question: QuizQuestion?)
}

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
}
