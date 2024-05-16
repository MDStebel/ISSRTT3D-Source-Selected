//
//  CrewViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/24/24.
//  Copyright © 2024 ISS Real-Time Tracker. All rights reserved.
//

import SwiftUI
import Combine

@Observable
final class CrewViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    var crews                            = [Crews.People]()
    var wasError                         = false
    var errorForAlert: ErrorCodes?
    
    // MARK: - Properties
    
    private let crewAPIEndpointURLString = ApiEndpoints.crewAPIEndpoint
    private let timerValue               = 5.0
    private var cancellables             = Set<AnyCancellable>()
    private var timer: AnyCancellable?

    // MARK: - Methods
    
    init() {
        fetchData()                      // Update the globe once before starting the timer
        start()
    }
    
    /// Set up and start the timer
    func start() {
        timer = Timer
            .publish(every: timerValue, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.fetchData()
            }
    }
     
    /// Stop the timer
    func stop() {
        timer?.cancel()
    }
    
    /// Get crew data using Combine pipeline
    func fetchData() {
        guard let url = URL(string: crewAPIEndpointURLString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { (data: Data, response: URLResponse) in
                data
            }
            .decode(type: Crews.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.wasError      = true
                    self?.errorForAlert = ErrorCodes(message: "\(error.localizedDescription)")
                } else {
                    self?.wasError      = false
                }
            }, receiveValue: { [weak self] crews in
                self?.crews = crews.people
            })
            .store(in: &cancellables)
    }
}
