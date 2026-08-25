import SwiftUI

/// 健康数据列表页 — 按类别展示所有健康指标
struct HealthDataView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMetric: MetricType?

    enum MetricType: String, CaseIterable, Identifiable {
        case heartRate = "心率"
        case restingHeartRate = "静息心率"
        case hrv = "心率变异性"
        case bloodOxygen = "血氧"
        case steps = "步数"
        case activeCalories = "活动能量"
        case exerciseMinutes = "锻炼时间"
        case standHours = "站立"
        case sleep = "睡眠"
        case bodyWeight = "体重"
        case bodyFat = "体脂率"
        case vo2Max = "心肺适能"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .heartRate: return "heart.fill"
            case .restingHeartRate: return "heart.circle.fill"
            case .hrv: return "waveform.path.ecg"
            case .bloodOxygen: return "drop.fill"
            case .steps: return "figure.run"
            case .activeCalories: return "flame.fill"
            case .exerciseMinutes: return "clock.fill"
            case .standHours: return "figure.stand"
            case .sleep: return "bed.double.fill"
            case .bodyWeight: return "scalemass.fill"
            case .bodyFat: return "percent"
            case .vo2Max: return "lungs.fill"
            }
        }

        var color: Color {
            switch self {
            case .heartRate, .restingHeartRate: return .hpRed
            case .hrv: return .hpPurple
            case .bloodOxygen: return .hpBlue
            case .steps: return .hpGreen
            case .activeCalories: return .hpOrange
            case .exerciseMinutes: return .hpTeal
            case .standHours: return .hpBlue
            case .sleep: return .hpIndigo
            case .bodyWeight: return .hpTeal
            case .bodyFat: return .hpPink
            case .vo2Max: return .hpGreen
            }
        }
    }

    // 按类别分组
    private let categories: [(String, [MetricType])] = [
        ("心脏", [.heartRate, .restingHeartRate, .hrv, .bloodOxygen, .vo2Max]),
        ("活动", [.steps, .activeCalories, .exerciseMinutes, .standHours]),
        ("身体", [.sleep, .bodyWeight, .bodyFat])
    ]

    var body: some View {
        List {
            ForEach(categories, id: \.0) { category in
                Section(header: Text(category.0)) {
                    ForEach(category.1) { metric in
                        Button {
                            selectedMetric = metric
                        } label: {
                            metricRow(for: metric)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section {
                VStack(alignment: .center, spacing: 4) {
                    Text("数据来源")
                        .font(.hpCaption)
                        .foregroundStyle(.hpSecondaryLabel)
                    Text("Apple Health / HealthKit")
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("健康数据")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedMetric) { metric in
            MetricDetailView(metricType: metric)
                .environmentObject(appState)
        }
    }

    private func metricRow(for metric: MetricType) -> some View {
        HealthMetricRow(
            icon: metric.icon,
            iconColor: metric.color,
            title: metric.rawValue,
            value: value(for: metric),
            unit: unit(for: metric),
            subtitle: subtitle(for: metric)
        )
    }

    private func value(for metric: MetricType) -> String {
        switch metric {
        case .heartRate: return "\(Int(appState.heartRate))"
        case .restingHeartRate: return "\(Int(appState.restingHeartRate))"
        case .hrv: return "\(Int(appState.heartRateVariability))"
        case .bloodOxygen: return appState.bloodOxygen > 0 ? "\(Int(appState.bloodOxygen))" : "--"
        case .steps: return appState.steps.withComma
        case .activeCalories: return "\(Int(appState.activeCalories))"
        case .exerciseMinutes: return "\(Int(appState.exerciseMinutes))"
        case .standHours: return "\(Int(appState.standHours))"
        case .sleep: return appState.sleepHours.asOneDecimalString
        case .bodyWeight: return appState.bodyWeight > 0 ? appState.bodyWeight.asOneDecimalString : "--"
        case .bodyFat: return appState.bodyFatPercentage > 0 ? appState.bodyFatPercentage.asOneDecimalString : "--"
        case .vo2Max: return appState.vo2Max > 0 ? appState.vo2Max.asOneDecimalString : "--"
        }
    }

    private func unit(for metric: MetricType) -> String? {
        switch metric {
        case .heartRate, .restingHeartRate: return "BPM"
        case .hrv: return "ms"
        case .bloodOxygen: return "%"
        case .activeCalories: return "千卡"
        case .exerciseMinutes: return "分钟"
        case .standHours: return "小时"
        case .sleep: return "小时"
        case .bodyWeight: return "kg"
        case .bodyFat: return "%"
        case .vo2Max: return "ml/kg·min"
        default: return nil
        }
    }

    private func subtitle(for metric: MetricType) -> String {
        switch metric {
        case .heartRate: return "当前"
        case .restingHeartRate: return "今日"
        case .hrv: return "今日最新"
        case .bloodOxygen: return "今日最新"
        case .steps: return "今日"
        case .activeCalories: return "今日"
        case .exerciseMinutes: return "今日"
        case .standHours: return "今日"
        case .sleep: return "昨晚"
        case .bodyWeight: return "最新记录"
        case .bodyFat: return "最新记录"
        case .vo2Max: return "最新记录"
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataView()
            .environmentObject(AppState())
    }
}
