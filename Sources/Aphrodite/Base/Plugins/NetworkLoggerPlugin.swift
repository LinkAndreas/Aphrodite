//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public final class NetworkLoggerPlugin: NetworkPlugin {
    private enum Constants { // swiftlint:disable:this nesting
        static let separator: String = ", "
        static let terminator: String = "\n"
        static let loggerId: String = "LS-Network"
    }

    private enum Context: String { // swiftlint:disable:this nesting
        case request = "⬆️"
        case response = "⬇️"
    }

    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd.MM.yyyy', 'HH:mm:ss"
        return formatter
    }()
    private let outputQueue: DispatchQueue = .init(label: "network.output.queue")
    private var date: String {
        return dateFormatter.string(from: .init())
    }

    public init() { /* Public Initializer */ }

    public func willSend(_ request: URLRequest, target: NetworkTarget) {
        output(logNetworkRequest(request as URLRequest?))
    }

    public func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) {
        if case .success(let response) = result {
            output(logNetworkResponse(response.httpUrlResponse, data: response.data, target: target))
        } else {
            output(logNetworkResponse(nil, data: nil, target: target))
        }
    }

    private func output(_ message: String) -> Void {
        outputQueue.async {
            print(message) // swiftlint:disable:this swiftybeaver_logging
        }
    }
}

extension NetworkLoggerPlugin {
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

    private func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: NetworkTarget) -> String {
        let output: [String] = {
            guard let response = response else {
                return ["Response: Received empty network response for \(target)."]
            }

            var result: [String] = []
            result += ["Response: \(response.description)"]
            format(data: data).flatMap { result += ["Body: \($0)"] }

            return result
        }()

        return format(context: .response, body: output.joined(separator: "\n"))
    }

    private func format(context: Context, body: String) -> String {
        let header: String = "[\(date)] \(Constants.loggerId): \(context.rawValue)"
        return "\(header)\n\(body)\n"
    }

    private func format(jsonObject: Any) -> String? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let prettyPrintedString = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }

        return prettyPrintedString
    }

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
