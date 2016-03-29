import Main

class TestClassifier: XCTestCase {
    var allTests: [(String, () -> Void)]{
        return [
            ("test_median", test_median)
        ]
    }

    let classifier = Classifier( filename:"" ); //This should print the error message 👀

    func test_median() {
        let heights = [54, 72, 78, 49, 65, 63, 75, 67, 54].map({ Double($0) })
        let median = classifier.median(heights)
        XCTAssertTrue( median == 65.0 , "Median func is wrong");
    }
}
