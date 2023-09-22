import SwiftUI

// Team Data Model
struct Team: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var players: [Player]
    var sessions: [Session] = []
}


// Player Data Model
struct Player: Identifiable {
    let id = UUID()
    var name: String
    var age: String
}

struct Session: Identifiable {
    let id = UUID()
    var date: Date
    var battingStats: [BattingStat]
    var bowlingStats: [BowlingStat]
    var fieldingStats: [FieldingStat]
    var fieldingAssessStats: [FieldingAssessStat]
}

struct BattingStat {
    var playerId: UUID
    var runsScored: Int
    var ballsFaced: Int
}

struct BowlingStat {
    var playerId: UUID
    var oversBowled: Double
    var wicketsTaken: Int
}

struct FieldingStat {
    var playerId: UUID
    var catches: Int
    var runOuts: Int
}

struct FieldingAssessStat {
    var playerId: UUID
    var totalTimeForThrows: Int
    var throwingCorrectly: Int
    var catchesTaken : Int
    var totalCatches : Int
    var totalThrows : Int
    
}


class TeamData: ObservableObject {
    @Published var teams: [Team] = []
    @Published var currentTeam: Team?
    
    func createTeam(name: String, description: String) {
        let newTeam = Team(name: name, description: description, players: [])
        teams.append(newTeam)
        currentTeam = newTeam
    }
    
    func savePlayer(name: String, age: String) {
        guard let team = currentTeam else { return }
        let newPlayer = Player(name: name, age: age)
        teams[teams.firstIndex(where: { $0.id == team.id })!].players.append(newPlayer)
        print("Teams save player function: \(teams)")
    }
    
    func addSession(session: Session, to team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            // Append the session to the selected team's sessions array
            teams[index].sessions.append(session)
        }
        print("Teams add session function: \(teams)")
    }
}

struct ContentView: View {
    @State private var teamName = ""
    @State private var teamDescription = ""
    @State private var playerName = ""
    @State private var playerAge = ""
    
    @ObservedObject var data = TeamData()
    
    @State private var isTeamDetailActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Team Information")) {
                        TextField("Team Name", text: $teamName)
                        
                        TextField("Team Description (Optional)", text: $teamDescription)
                        
                        Button("Create Team") {
                            data.createTeam(name: teamName, description: teamDescription)
                            teamName = ""
                            teamDescription = ""
                        }
                    }
                    
                    
                    if let team = data.currentTeam {
                        Section(header: Text("Player Information for \(team.name)")) {
                            TextField("Player Name", text: $playerName)
                            
                            TextField("Player Age", text: $playerAge)
                                                        
                            Button("Save Player") {
                                data.savePlayer(name: playerName, age: playerAge)
                                playerName = ""
                                playerAge = ""
                            }
                        }
                    }
                    
                    if !data.teams.isEmpty {
                        Section(header: Text("Teams")) {
                            List(data.teams) { team in
                                NavigationLink(destination: TeamDetailView(data: data, team: team)) {
                                    Text(team.name)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Cricket Tracker")
                .listStyle(GroupedListStyle())
            }
        }
    }
}


struct TeamDetailView: View {
    @ObservedObject var data: TeamData
    let team: Team
    @State private var isRecordingSession = false // To control navigation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Team Information")) {
                    Text("Name: \(team.name)")
                    Text("Description: \(team.description)")
                }
                
                Section(header: Text("Players")) {
                    ForEach(team.players) { player in
                        PlayerRow(player: player)
                    }
                }
                // Button to start recording a session
                Button("Record Session") {
                    isRecordingSession = true
                }
                .sheet(isPresented: $isRecordingSession) {
                    // Present the SessionRecordingView with the selected team
                    SessionRecordingView(data: data, selectedTeam: team)
                }
                // Section to display all sessions
                           Section(header: Text("Sessions")) {
                               ForEach(team.sessions) { session in
                                   SessionRow(session: session, playerInfo: team.players)
                               }
                           }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(team.name)
        }
    }
}

struct SessionRecordingView: View {
    @ObservedObject var data: TeamData
    let selectedTeam: Team
    @State private var sessionDate = Date()
    @State private var isRecording = false
    @State private var playerStats: [UUID: (runsScored: Int, ballsFaced: Int, oversBowled: Double, wicketsTaken: Int, catches: Int, runOuts: Int, totalTimeForThrows: Int, throwingCorrectly: Int,catchesTaken : Int, totalCatches : Int, totalThrows : Int )] = [:]

