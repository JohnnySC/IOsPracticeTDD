//
//  IOsPracticeTDDTests.swift
//  IOsPracticeTDDTests
//
//  Created by Hovhannes on 27.11.2024.
//

import XCTest
@testable import IOsPracticeTDD

final class Task007ViewmModelTest: XCTestCase {

    private var repository: FakeSimpleRepository!
    private var viewModel: SimpleViewModel!
    
    override func setUpWithError() throws {
        repository = FakeSimpleRepositoryImpl()
        viewModel = SimpleViewModel(repository: repository)
    }
    
    func testViewModelSuccess() throws {
        XCTAssertEqual(UiState(isLoadingNow: false, loadedData: "", isError: false), viewModel.uiState)
        
        viewModel.getData()
        
        XCTAssertEqual(UiState(isLoadingNow: true, loadedData: "", isError: false), viewModel.uiState)
        
        let expectation = expectation(description: "State should update")
        Task.detached {
            await MainActor.run {
                XCTAssertEqual(UiState(isLoadingNow: false, loadedData: "mock data", isError: false), self.viewModel.uiState)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func testViewModelError() throws {
        repository.expectError()
        XCTAssertEqual(UiState(isLoadingNow: false, loadedData: "", isError: false), viewModel.uiState)
        
        viewModel.getData()
        
        XCTAssertEqual(UiState(isLoadingNow: true, loadedData: "", isError: false), viewModel.uiState)
        
        let expectation = expectation(description: "State should update")
        Task.detached {
            await MainActor.run {
                XCTAssertEqual(UiState(isLoadingNow: false, loadedData: "", isError: true), self.viewModel.uiState)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}

private protocol FakeSimpleRepository : SimpleRepository {
    
    func expectError()
}

private class FakeSimpleRepositoryImpl : FakeSimpleRepository {
    
    private var shouldThrowError = false
    
    func expectError() {
        shouldThrowError = true
    }
    
    func loadData() async throws -> String {
        if shouldThrowError {
            throw SimpleError()
        } else {
            return "mock data"
        }
    }
}

private class SimpleError : Error {
}
