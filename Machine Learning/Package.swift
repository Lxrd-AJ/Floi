import PackageDescription

let package = Package(
    name: "Guide2DataMining",
    dependencies: [
        .Package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", versions: "0.1.0" ..< Version.max)
        .Package(url: "https://github.com/jkandzi/Table.swift", majorVersion: 0)//Draw beautiful tables to your terminal.
        .Package(url: "https://github.com/davecom/SwiftPriorityQueue", versions: Version(1,0,1)..<Version(1,0,3))
    ]
)
