import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
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
        // для инъекции зависимостей
        // создаем экземпляр QuestionFactory()
        questionFactory = QuestionFactory()
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        // создаем экземпляр AlertPresenter
        alertPresenter = AlertPresenter(presentingViewController: self)
        // инициализация сервиса по статистике
        statisticService = StatisticService()
        // print(NSHomeDirectory())
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        // конвертировать модель вопроса во вью-модель
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            // Отобразить вопрос на экране
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // Было sprint_04
        // let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        //создаем изображение из названия афиши фильма
        let image = UIImage(named: model.image) ?? UIImage()
            
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
        // Блокируем кнопки ответа
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
            
            // Разблокируем кнопки ответа
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
            completion: { [weak self] in //слабая ссылка на self
                // код, который сбрасывает игру и показывает вопрос
                guard let self = self else { return } // разворачиваем слабую ссылку
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                //заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        // обновление статистики после завершения квиза
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        // используем alertPresenter для отображения алерта
        alertPresenter?.presentAlert(with: alertModel)
    }
        
    private func disableAnswerButtons() {
        // Блокируем обе кнопки
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func enableAnswerButton() {
        // Разблокируем обе кнопки
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}

