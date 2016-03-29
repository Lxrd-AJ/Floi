
//http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/
indirect enum Cluster {
    case Empty 
    case ClusterNode( Cluster, index:Int, content:String )
}




  // let content: String
  // let distance: Double