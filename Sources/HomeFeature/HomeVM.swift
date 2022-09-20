import Combine
import Dispatch

public final class HomeVM: ObservableObject {

    @Published var stepCount: Int = 0
    let stepCountService: StepCountService

    private var cancellables = Set<AnyCancellable>()

    public init(stepCountService: StepCountService = StepCountServiceImpl()) {
        self.stepCountService = stepCountService

        self.stepCountService.stepCountPublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stepCount in
                self?.stepCount = stepCount ?? 0
            }
            .store(in: &cancellables)
    }
}
