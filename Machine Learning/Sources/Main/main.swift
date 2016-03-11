import Foundation

typealias Accuracy = Double
typealias Data = [(classification:String, attribute:[String], vector:[Double], ignore:[String])]
var accuracy = 0.0

func test( training training:String, test:String, testName:String, parser:DataParser, classColumn:Int ) -> Accuracy {
    print("\n")
    print("Using the \(testName) data set");
    print("Training with \(training)")
    print("Classfying with \(test)")

    //1st Make the Buckets
    Bucket.makeBuckets( training, bucketName:testName, classColumn:classColumn )//NB: Only Training used as source for Buckets
    let classifier = Classifier( bucketPrefix:testName, testBucketNumber:3, dataParser:parser )

    let testData:Data = parser.parseFile( test );
    var accuracy = 0;
    for data in testData {
        let guess = classifier.classify( data.vector );
        if guess == data.classification { accuracy += 1 }
    }
    return Double(accuracy) / Double(testData.count)
}

/**
    Performs 10 fold cross validation
    - todo:
        * Implement 10 fold cross validation on the BayesClassifier
    - parameter classColumn : The column where the class/category of data, counting starts from 0
*/
func tenFoldCrossValidation( filename:String, bucketPrefix:String, classColumn:Int, parser:DataParser, k:Int = 1 ){
    var results: [String:[String:Int]] = [:]
    let numOfBuckets = 10

    //Make the Buckets
    Bucket.makeBuckets( filename, bucketName:bucketPrefix, classColumn:classColumn )

    for i in 0..<numOfBuckets {
        let classifier = Classifier( bucketPrefix:bucketPrefix, testBucketNumber:i, dataParser:parser, k:k );
        let testFile = "Temp/\(bucketPrefix)-\(i).txt"
        let testBucketResults = classifier.testBucket( testFile, parser:parser );

        for (key,value) in testBucketResults {
            if results[key] == nil { results[key] = [:] }
            for (cKey, cValue) in value {
                if results[key]![cKey] == nil { results[key]![cKey] = 0 }
                results[key]![cKey]! += cValue
            }
        }
    }//end for loop

    drawConfusionMatrix( results )
}

/**
    Performs 10 fold cross validation
    - todo:
        - [ ] Encapsulate the similarities between the crossValidation Functions and avoid redundancy
    - parameter classColumn : The column where the class/category of data, counting starts from 0
*/
func tenFoldCrossValidation_Bayes( filename:String, bucketPrefix:String, classColumn:Int ){
    var results: [String:[String:Int]] = [:]
    let numOfBuckets = 10

    print("Performing Cross validation on \(bucketPrefix)")
    //Make the Buckets
    Bucket.makeBuckets( filename, bucketName:bucketPrefix, classColumn:classColumn )

    for i in 0..<numOfBuckets {
        let classifier = BayesClassifier( bucketPrefix:bucketPrefix, testBucketNumber:i, dataParser:Parser())
        let testFile = "Temp/\(bucketPrefix)-\(i).txt"
        let testBucketResults = classifier.testBucket( testFile, parser:Parser() );

        for (key,value) in testBucketResults {
            if results[key] == nil { results[key] = [:] }
            for (cKey, cValue) in value {
                if results[key]![cKey] == nil { results[key]![cKey] = 0 }
                results[key]![cKey]! += cValue
            }
        }
    }//end for loop
    
    drawConfusionMatrix( results )
}

func drawConfusionMatrix( results: [String:[String:Int]] ){
    let categories: [String] = results.keys.sort();
    var header = "\t\t"
    var subheader = "\t\t+"
    var total = 0
    var correct = 0
    var count = 0
    
    //MARK - Drawing the confusion matrix
    for category in categories { header += "\(category)\t"; subheader += "--------+"; }
    print("\(header)\n\(subheader)");
    
    for actualCategory in categories {
        var row = "\(actualCategory)\t|";
        _ = categories.map({ expectedCategory in
            if results[actualCategory]![expectedCategory] != nil { count = results[actualCategory]![expectedCategory]! }
            else{ count = 0; }
            row += "\(count)\t|"
            total += count
            if expectedCategory == actualCategory { correct += count }
        })
        print(row);
    }
    print(subheader)
    print("\n\(Double((correct * 100)/total))% correct")
    print("Total of \(total) instances");
    kappaStatistics( results );

}

