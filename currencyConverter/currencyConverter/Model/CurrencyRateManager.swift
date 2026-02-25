//
//  CurrencyRateManager.swift
//  currencyConverter
//
//  Created by Yeseul Jang on 2/25/26.
//
import CoreData

final class CurrencyRateStore {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    func fetchRate(currency: String) -> Double? {
        let request: NSFetchRequest<CurrencyRate> = CurrencyRate.fetchRequest()
        request.predicate = NSPredicate(format: "currency == %@", currency)
        request.fetchLimit = 1

        return (try? context.fetch(request).first)?.rate
    }

    // 네트워크에서 환율 받아온 뒤 저장할 때 (update + insert)
    func upsertRate(currency: String, rate: Double) {
        let request: NSFetchRequest<CurrencyRate> = CurrencyRate.fetchRequest()
        request.predicate = NSPredicate(format: "currency == %@", currency)
        request.fetchLimit = 1

        let currencyRate = (try? context.fetch(request).first) ?? CurrencyRate(context: context)
        currencyRate.currency = currency
        currencyRate.rate = rate

        try? context.save()
    }
}
