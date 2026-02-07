import XCTest
@testable import PCAStudy

final class QuestionParserTests: XCTestCase {
    func testParsesQuestionWithAnswerLine() {
        let text = """
        1.- ¿Cuál es la función del timón?
        A. Controlar el alabeo
        B. Controlar el guiñada
        C. Controlar el cabeceo
        Respuesta: B
        """

        let parser = QuestionParser()
        let questions = parser.parse(text: text, pageNumber: 1)

        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions.first?.answerKey, "B")
        XCTAssertEqual(questions.first?.choices.count, 3)
    }

    func testParsesQuestionWithoutAnswer() {
        let text = """
        2.- ¿Qué instrumento mide la altitud?
        A. Altímetro
        B. Acelerómetro
        C. Variómetro
        """

        let parser = QuestionParser()
        let questions = parser.parse(text: text, pageNumber: 2)

        XCTAssertEqual(questions.count, 1)
        XCTAssertNil(questions.first?.answerKey)
    }
}
