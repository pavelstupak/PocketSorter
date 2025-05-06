//
//  Log.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 25.04.2025.
//
//  Provides utility methods for logging messages with different severity levels using OSLog.
//

import OSLog

/// Utility for simplified, centralized logging across the application.
enum Log {

	/// Logs a debug-level message (useful for development and troubleshooting).
	///
	/// - Parameters:
	///   - message: The message to be logged.
	///   - logger: The specific logger instance to categorize the log.
	static func debug(_ message: String, logger: Logger) {
		logger.debug("\(message, privacy: .public)")
	}

	/// Logs an informational message (high-level runtime events).
	///
	/// - Parameters:
	///   - message: The message to be logged.
	///   - logger: The specific logger instance to categorize the log.
	static func info(_ message: String, logger: Logger) {
		logger.info("\(message, privacy: .public)")
	}

	/// Logs a warning message (unexpected situations that are not necessarily errors).
	///
	/// - Parameters:
	///   - message: The message to be logged.
	///   - logger: The specific logger instance to categorize the log.
	static func warning(_ message: String, logger: Logger) {
		logger.log(level: .default, "\(message, privacy: .public)")
	}

	/// Logs an error message (something went wrong and needs attention).
	///
	/// - Parameters:
	///   - message: The message to be logged.
	///   - logger: The specific logger instance to categorize the log.
	static func error(_ message: String, logger: Logger) {
		logger.error("\(message, privacy: .public)")
	}

	/// Logs a critical system fault (serious issues that might cause crashes or severe failures).
	///
	/// - Parameters:
	///   - message: The message to be logged.
	///   - logger: The specific logger instance to categorize the log.
	static func fault(_ message: String, logger: Logger) {
		logger.fault("\(message, privacy: .public)")
	}
}
