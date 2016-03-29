import Foundation

//Platform imports
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

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

/**
 Helper function to join 2 dictionaries together
 - note: reference http://stackoverflow.com/a/24052094/2468129
 */
//func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
//    for (k, v) in right {
//        left.updateValue(v, forKey: k)
//    }
//}

//Swift extensions to enable shuffling
extension Collection {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollection where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        for i in 0..<count-1 {
            #if os(Linux)
                let j = Int(random() % (count - i)) + i
            #else
                let j = Int(arc4random_uniform(UInt32(count - i))) + i
            #endif
            guard i != j else { continue }
            swap( &self[i], &self[j] )
        }
    }
}

//Checking if a directory exists
extension NSFileManager {
    func isDirectory( path:String ) -> Bool {
        var isDir: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath( path, isDirectory:&isDir ){
            if isDir { return true }
        }
        return false
    }
}

/**
 Immuable Helper function to merge two dictionaries, it returns a copy that contains the updated values for each key in both dictionaries.
 It sums the values in cases where they have the same keys
 */
extension Dictionary where Value:IntegerLiteralConvertible, Key: StringLiteralConvertible {
    func merge( rightDict: Dictionary<Key,Value> ) -> Dictionary<Key,Value> {
        var mutableCopy = self
        for( key,value) in rightDict {
            if mutableCopy[key] == nil { mutableCopy.updateValue( value, forKey:key ) }
            else{
                if let leftValue = mutableCopy[key] as? Int, rightValue = value as? Int {
                    mutableCopy.updateValue( (leftValue + rightValue) as! Value, forKey:key )
                }
            }
//            if let key = (leftDict[key] as? String), value = (value as? Int) {
//                if mutableCopy[key] == nil { mutableCopy.updateValue( value, forKey:key ) }
//                else{
//                    let v = mutableCopy[key]! + value
//                    mutableCopy.updateValue( v, forKey:key )
//                }
//
//// , mutableCopy = (mutableCopy as? [String:Int])    [String:Int]
////                if mutableCopy[key] == nil { mutableCopy[key] = value }
////                else{
////                    mutableCopy[key]! += value
////                    //                let v1 = mutableCopy[key]!
////                    //                mutableCopy[key] = v1 += value
////                }
//            }
        }
        return mutableCopy
    }
}
