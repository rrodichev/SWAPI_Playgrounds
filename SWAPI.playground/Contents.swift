import UIKit


// MARK: - Model
struct Person: Decodable {
    let name: String
    let films: [URL]
}

struct Film: Decodable {
    let title: String
    let opening_crawl: String
    let release_date: String
}

// MARK: - Model Controller
class SwapiService {
    
    static private let baseURL = URL(string: "https://swapi.dev/api/")
    
    static func fetchPerson(id: Int, completion: @escaping (Person?) -> Void) {
        
        //step 1: prepare URL
        guard let baseURL = baseURL else { return completion(nil) }
        let personURL = baseURL.appendingPathComponent("people")
        let finalURL = personURL.appendingPathComponent("/\(id)")
        print(finalURL)
        
        // step 2: data task
        URLSession.shared.dataTask(with: finalURL) { data, response, error in
            
            // step 3: error handling
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            // step 4: get data
            guard let data = data else { return completion(nil) }
            
            // step 5: decode data
            do {
                let person = try JSONDecoder().decode(Person.self, from: data)
                return completion(person)
                
            } catch {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                return completion(nil)
            }
        }.resume()
    }
    // film fetching
    static func fetchFilm(url: URL, completion: @escaping (Film?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in

            //error handler
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            // get response status
            if let response = response as? HTTPURLResponse {
                print("STATUS CODE: \(response.statusCode)")
            }
        
            //get data
            guard let data = data else { return completion(nil) }

            //decode data
            do {
                let film = try JSONDecoder().decode(Film.self, from: data)
                return completion(film)
            } catch {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
        }.resume()
    }
    
    static func getFilm(url: URL) {
        SwapiService.fetchFilm(url: url) { film in
            if let film = film {
                print(film)
            }
        }
    }
}//End of class

SwapiService.fetchPerson(id: 10) { person in
    if let person = person {
        print(person.name)
        for film in person.films {
            SwapiService.getFilm(url: film)
        }
    }
}
