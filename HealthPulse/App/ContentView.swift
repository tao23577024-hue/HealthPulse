import SwiftUI

/// 主内容视图 — 底部 Tab 导航，苹果原生风格
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .dashboard
    @State private var showHealthKitPrompt = false

    enum Tab: String, CaseIterable {
        case dashboard = "概览"
        case health = "健康"
        case sleep = "睡眠"
        case fitness = "健身"
        case more = "更多"

        var systemImage: String {
            switch self {
            case .dashboard: return "heart.text.square.fill"
            case .health: return "heart.fill"
            case .sleep: return "bed.double.fill"
            case .fitness: return "figure.run"
            case .more: return "ellipsis.circle.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.systemImage)
            }
            .tag(Tab.dashboard)

            NavigationStack {
                HealthDataView()
            }
            .tabItem {
                Label(Tab.health.rawValue, systemImage: Tab.health.systemImage)
            }
            .tag(Tab.health)

            NavigationStack {
                SleepView()
            }
            .tabItem {
                Label(Tab.sleep.rawValue, systemImage: Tab.sleep.systemImage)
            }
            .tag(Tab.sleep)

            NavigationStack {
                FitnessView()
            }
            .tabItem {
                Label(Tab.fitness.rawValue, systemImage: Tab.fitness.systemImage)
            }
            .tag(Tab.fitness)

            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label(Tab.more.rawValue, systemImage: Tab.more.systemImage)
            }
            .tag(Tab.more)
        }
        .tint(.hpAccent)
        .onAppear {
            configureTabBarAppearance()
            if !appState.hasHealthKitAccess && !appState.showDemoData {
                showHealthKitPrompt = true
            }
        }
        .alert("访问健康数据", isPresented: $showHealthKitPrompt) {
            Button("授权") {
                appState.requestHealthKitAuthorization { _ in }
            }
            Button("使用演示数据", role: .cancel) {
                appState.showDemoData = true
                appState.loadPreviewData()
            }
        } message: {
            Text("HealthPulse 需要访问 Apple 健康数据来展示你的心率、步数、睡眠等信息。所有数据仅存储在本地设备。")
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - 更多页面（包含日志、心情、设置入口）
struct MoreView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            Section {
                NavigationLink {
                    JournalView()
                } label: {
                    Label("健康日志", systemImage: "book.fill")
                        .foregroundStyle(.hpAccent)
                }

                NavigationLink {
                    MindView()
                } label: {
                    Label("心情记录", systemImage: "brain.head.profile")
                        .foregroundStyle(.hpPurple)
                }
            }

            Section {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("设置", systemImage: "gearshape.fill")
                        .foregroundStyle(.gray)
                }
            }

            Section {
                VStack(alignment: .center, spacing: 8) {
                    Text("HealthPulse")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("版本 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("数据仅存储在本地设备")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("更多")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
