import Foundation

public enum UserDefaultsSuitName: String {
    case app = "group.com.yyokii.sanpo"
}

public enum UserDefaultsKey: String {
    // 一日の目標値
    case dailyTargetActiveEnergyBurned
    case dailyTargetSteps
    
    case displayedStepCountDataInWidget
}
