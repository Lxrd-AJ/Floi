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
    typealias Probability = Double
    
    let parser:BayesTextParser
    var probability:[Category:[Word:Probability]] = [:]
    var totals:[Category:Int] = [:]
    var filesFailedToRead:[NSURL] = []
    var corpusByCategory: [Category:[Word:Int]] = [:]
    lazy var corpus:[Word:Int] = {
        return self.corpusByCategory.keys.reduce([:], combine:{ (result:[Word:Int],category:Category) in
            return result.merge( self.corpusByCategory[category]! )
        })
    }()
    
    /**
     - todo
        [ ] Verify the probability calculation being performed here as it doesn't correspond with 7-22
     */
    init( trainingDirectory:String, stopWordsPath:String ){
        parser = BayesTextParser( stopWordsPath:stopWordsPath, documentsPath:trainingDirectory )

        //Train the Classifier
        for( category, fileURLs ) in parser.categories {
            print("Training with dataset from \(category)")
            let (vocabulary,total) = self.train( fileURLs, category:category, stopWords:parser.stopWords )
            self.totals[category] = total
            self.corpusByCategory[category] = vocabulary
        }//end for
        
        //Calculate the probabilities
        for (category,_) in parser.categories {
            print("\nComputing Probabilities for \(category) ....")
            self.probability[category] = [:]
            let denominator = self.totals[category]! + (self.corpus.keys.count)
            self.probability[category] = self.corpus.keys.reduce([:], combine:{ (wordProbability:[Word:Probability],token:Word) in
                var count = 0
                var _wordProbability = wordProbability
                if self.corpusByCategory[category]!.keys.contains(token) {
                    count = self.corpusByCategory[category]![token]!
                }else{ count = 1 }
                _wordProbability[token] = Double(count+1)/Double(denominator)
                return _wordProbability
            })
        }
        
        //TEST
        print("*****************")
        print("Corpus Size: \(corpus.keys.count)\n");
        
        print( "rec.motorcycles - god \t \(probability["rec.motorcycles"]!["god"])" )
        print( "soc.religion.christian - god \t \(probability["soc.religion.christian"]!["god"])" )
        print( "rec.motorcycles - the \t \(probability["rec.motorcycles"]!["the"])" )
        print( "soc.religion.christian - the \t \(probability["soc.religion.christian"]!["the"])" )
        
        if filesFailedToRead.count > 0 {
            print( "\(filesFailedToRead.count) files failed to read \n \(filesFailedToRead)")
        }
        
    }
    
    /**
     Populates the classifier's vocabulary with the words read in from the `dataURLs`
     */
    func train( dataURLs:[NSURL], category:String, stopWords:[String] ) -> (vocabulary:[Word:Int],total:Int){
        //var counts:[Word:Int] = [:]
        var total = 0
        var vocabulary: [Word:Int] = [:]
        _ = dataURLs.map({ fileURL in
            if let contentsOfFile = readFile( fileURL.path!, encoding:NSISOLatin1StringEncoding ){
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
                vocabulary = vocabulary.merge( _vocabulary.keys.reduce([:], combine:{ (corpus:[Word:Int],token:Word) in
                    var _corpus = corpus
                    let count = _vocabulary[token]!
                    if( count > 3 ){ _corpus[token] = count }
                    return _corpus
                }))
            }else{
                print("Failed to read URL whilst in training function")
                filesFailedToRead += [fileURL]
            }
        })
        return (vocabulary,total)
    }
    
    /**
     Predicts the classification of a prediction 
     - returns: A String denoting the classification
     */
    func classify( fileURL:NSURL ) -> Category? {
        var results:[(category:Category, probability:Probability)] = []
        if let contentsOfFile = readFile( fileURL.path!, encoding:NSISOLatin1StringEncoding ){
            let tokens = filterTokens( contentsOfFile.componentsSeparatedByCharactersInSet(.whitespaceAndNewlineCharacterSet()) )
                .filter({ self.corpus.keys.contains($0) }) //Only use words that are in our vocabulary/corpus
            let tokenProbabilityInCategory: [(Word,[(Category,Probability)])] = tokens.map({ token in //Calculate it's respective probability in each category
                let probabilityInCategory:[(Category,Probability)] = self.parser.categories.keys.flatMap({ category -> (Category,Probability)? in
                    guard self.probability[category]![token] != 0 else{ return nil; } //probability of 0 affects entire calculation
                    return (category, log(self.probability[category]![token]))
                })
                return (token,probabilityInCategory)
            })
            let categoryProbability: [(Category,Probability)] = tokenProbabilityInCategory.reduce([],combine:{ //tuple elem 1 refers to `[(Category,Probability)]`
                (res,tupArr) in zip(res,tupArr)
            })
            //TODO: Use a dictionary to merge all the results together
        }else{
            print("Failed to read in URL \(fileURL) whilst classifying");
            return nil
        }
    }
    
    /**
     Helper function to perform custom filtering/parsing of a corpus
     - todo:
        [ ] Some whitespace characters are still escaping through the filtering `$0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())` doesnt seem to be getting rid of them
     */
    private func filterTokens( str:[String] ) -> [Stringssssss] {
        return str.filter({ $0 != "" })
            .map({ $0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(.punctuationCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(.symbolCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) })
            .map({ $0.lowercaseString })
    }
}