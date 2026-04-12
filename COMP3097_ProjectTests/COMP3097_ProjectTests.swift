//
//  COMP3097_ProjectTests.swift
//  COMP3097_ProjectTests
//
//  Created by Tech on 2026-03-12.
//

import XCTest
@testable import COMP3097_Project

final class COMP3097_ProjectTests: XCTestCase {
    func testTaxSummaryWithoutCoupon() throws {
        let items = [
            CheckoutLineItem(
                id: UUID(),
                groupName: "Electronics",
                itemName: "Headphones",
                quantity: 1,
                unitPrice: 100,
                lineSubtotal: 100,
                taxRate: 0.13,
                taxAmount: 13
            ),
            CheckoutLineItem(
                id: UUID(),
                groupName: "Books",
                itemName: "Notebook",
                quantity: 2,
                unitPrice: 10,
                lineSubtotal: 20,
                taxRate: 0,
                taxAmount: 0
            )
        ]

        let summary = TaxCalculator.summary(items: items, coupon: nil)

        XCTAssertEqual(summary.subtotal, 120, accuracy: 0.001)
        XCTAssertEqual(summary.discount, 0, accuracy: 0.001)
        XCTAssertEqual(summary.tax, 13, accuracy: 0.001)
        XCTAssertEqual(summary.total, 133, accuracy: 0.001)
    }

    func testTaxSummaryWithPercentageCoupon() throws {
        let items = [
            CheckoutLineItem(
                id: UUID(),
                groupName: "Men's Clothing",
                itemName: "Jacket",
                quantity: 1,
                unitPrice: 200,
                lineSubtotal: 200,
                taxRate: 0.10,
                taxAmount: 20
            )
        ]
        let coupon = CheckoutCoupon(code: "SAVE10", description: "10% off", kind: .percent, value: 0.10)

        let summary = TaxCalculator.summary(items: items, coupon: coupon)

        XCTAssertEqual(summary.subtotal, 200, accuracy: 0.001)
        XCTAssertEqual(summary.discount, 20, accuracy: 0.001)
        XCTAssertEqual(summary.taxableSubtotal, 180, accuracy: 0.001)
        XCTAssertEqual(summary.tax, 18, accuracy: 0.001)
        XCTAssertEqual(summary.total, 198, accuracy: 0.001)
    }
}
