//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Anna on 25.12.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func disableAnswerButtons() {
        
    }
    
    func enableAnswerButton() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
        
    }
    
    func hightlightImageBorder(isCorrect: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    
}

class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
