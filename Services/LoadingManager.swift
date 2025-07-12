import Foundation
import Combine

class LoadingManager: ObservableObject {
    @Published var isLoading: Bool = false
    private var loaderWorkItem: DispatchWorkItem?

    func showLoader(after delay: TimeInterval = 0.4) {
        loaderWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.isLoading = true
        }
        loaderWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    func hideLoader() {
        loaderWorkItem?.cancel()
        isLoading = false
    }
} 