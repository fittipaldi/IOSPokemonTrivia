//
//  PokemonAPI.swift
//  PokemonTrivia
//
//  Created by Carlos Gustavo Fittipaldi Vasconcelos on 29/11/2024.
//

import Foundation

struct Pokemon: Codable {
    let name: String
    let url: String
    
    var pokemonID: Int? {
       guard let idString = url.split(separator: "/").last else { return nil }
       return Int(idString)
   }
}

struct PokemonResponse: Codable {
    let results: [Pokemon]
}

class PokemonAPI {
    static let shared = PokemonAPI()
    
    private let baseURL = "https://pokeapi.co/api/v2/pokemon?limit=151"
    
    func fetchAllPokemon(completion: @escaping ([Pokemon]?) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                    let response = try JSONDecoder().decode(PokemonResponse.self, from: data)
                    completion(response.results)
                } catch {
                    print("Decoding error: \(error)")
                    completion(nil)
                }
            } else {
                print("Network error: \(String(describing: error))")
                completion(nil)
            }
        }.resume()
    }
    
}