/**
    Function to test the accuracy of the classifier using Kappa statistics, it works by comparing the results of an actual
    classifier to that of a random classifier. It gets the proportion of each category and uses the proportion to fill in
    the rows for each classification of a category
    - parameter: results: A Dictionary containing the results of the classification of the
                classifer to test
    - note :
        kappaResults contains an approximation as in some cases the percentage proportion might be 0.7199999999 and that might
        result in an equated value less than 1
*/
func kappaStatistics( results: [String:[String:Int]] ){
    let total = results.keys.reduce( 0, combine:{ (total,rowKey) in
        let row = results[rowKey]!
        return total + row.keys.reduce(0, combine:{ (total,key) in total + row[key]! })
    })
    var kappaResults: [String:[String:Int]] = [:]
    var keyToCount: [String:Int] = [:]
    //Anonymous function to sum the results of a row
    func sumRow( dictionary:[String:Int] ) -> Int {
        return dictionary.keys.reduce(0, combine:{ (total,key) in total + dictionary[key]! })
    }

    //Calculate the ratio for each key
    for (_,row) in results {
        for (rKey,value) in row { //NB: Map doesnt seem to be woking for dictionaries, strange 😩
            if keyToCount[rKey] == nil { keyToCount[rKey] = 0 }
            keyToCount[rKey]! += value;
        }
    }

    //convert to ratios
    let keyToRatio = keyToCount.keys.reduce( [String:Double](), combine:{ (ratioMap:[String:Double],currentKey:String) in
        var temp = ratioMap
        temp[currentKey] = Double(keyToCount[currentKey]!) / Double(total)
        return temp
    })

    for (category,row) in results {
        kappaResults[category] = [:]
        for (expectedCategory,_) in row {
            kappaResults[category]![expectedCategory] = Int( keyToRatio[expectedCategory]! * Double(sumRow(row)) )
        }
    }
    print(kappaResults);
    //TODO: Continue kappa statistics for classifier here 5-22

}


/**
    Classifying data without cross-validation
*/
// accuracy = test( training:"Data/athletesTrainingSet.txt", test:"Data/athletesTestSet.txt", testName: "Athlete", parser: AtheletesParser(),classColumn:1 )
// print("Accuracy is \(accuracy * 100)%")
//
// accuracy = test( training:"Data/mpgTrainingSet.txt", test:"Data/mpgTestSet.txt", testName: "mpgData", parser: MPGParser(), classColumn:0 )
// print("Accuracy is \(accuracy * 100)%")
//
// accuracy = test( training:"Data/irisTrainingSet.data.txt", test:"Data/irisTestSet.data.txt", testName: "Iris", parser: IrisParser(),classColumn:4 )
// print("Accuracy is \(accuracy * 100)%")

//Bucket.makeBuckets("Data/mpgTestSet.txt", bucketName:"mpgData", classColumn:0 )





/**
    Classifying data using 10 fold cross validation

//tenFoldCrossValidation( "Data/mpgData.txt", bucketPrefix:"mpgData", classColumn:0, parser:Parser() );
//tenFoldCrossValidation( "Data/pima.txt", bucketPrefix:"pima", classColumn:8, parser:Parser() );
tenFoldCrossValidation( "Data/pima.txt", bucketPrefix:"pima", classColumn:8, parser:Parser(), k:5 );

tenFoldCrossValidation( "Data/pimaSmall.txt", bucketPrefix:"pimaSmall", classColumn:8, parser:Parser() );
tenFoldCrossValidation( "Data/pimaSmall.txt", bucketPrefix:"pimaSmall", classColumn:8, parser:Parser(), k:5 );
*/





/**
    Testing the Bayes Classifier
*/
//Bucket.makeBuckets( "Data/iHealth.txt", bucketName:"iHealth", classColumn:4 )
//let classifier = BayesClassifier( bucketPrefix:"iHealth", testBucketNumber:9, dataParser:Parser())
//print("\nClassification based on the Fitness Store")
//print( classifier.classify( ["health", "moderate", "moderate", "yes"], numericVector:[] ) )
//
//// Bucket.makeBuckets( "Data/houseVotes.txt", bucketName:"houseVotes", classColumn:0 )
//// let classifier2 = BayesClassifier( bucketPrefix:"houseVotes", testBucketNumber:9 )
//print("\nClassification based on the Voting Data: Republican vs Democrats")
////print( classifier.classify( ["health", "moderate", "moderate", "yes"] ) )
//tenFoldCrossValidation_Bayes( "Data/houseVotes.txt", bucketPrefix:"houseVotes", classColumn:0 )
//tenFoldCrossValidation_Bayes( "Data/pimaSmall.txt", bucketPrefix:"pimaSmall", classColumn:0 );
//tenFoldCrossValidation_Bayes( "Data/pima.txt", bucketPrefix:"pima", classColumn:0 );
//
//
//let r = classifier.probabilityDensity(mean:72.875, standardDeviation:9.804, x:132);
//print("\n\nTesting Probability Density Function\t\(r)")





/**
    Testing the Bayes Text Classifier
*/
let bayesTextClassifier = BayesTextClassifier( trainingDirectory:"Data/20news-bydate/20news-bydate-train",stopWordsPath:"Data/20news-bydate/stopwords174.txt" )
bayesTextClassifier.test("Data/20news-bydate/stopwords0.txt", directory:"Data/20news-bydate/20news-bydate-test-small")

//Testing without stopwords
//let noStopWordsBTC = BayesTextClassifier( trainingDirectory:"Data/20news-bydate/20news-bydate-train",stopWordsPath:"Data/20news-bydate/stopwords0.txt" )
//noStopWordsBTC.test("Data/20news-bydate/stopwords0.txt", directory:"Data/20news-bydate/20news-bydate-test")

//25 Stop words 
//let twfiveBTWC = BayesTextClassifier( trainingDirectory:"Data/20news-bydate/20news-bydate-train",stopWordsPath:"Data/20news-bydate/stopwords25.txt" )
//twfiveBTWC.test("Data/20news-bydate/stopwords0.txt", directory:"Data/20news-bydate/20news-bydate-test")


