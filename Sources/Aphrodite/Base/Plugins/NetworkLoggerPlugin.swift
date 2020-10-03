//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// A network plugin for logging network traffic
public final class NetworkLoggerPlugin: NetworkPlugin {
    /// The context of the message, i.e., whether it is associated with a request or a response
    private enum MessageContext: String { // swiftlint:disable:this nesting
        /// A message context associated with requests
        case request = "⬆️"
        /// A message context associated with a response
        case response = "⬇️"
    }

    /// The date formatter used to format timestamps
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd.MM.yyyy', 'HH:mm:ss"
        return formatter
    }()

    /// A human readable description of the present moment
    private var formattedTimestamp: String {
        return dateFormatter.string(from: .init())
    }

    /// The dispatch queue that handles all output logs
    private let outputQueue: DispatchQueue = .init(label: "network.output.queue")
    /// The name of the logger
    private let name: String

    /**
     Initializes a network logger with the given name

     - Parameter name: The name of the network logger
     - Returns: A network logger plugin with the given name.
     */
    public init(name: String) {
        self.name = name
    }

    /**
     Notifies the network plugin right before the network request is sent.

     - Parameters:
        - request: The `URLRequest` that will be sent.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    public func willSend(_ request: URLRequest, target: NetworkTarget) {
        output(logNetworkRequest(request as URLRequest?))
    }

    /**
     Notifies the network plugin that a network response was received.

     - Parameters:
        - result: The `result` of the call including the `NetworkResponse` if the request succeeded or an `AphroditeError` if it failed.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    public func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) {
        switch result {
        case let .success(response):
            output(logNetworkResponse(response, target: target))

        case let .failure(error):
            output("Response: Error occured \(error) when receiving response for \(target).")
        }
    }
}

/// The extensions of the `NetworkLoggerPlugin`
extension NetworkLoggerPlugin {
    /**
     Outputs a given message to the console

     Messages are put into a serial dispatch queue asynchronously.

     - Parameter message: The message to ouput to the console
     */
    private func output(_ message: String) -> Void {
        outputQueue.async {
            print(message) // swiftlint:disable:this swiftybeaver_logging
        }
    }

    /**
     Generates a human readable description for the given `URLRequest`

     - Parameter request: The `URLRequest` that is turned into a textual representaton
     - Returns: The human readable description for the given `URLRequest`
     */
    private func logNetworkRequest(_ request: URLRequest?) -> String {
        var output: [String] = []

        output += ["Request: \(request?.description ?? "(invalid request)")"]

        if let httpMethod = request?.httpMethod {
            output += ["HTTP-Method: \(httpMethod)"]
        }

        if let headers = request?.allHTTPHeaderFields {
            output += ["Headers: \(format(jsonObject: headers) ?? headers.debugDescription)"]
        }

        if let bodyStream = request?.httpBodyStream {
            output += ["Body-Stream: \(bodyStream.description)"]
        }

        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8) {
            output += ["Body: \(stringOutput)"]
        }

        return format(context: .request, body: output.joined(separator: "\n"))
    }

    /**
     Generates a human readable description for the given `NetworkResponse` and `NetworkTarget`

     - Parameters:
      - response: The `NetworkResponse` that is used for the resulting textual representation.
      - target: The `NetworkTarget` that is used for the resulting textual representation.
     - Returns: The human readable description for the given network response and target
     */
    private func logNetworkResponse(_ response: NetworkResponse, target: NetworkTarget) -> String {
        let output: [String] = {
            var result: [String] = []
            result += ["Response: \(response.httpUrlResponse.description)"]
            format(data: response.data).flatMap { result += ["Body: \($0)"] }
            
            return result
        }()

        return format(context: .response, body: output.joined(separator: "\n"))
    }

    /**
     Formats a given message including it's context, the logger's name as well as a timestamp.
     */
    private func format(context: MessageContext, body: String) -> String {
        let header: String = "[\(formattedTimestamp)] \(name): \(context.rawValue)"
        return "\(header)\n\(body)\n"
    }

    /**
     Formats the given JSON object as string representation

     - Parameter jsonObject: The JSON object to be formatted as string
     - Returns: The formatted JSON object as string representation
     */
    private func format(jsonObject: Any) -> String? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let prettyPrintedString = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }

        return prettyPrintedString
    }

    /**
     Formats the given data as JSON or string representation if possible

     - Parameter data: The data to be formatted
     - Returns: The formatted data as JSON or String representation
     */
    private func format(data: Data?) -> String? {
        guard let data = data else { return nil }

        if
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let prettyPrintedString = format(jsonObject: jsonObject)
        {
            return prettyPrintedString
        } else if let stringData = String(data: data, encoding: String.Encoding.utf8) {
            return stringData
        }

        return nil
    }
}
