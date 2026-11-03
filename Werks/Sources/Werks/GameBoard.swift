// GameBoard.swift

/** The `GameBoard` actor should keep the array private and expose 
    operations and read-only snapshots, rather than exposing mutable 
    storage. It should never append, remove, or reorder spaces; a 
    locomotive becoming obsolete or unavailable is a state change, 
    not an array removal.*/
public actor GameBoard: Sendable {
    public private(set) var boardSpace: [Locomotive] = []
    //public private(set) var locomotiveCards: [LocomotiveCard] = []
    //public private(set) var gameLog: GameLog = GameLog()
    //public private(set) var gameSettings: GameSetting = GameSetting()
    
    public init(with locomotives: [Locomotive]) {
        self.boardSpace = locomotives
    }
}