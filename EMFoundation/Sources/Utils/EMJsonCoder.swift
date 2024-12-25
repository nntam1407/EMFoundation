//
//  EMJsonCoder.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 25/12/24.
//
import Foundation

public struct EMJsonCoder: Sendable {
    public let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    public let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    public let dataDecodingStrategy: JSONDecoder.DataDecodingStrategy

    public let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
    public let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
    public let dataEncodingStrategy: JSONEncoder.DataEncodingStrategy

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy

        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        encoder.outputFormatting = .prettyPrinted

        return encoder
    }

    public init(
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .millisecondsSince1970,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .millisecondsSince1970,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64
    ) {
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy

        self.keyEncodingStrategy = keyEncodingStrategy
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
    }
}

public extension EMJsonCoder {
    func decode<T>(fromJsonData jsonData: Data) throws(DecodingError) -> T where T: Decodable {
        do {
            return try decoder.decode(T.self, from: jsonData)
        }
        catch let error as DecodingError {
            throw error
        }
        catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Json format!"))
        }
    }

    func decode<T>(fromJsonData jsonData: Data) -> T? where T: Decodable {
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            return nil
        }
    }

    func decode<T>(fromJsonString jsonString: String) throws(DecodingError) -> T where T: Decodable {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Json format!"))
        }

        return try decode(fromJsonData: jsonData)
    }

    func decode<T>(fromJsonString jsonString: String) -> T? where T: Decodable {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            print("JsonMapper decoded failed: %@", error.localizedDescription)
            return nil
        }
    }
}

public extension EMJsonCoder {
    func encode<T>(value: T) throws(EncodingError) -> Data where T: Encodable {
        do {
            return try encoder.encode(value)
        }
        catch let error as EncodingError {
            throw error
        }
        catch {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Invalid json format!"))
        }
    }

    func encode<T>(value: T) -> Data? where T: Encodable {
        try? encoder.encode(value)
    }

    func encode<T>(value: T) throws(EncodingError) -> String where T: Encodable {
        let encodedData: Data = try encode(value: value)

        guard let jsonString = String(data: encodedData, encoding: .utf8) else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Invalid json format!"))
        }

        return jsonString
    }

    func encode<T>(value: T) -> String? where T: Encodable {
        guard let encodedData = try? encoder.encode(value),
                let jsonString = String(data: encodedData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }
}
