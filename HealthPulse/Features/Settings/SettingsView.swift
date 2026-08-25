import SwiftUI

/// 设置页面
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showHealthKitSettings = false

    var body: some View {
        List {
            // 健康数据
            Section("健康数据") {
                Button {
                    appState.requestHealthKitAuthorization { _ in }
                } label: {
                    HStack {
                        Label("健康数据授权", systemImage: "heart.text.square.fill")
                            .foregroundStyle(.hpRed)
                        Spacer()
                        Image(systemName: appState.hasHealthKitAccess ? "checkmark.circle.fill" : "chevron.right")
                            .foregroundStyle(appState.hasHealthKitAccess ? .hpGreen : .hpTertiaryLabel)
                    }
                }

                Button {
                    appState.fetchAllHealthData()
                } label: {
                    HStack {
                        Label("刷新健康数据", systemImage: "arrow.clockwise")
                            .foregroundStyle(.hpBlue)
                        Spacer()
                        if appState.isLoading {
                            ProgressView()
                        }
                    }
                }

                Toggle(isOn: $appState.showDemoData) {
                    Label("使用演示数据", systemImage: "testtube.2")
                        .foregroundStyle(.hpOrange)
                }
                .onChange(of: appState.showDemoData) { newValue in
                    if newValue {
                        appState.loadPreviewData()
                    }
                }
            }

            // 活动目标
            Section("活动目标") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("每日步数目标")
                            .foregroundStyle(.hpLabel)
                        Spacer()
                        Text("\(appState.dailyStepGoal.withComma) 步")
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    Slider(value: Binding(
                        get: { Double(appState.dailyStepGoal) },
                        set: { appState.dailyStepGoal = Int($0) }
                    ), in: 3000...20000, step: 1000)
                    .tint(.hpGreen)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("每日卡路里目标")
                            .foregroundStyle(.hpLabel)
                        Spacer()
                        Text("\(Int(appState.dailyCalorieGoal)) 千卡")
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    Slider(value: $appState.dailyCalorieGoal, in: 200...1000, step: 50)
                        .tint(.hpOrange)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("睡眠目标")
                            .foregroundStyle(.hpLabel)
                        Spacer()
                        Text("\(appState.sleepGoalHours.asOneDecimalString) 小时")
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    Slider(value: $appState.sleepGoalHours, in: 6...10, step: 0.5)
                        .tint(.hpIndigo)
                }
                .padding(.vertical, 4)
            }

            // 通知
            Section("通知") {
                Button {
                    appState.requestNotificationPermissions()
                } label: {
                    Label("开启通知权限", systemImage: "bell.fill")
                        .foregroundStyle(.hpRed)
                }

                Button {
                    appState.scheduleMedicationReminders()
                } label: {
                    Label("设置用药提醒", systemImage: "pill.fill")
                        .foregroundStyle(.hpGreen)
                }
            }

            // 数据管理
            Section("数据管理") {
                Button {
                    appState.saveLocalData()
                } label: {
                    Label("保存数据", systemImage: "square.and.arrow.down.fill")
                        .foregroundStyle(.hpBlue)
                }

                Button(role: .destructive) {
                    // 清除数据
                } label: {
                    Label("清除所有数据", systemImage: "trash.fill")
                }
            }

            // 关于
            Section {
                VStack(alignment: .center, spacing: 6) {
                    Text("HealthPulse")
                        .font(.hpHeadline)
                        .fontWeight(.bold)
                    Text("版本 1.0.0")
                        .font(.hpCaption)
                        .foregroundStyle(.hpSecondaryLabel)
                    Text("健康数据仅存储在本地设备")
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            appState.saveLocalData()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
