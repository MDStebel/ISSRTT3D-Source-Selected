//
//  CrewViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/24/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import Combine
import SwiftUI

@Observable
final class CrewViewModel: ObservableObject {
    
    // MARK: - Published properties
    var crews    = [Crews.People]()
    var wasError = false
    var errorForAlert: ErrorCodes?
    
    // MARK: - Properties
    private let crewAPIEndpointURLString = ApiEndpoints.crewAPIEndpoint
    private let timerValue               = 5.0
    private var cancellables             = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    // MARK: - Initializer
    init() {
        fetchData() // Fetch data once before starting the timer
        start()
    }
    
    // MARK: - Timer Methods
    func start() {
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchData()
            }
    }
    
    func stop() {
        timer?.cancel()
    }
    
    // MARK: - Data Fetching
    func fetchData() {
        guard let url = URL(string: crewAPIEndpointURLString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Crews.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: handleNewData)
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure(let error):
            wasError = true
            errorForAlert = ErrorCodes(message: "\(error.localizedDescription)")
        case .finished:
            wasError = false
        }
    }
    
    private func handleNewData(_ crews: Crews) {
        self.crews = crews.people
    }
}
