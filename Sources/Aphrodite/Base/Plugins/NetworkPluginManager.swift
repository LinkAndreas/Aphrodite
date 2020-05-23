//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final class NetworkPluginManager: NetworkPlugin {
    struct Task {
        var type: NetworkPluginType
        var plugin: NetworkPlugin
    }

    private let tasks: [Task]
    private var cancellables: Set<AnyCancellable> = .init()

    init(plugins: [NetworkPluginType: [NetworkPlugin]]) {
        var tasks: [Task] = []
        for (type, plugins) in plugins {
            tasks.append(contentsOf: plugins.map ({ Task(type: type, plugin: $0) }))
        }

        self.tasks = tasks
    }

    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never> {
        return Future<URLRequest, Never> { resolve in
            self.executeNextTaskIfNeeded(request: request, target: target, tasks: self.tasks) { request in
                resolve(.success(request))
            }
        }.eraseToAnyPublisher()
    }

    func willSend(_ request: URLRequest, target: NetworkTarget) {
        tasks.forEach { task in
            guard target.usedPlugins.contains(task.type) else { return }

            task.plugin.willSend(request, target: target)
        }
    }

    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) {
        tasks.forEach { task in
            guard target.usedPlugins.contains(task.type) else { return }

            task.plugin.didReceive(result, target: target)
        }
    }
}

extension NetworkPluginManager {
    private func executeNextTaskIfNeeded(
        request: URLRequest,
        target: NetworkTarget,
        tasks: [Task],
        completion: @escaping (URLRequest) -> Void
    ) {
        guard let nextTask = tasks.first else {
            completion(request)
            return
        }

        nextTask.plugin.prepare(request, target: target).sink { [unowned self] request in
            let remainingTasks: [Task] = [Task](tasks.dropFirst())
            self.runNextTaskIfNeeded(request: request, target: target, tasks: remainingTasks, completion: completion)
        }.store(in: &cancellables)
    }
}
