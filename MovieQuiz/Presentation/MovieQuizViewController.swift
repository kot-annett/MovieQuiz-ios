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
    private let presenter = MovieQuizPresenter()
    private var correctAnswers: Int = 0 //Presenter
    private var questionFactory: QuestionFactoryProtocol? //Presenter
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
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
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Methods
 
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        enableAnswerButton()
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
    }
    
    // метод, который обрабатывает результат ответа
    func showAnswerResult(isCorrect: Bool) {
        disableAnswerButtons()
        
        if isCorrect {
            correctAnswers += 1
        }
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            }
    }
    
    // метод для показа результатов раунда квиза
    func showResult(quiz result: QuizResultsViewModel) {
        // получаем количество сыгранных квизов
        let playedQuizzesCount = statisticService?.gamesCount ?? 0
        // получаем текущий рекорд
        let currentBestGame = statisticService?.bestGame ?? GameRecord(correct: 0, total: 0, date: Date())
        // формируем текст для алерта, включая округление точности и текущую дату
        let accuracyText = String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0)
        let dateText = statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
        let recordText = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount),\nКоличество сыгранных квизов: \(playedQuizzesCount),\nРекорд: \(currentBestGame.correct)/\(currentBestGame.total) (\(dateText)),\nСредняя точность: \(accuracyText)%"
        
        let alertModel = AlertModel(
            title: result.title,
            message: recordText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                // сбрасываем игру
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                //заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        // обновление статистики после завершения квиза
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        alertPresenter?.presentAlert(with: alertModel)
    }
      
    // Блокируем обе кнопки
    private func disableAnswerButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func enableAnswerButton() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // приватный метод, который обрабатывает состояние загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        // включаем анимацию
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // приватный метод, который обрабатывает состояние ошибки
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            // снова загружаем данные
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                //показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.presentAlert(with: alertModel)
    }
}

