import Foundation

typealias Accuracy = Double
var accuracy = 0.0

func test( training training:String, test:String, testName:String, parser:DataParser, classColumn:Int ) -> Accuracy {
    print("\n")
    print("Using the \(testName) data set");
    print("Training with \(training)")
    print("Classfying with \(test)")

    //1st Make the Buckets
    Bucket.makeBuckets( training, bucketName:testName, classColumn:classColumn )//NB: Only Training used as source for Buckets
    let classifier = Classifier( bucketPrefix:testName, testBucketNumber:3, dataParser:parser )

    let testData:[(classification:String, vector:[Double], ignore:[String])] = parser.parseFile( test );
    var accuracy = 0;
    for data in testData {
        let guess = classifier.classify( data.vector );
        if guess == data.classification { accuracy += 1 }
    }
    return Double(accuracy) / Double(testData.count)
}

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

    let categories: [String] = results.keys.sort();
    var header = "\t"
    var subheader = "\t+"
    var total = 0
    var correct = 0
    var count = 0

    //MARK - Drawing the confusion matrix
    print( "\n\(bucketPrefix) using \(k) nearest neighbour(s) \tClassified as:" )
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
    //kappaStatistics( results );
}

func kappaStatistics( results: [String:[String:Int]] ){
    let total = results.keys.reduce( 0, combine:{ (total,rowKey) in
        let row = results[rowKey]!
        return total + row.keys.reduce(0, combine:{ (total,key) in total + row[key]! })
    })
    var kappaResults: [String:[String:Int]] = [:]
    var keyToCount: [String:Int] = [:]

    //Calculate the ratio for each key
    for (key,row) in results {
        for (rKey,value) in row { //NB: Map doesnt seem to be woking for dictionaries, strange 😩
            if keyToCount[rKey] == nil { keyToCount[rKey] = 0 }
            keyToCount[rKey]! += value;
        }
    }

    //TODO: Continue kappa statistics for classifier here
    //convert to ratios
    // let keyToRatio = keyToCount.keys.reduce( [String:Double](), combine:{ (ratioMap:[String:Double],currentKey:String) in
    //     return ratioMap[currentKey] = currentKey / total
    // })
    print( keyToCount )
    print( keyToRatio )
    //print( results )
}


// accuracy = test( training:"Data/athletesTrainingSet.txt", test:"Data/athletesTestSet.txt", testName: "Athlete", parser: AtheletesParser(),classColumn:1 )
// print("Accuracy is \(accuracy * 100)%")
//
// accuracy = test( training:"Data/mpgTrainingSet.txt", test:"Data/mpgTestSet.txt", testName: "mpgData", parser: MPGParser(), classColumn:0 )
// print("Accuracy is \(accuracy * 100)%")
//
// accuracy = test( training:"Data/irisTrainingSet.data.txt", test:"Data/irisTestSet.data.txt", testName: "Iris", parser: IrisParser(),classColumn:4 )
// print("Accuracy is \(accuracy * 100)%")

//Bucket.makeBuckets("Data/mpgTestSet.txt", bucketName:"mpgData", classColumn:0 )


//tenFoldCrossValidation( "Data/mpgData.txt", bucketPrefix:"mpgData", classColumn:0, parser:Parser() );
tenFoldCrossValidation( "Data/pima.txt", bucketPrefix:"pima", classColumn:8, parser:Parser() );
tenFoldCrossValidation( "Data/pima.txt", bucketPrefix:"pima", classColumn:8, parser:Parser(), k:5 );

tenFoldCrossValidation( "Data/pimaSmall.txt", bucketPrefix:"pimaSmall", classColumn:8, parser:Parser() );
tenFoldCrossValidation( "Data/pimaSmall.txt", bucketPrefix:"pimaSmall", classColumn:8, parser:Parser(), k:5 );
