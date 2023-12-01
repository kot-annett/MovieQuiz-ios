//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Anna on 21.11.2023.
//

import Foundation

/// модель для сохранения результата
struct GameRecord: Codable {
    /// количество правильных ответов
    let correct: Int
    /// количество вопросов квиза
    let total: Int
    /// дата завершения раунда
    let date: Date
    
    /// метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}

