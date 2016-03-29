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
 - todo: Verify the accuracy of the classifier as there is most likely a bug in calculating the probabilities
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
            //An Extension would be to run this training on a different thread
            let (vocabulary,total) = self.train( fileURLs, category:category, stopWords:parser.stopWords )
            self.totals[category] = total
            self.corpusByCategory[category] = vocabulary
        }//end for
        
        //Calculate the probabilities
        for (category,_) in parser.categories {
            print("Computing Probabilities for \(category) ....")
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
     It predicts the category the contents of the `fileURL` might fall into
     - note: Not entirely sure but Probability of category seems missing using the example 
        Classify "I am stunned by the hype ove rgravity" as a like or dislike
        then using a posteriori Probability 
        where h1 = P(like) * P(I|like) * P(am|like ) * P(stunned|like) * ........ 
              h2 = P(dislike) * P(I|dislike) * ....... 
        ATM P(like) is not being calculated just P(I|like) * P(am|like)
        //TODO: Investigate why 
     - returns: A String denoting the classification
     */
    func classify( fileURL:NSURL ) -> Category? {
        if let contentsOfFile = readFile( fileURL.path!, encoding:NSISOLatin1StringEncoding ){
            let tokens = filterTokens( contentsOfFile.componentsSeparatedByCharactersInSet(.whitespaceAndNewlineCharacterSet()) )
                .filter({ self.corpus.keys.contains($0) }) //Only use words that are in our vocabulary/corpus
            let tokenProbabilityInCategory: [(Word,[(Category,Probability)])] = tokens.map({ token in //Calculate it's respective probability in each category
                let probabilityInCategory:[(Category,Probability)] = self.parser.categories.keys.flatMap({ category -> (Category,Probability)? in
                    guard self.probability[category]![token] != 0 else{ return nil; } //probability of 0 affects entire calculation
                    return (category, log(self.probability[category]![token]!))
                })
                return (token,probabilityInCategory)
            })
            //Create a dictionary of the Prediction results(probability) for each category, sort them by order of decreasing probabilities and return 
            //the category with the highest prediction
            let categoryProbability: [(Category,Probability)] = tokenProbabilityInCategory.reduce([],combine:{ (res:[(Category,Probability)],tuple) in return res + tuple.1 //tuple elem 1 refers to `[(Category,Probability)]`
            })
            let resultsDictionary:[Category:Probability] = categoryProbability.reduce([:], combine:{ (results:[Category:Probability],tuple:(Category,Probability)) in
                var _results = results; let (category,probability) = tuple;
                if _results[category] == nil { _results[category] = 0 }
                _results[category]! += probability
                return _results
            })
            let results:[(category:Category, probability:Probability)] = resultsDictionary.keys
                .map({ category in (category,resultsDictionary[category]!)})
                .sort({ $0.probability > $1.probability })
            print("Probability of \(fileURL.lastPathComponent!) in \(results.first?.category) is \(results.first!.probability)")
            return results.first?.category
        }else{
            print("Failed to read in URL \(fileURL) whilst attempting classifying");
            return nil
        }
    }
    
    
    //MARK: - Test functions
    //Not sure if i should do the testing in main.swift 🤔🤔🤔
    /**
    Test all files in the test directory--that directory is organized into subdirectories--each subdir is a classification category
    */
    func test( stopWordsPath:String, directory:String ){
        let reader = BayesTextParser( stopWordsPath:stopWordsPath, documentsPath:directory )
        var correct = 0;
        var total = 0;
        for( category, fileURLs ) in reader.categories {
            let (_correct, _total) = self.testCategory( category, categoryURLs:fileURLs )
            print("\nTested with dataset from \(category): \(_correct) out of \(_total) correct")
            correct += _correct; total += _total
        }//end for
        print("\n\nAccuracy is \((Float(correct)/Float(total)) * 100)% \t(\(total) test instances)")
    }
    
    func testCategory( category:Category, categoryURLs:[NSURL] ) -> (correct:Int, total:Int) {
        return categoryURLs.reduce( (0,0), combine:{ (result:(correct:Int, total:Int), url) in
            print("Testing with \(url.lastPathComponent!)")
            var _result = result
            _result.total += 1
            if let classification = self.classify( url ) {
                if classification == category { _result.correct += 1 }
            }
            return _result
        })
    }
    //END MARK
    
    
    /**
     Helper function to perform custom filtering/parsing of a corpus
     - todo:
        [ ] Some whitespace characters are still escaping through the filtering `$0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())` doesnt seem to be getting rid of them
     */
    private func filterTokens( str:[String] ) -> [String] {
        return str.filter({ $0 != "" })
            .map({ $0.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(.punctuationCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(.symbolCharacterSet()) })
            .map({ $0.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) })
            .map({ $0.lowercaseString })
    }
}