    var body: some View {
        NavigationView {
            VStack {
                Section(header: Text("Session Details")) {
                    DatePicker("Session Date", selection: $sessionDate, displayedComponents: .date)
                }

                Button(isRecording ? "Stop Recording" : "Start Recording") {
                    isRecording.toggle()
                }

                if isRecording {
                    List(selectedTeam.players, id: \.id) { player in
                        PlayerStatEntryView(player: player, playerStats: $playerStats)
                    }
                    Button("Save Session") {
                        // Create session with recorded stats
                        var session = Session(date: sessionDate, battingStats: [], bowlingStats: [], fieldingStats: [], fieldingAssessStats: [])

                        for (playerId, stats) in playerStats {
                            let battingStat = BattingStat(playerId: playerId, runsScored: stats.runsScored, ballsFaced: stats.ballsFaced)
                            let bowlingStat = BowlingStat(playerId: playerId, oversBowled: stats.oversBowled, wicketsTaken: stats.wicketsTaken)
                            let fieldingStat = FieldingStat(playerId: playerId, catches: stats.catches, runOuts: stats.runOuts)
                            let fieldingAssessStat = FieldingAssessStat(playerId: playerId, totalTimeForThrows: stats.totalTimeForThrows, throwingCorrectly: stats.throwingCorrectly, catchesTaken: stats.catchesTaken, totalCatches: stats.totalCatches, totalThrows: stats.totalThrows)

                            session.battingStats.append(battingStat)
                            session.bowlingStats.append(bowlingStat)
                            session.fieldingStats.append(fieldingStat)
                            session.fieldingAssessStats.append(fieldingAssessStat)
                        }
                        // Add the session to the selected team's sessions array
                        data.addSession(session: session, to: selectedTeam)

                        // Reset recording stats
                        playerStats = [:]
                        isRecording = false
                    }
                }
            }
            .navigationBarTitle("Record Session")
        }
    }
}

struct PlayerStatEntryView: View {
    let player: Player
    @Binding var playerStats: [UUID: (runsScored: Int, ballsFaced: Int, oversBowled: Double, wicketsTaken: Int, catches: Int, runOuts: Int , totalTimeForThrows: Int, throwingCorrectly: Int,catchesTaken : Int, totalCatches : Int, totalThrows : Int)]

    // Computed property to access the player's stats from playerStats
    private var playerStatBinding: Binding<(runsScored: Int, ballsFaced: Int, oversBowled: Double, wicketsTaken: Int, catches: Int, runOuts: Int, totalTimeForThrows: Int, throwingCorrectly: Int,catchesTaken : Int, totalCatches : Int, totalThrows : Int )> {
        Binding(
            get: {
                self.playerStats[player.id] ?? (0, 0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0)
            },
            set: { newValue in
                self.playerStats[player.id] = newValue
            }
        )
    }

    var body: some View {
        VStack {
            Text("Player: \(player.name)")
            TextField("Runs Scored", value: playerStatBinding.runsScored, formatter: NumberFormatter())
            TextField("Balls Faced", value: playerStatBinding.ballsFaced, formatter: NumberFormatter())
            TextField("totalTimeForThrows", value: playerStatBinding.totalTimeForThrows, formatter: NumberFormatter())
            TextField("throwingCorrectly", value: playerStatBinding.throwingCorrectly, formatter: NumberFormatter())
            TextField("catchesTaken", value: playerStatBinding.catchesTaken, formatter: NumberFormatter())
            TextField("totalCatches", value: playerStatBinding.totalCatches, formatter: NumberFormatter())
            TextField("totalThrows", value: playerStatBinding.totalThrows, formatter: NumberFormatter())
            // Add fields for other stats
        }
    }
}


struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Name: \(player.name)")
            Text("Age: \(player.age)")
        }
    }
}


struct SessionRow: View {
    let session: Session
    let playerInfo: [Player] // Array of player information

//    var body: some View {
//        VStack(alignment: .leading) {
//
//
//            // Display batting stats for each player in the session
//            ForEach(session.battingStats, id: \.playerId) { battingStat in
//                Text("Player: \(playerName(for: battingStat.playerId))")
//            }
//            // Display Fielding Assessment stats for each player in the session
//            ForEach(session.fieldingAssessStats, id: \.playerId) { fieldingAssessStat in
//                Text("Player: \")
//                Text("Total Time: \")
//                Text("Total Throws \")
//                Text("Accurate Throws: \")
//                Text("Total Catches Given: \")
//                Text("Total Catches Taken: \")
//            }
//
//            // Add more sections to display bowling and fielding stats if needed
//        }
//    }
  
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(formattedDate)")
                    // Header row with column titles
                    HStack {
                        Text("Player")
                        Text("Total Time")
                        Text("Total Throws ")
                        Text("Accurate Throws")
                        Text("Total Catches Given ")
                        Text("Total Catches Taken")
                        
                        // Add more column titles for other stats
                    }
                    // Iterate through each player
                    ForEach(session.fieldingAssessStats, id: \.playerId) { fieldingAssessStat in
                                HStack {
                                    Text(playerName(for: fieldingAssessStat.playerId))
                                    Text("\(fieldingAssessStat.totalTimeForThrows)")
                                    Text("\(fieldingAssessStat.totalThrows)")
                                    Text("\(fieldingAssessStat.throwingCorrectly)")
                                    Text("\(fieldingAssessStat.totalCatches)")
                                    Text("\(fieldingAssessStat.catchesTaken)")
                                    
                                    // Add more Text views for other stats
                                }
                            }
                        }
            }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: session.date)
    }
    
    
    // Helper function to get player name for a given player ID
    private func playerName(for playerId: UUID) -> String {
        if let player = session.battingStats.first(where: { $0.playerId == playerId }),
           let playerInfo = playerInfo.first(where: { $0.id == playerId }) {
            return "\(playerInfo.name)"
        }
        return "Unknown"
    }
        }
    
    

   







 



