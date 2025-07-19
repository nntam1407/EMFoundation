//
//  EMReadWriteTaskQueue.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 18/7/25.
//
import Foundation

/// A task queue that allows:
/// - Multiple concurrent reads when no writes are running.
/// - Exclusive access for writes.
public actor EMReadWriteTaskQueue {
    /// Number of currently running read tasks
    private var activeReaderCount = 0

    /// Indicates whether a write task is currently executing
    private var isWriting = false

    /// Queue for suspended read continuations
    private var readerQueue: [CheckedContinuation<Void, Error>] = []

    /// Queue for suspended write continuations
    private var writerQueue: [CheckedContinuation<Void, Error>] = []

    // MARK: - Public Methods

    public init() { }

    /// Executes a read block with shared access.
    /// - Allows concurrent reads as long as no write is in progress or waiting.
    public func read<T: Sendable>(_ block: @Sendable @escaping () async throws -> T) async throws -> T {
        try await waitForReadAccess()

        activeReaderCount += 1
        defer {
            activeReaderCount -= 1
            if activeReaderCount == 0 {
                // No more reading tasks, try to resume writers
                resumeNextWriterIfAvailable()
            }
        }

        return try await block()
    }

    /// Read with a non-throwing block
    public func read<T: Sendable>(_ block: @Sendable @escaping () async -> T) async -> T {
        try? await waitForReadAccess()

        activeReaderCount += 1
        defer {
            activeReaderCount -= 1
            if activeReaderCount == 0 {
                resumeNextWriterIfAvailable()
            }
        }
        return await block()
    }

    /// Executes a write block with exclusive access.
    /// - Waits until all reads and other writes are complete.
    public func write<T: Sendable>(_ block: @Sendable @escaping () async throws -> T) async throws -> T {
        try await waitForWriteAccess()

        isWriting = true
        defer {
            isWriting = false
            resumeNextWriterOrReaders()
        }

        return try await block()
    }

    /// Write with a non-throwing block
    public func write<T: Sendable>(_ block: @Sendable @escaping () async -> T) async -> T {
        try? await waitForWriteAccess()

        isWriting = true
        defer {
            isWriting = false
            resumeNextWriterOrReaders()
        }

        return await block()
    }

    // MARK: - Private Helpers

    private func waitForReadAccess() async throws {
        if isWriting || !writerQueue.isEmpty {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                readerQueue.append(continuation)
            }
        }
    }

    private func waitForWriteAccess() async throws {
        if isWriting || activeReaderCount > 0 {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                writerQueue.append(continuation)
            }
        }
    }

    /// Resumes the next writer in queue if no readers are active,
    /// otherwise resumes any pending readers.
    private func resumeNextWriterOrReaders() {
        if !writerQueue.isEmpty, activeReaderCount == 0 {
            resumeNextWriterIfAvailable()
        } else {
            resumeAllReaders()
        }
    }

    /// Resumes the next writer if available
    private func resumeNextWriterIfAvailable() {
        guard let nextWriter = writerQueue.first else { return }

        writerQueue.removeFirst()
        nextWriter.resume()
    }

    /// Resumes all suspended readers
    private func resumeAllReaders() {
        let queuedReaders = readerQueue
        readerQueue.removeAll()
        for continuation in queuedReaders {
            continuation.resume()
        }
    }
}
