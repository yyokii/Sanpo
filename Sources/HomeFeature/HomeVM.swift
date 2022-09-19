import Combine

public final class HomeVM: ObservableObject {

    @Published var stepCount: Int = 0
    let stepCountService: StepCountService

    private var cancellables = Set<AnyCancellable>()

    public init(stepCountService: StepCountService = StepCountServiceImpl()) {
        self.stepCountService = stepCountService
    }
}
