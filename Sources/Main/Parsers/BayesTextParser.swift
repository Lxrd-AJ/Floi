//
// Created by AJ Ibraheem <AJ> on 2016-03-02
// Email: ibraheemaj@icloud.com
// Copyright (c) The Leaf Enterprise. All rights reserved.
//

import Foundation

/**
 Parser to parse in Data for use in the BayesTextClassifier. It handles all the data related cleaning and parsing so as to separate concerns from the classifier
 code. It exposes the following to
    * The stoplist words
    * The names of the subdirectories and an array of the file paths they contain as a dictionary
 */
class BayesTextParser {
    
    var stopWords: [String] = []
    var directoryContentsURL: [NSURL] = [] //The URLs for all the files in the current training/test directory 
    lazy var categories: [String:[NSURL]] = { //The categories and their respective file URLs
        return self.directoryContentsURL.reduce([:], combine:{ (map:[String:[NSURL]], url:NSURL) in
            var _map = map
            do{ 
                _map[url.lastPathComponent!] = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: [.SkipsHiddenFiles])
            }catch let error{ print(error) } //Silently fail like the wolf hunting a sheep
            return _map
        });
    }()
    
    init( stopWordsPath:String, documentsPath:String ){
        //1. Read in the stop words 
        if let contentsOfFile = readFile( stopWordsPath, encoding:NSISOLatin1StringEncoding ){
            self.stopWords = contentsOfFile.componentsSeparatedByString("\n").filter({ $0 != "" })
        }
        
        //2.Read in all the URLs for each category 
        do{
            let directoryURL = NSURL(string: documentsPath)!
            self.directoryContentsURL = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: nil, options: [.SkipsHiddenFiles]).filter({ NSFileManager.defaultManager().isDirectory($0.path!) })
        }catch let error  {
            print( error )
        }
    }
}