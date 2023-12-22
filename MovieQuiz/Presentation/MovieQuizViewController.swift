import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
        statisticService = StatisticService()
        showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Methods
 
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
        
        presenter.didAnswer(isCorrect: isCorrect)
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
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
        let recordText = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount),\nКоличество сыгранных квизов: \(playedQuizzesCount),\nРекорд: \(currentBestGame.correct)/\(currentBestGame.total) (\(dateText)),\nСредняя точность: \(accuracyText)%"
        
        let alertModel = AlertModel(
            title: result.title,
            message: recordText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                // сбрасываем игру
                guard let self = self else { return }
                self.presenter.restartGame()
            })
        // обновление статистики после завершения квиза
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        }
        
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
    
    // метод, который обрабатывает состояние загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        // включаем анимацию
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // метод, который обрабатывает состояние ошибки
    func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            // снова загружаем данные
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            })
        alertPresenter?.presentAlert(with: alertModel)
    }
}

