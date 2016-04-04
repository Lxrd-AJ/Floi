
import Foundation



class kMeansClusterer {
    
    var clusters:[Cluster] = []
    lazy var normalizedClusters: [Cluster] = { 
        return normalizeClusters(self.clusters);
    }()
    
    init( filename:String ){
        self.clusters = ClusterParser.parseFile( filename ); 
        //print( self.normalizedClusters )
        //print("Nearest Neighbour")
        //print( self.normalizedClusters[0].nearestNeighbour(self.normalizedClusters)
        
        print(self.normalizedClusters);
        
    }
    
    
}