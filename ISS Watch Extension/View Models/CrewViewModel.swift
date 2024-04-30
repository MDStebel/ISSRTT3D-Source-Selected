//
//  CrewViewModel.swift
//  ISS Watch Extension
//
//  Created by Michael Stebel on 4/24/24.
//  Copyright © 2024 ISS Real-Time Tracker, LLC. All rights reserved.
//

import SwiftUI
import Combine

class CrewViewModel: ObservableObject {
    
    // MARK: - Published properties
    
    @Published var crews    = [Crews.People]()
    @Published var wasError = false
    @Published var errorForAlert: ErrorCodes?
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let crewAPIEndpointURLString = ApiEndpoints.crewAPIEndpoint

    // MARK: - Methods
    
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
