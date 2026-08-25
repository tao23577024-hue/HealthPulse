import Foundation
import HealthKit

/// 健康数据存储管理器 — 封装 HealthKit 查询
/// 设计上兼容 HealthHub 库的调用模式，同时提供原生 HealthKit 实现
final class HealthStoreManager {

    // MARK: - 今日指标
    func fetchTodayMetrics(healthStore: HKHealthStore, completion: @escaping (TodayMetrics) -> Void) {
        var metrics = TodayMetrics()
        let group = DispatchGroup()

        // 心率（最新值）
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .heartRate, unit: .count().unitDivided(by: .minute())) { value in
            metrics.heartRate = value
            group.leave()
        }

        // 静息心率
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .restingHeartRate, unit: .count().unitDivided(by: .minute())) { value in
            metrics.restingHeartRate = value
            group.leave()
        }

        // HRV
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .heartRateVariabilitySDNN, unit: .secondUnit(with: .milli)) { value in
            metrics.hrv = value
            group.leave()
        }

        // 步数
        group.enter()
        fetchDailySum(healthStore: healthStore, type: .stepCount, unit: .count()) { value in
            metrics.steps = Int(value)
            group.leave()
        }

        // 活动能量
        group.enter()
        fetchDailySum(healthStore: healthStore, type: .activeEnergyBurned, unit: .kilocalorie()) { value in
            metrics.activeCalories = value
            group.leave()
        }

        // 锻炼时间
        group.enter()
        fetchDailySum(healthStore: healthStore, type: .appleExerciseTime, unit: .minute()) { value in
            metrics.exerciseMinutes = value
            group.leave()
        }

        // 站立时间
        group.enter()
        fetchDailySum(healthStore: healthStore, type: .appleStandTime, unit: .hour()) { value in
            metrics.standHours = value
            group.leave()
        }

        // 血氧
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .oxygenSaturation, unit: .percent()) { value in
            metrics.bloodOxygen = value * 100
            group.leave()
        }

        // 体重
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .bodyMass, unit: .kilogram()) { value in
            metrics.bodyWeight = value
            group.leave()
        }

        // 体脂率
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .bodyFatPercentage, unit: .percent()) { value in
            metrics.bodyFat = value * 100
            group.leave()
        }

        // VO2 Max
        group.enter()
        fetchLatestQuantity(healthStore: healthStore, type: .vo2Max, unit: HKUnit(from: "ml/kg*min")) { value in
            metrics.vo2Max = value
            group.leave()
        }

        group.notify(queue: .main) {
            completion(metrics)
        }
    }

    // MARK: - 睡眠数据
    func fetchSleepData(healthStore: HKHealthStore, completion: @escaping (SleepData) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(SleepData())
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        // 取前一天晚上到今天的数据
        let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfDay)!
        let startTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday)!

        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0,
                                   sortDescriptors: [sortDescriptor]) { _, samples, error in
            var sleepData = SleepData()
            guard let samples = samples as? [HKCategorySample], error == nil else {
                DispatchQueue.main.async { completion(sleepData) }
                return
            }

            var stages: [SleepStageSample] = []
            var totalAsleep: Double = 0
            var totalInBed: Double = 0

            for sample in samples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                let stage: SleepStage

                switch sample.value {
                case HKCategoryValueSleepAnalysis.inBed.rawValue:
                    stage = .inBed
                    totalInBed += duration
                case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                    stage = .unspecified
                    totalAsleep += duration
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    stage = .core
                    totalAsleep += duration
                    sleepData.coreMinutes += duration / 60
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    stage = .deep
                    totalAsleep += duration
                    sleepData.deepMinutes += duration / 60
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    stage = .rem
                    totalAsleep += duration
                    sleepData.remMinutes += duration / 60
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    stage = .awake
                    sleepData.awakeMinutes += duration / 60
                default:
                    stage = .unspecified
                    totalAsleep += duration
                }

                if stage != .inBed {
                    stages.append(SleepStageSample(stage: stage, startDate: sample.startDate, endDate: sample.endDate))
                }
            }

            sleepData.totalHours = totalAsleep / 3600
            sleepData.inBedMinutes = totalInBed / 60
            sleepData.stages = stages
            if totalInBed > 0 {
                sleepData.efficiency = totalAsleep / totalInBed
            }

            // 推断入睡和起床时间
            if let firstAsleep = stages.first(where: { $0.stage != .awake }) {
                sleepData.bedtime = firstAsleep.startDate
            }
            if let lastAsleep = stages.last(where: { $0.stage != .awake }) {
                sleepData.wakeTime = lastAsleep.endDate
            }

            DispatchQueue.main.async {
                completion(sleepData)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - 周历史数据
    func fetchWeeklyHistory(healthStore: HKHealthStore, completion: @escaping (WeeklyHistory) -> Void) {
        var history = WeeklyHistory()
        let group = DispatchGroup()

        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!

        // 步数历史
        group.enter()
        fetchDailySeries(healthStore: healthStore, type: .stepCount, unit: .count(),
                         start: weekStart, end: now, aggregation: .sum) { values in
            history.steps = values
            group.leave()
        }

        // 心率历史（日均）
        group.enter()
        fetchDailySeries(healthStore: healthStore, type: .heartRate,
                         unit: .count().unitDivided(by: .minute()),
                         start: weekStart, end: now, aggregation: .average) { values in
            history.heartRate = values
            group.leave()
        }

        // 睡眠历史
        group.enter()
        fetchSleepSeries(healthStore: healthStore, start: weekStart, end: now) { values in
            history.sleep = values
            group.leave()
        }

        // HRV历史
        group.enter()
        fetchDailySeries(healthStore: healthStore, type: .heartRateVariabilitySDNN,
                         unit: .secondUnit(with: .milli),
                         start: weekStart, end: now, aggregation: .average) { values in
            history.hrv = values
            group.leave()
        }

        // 卡路里历史
        group.enter()
        fetchDailySeries(healthStore: healthStore, type: .activeEnergyBurned, unit: .kilocalorie(),
                         start: weekStart, end: now, aggregation: .sum) { values in
            history.calories = values
            group.leave()
        }

        group.notify(queue: .main) {
            completion(history)
        }
    }

    // MARK: - 最近锻炼
    func fetchRecentWorkouts(healthStore: HKHealthStore, completion: @escaping ([WorkoutRecord]) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-30*24*3600), end: nil, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 20,
                                   sortDescriptors: [sortDescriptor]) { _, samples, error in
            var workouts: [WorkoutRecord] = []
            guard let samples = samples as? [HKWorkout], error == nil else {
                DispatchQueue.main.async { completion(workouts) }
                return
            }

            for workout in samples {
                let type = mapWorkoutType(workout.workoutActivityType)
                let duration = workout.duration / 60
                let calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                let distance = workout.totalDistance?.doubleValue(for: .meter())

                var avgHR: Double?
                if let hrStats = workout.statistics(for: HKObjectType.quantityType(forIdentifier: .heartRate)!) {
                    avgHR = hrStats.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
                }

                workouts.append(WorkoutRecord(
                    id: UUID(),
                    type: type,
                    startDate: workout.startDate,
                    endDate: workout.endDate,
                    durationMinutes: duration,
                    calories: calories,
                    distance: distance,
                    averageHeartRate: avgHR
                ))
            }

            DispatchQueue.main.async {
                completion(workouts)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - 私有辅助方法

    private func fetchLatestQuantity(healthStore: HKHealthStore, type: HKQuantityTypeIdentifier,
                                     unit: HKUnit, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            completion(0)
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1,
                                   sortDescriptors: [sortDescriptor]) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                completion(sample.quantity.doubleValue(for: unit))
            } else {
                completion(0)
            }
        }
        healthStore.execute(query)
    }

    private func fetchDailySum(healthStore: HKHealthStore, type: HKQuantityTypeIdentifier,
                               unit: HKUnit, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate,
                                       options: .cumulativeSum) { _, result, _ in
            if let sum = result?.sumQuantity()?.doubleValue(for: unit) {
                completion(sum)
            } else {
                completion(0)
            }
        }
        healthStore.execute(query)
    }

    private enum AggregationType {
        case sum
        case average
    }

    private func fetchDailySeries(healthStore: HKHealthStore, type: HKQuantityTypeIdentifier,
                                   unit: HKUnit, start: Date, end: Date,
                                   aggregation: AggregationType,
                                   completion: @escaping ([DailyMetric]) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            completion([])
            return
        }

        var interval = DateComponents()
        interval.day = 1

        let options: HKStatisticsOptions = aggregation == .sum ? .cumulativeSum : .discreteAverage

        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                  quantitySamplePredicate: nil,
                                                  options: options,
                                                  anchorDate: Calendar.current.startOfDay(for: start),
                                                  intervalComponents: interval)

        query.initialResultsHandler = { _, collection, _ in
            var results: [DailyMetric] = []
            collection?.enumerateStatistics(from: start, to: end) { statistics, _ in
                let value: Double
                if aggregation == .sum {
                    value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
                } else {
                    value = statistics.averageQuantity()?.doubleValue(for: unit) ?? 0
                }
                results.append(DailyMetric(date: statistics.startDate, value: value))
            }
            DispatchQueue.main.async {
                completion(results)
            }
        }

        healthStore.execute(query)
    }

    private func fetchSleepSeries(healthStore: HKHealthStore, start: Date, end: Date,
                                   completion: @escaping ([DailyMetric]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0,
                                   sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            // 按日期分组计算睡眠时长
            var dailySleep: [Date: Double] = [:]
            let calendar = Calendar.current

            for sample in samples {
                let value = sample.value
                // 只计算睡眠阶段（不含在床和清醒）
                if value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                    value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                    value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                    value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                    let day = calendar.startOfDay(for: sample.endDate)
                    let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                    dailySleep[day, default: 0] += duration
                }
            }

            var results: [DailyMetric] = []
            var current = calendar.startOfDay(for: start)
            while current <= end {
                let hours = dailySleep[current] ?? 0
                results.append(DailyMetric(date: current, value: hours))
                current = calendar.date(byAdding: .day, value: 1, to: current)!
            }

            DispatchQueue.main.async {
                completion(results)
            }
        }

        healthStore.execute(query)
    }

    private func mapWorkoutType(_ type: HKWorkoutActivityType) -> WorkoutType {
        switch type {
        case .running: return .running
        case .walking: return .walking
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .traditionalStrengthTraining, .functionalStrengthTraining: return .strengthTraining
        case .yoga: return .yoga
        case .hiking: return .hiking
        case .rowing: return .rowing
        case .stairClimbing: return .stairClimbing
        default: return .other
        }
    }
}
