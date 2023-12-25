//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Anna on 22.12.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Methods
    
    func yesButtonClicked() {
        answerGived(answer: true)
    }
    
    func noButtonClicked() {
        answerGived(answer: false)
    }
    
    //универсальный метод для блоков кода внутри IBAction
    private func answerGived(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
    
    // метод, который обрабатывает результат ответа
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.disableAnswerButtons()
        
        didAnswer(isCorrect: isCorrect)
        viewController?.hightlightImageBorder(isCorrect: isCorrect)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            }
    }
    
    // метод, который содержит логику перехода в один из сценариев
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идем в состояние "Результат квиза"
            let text = correctAnswers == self.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.showResult(quiz: viewModel)
        } else {
            // идем в состояние "Вопрос показан"
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
            viewController?.enableAnswerButton()
        }
    }
    
    func makeResultMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        // текущий рекорд
        let bestGame = statisticService?.bestGame ?? GameRecord(correct: 0, total: 0, date: Date())
        let dateText = statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)" + " (\(dateText))"
        // количество сыгранных квизов
        let playedQuizzesCount = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0))%"
        
        let resultMessage = [
            currentGameResultLine, playedQuizzesCount, bestGameInfoLine, accuracyText
        ].joined(separator: "\n")
        
        return resultMessage
    }
 
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        //заново показываем первый вопрос
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
}

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(quiz result: QuizResultsViewModel)
    func hightlightImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func disableAnswerButtons()
    func enableAnswerButton()
}
