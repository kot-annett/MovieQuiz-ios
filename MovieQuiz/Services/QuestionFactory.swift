//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Anna on 14.11.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoadingProtocol
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    weak var delegate: QuestionFactoryDelegate?
    
    enum ComparisonType {
        case greater
        case less
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                // обработка ошибочной загрузки изображения
                let loadingError = ImageLoadingError(type: .failedToLoadImage)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: loadingError)
                }
            }
            
            let comparisonType: ComparisonType = Bool.random() ? .greater : .less
            
            var randomRating = Int(movie.rating) ?? 0
            switch comparisonType {
            case .greater:
                randomRating = Int.random(in: 7...9)
            case .less:
                randomRating = Int.random(in: 2...7)
            }
            
            var questionText: String
            switch comparisonType {
            case .greater:
                questionText = "Рейтинг этого фильма больше чем \(randomRating)?"
            case .less:
                questionText = "Рейтинг этого фильма меньше чем \(randomRating)?"
            }
            
            let correctAnswer = comparisonType == .greater
            
            let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
                
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}


    
    
