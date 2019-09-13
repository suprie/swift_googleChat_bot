import SPMUtility
import Foundation
import AsyncHTTPClient

struct ThreadCodable: Codable {
    let name: String
}

struct MessageCodable: Codable {
    let message: String
    let thread: ThreadCodable?
    
    enum CodingKeys: String, CodingKey {
        case message = "text"
        case thread
    }
}

protocol APIAdapter {
    func postChat(url: String, message: String, room: String?)
}

class AsyncHTTPAPIClient: APIAdapter {
    func postChat(url: String, message: String, room: String?) {
        do {
            guard let _url = URL(string: url) else { fatalError("Error coi \(url) bukan URL") }
            
            var thread: ThreadCodable? = nil
            if let room = room {
                thread = ThreadCodable(name: room)
            }
            
            let message = MessageCodable(message: message, thread: thread)
            let encoder = JSONEncoder()
            let bodyEncoded = try encoder.encode(message)
            
            let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
            defer {
                try? httpClient.syncShutdown()
            }
            
            var request = try HTTPClient.Request(url: _url, method: .POST)
            request.headers.add(name: "Content-Type", value: "application/json; charset=UTF-8")
            request.body = .string(String(data: bodyEncoded, encoding: .utf8)!)
            
            httpClient.execute(request: request).whenComplete { result in
                switch result {
                case .failure(let e):
                    print("test \(#line)")
                    print(e)
                case .success(let response):
                    if (response.status == .ok) {
                    }
                }
            }
        } catch(let e) {
            print("test")
            print(e.localizedDescription)
        }
        
    }
}


class URLSessionAPIClient: APIAdapter {
    func postChat(url: String, message: String, room: String?) {
        do {
            guard let _url = URL(string: url) else { fatalError("Error coi \(url) bukan URL") }
            
            var thread: ThreadCodable? = nil
            if let room = room {
                thread = ThreadCodable(name: room)
            }
            
            let message = MessageCodable(message: message, thread: thread)
            let encoder = JSONEncoder()
            let bodyEncoded = try encoder.encode(message)
            
            var urlRequest = URLRequest(url: _url)
            urlRequest.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = bodyEncoded
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                guard let data = data else { fatalError() }
                
                let jsonDecoder = JSONDecoder()
                let message = try? jsonDecoder.decode(MessageCodable.self, from: data)
                
                let  currentDirectory = FileManager.default.currentDirectoryPath
                
                let fileName = "/.room.txt"
                let fileToSave = URL(fileURLWithPath: currentDirectory + fileName)
                
                guard let roomName = message?.thread?.name else { fatalError("unable to get room name")}
                
                do {
                    print("saving to \(fileToSave.absoluteString)")
                    try roomName.write(to: fileToSave, atomically: true, encoding: .utf8)
                } catch (let exception) {
                    print(exception.localizedDescription)
                    exit(301)
                }
                
                exit(EXIT_SUCCESS)
            }.resume()
        } catch {
            print("Eh ada exception")
            exit(300)
        }
        
        dispatchMain()
    }
}

do {
    let parser = ArgumentParser(commandName: "swift-googlechat-bot", 
                                usage: "--url <Google chat webhook api> --room <Room> <Message to be sent>",
                                overview: "Send chat to google chat")
    
    var apiClient: APIAdapter = URLSessionAPIClient()
    
    
    
    let input = parser.add(option: "--url",
                           shortName: "-u",
                           kind: String.self,
                           usage: "URL Web hook api")
    
    let room = parser.add(option: "--room",
                          shortName: "-r",
                          kind: String.self,
                          usage: "Room to post")
    
    let newApi = parser.add(option: "--use-new-api",
                           shortName: "",
                           kind: Bool.self,
                           usage: "URL Web hook api")
    
    let message = parser.add(positional: "message", kind: String.self)
    
    let args = Array(CommandLine.arguments.dropFirst())
    let result = try parser.parse(args)
    
    if let useNewApi = result.get(newApi), useNewApi == true {
        apiClient = AsyncHTTPAPIClient()
    }
    
    if let url = result.get(input), let message = result.get(message) {
        print("going to post to \(url)")
        apiClient.postChat(url: url, message: message, room: result.get(room))
    } else {
        print("Koq ada kesini")
    }
    
} catch {
    print("dead end lagi")
}

