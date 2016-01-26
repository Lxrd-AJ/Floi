import Foundation

typealias Accuracy = Double

func test( training:String, test:String ) throws -> Accuracy {
    print("Training with \(training)")
    print("Classfying with \(test)")

    let parser = AtheletesParser();
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

print("\n")
accuracy = try! test( "Data/athletesTrainingSet.txt", test:"Data/athletesTestSet.txt" )
print("Accuracy is \(accuracy * 100)%")
