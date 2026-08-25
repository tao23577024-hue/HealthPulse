import Foundation
import Combine
import HealthKit

/// 应用全局状态管理 — iOS 16 兼容（使用 ObservableObject 而非 @Observable 宏）
final class AppState: ObservableObject {

    // MARK: - 健康数据
    @Published var heartRate: Double = 0
    @Published var restingHeartRate: Double = 0
    @Published var heartRateVariability: Double = 0
    @Published var steps: Int = 0
    @Published var activeCalories: Double = 0
    @Published var exerciseMinutes: Double = 0
    @Published var standHours: Double = 0
    @Published var sleepHours: Double = 0
    @Published var deepSleepMinutes: Double = 0
    @Published var remSleepMinutes: Double = 0
    @Published var sleepEfficiency: Double = 0
    @Published var bloodOxygen: Double = 0
    @Published var bodyWeight: Double = 0
    @Published var bodyFatPercentage: Double = 0
    @Published var vo2Max: Double = 0

    // MARK: - 历史数据（用于图表）
    @Published var weeklySteps: [DailyMetric] = []
    @Published var weeklyHeartRate: [DailyMetric] = []
    @Published var weeklySleep: [DailyMetric] = []
    @Published var weeklyHRV: [DailyMetric] = []
    @Published var weeklyCalories: [DailyMetric] = []

    // MARK: - 锻炼记录
    @Published var recentWorkouts: [WorkoutRecord] = []

    // MARK: - 睡眠阶段
    @Published var sleepStages: [SleepStageSample] = []

    // MARK: - 洞察
    @Published var insights: [HealthInsight] = []

    // MARK: - 状态
    @Published var isLoading = false
    @Published var hasHealthKitAccess = false
    @Published var lastUpdated: Date?
    @Published var showDemoData = false

    // MARK: - 用户记录（本地存储）
    @Published var medications: [Medication] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var moodEntries: [MoodEntry] = []

    // MARK: - 设置
    @Published var dailyStepGoal: Int = 10000
    @Published var dailyCalorieGoal: Double = 500
    @Published var sleepGoalHours: Double = 8.0
    @Published var useMetricUnits = true

    let healthStore = HKHealthStore()
    private let healthManager = HealthStoreManager()
    private let insightsEngine = InsightsEngine()
    private let notificationManager = NotificationManager()

