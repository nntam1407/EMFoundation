//
//  EMSerialTaskQueue.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 12/7/25.
//
import Foundation

/// Although actors serialize access to their internal state, they are reentrant — meaning if an `await` happens inside an actor method,
/// the actor can suspend and allow the next task to start before the current one finishes. This breaks strict serial execution which we don't expect.
///
/// Using the task-chaining technique to ensure each task waits for the previous one to complete entirely.
/// Approach:
/// Each new task will wait for the current `lastTask` to finish,
/// and then it becomes the new `lastTask` for subsequent tasks.
public actor EMSerialTaskQueue {
    private var lastTask: Task<Void, Never>?

    public init() { }

    @discardableResult
    public func enqueue<T: Sendable>(_ block: @escaping @Sendable () async throws -> T) async throws -> T {
        let previousTask = lastTask

        let currentTask = Task { () throws -> T in
            await previousTask?.value
            return try await block()
        }

        lastTask = Task {
            _ = try? await currentTask.value
        }

        return try await currentTask.value
    }

    @discardableResult
    public func enqueue<T: Sendable>(_ block: @escaping @Sendable () async -> T) async -> T {
        let previousTask = lastTask

        let currentTask = Task {
            await previousTask?.value
            return await block()
        }

        lastTask = Task {
            _ = await currentTask.value
        }

        return await currentTask.value
    }

    @discardableResult
    public func enqueue<T: Sendable>(_ task: Task<T, Error>) async throws -> T {
        let previousTask = lastTask

        let wrapped = Task { () throws -> T in
            await previousTask?.value
            return try await task.value
        }

        lastTask = Task {
            _ = try? await wrapped.value
        }

        return try await wrapped.value
    }

    @discardableResult
    public func enqueue<T: Sendable>(_ task: Task<T, Never>) async -> T {
        let previousTask = lastTask

        let wrapped = Task {
            await previousTask?.value
            return await task.value
        }

        lastTask = Task {
            _ = await wrapped.value
        }

        return await wrapped.value
    }
}
