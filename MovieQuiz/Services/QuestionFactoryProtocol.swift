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
    // сообщение об успешной загрузке
    func didLoadDataFromServer()
    // сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error)
}

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    // метод инициирует загрузку данных
    func loadData()
}
