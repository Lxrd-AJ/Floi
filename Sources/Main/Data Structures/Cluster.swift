
//http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/
indirect enum Cluster {
    case Empty 
    case ClusterNode( left:Cluster, distance:[Double], content:String, right:Cluster )
    
    init(){ self = .Empty }
    
    init( name:String, distance:[Double] ){
      self = .ClusterNode(left:.Empty,distance:distance,content:name,right:.Empty)
    }
}