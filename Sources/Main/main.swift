import Foundation

typealias Accuracy = Double

func test( training training:String, test:String, testName:String, parser:DataParser ) -> Accuracy {
    print("\n")
    print("Using the \(testName) data set");
    print("Training with \(training)")
    print("Classfying with \(test)")

    let classifier = Classifier( filename:training, dataParser:parser )

    let testData:[(classification:String, vector:[Double], ignore:[String])] = parser.parseFile( test );
    var accuracy = 0;
    for data in testData {
        let guess = classifier.classify( data.vector );
        if guess == data.classification { accuracy+=1 }
    }
    return Double(accuracy) / Double(testData.count)
}

var accuracy = 0.0

accuracy = test( training:"Data/athletesTrainingSet.txt", test:"Data/athletesTestSet.txt", testName: "Athlete", parser: AtheletesParser() )
print("Accuracy is \(accuracy * 100)%")

accuracy = test( training:"Data/mpgTrainingSet.txt", test:"Data/mpgTestSet.txt", testName: "Mile Per Gallon", parser: MPGParser() )
print("Accuracy is \(accuracy * 100)%")

accuracy = test( training:"Data/irisTrainingSet.data.txt", test:"Data/irisTestSet.data.txt", testName: "Iris", parser: IrisParser() )
print("Accuracy is \(accuracy * 100)%")
