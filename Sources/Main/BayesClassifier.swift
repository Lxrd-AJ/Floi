/**
* @Author: AJ Ibraheem <AJ>
* @Date:   2016-02-20T08:50:02+00:00
* @Email:  ibraheemaj@icloud.com
* @Last modified by:   AJ
* @Last modified time: 2016-02-20T09:35:25+00:00
*/

import Foundation

/**
    a classifier will be built from files with the bucketPrefix excluding the file with
    textBucketNumber. dataFormat is a string that describes how to interpret each line of the data files.
    For example, for the iHealth data the format is: "attr     attr  attr  attr  class"
    - note
        * This BayesClassifier seems to be having lots of similarites to the Classifier class, a todo might be to inherit from the classifier class
        * Another extension could be to use typealias(es) to simplify the dictionary definitions e.g counts[Category:[Column:[DataItem:Count]]]
    - todo
        Use a parser that inherits from the DataParser protocol instead and modify the data parser protocol
        to include attributes:[String] alongside vectors
*/
class BayesClassifier {

    typealias Classification = String
    typealias Column = Int
    typealias Attribute = String
    typealias Probability = Double

    let numOfBuckets = 10

    var classes:[String:Int] = [:] //Counts the occurrence of each class or category
    var counts:[String:[Int:[String:Int]]] = [:] //tracks the occurrence of each attribute values in the different columns
    var data: [(classification:String, attribute:[String], vector:[Double], ignore:[String])] = []
    var total:Int { return data.count } //track the number of rows we processed

    lazy var priorProbability: [String:Double] = {
        //Calculates the Prior Probability p(h) for every category in classes
        return self.classes.keys.reduce([:], combine:{ (probabilities:[Classification:Probability],category:String) in
            var result = probabilities
            result[category] = Double(self.classes[category]!) / Double(self.total)
            return result
        })
    }()
    lazy var conditionalProbability: [Classification:[Column:[Attribute:Probability]]] = {
        //Compute the conditional probability for the Hypothesis given Data
        //Column number is being used to preserve integrity of each attribute as they might repeat across columns
        //Probs i could have gone functional and used `reduce` ? 🤔🤔🤔
        var result:[Classification:[Column:[Attribute:Probability]]] = [:]
        for (category,column) in self.counts {
            result[category] = [:]
            for (cNo,attributeCount) in column {
                if result[category]![cNo] == nil { result[category]![cNo] = [:] }
                for (attribute,count) in attributeCount {
                    result[category]![cNo]![attribute] = Double(count) / Double(self.classes[category]!)
                }
            }
        }
        return result
    }()

    /**
        Trains the classifier and builds an internal model
        - parameter testBucketNumber: The Bucket number to use to test, counting starts from 0
    */
    init( bucketPrefix:String, testBucketNumber:Int, dataParser:BayesParser ){
        //Read in the data
        for i in 0..<numOfBuckets {
            if i == testBucketNumber { continue }
            let filename = "Temp/\(bucketPrefix)-\(i).txt"
            self.data += dataParser.parseFile( filename )
        }

        //Process the entire collection and fill up the classes and counts variables
        _ = self.data.map({ datum in
            if classes[datum.classification] == nil {
                classes[datum.classification] = 0
                counts[datum.classification] = [:]
            }
            classes[datum.classification]! += 1
            //Process each attribute/vector for the current datum
            var column:Int = 0
            for attrib in datum.attribute {
                column += 1
                let category = datum.classification
                if counts[category]![column] == nil { counts[category]![column] = [:] }
                if counts[category]![column]![attrib] == nil { counts[category]![column]![attrib] = 0 }
                counts[category]![column]![attrib]! += 1
            }
        })
    }

    /**
        Makes a classification based on the `attributeVector` by computing the maximum a posteriori
        probability of each Hypothesis and returning the maximum probability
        - note: Presently `Attribute` is a string and as a result, the classifier would not classify data
            with Integer/Double attributes **This needs to be improved**
        - parameter attributeVector: The array of attributes to base the classification on
    */
    func classify( attributeVector:[Attribute] ) -> Classification {
        return self.priorProbability.keys
            .reduce( [(Classification,Probability)](), combine:{
                (results:[(Classification,Probability)], category:String) in
                var temp = results
                var probability = self.priorProbability[category]!
                var column = 1
                _ = attributeVector.map({ attribute in
                    if let prob = self.conditionalProbability[category]![column]![attribute] {
                        probability *= prob;
                        column += 1
                    }else{ probability = 0 }
                })
                temp += [(category,probability)]
                return temp
            })
            .sort({ $0.1 > $1.1 })
            .first!.0 // 0 is Classification
    }
}
