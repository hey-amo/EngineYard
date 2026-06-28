import Foundation

public class GameSetupManager {
    public func makeNewGame(with players:[Player]) {
        // Check number of players is valid, else throw error

        switch players.count {
            case 3, 4: 
            // set the game up for 3-4 players
            break
            case 5:
            // set the game up for 5 players
            break
            default:
            // throw an error (unknown player count)
            break
        }
    }
}