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
 - warning 
    * Some Files are failing to read
 */
class BayesTextClassifier {
    
    typealias Word = String
    typealias Category = String
    
    let parser:BayesTextParser
    var probability:[Category:[Word:Double]] = [:]
    var totals:[Category:Int] = [:]
    
    /**
     - todo
        [ ] Verify the probability calculation being performed here
     */
    init( trainingDirectory:String, stopWordsPath:String ){
        parser = BayesTextParser( stopWordsPath:stopWordsPath, documentsPath:trainingDirectory )

        //Train the Classifier
        for( category, fileURLs ) in parser.categories {
            print("\(category)")
            let (vocabulary,total) = self.train( fileURLs, category:category, stopWords:parser.stopWords )
            self.totals[category] = total
            print("Totals length \(total)")
            print("Vocabulary length \(vocabulary.keys.count)")
            //Calculate the probability
            print("Computing Probabilities ....")
            self.probability[category] = [:]
            let denominator = total + (vocabulary.keys.count)
            for (word,wordCount) in vocabulary {
                print("Word \(word)")
                print("Probability \(Double(wordCount+1)/Double(denominator))")
                print("numerator \(wordCount+1) \nDenominator \(denominator)\n")
                self.probability[category]![word] = Double(wordCount+1)/Double(denominator)
            }
        }//end for
        
        //TEST 
        print( probability["rec.motorcycles"]!["god"] )
        print( probability["soc.religion.christian"]!["god"] )
        print( probability["rec.motorcycles"]!["the"] )
        print( probability["soc.religion.christian"]!["the"] )
        
    }
    
    /**
     Populates the classifier's vocabulary with the words read in from the `dataURLs`
     - todo:
        [ ] Some whitespace characters are still escaping through the filtering `$0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())` doesnt seem to be getting rid of them
     */
    func train( dataURLs:[NSURL], category:String, stopWords:[String] ) -> (vocabulary:[Word:Int],total:Int){
        //var counts:[Word:Int] = [:]
        var total = 0
        var vocabulary: [Word:Int] = [:]
        _ = dataURLs.map({ fileURL in
            if let contentsOfFile = readFile( fileURL.path! ){
                //Filtering and cleaning of the data
                let tokens = contentsOfFile.componentsSeparatedByCharactersInSet( .whitespaceAndNewlineCharacterSet() )
                    .filter({ $0 != "" })
                    .filter({ !stopWords.contains($0) })
                    .map({ $0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) })
                    .map({ $0.stringByTrimmingCharactersInSet(.punctuationCharacterSet()) })
                    .map({ $0.stringByTrimmingCharactersInSet(.symbolCharacterSet()) })
                    .map({ $0.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) })
                    .map({ $0.lowercaseString })
                //Count the occurence of each word and total words parsed
                var _vocabulary = tokens.reduce([:], combine:{ (corpus:[Word:Int],token:Word) in
                    var _corpus = corpus
                    if( _corpus[token] == nil ){ _corpus[token] = 0 }
                    _corpus[token]! += 1
                    total += 1 //We are using the actual total of words including the words that occur less than 3 times
                    return _corpus
                })
                //Strip words from the vocabulary that don't occur at least 3 times
                //note: Join the dictionaries together not replace
                vocabulary += _vocabulary.keys.reduce([:], combine:{ (corpus:[Word:Int],token:Word) in
                    var _corpus = corpus
                    let count = _vocabulary[token]!
                    if( count > 3 ){ _corpus[token] = count }
                    return _corpus
                })
            }else{ print("Failed to read URL whilst in training function") }
        })
        return (vocabulary,total)
    }
}