import Foundation

enum Choice {
    case Like
    case Dislike
}

//Computes the manhattan distance between two vectors
func manhattan( vector1:[Double], vector2:[Double] ) -> Double {
    return abs( Array(zip(vector1,vector2)).map({ $0.0 - $0.1 }).reduce(0, combine:+) )
}

func help (){
    let num = "attr"
    let cl = "class"
    var result = "\(cl)\t"
    for _ in 0..<16 {
    	result += "\(num)\t"
    }
    //result +=
    print(result)
}

//Creates a sorted list of items based on their distances to item
func computeNearestNeighbour( item:String , itemVector:[Double], items:[String:[Double]] ) -> [Double] {
    var distances: [Double] = []
    for (otherItem,vectors) in items {
        if otherItem != item {
            distances.append( manhattan( itemVector, vector2:vectors ) )
        }
    }
    return distances.sort()
}

func readFile( path:String , encoding: NSStringEncoding = NSUTF8StringEncoding ) -> String? {
    guard NSFileManager().fileExistsAtPath( path ) else{ return nil }
    do{ return try String( contentsOfFile:path, encoding:encoding ); }
    catch{ print("An error occured whilst reading file, Error: \(error)") }
    return nil;
}

/**
    Helper function to help compute the power of a radix
    - note: Only works on Double **not Int** as a use case hasnt risen yet
*/
infix operator ^^ {}
func ^^ (radix:Double, power:Double) -> Double {
    return pow(radix,power)
}

//Swift extensions to enable shuffling
extension CollectionType {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollectionType where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        for i in 0..<count-1 {
            let j = Int( arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap( &self[i], &self[j] )
        }
    }
}
