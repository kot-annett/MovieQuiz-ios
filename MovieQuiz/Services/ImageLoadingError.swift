//
//  ImageLoadingError.swift
//  MovieQuiz
//
//  Created by Anna on 03.12.2023.
//

import Foundation

/// Отвечает за обработку ошибочной загрузки изображения
struct ImageLoadingError: Error {
    let type: ImageLoadingErrorType
    
    enum ImageLoadingErrorType {
        case failedToLoadImage
        case otherError(description: String)
    }
}

