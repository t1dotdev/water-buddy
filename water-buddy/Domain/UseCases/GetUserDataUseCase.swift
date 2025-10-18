import Foundation

protocol GetUserDataUseCase {
    func execute() async throws -> User
    func isFirstLaunch() async throws -> Bool
}

class GetUserDataUseCaseImpl: GetUserDataUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute() async throws -> User {
        return try await userRepository.getUser()
    }

    func isFirstLaunch() async throws -> Bool {
        do {
            let user = try await userRepository.getUser()
            return user.isNewUser
        } catch {
            // If user doesn't exist, it's the first launch
            return true
        }
    }
}