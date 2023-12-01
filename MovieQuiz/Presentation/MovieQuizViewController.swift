import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    //переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex: Int = 0
    //переменная со счетчиком правильных ответов
    private var correctAnswers: Int = 0
    // общее кличество вопросов для квиза
    private let questionsAmount: Int = 10
    // фабрика вопросов. передаем делегат в фабрику через свойство
    private var questionFactory: QuestionFactoryProtocol?
    // вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        //начинаем загрузку данных
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerGived(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerGived(answer: true)
    }
    
    // MARK: - Private Methods
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        //создаем изображение из названия афиши фильма
        let image = UIImage(data: model.image) ?? UIImage()
        
        //Определение порядкового номера текущего вопроса
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        //Возвращаем вью модель для текущего вопроса
        return QuizStepViewModel(image: image, question: model.text, questionNumber: questionNumber)
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {
        enableAnswerButton()
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
    }
    
    // приватный метод, который обрабатывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        disableAnswerButtons()
        
        if isCorrect {
            correctAnswers += 1
        }
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //слабая ссылка на self
            guard let self = self else { return } //разворачиваем слабую ссылку
                self.showNextQuestionOrResults()
            }
    }
    
    //универсальный метод для блоков кода внутри IBAction
    private func answerGived(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идем в состояние "Результат квиза"
            let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: text,
                buttonText: "Сыграть еще раз")
            showResult(quiz: viewModel)
        } else {
            // идем в состояние "Вопрос показан"
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            
            enableAnswerButton()
        }
    }
    
    // приватный метод для показа результатов раунда квиза
    private func showResult(quiz result: QuizResultsViewModel) {
        // получаем количество сыгранных квизов
        let playedQuizzesCount = statisticService?.gamesCount ?? 0
        // получаем текущий рекорд
        let currentBestGame = statisticService?.bestGame ?? GameRecord(correct: 0, total: 0, date: Date())
        // формируем текст для алерта, включая округление точности и текущую дату
        let accuracyText = String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0)
        let dateText = statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
        let recordText = "Ваш результат: \(correctAnswers)/\(questionsAmount),\nКоличество сыгранных квизов: \(playedQuizzesCount),\nРекорд: \(currentBestGame.correct)/\(currentBestGame.total) (\(dateText)),\nСредняя точность: \(accuracyText)%"
        
        let alertModel = AlertModel(
            title: result.title,
            message: recordText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                // сбрасываем игру
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                //заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        // обновление статистики после завершения квиза
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        alertPresenter?.presentAlert(with: alertModel)
    }
      
    // Блокируем обе кнопки
    private func disableAnswerButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func enableAnswerButton() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // приватный метод, который обрабатывает состояние загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        // включаем анимацию
        activityIndicator.startAnimating()
    }
    
    // приватный метод, который обрабатывает состояние ошибки
    private func showNetworkError(message: String) {
        // скрываем индикатор загрузки
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            // снова загружаем данные
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                //показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.presentAlert(with: alertModel)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
}

