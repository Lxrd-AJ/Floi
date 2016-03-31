import Foundation

/**
Cluster Parser.
Reads in a file and parses the data into an array of clusters
- note: Cluster is dataset specific
*/
class ClusterParser {
    static func parseFile( filename:String ) -> [Cluster]{
        if let contentsOfFile = readFile(filename) {
            let lines: [String] = contentsOfFile
                .componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                .filter({ $0 != "" });
            var contents : [[String]] = lines.map({ $0.componentsSeparatedByString(",") })

            //let format = contents[0];
            let data = Array(contents[1..<contents.count]); 
            return data.map({ line in 
                return Cluster(name:line[0], distance:Array(line[1..<line.count]
                    .map({ return Double($0)! })
                )) 
            })
        }else{
            print("ClusterParser.swift => Failed to read File \(filename)");
            return [];
        }
    }
}