    // 要读取的健康数据类型
    private var readTypes: Set<HKObjectType> {
        Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ])
    }

    // 要写入的健康数据类型
    private var shareTypes: Set<HKSampleType> {
        Set([
            HKObjectType.workoutType(),
        ])
    }

    init() {
        loadLocalData()
        loadDemoDataIfNeeded()
    }

    // MARK: - HealthKit 授权
    func requestHealthKitAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            showDemoData = true
            completion(false)
            return
        }

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.hasHealthKitAccess = success
                if success {
                    self?.fetchAllHealthData()
                } else {
                    self?.showDemoData = true
                }
                completion(success)
            }
        }
    }

    // MARK: - 拉取所有健康数据
    func fetchAllHealthData() {
        isLoading = true

        let group = DispatchGroup()

        group.enter()
        healthManager.fetchTodayMetrics(healthStore: healthStore) { [weak self] metrics in
            DispatchQueue.main.async {
                self?.heartRate = metrics.heartRate
                self?.restingHeartRate = metrics.restingHeartRate
                self?.heartRateVariability = metrics.hrv
                self?.steps = metrics.steps
                self?.activeCalories = metrics.activeCalories
                self?.exerciseMinutes = metrics.exerciseMinutes
                self?.standHours = metrics.standHours
                self?.bloodOxygen = metrics.bloodOxygen
                self?.bodyWeight = metrics.bodyWeight
                self?.bodyFatPercentage = metrics.bodyFat
                self?.vo2Max = metrics.vo2Max
                group.leave()
            }
        }

        group.enter()
        healthManager.fetchSleepData(healthStore: healthStore) { [weak self] sleep in
            DispatchQueue.main.async {
                self?.sleepHours = sleep.totalHours
                self?.deepSleepMinutes = sleep.deepMinutes
                self?.remSleepMinutes = sleep.remMinutes
                self?.sleepEfficiency = sleep.efficiency
                self?.sleepStages = sleep.stages
                group.leave()
            }
        }

        group.enter()
        healthManager.fetchWeeklyHistory(healthStore: healthStore) { [weak self] history in
            DispatchQueue.main.async {
                self?.weeklySteps = history.steps
                self?.weeklyHeartRate = history.heartRate
                self?.weeklySleep = history.sleep
                self?.weeklyHRV = history.hrv
                self?.weeklyCalories = history.calories
                group.leave()
            }
        }

        group.enter()
        healthManager.fetchRecentWorkouts(healthStore: healthStore) { [weak self] workouts in
            DispatchQueue.main.async {
                self?.recentWorkouts = workouts
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.lastUpdated = Date()
            self?.generateInsights()
        }
    }

    // MARK: - 洞察生成
    private func generateInsights() {
        insights = insightsEngine.generateInsights(
            heartRate: heartRate,
            restingHeartRate: restingHeartRate,
            hrv: heartRateVariability,
            steps: steps,
            stepGoal: dailyStepGoal,
            sleepHours: sleepHours,
            sleepGoal: sleepGoalHours,
            deepSleepMinutes: deepSleepMinutes,
            sleepEfficiency: sleepEfficiency,
            activeCalories: activeCalories,
            exerciseMinutes: exerciseMinutes,
            weeklySteps: weeklySteps,
            weeklyHeartRate: weeklyHeartRate,
            weeklySleep: weeklySleep,
            weeklyHRV: weeklyHRV
        )
    }

    // MARK: - 本地数据持久化
    private func loadLocalData() {
        let defaults = UserDefaults.standard

        if let goal = defaults.value(forKey: "dailyStepGoal") as? Int {
            dailyStepGoal = goal
        }
        if let calorieGoal = defaults.value(forKey: "dailyCalorieGoal") as? Double {
            dailyCalorieGoal = calorieGoal
        }
        if let sleepGoal = defaults.value(forKey: "sleepGoalHours") as? Double {
            sleepGoalHours = sleepGoal
        }

        // 加载用药、日志、心情
        if let medsData = defaults.data(forKey: "medications"),
           let meds = try? JSONDecoder().decode([Medication].self, from: medsData) {
            medications = meds
        }
        if let journalData = defaults.data(forKey: "journalEntries"),
           let entries = try? JSONDecoder().decode([JournalEntry].self, from: journalData) {
            journalEntries = entries
        }
        if let moodData = defaults.data(forKey: "moodEntries"),
           let moods = try? JSONDecoder().decode([MoodEntry].self, from: moodData) {
            moodEntries = moods
        }
    }

    func saveLocalData() {
        let defaults = UserDefaults.standard
        defaults.set(dailyStepGoal, forKey: "dailyStepGoal")
        defaults.set(dailyCalorieGoal, forKey: "dailyCalorieGoal")
        defaults.set(sleepGoalHours, forKey: "sleepGoalHours")

        if let medsData = try? JSONEncoder().encode(medications) {
            defaults.set(medsData, forKey: "medications")
        }
        if let journalData = try? JSONEncoder().encode(journalEntries) {
            defaults.set(journalData, forKey: "journalEntries")
        }
        if let moodData = try? JSONEncoder().encode(moodEntries) {
            defaults.set(moodData, forKey: "moodEntries")
        }
    }

    // MARK: - 演示数据
    private func loadDemoDataIfNeeded() {
        #if DEBUG
        showDemoData = true
        loadPreviewData()
        #endif
    }

    func loadPreviewData() {
        let preview = PreviewData.shared
        heartRate = preview.heartRate
        restingHeartRate = preview.restingHeartRate
        heartRateVariability = preview.hrv
        steps = preview.steps
        activeCalories = preview.activeCalories
        exerciseMinutes = preview.exerciseMinutes
        standHours = preview.standHours
        sleepHours = preview.sleepHours
        deepSleepMinutes = preview.deepSleepMinutes
        remSleepMinutes = preview.remSleepMinutes
        sleepEfficiency = preview.sleepEfficiency
        bloodOxygen = preview.bloodOxygen
        bodyWeight = preview.bodyWeight
        bodyFatPercentage = preview.bodyFat
        vo2Max = preview.vo2Max
        weeklySteps = preview.weeklySteps
        weeklyHeartRate = preview.weeklyHeartRate
        weeklySleep = preview.weeklySleep
        weeklyHRV = preview.weeklyHRV
        weeklyCalories = preview.weeklyCalories
        recentWorkouts = preview.recentWorkouts
        sleepStages = preview.sleepStages
        medications = preview.medications
        journalEntries = preview.journalEntries
        moodEntries = preview.moodEntries
        generateInsights()
    }

    // MARK: - 用药管理
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveLocalData()
    }

    func removeMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
        saveLocalData()
    }

    // MARK: - 日志管理
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
        saveLocalData()
    }

    func removeJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveLocalData()
    }

    // MARK: - 心情管理
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.insert(entry, at: 0)
        saveLocalData()
    }

    // MARK: - 通知
    func scheduleMedicationReminders() {
        notificationManager.scheduleMedicationReminders(medications)
    }

    func requestNotificationPermissions() {
        notificationManager.requestPermissions()
    }
}
