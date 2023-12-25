import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private lazy var presenter: MovieQuizPresenter = {
        return MovieQuizPresenter(viewController: self)
    }()
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
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
    
    // метод красит рамку
    func hightlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // метод для показа результатов раунда квиза
    func showResult(quiz result: QuizResultsViewModel) {
        
        let message = presenter.makeResultMessage()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                // сбрасываем игру
                guard let self = self else { return }
                
                self.presenter.restartGame()
            })
    
        alertPresenter?.presentAlert(with: alertModel)
    }
      
    // Блокируем обе кнопки
    func disableAnswerButtons() {
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

