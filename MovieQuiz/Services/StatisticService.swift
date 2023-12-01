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
    
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        // данные читаются из UserDefaults и декодируются в GameRecord
        get {
            // пытаемся получить данные из UserDefaults по ключу bestGame
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  // используем JSONDecoder, чтобы декодировать данные data в экземпляр GameRecord (record)
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
    
    // метод store с проверкой на лучший результат
    func store(correct: Int, total: Int) {
        let newGame = GameRecord(correct: correct, total: total, date: Date())
        let currentBestGame = bestGame
        if newGame.isBetterThan(currentBestGame) {
            bestGame = newGame
        }
    
        gamesCount += 1
        
        // отладочный метод
        print("Stored game. Total Accuracy: \(totalAccuracy), Games Count: \(gamesCount), Best Game: \(bestGame)")
    }
}

protocol StatisticServiceProtocol {
    // средняя точность правильных ответов за все игры в процентах
    var totalAccuracy: Double { get }
    // количество завершенных игр
    var gamesCount: Int { get }
    // информация о лучшей попытке
    var bestGame: GameRecord { get }
    
    // метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int)
}
