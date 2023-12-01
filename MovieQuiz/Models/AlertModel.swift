//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Anna on 17.11.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    /// опциональное замыкание для действия по кнопке алерта
    let completion: (() -> Void)?
}

