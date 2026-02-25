//
//  AppStateManager.swift
//  currencyConverter
//
//  Created by Yeseul Jang on 2/25/26.
//
import CoreData

enum LastScreen: String {
    case list
    case calculator
}

final class AppStateStore {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    // 항상 AppState는 유일해야함
    private func fetchOrCreateState() -> AppState {
        let request: NSFetchRequest<AppState> = AppState.fetchRequest()
        request.fetchLimit = 1

        if let state = try? context.fetch(request).first {
            return state
        } else {
            return AppState(context: context)
        }
    }

    func saveLastScreen(_ screen: LastScreen, selectedCurrency: String?) {
        let state = fetchOrCreateState()
        state.lastScreen = screen.rawValue
        state.selectedCurrency = selectedCurrency
        try? context.save()
    }

    func loadLastState() -> (screen: LastScreen, selectedCurrency: String?) {
        let request: NSFetchRequest<AppState> = AppState.fetchRequest()
        request.fetchLimit = 1

        guard let state = try? context.fetch(request).first,
              let raw = state.lastScreen,
              let screen = LastScreen(rawValue: raw) else {

            return (.list, nil)
        }
        return (screen, state.selectedCurrency)
    }
}
