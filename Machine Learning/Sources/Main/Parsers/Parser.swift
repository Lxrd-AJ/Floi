//
// Created by AJ Ibraheem <AJ> on 2016-02-21T08:53:01+00:00
// Email: ibraheemaj@icloud.com
// Copyright (c) The Leaf Enterprise. All rights reserved.
//
// Last Modified by AJ on 2016-02-21T08:53:01+00:00

import Foundation

class Parser: DataParser {

    var format: [String]?

    func parseFile( filename:String ) -> [(classification:String, attribute:[String], vector:[Double], ignore:[String])] {
        if let contentsOfFile = readFile(filename) {
            let lines: [String] = contentsOfFile.componentsSeparatedByString("\n").filter({ $0 != "" });
            var contents : [[String]] = lines.map({ $0.componentsSeparatedByString("\t") })

            let format = contents[0];
            self.format = format;
            return parseData( Array(contents[1..<contents.count]) , format: format );
        }else{
            print("Parser.swift => Failed to read File \(filename)");
            return [];
        }
    }

    func parseData( contents:[[String]], format:[String] ) -> [(classification:String, attribute:[String], vector:[Double], ignore:[String])] {
        var data: [(classification:String, attribute:[String], vector:[Double], ignore:[String])] = []
        for line in contents {
            var dataEntry = (classification:"", attribute:[String](), vector:[Double](), ignore:[String]())
            for i in 0..<line.count {
                switch format[i] {
                    case "attr":
                        dataEntry.attribute.append( line[i] )
                    case "num":
                        dataEntry.vector.append( Double(line[i])! );
                    case "comment":
                        dataEntry.ignore.append( line[i] )
                    case "class":
                        dataEntry.classification = line[i]
                    default:
                        break;
                }
            }
            data.append( dataEntry );
        }
        return data;
    }

}

