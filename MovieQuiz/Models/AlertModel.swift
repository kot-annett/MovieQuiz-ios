//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Anna on 17.11.2023.
//

import Foundation

struct AlertModel {
    // текст заголовка алерта
    let title: String
    // текст сообщения алерта
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    // опциональное замыкание для действия по кнопке алерта
    // не принимает никаких аргументов и не возвращает никакого значения
    let completion: (() -> Void)?
}


