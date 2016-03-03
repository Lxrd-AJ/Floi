/**
* @Author: AJ Ibraheem <AJ>
* @Date:   2016-03-02T08:50:02+00:00
* @Email:  ibraheemaj@icloud.com
* @Last modified by:   AJ
*/

import Foundation

/**
 A Naive Bayes Classifier that uses supervised learning to classify unstructured text data. Trains and classifies data by computing the maximum a 
 posteri probability
 for each hypothesis for the current word. 
    * It loads in data from the BayesTextParser and trains itself with all the words in files for each subdirectory 
    * It then computes the probability for each word
 */
class BayesTextClassifier {
    
    typealias Word = String
    typealias Category = String
    
    let parser:BayesTextParser
    var probability:[Category:[Word:Double]] = [:]
    
    init( trainingDirectory:String, stopWordsPath:String ){
        parser = BayesTextParser( stopWordsPath:stopWordsPath, documentsPath:trainingDirectory )

        //Train the Classifier
        for( category, fileURLs ) in parser.categories {
            _ = self.train( fileURLs, category:category )
        }
    }
    
    /**
     Populates the classifier's vocabulary with the words read in from the `dataURLs`
     */
    func train( dataURLs:[NSURL], category:String ) -> (counts:[Word:Int],total:Int){
        //var counts:[Word:Int] = [:]
        var total = 0
        var vocabulary: [Word:Int] = [:]
        _ = dataURLs.map({ fileURL in
            if let contentsOfFile = readFile( fileURL.path! ){
                //TODO: Continue Here 
                let tokens = contentsOfFile.componentsSeparatedByCharactersInSet( .whitespaceAndNewlineCharacterSet() )
                    .filter({ $0 != "" })
                    .map({ $0.lowercaseString })
                vocabulary = tokens.reduce([:], combine:{})
            }else{ print("Failed to read URL") }
        })
        
        return (vocabulary,total)
    }
}