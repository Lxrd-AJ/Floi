import Foundation

// let userRatings: [String:[String:Double]] = [
//     "Amy": ["Taylor Swift":4, "PSY":3, "Whitney Houston":4],
//     "Ben": ["Taylor Swift":5, "PSY":2],
//     "Clara": ["PSY":3.5, "Whitney Houston":4],
//     "Daisy": ["Taylor Swift":5, "Whitney Houston":3]
// ]
//
// let music: [String:[String:Double]] = [
//     "Dr Dog/Fate": ["piano":2.5,"vocals":4,"beat":3.5,"blues":3,"guitar":5,"backup vocals":4,"rap":1],
//     "Phoenix/Lisztomania": ["piano":2, "vocals":5, "beat":5, "blues":3, "guitar":2, "backup vocals":1, "rap":1]
// ]
//
// let users: [String:[String:Character]] = [
//     "Angelica": ["Dr Dog/Fate":"L", "Phoenix/Lisztomania":"L","Heartless Bastards/Out at Sea":"D"]
// ]
//
// let recommender: Recommender = Recommender( data:userRatings );
//
// recommender.computeDeviations( userRatings )
//
// print( "User Ratings: \(userRatings)")
// print( "Frequencies: \(recommender.frequencies)" )
// print( "Deviations: \(recommender.deviations)" )
//
// print( "Computing recommendations for Ben" )
// let ben = userRatings["Ben"]!
// print("\(recommender.slopeOneRecommendations( ben ))")


// print("Classifying Data for the Athlete's Dataset");
// let filename = "Data/athletesTrainingSet.txt"
// print("Reading in file: " + filename);
// let classifier = Classifier( filename:filename );

// =========================== TESTING ==========================
// print("=========================== TESTING ==========================");
// let heights = [54, 72, 78, 49, 65, 63, 75, 67, 54].map({ Double($0) })
// let median = classifier.median(heights)
// let asd = classifier.absoluteStandardDeviation(heights,median: median)
// print("Testing median and Absolute Standard Deviation for \(heights)")
// print("     Median is \(median)")
// print("     Absolute Standard Deviation is \(asd)")
//
// let toFlatten = [[0.0,1.0],[2.0,3.0],[4.0,5.0]]
// let flattened = classifier.flatten( toFlatten );
// let unflattened = classifier.unflatten( flattened )
// let normalized_list = classifier.normalize( toFlatten )
// print("Testing Flattening a list, custom style with list \(toFlatten)")
// print("     Flattened list \(flattened)")
// print("     Unflattened list \(unflattened)")
//
// print("=========================== CLASSIFYING \(filename) ==================");
// print("Modified Contents of \(filename)")
// for entry in classifier.data { print(entry) }
// print("Classfying Data *****************");
// print(classifier.classify( [70,170] ))


enum ProgramError: ErrorType {
    case ChuckNorris
}

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
