//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Anna on 28.11.2023.
//

import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {
    
    // реализация протокола Error.
    private enum NetworkError: Error {
        // обозначение ошибки связанной с HTTP-кодом ответа
        case codeError
    }
    
    // функция, которая загружает данные по заранее заданному URL
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        // создаем запрос из url
        let request = URLRequest(url: url)
        // Создаем задачу на отправление запроса в сеть
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            // обрабатываем ответ от сервера
            
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        // Отправляем запрос
        task.resume()
    }
}
