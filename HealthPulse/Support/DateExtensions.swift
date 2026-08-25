import Foundation

extension Date {
    /// 格式化为 "今天/昨天 + 时间"
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// 格式化为 "M月d日"
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 格式化为 "M月d日 HH:mm"
    var fullDateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 格式化为 "HH:mm"
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// 星期几缩写
    var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }

    /// 是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// 是否是昨天
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// 当天开始时间
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// 当天结束时间
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// 7天前
    var sevenDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }

    /// 30天前
    var thirtyDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -30, to: self)!
    }
}

// MARK: - Double 扩展（健康数据格式化）
extension Double {
    /// 格式化为整数显示
    var asIntString: String {
        String(format: "%.0f", self)
    }

    /// 格式化为一位小数
    var asOneDecimalString: String {
        String(format: "%.1f", self)
    }

    /// 格式化为两位小数
    var asTwoDecimalString: String {
        String(format: "%.2f", self)
    }

    /// 秒转分钟
    var secondsToMinutes: Double {
        self / 60
    }

    /// 秒转小时
    var secondsToHours: Double {
        self / 3600
    }

    /// 分钟转小时分钟格式 "Xh Ym"
    var minutesToHourMinuteString: String {
        let hours = Int(self) / 60
        let minutes = Int(self) % 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }

    /// 小时转 "X小时Y分钟"
    var hoursToHourMinuteString: String {
        let totalMinutes = Int(self * 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)小时\(minutes)分"
        } else if hours > 0 {
            return "\(hours)小时"
        }
        return "\(minutes)分钟"
    }
}

// MARK: - Int 扩展
extension Int {
    /// 带千分位分隔符
    var withComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// 百分比显示
    var asPercent: String {
        "\(self)%"
    }
}
