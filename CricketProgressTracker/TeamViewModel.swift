////
////  TeamViewModel.swift
////  CricketProgressTracker
////
////  Created by Ankit Bharatiya on 9/21/23.
////
//
//import Foundation
//import SwiftUI
//
//// Team ViewModel
//class TeamViewModel: ObservableObject {
//    @Published var teams: [Team] = []
//    @Published var currentTeam: Team? = nil // Initialize with nil
//    
//    func createTeam(name: String, description: String) {
//        let newTeam = Team(name: name, description: description, players: [])
//        teams.append(newTeam)
//        currentTeam = newTeam
//    }
//    
//    func savePlayer(name: String, age: String, skillLevel: String) {
//        guard let team = currentTeam else { return }
//        let newPlayer = Player(name: name, age: age, skillLevel: skillLevel)
//        teams[teams.firstIndex(where: { $0.id == team.id })!].players.append(newPlayer)
//    }
//}
