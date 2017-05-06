//: Playground - noun: a place where people can play

import UIKit
import SwiftDate

let date = DateInRegion()
print("\(date.year)\(date.shortMonthName)\(date.day)\(date.weekdayName)\(date.string(custom: "HH:mm:ss"))")
