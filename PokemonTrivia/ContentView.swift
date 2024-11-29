//
//  PokemonGame.swift
//  PokemonTrivia
//
//  Created by Carlos Gustavo Fittipaldi Vasconcelos on 29/11/2024.
//


import SwiftUI

struct ContentView: View {
    @State private var pokemonList: [Pokemon] = []
    @State private var question: String = ""
    @State private var options: [String] = []
    @State private var correctAnswer: String = ""
    @State private var questionAnswer: String = ""
    @State private var questionAnswerColor: Color = .gray
    @State private var imageURL: String = ""
    @State private var activeAnswer: Bool = true
    @State private var showAlert: Bool = false
    @State private var score: Int = 0
    @State private var gamerCounter: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Pokémon Trivia")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(gamerCounter)/\(score)")
                .font(.title3)
                .foregroundColor(.brown)
                .multilineTextAlignment(.center)
            
            if let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    } else if phase.error != nil {
                        Text("Image failed to load")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
            }
            
            Text(question)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text(questionAnswer)
                .font(.title2)
                .foregroundColor(questionAnswerColor)
                .multilineTextAlignment(.center)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    checkAnswer(option)
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
        }
        .padding()
        .onAppear(perform: loadTrivia)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Alert"),
                message: Text("Wait until load the new question!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func loadTrivia() {
        PokemonAPI.shared.fetchAllPokemon { pokemons in
            if let pkms = pokemons {
                DispatchQueue.main.async {
                    self.pokemonList = pkms
                    generateQuestion()
                }
            }
        }
    }
    
    private func generatePokemonImageURL(for id: Int) -> String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
    }

    private func generateQuestion() {
        activeAnswer = true
        questionAnswer = ""
        showAlert = false
        guard pokemonList.count >= 4 else { return }
        let shuffled = pokemonList.shuffled()
        let selectedPokemon = shuffled.first!
        correctAnswer = selectedPokemon.name
        question = "Which Pokémon is this?"

        var possibleOptions = shuffled.prefix(4).map { $0.name }
        if !possibleOptions.contains(correctAnswer) {
            possibleOptions[0] = correctAnswer
        }
        options = possibleOptions.shuffled()
  
        if let id = selectedPokemon.pokemonID {
           imageURL = generatePokemonImageURL(for: id)
        }
        
    }

    private func checkAnswer(_ selected: String) {
        if activeAnswer {
            gamerCounter += 1
            activeAnswer = false
            if selected == correctAnswer {
                score += 1
                questionAnswer = "Correct!"
                questionAnswerColor = .green
            } else {
                questionAnswer = "Incorrect!\nThe correct answer is \(correctAnswer)"
                questionAnswerColor = .red
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                generateQuestion()
            }
        } else {
            showAlert = true
        }
    }
}

