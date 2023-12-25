//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Anna on 20.11.2023.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    // MARK: - Properties
    private var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    /// средняя точность правильных ответов в процентах
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    private(set) var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        // данные читаются из UserDefaults и декодируются в GameRecord
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                // если данные отсутствуют и декодирование не удалось
                // возвращаем значение по умолчанию для GameRecord
                return .init(correct: 0, total: 0, date: Date())
            }
            // возвращаем экземпляр GameRecord, который сохраняется в UserDefaults
            return record
        }
        // данные кодируются в Data  и сохраняются в UserDefaults
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                // в случае ошибки кодирования
                print("Невозможно сохранить результат")
                return
            }
            // сохраняем константу data в UserDefaults
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // MARK: - Public methods
    
    // метод store с проверкой на лучший результат
//    func store(correct: Int, total: Int) {
//        let newGame = GameRecord(correct: correct, total: total, date: Date())
//        let currentBestGame = bestGame
//        if newGame.isBetterThan(currentBestGame) {
//            bestGame = newGame
//        }
//
//        gamesCount += 1
//
//        // отладочный метод
//        print("Stored game. Total Accuracy: \(totalAccuracy), Games Count: \(gamesCount), Best Game: \(bestGame)")
//    }
    
    func store(correct count: Int, total amount: Int) {
        self.correct += count
        self.total += amount
        self.gamesCount += 1
        
        let game = GameRecord(correct: correct, total: total, date: Date())
        if game.isBetterThan(bestGame) {
            bestGame = game
        }
    }
}

// MARK: - Protocol
protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}
